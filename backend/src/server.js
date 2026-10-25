import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Pool } from 'pg';
import ExcelJS from 'exceljs';
import PDFDocument from 'pdfkit';
import { z } from 'zod';
import { EventEmitter } from 'node:events';

const app = express();
const port = Number(process.env.PORT || 3000);
const jwtSecret = process.env.JWT_SECRET;
if (!jwtSecret) throw new Error('JWT_SECRET is required');

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const events = new Map();
const origins = (process.env.CORS_ORIGIN || '*').split(',').map((item) => item.trim());
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({ origin: origins.includes('*') ? true : origins }));
app.use(express.json({ limit: '2mb' }));

const asyncRoute = (handler) => (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);
const registerSchema = z.object({ email: z.string().email(), password: z.string().min(8), fullName: z.string().min(2) });
const loginSchema = z.object({ email: z.string().email(), password: z.string().min(1) });
const reportSchema = z.object({ orphanId: z.string().uuid(), title: z.string().min(3), summary: z.string().min(5), reportDate: z.string(), metrics: z.record(z.unknown()).optional() });

function issueToken(user) {
  return jwt.sign({ sub: user.id, role: user.role, email: user.email }, jwtSecret, { expiresIn: '7d' });
}
function publicUser(user) {
  return { id: user.id, email: user.email, name: user.full_name, fullName: user.full_name, role: user.role };
}

const authenticate = asyncRoute(async (req, res, next) => {
  const value = req.headers.authorization || '';
  if (!value.startsWith('Bearer ')) return res.status(401).json({ message: 'Authentication required' });
  try {
    const payload = jwt.verify(value.slice(7), jwtSecret);
    const result = await pool.query('SELECT id, email, full_name, role FROM users WHERE id = $1', [payload.sub]);
    if (!result.rows[0]) return res.status(401).json({ message: 'User no longer exists' });
    req.user = result.rows[0];
    return next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
});
const requireRole = (...roles) => (req, res, next) => roles.includes(req.user.role) ? next() : res.status(403).json({ message: 'Insufficient permissions' });
const requireAdmin = requireRole('admin', 'supervisor');

function streamFor(userId) {
  if (!events.has(userId)) events.set(userId, new EventEmitter());
  return events.get(userId);
}
async function notifyUser(userId, notification) {
  const result = await pool.query(`INSERT INTO in_app_notifications (user_id, type, title, message, entity_type, entity_id)
    VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, type, title, message, entity_type, entity_id, read_at, created_at`, [
    userId, notification.type, notification.title, notification.message, notification.entityType || null, notification.entityId || null,
  ]);
  streamFor(userId).emit('notification', result.rows[0]);
  return result.rows[0];
}
async function notifyReportAudience(report, client = pool) {
  const sponsors = await client.query(`SELECT DISTINCT s.donor_id, o.full_name AS orphan_name
    FROM sponsorships s JOIN orphan_profiles o ON o.id = s.orphan_id
    WHERE s.orphan_id = $1 AND s.status = 'active'`, [report.orphan_id]);
  const moderators = await client.query(`SELECT id FROM users WHERE role IN ('admin', 'supervisor')`);
  for (const sponsor of sponsors.rows) {
    await notifyUser(sponsor.donor_id, { type: 'report_ready', title: `تقرير جديد عن ${sponsor.orphan_name}`, message: 'صدر تقرير دوري جديد عن حالة اليتيم المكفول ويمكنك مراجعته الآن.', entityType: 'sponsorship_report', entityId: report.id });
  }
  for (const moderator of moderators.rows) {
    await notifyUser(moderator.id, { type: 'report_review', title: 'تقرير جديد بانتظار المراجعة', message: `يوجد تقرير دوري جديد عن ${report.orphan_id} يحتاج إلى اعتمادك.`, entityType: 'sponsorship_report', entityId: report.id });
  }
}

app.get('/health', asyncRoute(async (_req, res) => {
  await pool.query('SELECT 1');
  res.json({ ok: true, service: 'ekfalni-api' });
}));

app.post('/api/auth/register', asyncRoute(async (req, res) => {
  const input = registerSchema.parse(req.body);
  const hash = await bcrypt.hash(input.password, 12);
  const result = await pool.query(`INSERT INTO users (email, password_hash, full_name) VALUES ($1, $2, $3)
    RETURNING id, email, full_name, role`, [input.email.toLowerCase(), hash, input.fullName]);
  const user = result.rows[0];
  res.status(201).json({ user: publicUser(user), token: issueToken(user) });
}));

app.post('/api/auth/login', asyncRoute(async (req, res) => {
  const input = loginSchema.parse(req.body);
  const result = await pool.query('SELECT * FROM users WHERE email = $1', [input.email.toLowerCase()]);
  const user = result.rows[0];
  if (!user || !(await bcrypt.compare(input.password, user.password_hash))) return res.status(401).json({ message: 'Invalid credentials' });
  res.json({ user: publicUser(user), token: issueToken(user) });
}));

app.get('/api/user/profile', authenticate, (req, res) => res.json({ user: publicUser(req.user) }));

app.get('/api/notifications', authenticate, asyncRoute(async (req, res) => {
  const limit = Math.min(Number(req.query.limit || 50), 100);
  const result = await pool.query(`SELECT id, type, title, message, entity_type, entity_id, read_at, created_at
    FROM in_app_notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2`, [req.user.id, limit]);
  res.json({ notifications: result.rows });
}));
app.patch('/api/notifications/:id/read', authenticate, asyncRoute(async (req, res) => {
  const result = await pool.query(`UPDATE in_app_notifications SET read_at = COALESCE(read_at, NOW())
    WHERE id = $1 AND user_id = $2 RETURNING id, read_at`, [req.params.id, req.user.id]);
  if (!result.rows[0]) return res.status(404).json({ message: 'Notification not found' });
  res.json({ notification: result.rows[0] });
}));
app.post('/api/notifications/read-all', authenticate, asyncRoute(async (req, res) => {
  await pool.query('UPDATE in_app_notifications SET read_at = COALESCE(read_at, NOW()) WHERE user_id = $1', [req.user.id]);
  res.status(204).end();
}));
app.put('/api/notifications/preferences', authenticate, asyncRoute(async (req, res) => {
  const input = z.object({ emailReports: z.boolean(), pushReports: z.boolean(), emailAddress: z.string().email().or(z.literal('')) }).parse(req.body);
  const result = await pool.query(`INSERT INTO notification_preferences (user_id, email_reports, push_reports, email_address)
    VALUES ($1, $2, $3, NULLIF($4, '')) ON CONFLICT (user_id) DO UPDATE SET email_reports = $2, push_reports = $3, email_address = NULLIF($4, ''), updated_at = NOW()
    RETURNING email_reports, push_reports, email_address`, [req.user.id, input.emailReports, input.pushReports, input.emailAddress]);
  res.json({ preferences: result.rows[0] });
}));
app.post('/api/notifications/device-token', authenticate, asyncRoute(async (req, res) => {
  const input = z.object({ token: z.string().min(10), platform: z.string().min(2) }).parse(req.body);
  await pool.query(`INSERT INTO device_tokens (user_id, token, platform) VALUES ($1, $2, $3)
    ON CONFLICT (token) DO UPDATE SET user_id = $1, platform = $3, last_seen_at = NOW()`, [req.user.id, input.token, input.platform]);
  res.status(204).end();
}));
app.get('/api/notifications/stream', authenticate, (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream'); res.setHeader('Cache-Control', 'no-cache'); res.setHeader('Connection', 'keep-alive'); res.flushHeaders?.();
  const emitter = streamFor(req.user.id);
  const handler = (notification) => res.write(`event: notification\ndata: ${JSON.stringify(notification)}\n\n`);
  emitter.on('notification', handler); res.write('event: ready\ndata: {}\n\n');
  req.on('close', () => emitter.off('notification', handler));
});

app.get('/api/admin/orphans', authenticate, requireAdmin, asyncRoute(async (_req, res) => {
  const result = await pool.query(`SELECT o.*, COUNT(DISTINCT s.id)::int AS active_sponsorships, MAX(r.report_date) AS last_report_date
    FROM orphan_profiles o LEFT JOIN sponsorships s ON s.orphan_id = o.id AND s.status = 'active'
    LEFT JOIN sponsorship_reports r ON r.orphan_id = o.id GROUP BY o.id ORDER BY o.created_at DESC`);
  res.json({ orphans: result.rows });
}));
app.get('/api/admin/sponsorship-reports', authenticate, requireAdmin, asyncRoute(async (_req, res) => {
  const result = await pool.query(`SELECT r.*, o.full_name AS orphan_name, u.full_name AS author_name
    FROM sponsorship_reports r JOIN orphan_profiles o ON o.id = r.orphan_id JOIN users u ON u.id = r.author_id
    WHERE r.status = 'pending' ORDER BY r.report_date DESC`);
  res.json({ reports: result.rows });
}));
app.post('/api/admin/sponsorship-reports/:id/approve', authenticate, requireAdmin, asyncRoute(async (req, res) => {
  const input = z.object({ decision: z.enum(['approved', 'changes_requested']), notes: z.string().max(2000).optional() }).parse(req.body);
  const result = await pool.query(`UPDATE sponsorship_reports SET status = $1, reviewed_by = $2, reviewed_at = NOW(), review_notes = $3
    WHERE id = $4 RETURNING *`, [input.decision, req.user.id, input.notes || null, req.params.id]);
  if (!result.rows[0]) return res.status(404).json({ message: 'Report not found' });
  const report = result.rows[0];
  const sponsors = await pool.query('SELECT DISTINCT donor_id FROM sponsorships WHERE orphan_id = $1 AND status = $2', [report.orphan_id, 'active']);
  for (const sponsor of sponsors.rows) await notifyUser(sponsor.donor_id, { type: 'report_status', title: input.decision === 'approved' ? 'تم اعتماد التقرير' : 'يحتاج التقرير إلى تحديث', message: input.decision === 'approved' ? 'تم اعتماد التقرير الدوري من المشرف.' : 'طلب المشرف تحديث التقرير الدوري.', entityType: 'sponsorship_report', entityId: report.id });
  res.json({ report });
}));

app.post('/api/sponsorship-reports', authenticate, requireAdmin, asyncRoute(async (req, res) => {
  const input = reportSchema.parse(req.body);
  const result = await pool.query(`INSERT INTO sponsorship_reports (orphan_id, author_id, title, summary, report_date, metrics)
    VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [input.orphanId, req.user.id, input.title, input.summary, input.reportDate, JSON.stringify(input.metrics || {})]);
  await notifyReportAudience(result.rows[0]);
  res.status(201).json({ report: result.rows[0] });
}));

async function reportRows(type) {
  if (type === 'financial') {
    const result = await pool.query(`SELECT d.created_at::date AS date, u.full_name AS donor, d.amount, d.currency, d.category, d.status
      FROM donations d JOIN users u ON u.id = d.donor_id ORDER BY d.created_at DESC`);
    return { title: 'Ekfalni Financial Report', headers: ['Date', 'Donor', 'Amount', 'Currency', 'Category', 'Status'], rows: result.rows.map((r) => [r.date, r.donor, r.amount, r.currency, r.category, r.status]) };
  }
  const result = await pool.query(`SELECT o.full_name AS orphan, r.report_date, r.status, r.metrics
    FROM sponsorship_reports r JOIN orphan_profiles o ON o.id = r.orphan_id ORDER BY r.report_date DESC`);
  return { title: 'Ekfalni Orphan Analytics Report', headers: ['Orphan', 'Report date', 'Status', 'Metrics'], rows: result.rows.map((r) => [r.orphan, r.report_date, r.status, JSON.stringify(r.metrics)]) };
}
app.get('/api/admin/exports/:report', authenticate, requireAdmin, asyncRoute(async (req, res) => {
  if (!['financial', 'analytics'].includes(req.params.report)) return res.status(404).json({ message: 'Unknown export' });
  const format = req.query.format === 'xlsx' ? 'xlsx' : req.query.format === 'pdf' ? 'pdf' : null;
  if (!format) return res.status(400).json({ message: 'format must be xlsx or pdf' });
  const data = await reportRows(req.params.report);
  if (format === 'xlsx') {
    const workbook = new ExcelJS.Workbook(); const sheet = workbook.addWorksheet('Ekfalni');
    sheet.addRow(data.headers); data.rows.forEach((row) => sheet.addRow(row));
    sheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } }; sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF7657E8' } };
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'); res.setHeader('Content-Disposition', `attachment; filename="${req.params.report}-report.xlsx"`);
    return workbook.xlsx.write(res).then(() => res.end());
  }
  res.setHeader('Content-Type', 'application/pdf'); res.setHeader('Content-Disposition', `attachment; filename="${req.params.report}-report.pdf"`);
  const pdf = new PDFDocument({ margin: 40 }); pdf.pipe(res); pdf.fontSize(18).text(data.title); pdf.moveDown(); data.rows.forEach((row) => pdf.fontSize(9).text(row.join(' | '))); pdf.end();
}));

app.use((error, _req, res, _next) => {
  if (error instanceof z.ZodError) return res.status(400).json({ message: 'Validation error', issues: error.issues });
  if (error.code === '23505') return res.status(409).json({ message: 'Resource already exists' });
  console.error(error); res.status(500).json({ message: 'Internal server error' });
});

app.listen(port, () => console.log(`Ekfalni API listening on http://localhost:${port}`));

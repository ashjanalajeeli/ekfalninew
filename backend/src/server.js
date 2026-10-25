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
const reportSchema = z.object({ orphanId: z.string().uuid(), title: z.string().min(3), summary: z.string().min(5), reportDate: z.string(), metrics: z.record(z.string(), z.unknown()).optional() });
const charitySchema = z.object({ name: z.string().min(2), licenseNumber: z.string().optional(), phone: z.string().optional(), email: z.string().email().optional() });
const orphanSchema = z.object({ fullName: z.string().min(2), birthYear: z.number().int().optional(), location: z.string().optional(), story: z.string().optional(), gender: z.string().optional(), healthStatus: z.string().optional(), educationLevel: z.string().optional(), guardianName: z.string().optional(), charityId: z.string().uuid().optional() });
const projectSchema = z.object({ charityId: z.string().uuid(), name: z.string().min(2), description: z.string().optional(), targetAmount: z.number().nonnegative(), imageUrl: z.string().url().optional() });
const requestSchema = z.object({ orphanId: z.string().uuid(), monthlyAmount: z.number().positive(), notes: z.string().max(2000).optional() });

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
const requireCharity = requireRole('admin', 'supervisor', 'charity');

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
async function audit(actorId, action, entityType, entityId, details = {}) {
  await pool.query(`INSERT INTO audit_logs (actor_id, action, entity_type, entity_id, details) VALUES ($1, $2, $3, $4, $5)`, [actorId, action, entityType, entityId || null, JSON.stringify(details)]);
}
async function canManageCharity(user, charityId) {
  if (user.role === 'admin' || user.role === 'supervisor') return true;
  const result = await pool.query('SELECT 1 FROM charity_members WHERE charity_id = $1 AND user_id = $2', [charityId, user.id]);
  return Boolean(result.rows[0]);
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

app.post('/api/sponsorship-reports', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = reportSchema.parse(req.body);
  const orphan = await pool.query('SELECT charity_id FROM orphan_profiles WHERE id = $1', [input.orphanId]);
  if (!orphan.rows[0] || (req.user.role === 'charity' && !(await canManageCharity(req.user, orphan.rows[0].charity_id)))) return res.status(403).json({ message: 'Not allowed to submit a report for this orphan' });
  const result = await pool.query(`INSERT INTO sponsorship_reports (orphan_id, author_id, title, summary, report_date, metrics)
    VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [input.orphanId, req.user.id, input.title, input.summary, input.reportDate, JSON.stringify(input.metrics || {})]);
  await notifyReportAudience(result.rows[0]);
  res.status(201).json({ report: result.rows[0] });
}));

// Charities, projects and orphan management
app.get('/api/charities', asyncRoute(async (_req, res) => {
  const result = await pool.query("SELECT id, name, license_number, phone, email FROM charities WHERE status = 'active' ORDER BY name");
  res.json({ charities: result.rows });
}));
app.post('/api/admin/charities', authenticate, requireRole('admin'), asyncRoute(async (req, res) => {
  const input = charitySchema.parse(req.body);
  const result = await pool.query(`INSERT INTO charities (name, license_number, phone, email) VALUES ($1, $2, $3, $4) RETURNING *`, [input.name, input.licenseNumber || null, input.phone || null, input.email || null]);
  await audit(req.user.id, 'create', 'charity', result.rows[0].id, { name: input.name });
  res.status(201).json({ charity: result.rows[0] });
}));
app.patch('/api/admin/charities/:id', authenticate, requireRole('admin'), asyncRoute(async (req, res) => {
  const input = charitySchema.partial().extend({ status: z.enum(['active', 'inactive']).optional() }).parse(req.body);
  const result = await pool.query(`UPDATE charities SET name = COALESCE($1, name), license_number = COALESCE($2, license_number), phone = COALESCE($3, phone), email = COALESCE($4, email), status = COALESCE($5, status) WHERE id = $6 RETURNING *`, [input.name || null, input.licenseNumber || null, input.phone || null, input.email || null, input.status || null, req.params.id]);
  if (!result.rows[0]) return res.status(404).json({ message: 'Charity not found' });
  await audit(req.user.id, 'update', 'charity', req.params.id, input);
  res.json({ charity: result.rows[0] });
}));
app.post('/api/charity/orphans', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = orphanSchema.parse(req.body);
  const charityId = input.charityId;
  if (!charityId || !(await canManageCharity(req.user, charityId))) return res.status(403).json({ message: 'Charity membership is required' });
  const result = await pool.query(`INSERT INTO orphan_profiles (full_name, birth_year, location, story, gender, health_status, education_level, guardian_name, charity_id)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`, [input.fullName, input.birthYear || null, input.location || null, input.story || null, input.gender || null, input.healthStatus || null, input.educationLevel || null, input.guardianName || null, charityId]);
  await audit(req.user.id, 'create', 'orphan', result.rows[0].id, { charityId });
  res.status(201).json({ orphan: result.rows[0] });
}));
app.patch('/api/charity/orphans/:id', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = orphanSchema.partial().extend({ status: z.enum(['active', 'inactive']).optional() }).parse(req.body);
  const current = await pool.query('SELECT charity_id FROM orphan_profiles WHERE id = $1', [req.params.id]);
  if (!current.rows[0] || !(await canManageCharity(req.user, current.rows[0].charity_id))) return res.status(403).json({ message: 'Not allowed to manage this orphan' });
  const result = await pool.query(`UPDATE orphan_profiles SET full_name = COALESCE($1, full_name), birth_year = COALESCE($2, birth_year), location = COALESCE($3, location), story = COALESCE($4, story), gender = COALESCE($5, gender), health_status = COALESCE($6, health_status), education_level = COALESCE($7, education_level), guardian_name = COALESCE($8, guardian_name), status = COALESCE($9, status) WHERE id = $10 RETURNING *`, [input.fullName || null, input.birthYear || null, input.location || null, input.story || null, input.gender || null, input.healthStatus || null, input.educationLevel || null, input.guardianName || null, input.status || null, req.params.id]);
  await audit(req.user.id, 'update', 'orphan', req.params.id, input);
  res.json({ orphan: result.rows[0] });
}));
app.post('/api/charity/projects', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = projectSchema.parse(req.body);
  if (!(await canManageCharity(req.user, input.charityId))) return res.status(403).json({ message: 'Charity membership is required' });
  const result = await pool.query(`INSERT INTO projects (charity_id, name, description, target_amount, image_url) VALUES ($1,$2,$3,$4,$5) RETURNING *`, [input.charityId, input.name, input.description || null, input.targetAmount, input.imageUrl || null]);
  await audit(req.user.id, 'create', 'project', result.rows[0].id, { charityId: input.charityId });
  res.status(201).json({ project: result.rows[0] });
}));
app.get('/api/charities/:id/projects', asyncRoute(async (req, res) => {
  const result = await pool.query("SELECT * FROM projects WHERE charity_id = $1 AND status = 'active' ORDER BY created_at DESC", [req.params.id]);
  res.json({ projects: result.rows });
}));
app.patch('/api/charity/projects/:id', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = projectSchema.partial().extend({ status: z.enum(['active', 'inactive']).optional(), currentAmount: z.number().nonnegative().optional() }).parse(req.body);
  const current = await pool.query('SELECT charity_id FROM projects WHERE id = $1', [req.params.id]);
  if (!current.rows[0] || !(await canManageCharity(req.user, current.rows[0].charity_id))) return res.status(403).json({ message: 'Not allowed to manage this project' });
  const result = await pool.query(`UPDATE projects SET name = COALESCE($1,name), description = COALESCE($2,description), target_amount = COALESCE($3,target_amount), current_amount = COALESCE($4,current_amount), image_url = COALESCE($5,image_url), status = COALESCE($6,status) WHERE id = $7 RETURNING *`, [input.name || null, input.description || null, input.targetAmount ?? null, input.currentAmount ?? null, input.imageUrl || null, input.status || null, req.params.id]);
  await audit(req.user.id, 'update', 'project', req.params.id, input);
  res.json({ project: result.rows[0] });
}));
app.post('/api/admin/charities/:id/members', authenticate, requireRole('admin'), asyncRoute(async (req, res) => {
  const input = z.object({ userId: z.string().uuid(), membershipRole: z.string().min(2).default('manager') }).parse(req.body);
  const result = await pool.query(`INSERT INTO charity_members (charity_id, user_id, membership_role) VALUES ($1,$2,$3) ON CONFLICT (charity_id,user_id) DO UPDATE SET membership_role = $3 RETURNING *`, [req.params.id, input.userId, input.membershipRole]);
  await pool.query("UPDATE users SET role = 'charity' WHERE id = $1 AND role = 'donor'", [input.userId]);
  await audit(req.user.id, 'assign', 'charity_member', input.userId, { charityId: req.params.id, membershipRole: input.membershipRole });
  res.status(201).json({ member: result.rows[0] });
}));
app.post('/api/charity/orphan-cases', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = z.object({ orphanId: z.string().uuid(), charityId: z.string().uuid(), title: z.string().min(2), description: z.string().min(5), imageUrl: z.string().url().optional() }).parse(req.body);
  if (!(await canManageCharity(req.user, input.charityId))) return res.status(403).json({ message: 'Charity membership is required' });
  const result = await pool.query(`INSERT INTO orphan_cases (orphan_id, charity_id, title, description, image_url) VALUES ($1,$2,$3,$4,$5) RETURNING *`, [input.orphanId, input.charityId, input.title, input.description, input.imageUrl || null]);
  await audit(req.user.id, 'create', 'orphan_case', result.rows[0].id, { orphanId: input.orphanId });
  res.status(201).json({ case: result.rows[0] });
}));
app.patch('/api/charity/orphan-cases/:id', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = z.object({ title: z.string().min(2).optional(), description: z.string().min(5).optional(), imageUrl: z.string().url().optional(), status: z.enum(['active', 'inactive']).optional() }).parse(req.body);
  const current = await pool.query('SELECT charity_id FROM orphan_cases WHERE id = $1', [req.params.id]);
  if (!current.rows[0] || !(await canManageCharity(req.user, current.rows[0].charity_id))) return res.status(403).json({ message: 'Not allowed to manage this case' });
  const result = await pool.query(`UPDATE orphan_cases SET title = COALESCE($1,title), description = COALESCE($2,description), image_url = COALESCE($3,image_url), status = COALESCE($4,status) WHERE id = $5 RETURNING *`, [input.title || null, input.description || null, input.imageUrl || null, input.status || null, req.params.id]);
  await audit(req.user.id, 'update', 'orphan_case', req.params.id, input);
  res.json({ case: result.rows[0] });
}));
app.post('/api/admin/notifications/send', authenticate, requireAdmin, asyncRoute(async (req, res) => {
  const input = z.object({ title: z.string().min(2), message: z.string().min(2), recipientType: z.enum(['all', 'role', 'user', 'charity']), recipientId: z.string().uuid().optional(), role: z.enum(['donor', 'charity', 'supervisor', 'admin']).optional() }).parse(req.body);
  let recipients;
  if (input.recipientType === 'user') recipients = await pool.query('SELECT id FROM users WHERE id = $1', [input.recipientId]);
  else if (input.recipientType === 'role') recipients = await pool.query('SELECT id FROM users WHERE role = $1', [input.role]);
  else if (input.recipientType === 'charity') recipients = await pool.query('SELECT user_id AS id FROM charity_members WHERE charity_id = $1', [input.recipientId]);
  else recipients = await pool.query('SELECT id FROM users WHERE role <> $1', ['admin']);
  for (const recipient of recipients.rows) await notifyUser(recipient.id, { type: 'admin_announcement', title: input.title, message: input.message });
  await audit(req.user.id, 'send', 'notification', null, { recipientType: input.recipientType, count: recipients.rows.length });
  res.status(201).json({ sent: recipients.rows.length });
}));

// Sponsorship request lifecycle with duplicate-active-sponsorship protection
app.post('/api/sponsorship-requests', authenticate, requireRole('donor'), asyncRoute(async (req, res) => {
  const input = requestSchema.parse(req.body);
  const orphan = await pool.query('SELECT id, full_name, charity_id FROM orphan_profiles WHERE id = $1 AND status = $2', [input.orphanId, 'active']);
  if (!orphan.rows[0]) return res.status(404).json({ message: 'Orphan not found' });
  const active = await pool.query("SELECT 1 FROM sponsorships WHERE orphan_id = $1 AND status = 'active'", [input.orphanId]);
  const pending = await pool.query("SELECT 1 FROM sponsorship_requests WHERE donor_id = $1 AND orphan_id = $2 AND status = 'pending'", [req.user.id, input.orphanId]);
  if (active.rows[0]) return res.status(409).json({ message: 'This orphan already has an active sponsorship' });
  if (pending.rows[0]) return res.status(409).json({ message: 'You already have a pending request for this orphan' });
  const result = await pool.query(`INSERT INTO sponsorship_requests (donor_id, orphan_id, charity_id, monthly_amount, notes) VALUES ($1,$2,$3,$4,$5) RETURNING *`, [req.user.id, input.orphanId, orphan.rows[0].charity_id, input.monthlyAmount, input.notes || null]);
  const recipients = orphan.rows[0].charity_id ? await pool.query('SELECT user_id FROM charity_members WHERE charity_id = $1', [orphan.rows[0].charity_id]) : { rows: [] };
  for (const recipient of recipients.rows) await notifyUser(recipient.user_id, { type: 'sponsorship_request', title: 'طلب كفالة جديد', message: `يوجد طلب كفالة جديد لـ ${orphan.rows[0].full_name}.`, entityType: 'sponsorship_request', entityId: result.rows[0].id });
  await audit(req.user.id, 'create', 'sponsorship_request', result.rows[0].id, { orphanId: input.orphanId });
  res.status(201).json({ request: result.rows[0] });
}));
app.get('/api/sponsorship-requests/my', authenticate, requireRole('donor'), asyncRoute(async (req, res) => {
  const result = await pool.query(`SELECT r.*, o.full_name AS orphan_name FROM sponsorship_requests r JOIN orphan_profiles o ON o.id = r.orphan_id WHERE r.donor_id = $1 ORDER BY r.created_at DESC`, [req.user.id]);
  res.json({ requests: result.rows });
}));
app.get('/api/charity/sponsorship-requests', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const charityId = req.query.charityId;
  if (req.user.role === 'charity' && !(await canManageCharity(req.user, charityId))) return res.status(403).json({ message: 'Charity membership is required' });
  const result = await pool.query(`SELECT r.*, o.full_name AS orphan_name, u.full_name AS donor_name FROM sponsorship_requests r JOIN orphan_profiles o ON o.id = r.orphan_id JOIN users u ON u.id = r.donor_id WHERE ($1::uuid IS NULL OR r.charity_id = $1) ORDER BY r.created_at DESC`, [charityId || null]);
  res.json({ requests: result.rows });
}));
app.patch('/api/charity/sponsorship-requests/:id', authenticate, requireCharity, asyncRoute(async (req, res) => {
  const input = z.object({ decision: z.enum(['approved', 'rejected']), notes: z.string().max(2000).optional() }).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const request = await client.query('SELECT * FROM sponsorship_requests WHERE id = $1 FOR UPDATE', [req.params.id]);
    if (!request.rows[0] || request.rows[0].status !== 'pending') { await client.query('ROLLBACK'); return res.status(404).json({ message: 'Pending request not found' }); }
    if (!(await canManageCharity(req.user, request.rows[0].charity_id))) { await client.query('ROLLBACK'); return res.status(403).json({ message: 'Not allowed to review this request' }); }
    let sponsorship = null;
    if (input.decision === 'approved') {
      const active = await client.query("SELECT 1 FROM sponsorships WHERE orphan_id = $1 AND status = 'active'", [request.rows[0].orphan_id]);
      if (active.rows[0]) { await client.query('ROLLBACK'); return res.status(409).json({ message: 'This orphan already has an active sponsorship' }); }
      sponsorship = (await client.query(`INSERT INTO sponsorships (donor_id, orphan_id, monthly_amount, request_id, charity_id) VALUES ($1,$2,$3,$4,$5) RETURNING *`, [request.rows[0].donor_id, request.rows[0].orphan_id, request.rows[0].monthly_amount, request.rows[0].id, request.rows[0].charity_id])).rows[0];
    }
    const updated = (await client.query(`UPDATE sponsorship_requests SET status = $1, reviewed_by = $2, reviewed_at = NOW(), notes = COALESCE($3, notes) WHERE id = $4 RETURNING *`, [input.decision, req.user.id, input.notes || null, req.params.id])).rows[0];
    await client.query('COMMIT');
    await notifyUser(updated.donor_id, { type: 'sponsorship_status', title: input.decision === 'approved' ? 'تم قبول طلب الكفالة' : 'تم رفض طلب الكفالة', message: input.decision === 'approved' ? 'تم إنشاء الكفالة ويمكنك متابعتها من لوحة المتبرع.' : (input.notes || 'تم رفض طلب الكفالة من الجهة المشرفة.'), entityType: 'sponsorship_request', entityId: updated.id });
    await audit(req.user.id, input.decision === 'approved' ? 'approve' : 'reject', 'sponsorship_request', updated.id, { notes: input.notes });
    res.json({ request: updated, sponsorship });
  } catch (error) { await client.query('ROLLBACK'); throw error; } finally { client.release(); }
}));

// Donation records and payment provider handoff. Provider confirmation remains server-side.
app.post('/api/donations', authenticate, requireRole('donor'), asyncRoute(async (req, res) => {
  const input = z.object({ amount: z.number().positive(), currency: z.string().length(3).default('SAR'), category: z.string().min(2), paymentMethod: z.string().min(2), sponsorshipId: z.string().uuid().optional(), projectId: z.string().uuid().optional() }).parse(req.body);
  const result = await pool.query(`INSERT INTO donations (donor_id, sponsorship_id, project_id, amount, currency, category, payment_method) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`, [req.user.id, input.sponsorshipId || null, input.projectId || null, input.amount, input.currency, input.category, input.paymentMethod]);
  await audit(req.user.id, 'create', 'donation', result.rows[0].id, { amount: input.amount });
  res.status(201).json({ donation: result.rows[0] });
}));
app.post('/api/donations/:id/payment-intent', authenticate, requireRole('donor'), asyncRoute(async (req, res) => {
  const donation = await pool.query('SELECT * FROM donations WHERE id = $1 AND donor_id = $2', [req.params.id, req.user.id]);
  if (!donation.rows[0]) return res.status(404).json({ message: 'Donation not found' });
  const result = await pool.query(`INSERT INTO payments (donation_id, provider, amount, currency, metadata) VALUES ($1,$2,$3,$4,$5) RETURNING *`, [req.params.id, donation.rows[0].payment_method || 'manual', donation.rows[0].amount, donation.rows[0].currency, JSON.stringify({ next: 'connect-provider-webhook' })]);
  res.status(201).json({ payment: result.rows[0], message: 'Payment intent created; connect a provider webhook before production.' });
}));
app.post('/api/payments/:id/status', authenticate, requireAdmin, asyncRoute(async (req, res) => {
  const input = z.object({ status: z.enum(['pending', 'paid', 'failed', 'refunded']), providerReference: z.string().optional() }).parse(req.body);
  const payment = await pool.query(`UPDATE payments SET status = $1, provider_reference = COALESCE($2, provider_reference), updated_at = NOW() WHERE id = $3 RETURNING *`, [input.status, input.providerReference || null, req.params.id]);
  if (!payment.rows[0]) return res.status(404).json({ message: 'Payment not found' });
  await pool.query('UPDATE donations SET status = $1 WHERE id = $2', [input.status === 'paid' ? 'completed' : input.status, payment.rows[0].donation_id]);
  await audit(req.user.id, 'update', 'payment', req.params.id, { status: input.status });
  res.json({ payment: payment.rows[0] });
}));
app.get('/api/admin/audit-logs', authenticate, requireRole('admin'), asyncRoute(async (req, res) => {
  const result = await pool.query(`SELECT a.*, u.full_name AS actor_name FROM audit_logs a LEFT JOIN users u ON u.id = a.actor_id ORDER BY a.created_at DESC LIMIT 200`);
  res.json({ logs: result.rows });
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

if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => console.log(`Ekfalni API listening on http://localhost:${port}`));
}

export { app, pool };

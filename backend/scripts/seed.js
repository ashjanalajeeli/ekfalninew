import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const password = await bcrypt.hash(process.env.SEED_PASSWORD || 'ChangeMe123!', 12);
const client = await pool.connect();
try {
  await client.query('BEGIN');
  const admin = await client.query(`INSERT INTO users (email, password_hash, full_name, role)
    VALUES ('admin@ekfalni.local', $1, 'مشرف Ekfalni', 'admin')
    ON CONFLICT (email) DO UPDATE SET role = 'admin' RETURNING id`, [password]);
  const donor = await client.query(`INSERT INTO users (email, password_hash, full_name, role)
    VALUES ('donor@ekfalni.local', $1, 'متبرع تجريبي', 'donor')
    ON CONFLICT (email) DO UPDATE SET role = 'donor' RETURNING id`, [password]);
  const orphan = await client.query(`INSERT INTO orphan_profiles (full_name, birth_year, location, story)
    VALUES ('أحمد محمد', 2017, 'صنعاء، اليمن', 'طفل محب للتعلم') RETURNING id`);
  await client.query(`INSERT INTO sponsorships (donor_id, orphan_id, monthly_amount) VALUES ($1, $2, 1250) ON CONFLICT DO NOTHING`, [donor.rows[0].id, orphan.rows[0].id]);
  await client.query(`INSERT INTO sponsorship_reports (orphan_id, author_id, title, summary, report_date, metrics)
    VALUES ($1, $2, 'تقرير مارس 2026', 'تقدم دراسي وصحي جديد', CURRENT_DATE, $3)`, [orphan.rows[0].id, admin.rows[0].id, JSON.stringify({ attendance: 92, health: 'stable', education: 'excellent' })]);
  await client.query('COMMIT');
  console.log('Seed complete. Admin: admin@ekfalni.local /', process.env.SEED_PASSWORD || 'ChangeMe123!');
} catch (error) {
  await client.query('ROLLBACK'); console.error(error); process.exitCode = 1;
} finally { client.release(); await pool.end(); }

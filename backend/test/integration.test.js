import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import bcrypt from 'bcryptjs';
import request from 'supertest';
import { app, pool } from '../src/server.js';

const api = request(app);
const suffix = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
const adminEmail = `admin-${suffix}@test.ekfalni.local`;
const donorEmail = `donor-${suffix}@test.ekfalni.local`;
const password = 'IntegrationTest123!';
let adminToken;
let donorToken;
let charityId;
let orphanId;
let reportId;

before(async () => {
  const adminHash = await bcrypt.hash(password, 4);
  const admin = await pool.query(`INSERT INTO users (email, password_hash, full_name, role) VALUES ($1,$2,'Integration Admin','admin') RETURNING id`, [adminEmail, adminHash]);
  const donorResponse = await api.post('/api/auth/register').send({ email: donorEmail, password, fullName: 'Integration Donor' });
  assert.equal(donorResponse.status, 201);
  donorToken = donorResponse.body.token;
  const login = await api.post('/api/auth/login').send({ email: adminEmail, password });
  assert.equal(login.status, 200);
  adminToken = login.body.token;
  assert.equal(admin.rows.length, 1);
});

test('donor can read public charities and admin can create one', async () => {
  const publicList = await api.get('/api/charities');
  assert.equal(publicList.status, 200);
  const created = await api.post('/api/admin/charities').set('Authorization', `Bearer ${adminToken}`).send({ name: `Integration Charity ${suffix}`, licenseNumber: `TEST-${suffix}` });
  assert.equal(created.status, 201);
  charityId = created.body.charity.id;
});

test('admin can create an orphan and donor can submit one sponsorship request', async () => {
  const created = await api.post('/api/charity/orphans').set('Authorization', `Bearer ${adminToken}`).send({ charityId, fullName: `Integration Orphan ${suffix}`, birthYear: 2016, healthStatus: 'stable', educationLevel: 'good' });
  assert.equal(created.status, 201);
  orphanId = created.body.orphan.id;
  const submitted = await api.post('/api/sponsorship-requests').set('Authorization', `Bearer ${donorToken}`).send({ orphanId, monthlyAmount: 250, notes: 'Integration request' });
  assert.equal(submitted.status, 201);
  const duplicate = await api.post('/api/sponsorship-requests').set('Authorization', `Bearer ${donorToken}`).send({ orphanId, monthlyAmount: 250 });
  assert.equal(duplicate.status, 409);
});

test('non-admin donor cannot access admin reports', async () => {
  const response = await api.get('/api/admin/sponsorship-reports').set('Authorization', `Bearer ${donorToken}`);
  assert.equal(response.status, 403);
});

test('admin can approve the request and donor receives an in-app notification', async () => {
  const list = await api.get('/api/charity/sponsorship-requests').set('Authorization', `Bearer ${adminToken}`).query({ charityId });
  assert.equal(list.status, 200);
  assert.equal(list.body.requests.length, 1);
  const decision = await api.patch(`/api/charity/sponsorship-requests/${list.body.requests[0].id}`).set('Authorization', `Bearer ${adminToken}`).send({ decision: 'approved' });
  assert.equal(decision.status, 200);
  assert.equal(decision.body.sponsorship.status, 'active');
  const notifications = await api.get('/api/notifications').set('Authorization', `Bearer ${donorToken}`);
  assert.equal(notifications.status, 200);
  assert.ok(notifications.body.notifications.some((item) => item.type === 'sponsorship_status'));
});

test('admin report review creates donor notification and supports exports', async () => {
  const created = await api.post('/api/sponsorship-reports').set('Authorization', `Bearer ${adminToken}`).send({ orphanId, title: 'Integration report', summary: 'Monthly integration report', reportDate: '2026-10-25', metrics: { attendance: 93, health: 'stable' } });
  assert.equal(created.status, 201);
  reportId = created.body.report.id;
  const pending = await api.get('/api/admin/sponsorship-reports').set('Authorization', `Bearer ${adminToken}`);
  assert.equal(pending.status, 200);
  assert.ok(pending.body.reports.some((item) => item.id === reportId));
  const donorNotifications = await api.get('/api/notifications').set('Authorization', `Bearer ${donorToken}`);
  assert.ok(donorNotifications.body.notifications.some((item) => item.entity_id === reportId));
  const xlsx = await api.get('/api/admin/exports/financial?format=xlsx').set('Authorization', `Bearer ${adminToken}`);
  assert.equal(xlsx.status, 200);
  assert.match(xlsx.headers['content-type'], /spreadsheetml/);
  const pdf = await api.get('/api/admin/exports/analytics?format=pdf').set('Authorization', `Bearer ${adminToken}`);
  assert.equal(pdf.status, 200);
  assert.match(pdf.headers['content-type'], /application\/pdf/);
});

test('notification read state and audit logs work', async () => {
  const notifications = await api.get('/api/notifications').set('Authorization', `Bearer ${donorToken}`);
  const notificationId = notifications.body.notifications[0].id;
  const marked = await api.patch(`/api/notifications/${notificationId}/read`).set('Authorization', `Bearer ${donorToken}`);
  assert.equal(marked.status, 200);
  const logs = await api.get('/api/admin/audit-logs').set('Authorization', `Bearer ${adminToken}`);
  assert.equal(logs.status, 200);
  assert.ok(logs.body.logs.some((log) => log.entity_type === 'sponsorship_request'));
});

after(async () => {
  if (reportId) await pool.query('DELETE FROM sponsorship_reports WHERE id = $1', [reportId]);
  if (orphanId) await pool.query('DELETE FROM orphan_profiles WHERE id = $1', [orphanId]);
  if (charityId) await pool.query('DELETE FROM charities WHERE id = $1', [charityId]);
  await pool.query('DELETE FROM users WHERE email IN ($1, $2)', [adminEmail, donorEmail]);
  await pool.end();
});

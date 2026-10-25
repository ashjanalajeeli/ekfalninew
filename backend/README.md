# Ekfalni Backend

خادم REST لتطبيق Ekfalni باستخدام Node.js وExpress وPostgreSQL. يحتوي على المصادقة، صلاحيات الأدوار، إدارة تقارير الأيتام، التصدير، والإشعارات داخل التطبيق.

## التشغيل

1. شغّل PostgreSQL وأنشئ قاعدة باسم `ekfalni`.
2. انسخ `.env.example` إلى `.env` وعدّل `DATABASE_URL` و`JWT_SECRET`.
3. طبّق المخطط والترحيل الثاني:

```bash
psql "$DATABASE_URL" -f sql/001_initial.sql
psql "$DATABASE_URL" -f sql/002_charities_requests_payments_audit.sql
```

4. ثبّت الحزم وشغّل الخادم:

```bash
npm install
npm run dev
```

## الصلاحيات

- `donor`: يرى تبرعاته وكفالاته وإشعاراته.
- `supervisor`: يراجع التقارير ويعتمدها أو يطلب تعديلها.
- `admin`: يمتلك صلاحيات المشرف بالإضافة إلى التصدير وإدارة أوسع.
- `charity`: يدير الأيتام والمشاريع وطلبات الكفالة التابعة لجمعيته.

يتم فرض الدور على الخادم عبر middleware `requireRole`، ولا يكفي إخفاء الزر في تطبيق Flutter.

## أهم المسارات

```text
POST /api/auth/register
POST /api/auth/login
GET  /api/user/profile
GET  /api/notifications
PATCH /api/notifications/:id/read
POST /api/notifications/read-all
GET  /api/notifications/stream
PUT  /api/notifications/preferences
POST /api/notifications/device-token
GET  /api/admin/sponsorship-reports
POST /api/admin/sponsorship-reports/:id/approve
GET  /api/admin/exports/financial?format=xlsx|pdf
GET  /api/admin/exports/analytics?format=xlsx|pdf
POST /api/sponsorship-reports
GET  /api/charities
POST /api/admin/charities
POST /api/charity/orphans
PATCH /api/charity/orphans/:id
POST /api/charity/projects
PATCH /api/charity/projects/:id
POST /api/charity/orphan-cases
PATCH /api/charity/orphan-cases/:id
POST /api/admin/charities/:id/members
POST /api/admin/notifications/send
POST /api/sponsorship-requests
GET  /api/sponsorship-requests/my
GET  /api/charity/sponsorship-requests
PATCH /api/charity/sponsorship-requests/:id
POST /api/donations
POST /api/donations/:id/payment-intent
POST /api/payments/:id/status
GET  /api/admin/audit-logs
```

عند إنشاء تقرير جديد، يكتب الخادم إشعارًا داخل التطبيق لكل متبرع لديه كفالة نشطة على اليتيم، وكذلك للمشرفين لمراجعته. يدعم `GET /api/notifications/stream` بث Server-Sent Events، بينما يمكن لتطبيق الهاتف استخدام `GET /api/notifications` عند الفتح أو التحديث.

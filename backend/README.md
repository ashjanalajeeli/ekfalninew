# Ekfalni Backend

خادم REST لتطبيق Ekfalni باستخدام Node.js وExpress وPostgreSQL. يحتوي على المصادقة، صلاحيات الأدوار، إدارة تقارير الأيتام، التصدير، والإشعارات داخل التطبيق.

## التشغيل

1. شغّل PostgreSQL وأنشئ قاعدة باسم `ekfalni`.
2. انسخ `.env.example` إلى `.env` وعدّل `DATABASE_URL` و`JWT_SECRET`.
3. طبّق المخطط:

```bash
psql "$DATABASE_URL" -f sql/001_initial.sql
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
```

عند إنشاء تقرير جديد، يكتب الخادم إشعارًا داخل التطبيق لكل متبرع لديه كفالة نشطة على اليتيم، وكذلك للمشرفين لمراجعته. يدعم `GET /api/notifications/stream` بث Server-Sent Events، بينما يمكن لتطبيق الهاتف استخدام `GET /api/notifications` عند الفتح أو التحديث.

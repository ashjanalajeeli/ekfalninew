# اختبار التكامل والمراقبة الأمنية

## تشغيل الاختبارات محليًا

يتطلب الاختبار PostgreSQL مطبقًا عليه الترحيلان:

```bash
docker compose up -d
psql "$DATABASE_URL" -f sql/001_initial.sql
psql "$DATABASE_URL" -f sql/002_charities_requests_payments_audit.sql
npm ci
DATABASE_URL=postgres://ekfalni:ekfalni@localhost:5432/ekfalni JWT_SECRET=test-secret npm run test:integration
```

يغطي الاختبار:

- تسجيل المتبرع وتسجيل دخول المشرف.
- إنشاء جمعية ويتيم.
- إرسال طلب كفالة ومنع الطلب المكرر.
- رفض وصول المتبرع لمسارات الإدارة.
- اعتماد طلب الكفالة وإشعار المتبرع.
- إنشاء تقرير دوري وإشعار المتبرع.
- قراءة الإشعارات وتغيير حالتها.
- تصدير Excel وPDF.
- سجل التدقيق.

## المراقبة والتحديث

- `npm audit --audit-level=high --omit=dev` يعمل أسبوعيًا عبر GitHub Actions.
- Dependabot يفتح Pull Requests أسبوعية لاعتماديات Backend وشهرية لـ GitHub Actions.
- كل Pull Request أو push إلى `main` يشغل اختبارات التكامل على PostgreSQL 16.
- لا يتم دمج تحديثات الاعتماديات تلقائيًا دون مرور الاختبارات والمراجعة.

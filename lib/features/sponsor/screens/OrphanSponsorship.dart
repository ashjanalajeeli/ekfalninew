import 'package:flutter/material.dart';

class OrphanSponsorshipPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('شروط كفالة يتيم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Align(
              alignment: Alignment.centerRight,  // محاذاة العنوان إلى اليمين
              child: Text(
                ':شروط كفالة يتيم',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildConditionItem('1. التسجيل في التطبيق: يجب عليك التسجيل باستخدام بياناتك الشخصية (الاسم، رقم الهوية، رقم الهاتف، البريد الإلكتروني).'),
            _buildConditionItem('2. الموافقة على الشروط والأحكام: يجب الموافقة على الشروط والأحكام الخاصة بالكفالة.'),
            _buildConditionItem('3. التأكد من القدرة المالية: يجب التأكد من قدرتك المالية على دفع المبالغ المطلوبة للكفالة (شهريًا أو سنويًا).'),
            _buildConditionItem('4. اختيار اليتيم: يمكنك اختيار اليتيم الذي ترغب في كفالته من بين الأيتام المتاحين في التطبيق.'),
            _buildConditionItem('5. التحقق من الكفالة السابقة: التأكد من أن اليتيم المختار ليس مكفولًا من قبل شخص آخر.'),
            _buildConditionItem('6. تحديد مدة الكفالة: يجب تحديد مدة الكفالة (شهريًا أو سنويًا).'),
            _buildConditionItem('7. التواصل مع اليتيم: يمكنك التواصل مع اليتيم عبر التطبيق (إذا كان ذلك جزءًا من سياسة الجمعية).'),
            _buildConditionItem('8. التزام بالدفع المنتظم: يجب الالتزام بالدفع المنتظم في الوقت المحدد للكفالة.'),
            _buildConditionItem('9. تقديم مستلزمات إضافية: يمكنك تقديم مستلزمات إضافية لليتيم مثل الملابس، المستلزمات المدرسية، أو الطعام.'),
            _buildConditionItem('10. التحديثات والإنذارات: ستتلقى إشعارات بتحديثات حول حالة اليتيم.'),
            _buildConditionItem('11. حماية البيانات والسرية: سيتم حماية بياناتك الشخصية وسرية معلومات الكفالة.'),
            _buildConditionItem('12. التقرير الدوري: ستتلقى تقارير دورية عن حالة اليتيم.'),
            _buildConditionItem('13. إلغاء الكفالة: يمكنك إلغاء الكفالة عند الحاجة مع إشعار مسبق.'),
            _buildConditionItem('14. تعديل بيانات الكفالة: يمكنك تعديل بيانات الكفالة مثل وسيلة الدفع أو مدة الكفالة.'),
            SizedBox(height: 30),
            // تعديل المحاذاة وجعل الزر في الوسط مع اللون المحدد
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // إرجاع المستخدم إلى صفحة sponsor.dart عند الضغط على الزر
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم قبول شروط الكفالة')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // اللون الذي طلبته
                ),
                child: Text('موافقة على الشروط',style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,  // محاذاة النص إلى اليمين
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class OrphanDetailsScreen extends StatelessWidget {
  const OrphanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text('تفاصيل المستفيد', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800)),
          backgroundColor: AppTheme.backgroundColor,
          foregroundColor: AppTheme.textColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [IconButton(onPressed: () => _share(context), icon: const Icon(Icons.ios_share_rounded))],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _buildProfileHero(),
            const SizedBox(height: 18),
            _buildStats(),
            const SizedBox(height: 20),
            _sectionTitle('قصته'),
            const SizedBox(height: 9),
            Text('أحمد طفل محب للتعلم ويطمح أن يصبح مهندسًا. تساعده الكفالة على الاستمرار في دراسته والحصول على الرعاية الأساسية التي يحتاجها لينمو بأمان وثقة.', style: AppTheme.bodyStyle.copyWith(color: AppTheme.subtitleColor, fontSize: 12)),
            const SizedBox(height: 22),
            _sectionTitle('احتياجاته الحالية'),
            const SizedBox(height: 11),
            _needRow(Icons.school_rounded, 'المستلزمات التعليمية', 'حقيبة وكتب دراسية للفصل الجديد', AppTheme.softPurple, AppTheme.primaryColor),
            _needRow(Icons.health_and_safety_rounded, 'الرعاية الصحية', 'فحص دوري وأدوية أساسية', AppTheme.softGold, const Color(0xFFC18320)),
            _needRow(Icons.restaurant_rounded, 'الدعم الغذائي', 'سلة غذائية شهرية للأسرة', const Color(0xFFE5F6F0), AppTheme.successColor),
            const SizedBox(height: 23),
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.softPurple, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryColor, size: 20), const SizedBox(width: 10), Expanded(child: Text('نحافظ على خصوصية المستفيدين ونشارك المعلومات الضرورية فقط لضمان رحلة كفالة آمنة ومحترمة.', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 10, height: 1.7)))])),
            const SizedBox(height: 18),
            SizedBox(height: 52, child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/sposership'), icon: const Icon(Icons.volunteer_activism_rounded, size: 19), label: Text('ابدأ كفالة أحمد', style: AppTheme.buttonTextStyle), style: AppTheme.elevatedButtonStyle)),
          ]),
        ),
      ),
    );
  }

  Widget _buildProfileHero() => Container(decoration: AppTheme.cardDecoration, clipBehavior: Clip.antiAlias, child: Column(children: [SizedBox(height: 190, width: double.infinity, child: Stack(fit: StackFit.expand, children: [Image.asset('images/child1.jpg', fit: BoxFit.cover), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(.78)], begin: Alignment.topCenter, end: Alignment.bottomCenter))), PositionedDirectional(bottom: 15, start: 17, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ملف كفالة نشط', style: GoogleFonts.cairo(color: AppTheme.secondaryColor, fontSize: 10, fontWeight: FontWeight.w700)), Text('أحمد محمد', style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)), Text('9 سنوات · صنعاء، اليمن', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10))]))])), Padding(padding: const EdgeInsets.all(15), child: Row(children: [const Icon(Icons.verified_rounded, color: AppTheme.successColor, size: 18), const SizedBox(width: 7), Text('تم التحقق من البيانات عبر الجمعية الشريكة', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 10))]))]));

  Widget _buildStats() => Row(children: [_stat('50 ر.س', 'الكفالة الشهرية', AppTheme.softGold, const Color(0xFFC18320)), const SizedBox(width: 9), _stat('68%', 'تقدم الخطة', AppTheme.softPurple, AppTheme.primaryColor), const SizedBox(width: 9), _stat('تعليم', 'نوع الرعاية', const Color(0xFFE5F6F0), AppTheme.successColor)]);
  Widget _stat(String value, String label, Color bg, Color color) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)), child: Column(children: [Text(value, style: GoogleFonts.cairo(color: color, fontSize: 13, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(label, textAlign: TextAlign.center, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8))])));
  Widget _sectionTitle(String title) => Text(title, style: AppTheme.subheadingStyle.copyWith(fontSize: 16));
  Widget _needRow(IconData icon, String title, String subtitle, Color bg, Color color) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12), decoration: AppTheme.cardDecoration, child: Row(children: [Container(width: 37, height: 37, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 19)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.cairo(color: AppTheme.textColor, fontWeight: FontWeight.w700, fontSize: 11)), const SizedBox(height: 2), Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))])), const Icon(Icons.chevron_left_rounded, color: AppTheme.subtitleColor, size: 18)]));
  void _share(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تجهيز رابط مشاركة الملف')));
}

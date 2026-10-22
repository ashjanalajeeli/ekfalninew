import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DonorDashboardScreen extends StatelessWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          foregroundColor: AppTheme.textColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text('لوحة المتبرع', style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800)),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () => Navigator.pushNamed(context, '/notification-settings'), icon: const Icon(Icons.tune_rounded)),
            IconButton(onPressed: () => Navigator.pushNamed(context, '/notification-center'), icon: const Icon(Icons.notifications_none_rounded)),
          ],
        ),
        body: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 500)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Text('أهلًا أشجان،', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 12)),
              Text('تابعي أثر عطائك', style: AppTheme.headingStyle.copyWith(fontSize: 23)),
              const SizedBox(height: 17),
              _buildOverviewCard(),
              const SizedBox(height: 23),
              _sectionHeader('ملخصك هذا الشهر', 'التفاصيل'),
              const SizedBox(height: 11),
              _buildStats(),
              const SizedBox(height: 25),
              _sectionHeader('حالاتك المكفولة', 'عرض الكل'),
              const SizedBox(height: 11),
              _buildSponsoredChildren(),
              const SizedBox(height: 25),
              _sectionHeader('التقارير الدورية', 'كل التقارير'),
              const SizedBox(height: 11),
              _buildReports(context),
              const SizedBox(height: 25),
              _sectionHeader('أثر مساهمتك', ''),
              const SizedBox(height: 11),
              _buildImpactChart(),
              const SizedBox(height: 20),
              _buildExploreCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() => Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(25), boxShadow: const [BoxShadow(color: Color(0x357657E8), blurRadius: 20, offset: Offset(0, 9))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.secondaryColor)), const SizedBox(width: 11), Expanded(child: Text('أنت تصنع فرقًا حقيقيًا', style: GoogleFonts.cairo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))), const Icon(Icons.favorite_rounded, color: AppTheme.secondaryColor, size: 21)]),
          const SizedBox(height: 17),
          Text('ساهمتِ في رعاية 3 حالات منذ انضمامك إلى Ekfalni', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 12),
          Row(children: [Text('4,850 ر.س', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(10)), child: Text('+18% هذا العام', style: GoogleFonts.cairo(color: AppTheme.secondaryColor, fontSize: 9, fontWeight: FontWeight.w700)))]),
        ]),
      );

  Widget _buildStats() => Row(children: [_stat('3', 'كفالات نشطة', Icons.volunteer_activism_rounded, AppTheme.softPurple, AppTheme.primaryColor), const SizedBox(width: 9), _stat('1,250', 'شهريًا ر.س', Icons.payments_outlined, AppTheme.softGold, const Color(0xFFC18320)), const SizedBox(width: 9), _stat('4', 'تقارير جديدة', Icons.description_outlined, const Color(0xFFE5F6F0), AppTheme.successColor)]);

  Widget _stat(String value, String label, IconData icon, Color bg, Color color) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 5), decoration: AppTheme.cardDecoration, child: Column(children: [Container(width: 33, height: 33, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 17)), const SizedBox(height: 7), Text(value, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 15, fontWeight: FontWeight.w800)), Text(label, textAlign: TextAlign.center, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8))]));

  Widget _buildSponsoredChildren() => SizedBox(height: 209, child: ListView(scrollDirection: Axis.horizontal, children: [
        _childCard('أحمد محمد', '9 سنوات · صنعاء', '68%', 'images/child1.jpg', 'تقرير جديد', AppTheme.primaryColor),
        _childCard('سارة عبدالله', '7 سنوات · تعز', '82%', 'images/child2.jpg', 'تمت القراءة', const Color(0xFFC18320)),
        _childCard('ليان خالد', '6 سنوات · إب', '54%', 'images/orphan.jpg', 'بانتظار التحديث', AppTheme.successColor),
      ]));

  Widget _childCard(String name, String meta, String progress, String image, String status, Color color) => Container(width: 205, margin: const EdgeInsetsDirectional.only(end: 11), decoration: AppTheme.cardDecoration, clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 92, width: double.infinity, child: Stack(fit: StackFit.expand, children: [Image.asset(image, fit: BoxFit.cover), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(.6)], begin: Alignment.topCenter, end: Alignment.bottomCenter))), PositionedDirectional(bottom: 8, start: 10, child: Text(status, style: GoogleFonts.cairo(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)))])), Padding(padding: const EdgeInsets.all(11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(meta, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: double.parse(progress.replaceAll('%', '')) / 100, minHeight: 5, backgroundColor: const Color(0xFFEDEBF6), valueColor: AlwaysStoppedAnimation<Color>(color))), const SizedBox(height: 5), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('تقدم الكفالة', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8)), Text(progress, style: GoogleFonts.cairo(color: color, fontSize: 9, fontWeight: FontWeight.w800))])]))]));

  Widget _buildReports(BuildContext context) => Column(children: [_reportTile(context, 'تقرير أحمد · مارس 2026', 'تقدم دراسي وصحي جديد', 'منذ يومين', Icons.school_rounded, AppTheme.primaryColor, true), _reportTile(context, 'تقرير سارة · فبراير 2026', 'صور من النشاط التعليمي', 'منذ 8 أيام', Icons.photo_camera_back_rounded, const Color(0xFFC18320), false), _reportTile(context, 'إيصال الكفالة الشهري', 'تم تسجيل الدفعة بنجاح', 'منذ 15 يومًا', Icons.check_circle_outline_rounded, AppTheme.successColor, false)]);

  Widget _reportTile(BuildContext context, String title, String subtitle, String date, IconData icon, Color color, bool unread) => InkWell(onTap: () => _showReport(context, title, subtitle), borderRadius: BorderRadius.circular(18), child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12), decoration: AppTheme.cardDecoration, child: Row(children: [Container(width: 39, height: 39, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color, size: 19)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(title, overflow: TextOverflow.ellipsis, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 10, fontWeight: FontWeight.w800)), if (unread) ...[const SizedBox(width: 5), Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle))]]), const SizedBox(height: 3), Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(date, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8)), const SizedBox(height: 4), const Icon(Icons.chevron_left_rounded, color: AppTheme.subtitleColor, size: 17)])])));

  Widget _buildImpactChart() => Container(padding: const EdgeInsets.fromLTRB(15, 16, 15, 12), decoration: AppTheme.cardDecoration, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مساهماتك خلال آخر 6 أشهر', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 10)), const SizedBox(height: 16), SizedBox(height: 100, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_bar('أكتوبر', .45), _bar('نوفمبر', .62), _bar('ديسمبر', .38), _bar('يناير', .7), _bar('فبراير', .55), _bar('مارس', .86)])), const SizedBox(height: 13), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)), const SizedBox(width: 5), Text('إجمالي التبرعات', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))])]);

  Widget _bar(String label, double value) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(width: 17, height: 90 * value, decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(.85), borderRadius: const BorderRadius.vertical(top: Radius.circular(7))))),), const SizedBox(height: 5), Text(label, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8))]);

  Widget _buildExploreCard(BuildContext context) => InkWell(onTap: () => Navigator.pushNamed(context, '/sponsor'), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.softGold, borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.65), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.add_rounded, color: Color(0xFFC18320))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('وسّعي دائرة أثرك', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.w800)), Text('اكتشفي فرص كفالة جديدة', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))])), const Icon(Icons.chevron_left_rounded, color: Color(0xFFC18320))]));

  Widget _sectionHeader(String title, String action) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: AppTheme.subheadingStyle.copyWith(fontSize: 16)), if (action.isNotEmpty) TextButton(onPressed: () {}, child: Text(action, style: GoogleFonts.cairo(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w700)))]);

  void _showReport(BuildContext context, String title, String subtitle) => showModalBottomSheet(context: context, showDragHandle: true, backgroundColor: AppTheme.backgroundColor, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(22, 5, 22, 30), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTheme.subheadingStyle), const SizedBox(height: 7), Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 11)), const SizedBox(height: 18), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.softPurple, borderRadius: BorderRadius.circular(16)), child: Text('تمت إضافة هذا التحديث إلى سجل أثرِك. ستظهر التفاصيل والصور الكاملة هنا بعد مزامنة التقرير من الجمعية الشريكة.', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, height: 1.7))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: AppTheme.elevatedButtonStyle, child: Text('حسنًا', style: AppTheme.buttonTextStyle)))])));
}

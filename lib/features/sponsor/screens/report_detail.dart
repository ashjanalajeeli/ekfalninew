import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/api_config.dart';
import '../../../theme/app_theme.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  final String title;
  const ReportDetailScreen({super.key, this.reportId = 'ahmed-march-2026', this.title = 'تقرير أحمد · مارس 2026'});
  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _downloading = false;

  Future<void> _downloadPdf() async {
    setState(() => _downloading = true);
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sponsorshipReportPdf}/${widget.reportId}/pdf');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    setState(() => _downloading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(opened ? 'تم فتح التقرير لتنزيله بصيغة PDF' : 'تعذر فتح التقرير. تأكدي من اتصال الخادم.', style: GoogleFonts.cairo()), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: AppTheme.backgroundColor, appBar: AppBar(backgroundColor: AppTheme.backgroundColor, foregroundColor: AppTheme.textColor, surfaceTintColor: Colors.transparent, elevation: 0, centerTitle: true, title: Text('تفاصيل التقرير', style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: _downloading ? null : _downloadPdf, icon: const Icon(Icons.picture_as_pdf_outlined), tooltip: 'تنزيل PDF')]), body: ListView(padding: const EdgeInsets.fromLTRB(20, 6, 20, 30), children: [_reportHeader(), const SizedBox(height: 20), _section('ملخص الحالة', 'أظهر أحمد تقدمًا إيجابيًا خلال هذا الشهر، مع تحسن في المواظبة على الدراسة واستقرار حالته الصحية.'), const SizedBox(height: 14), _metrics(), const SizedBox(height: 20), _sectionTitle('آخر التحديثات'), const SizedBox(height: 10), _timeline(), const SizedBox(height: 19), _downloadCard()]));
  }

  Widget _reportHeader() => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(23)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.description_rounded, color: AppTheme.secondaryColor, size: 25)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.title, style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)), Text('تقرير دوري · كفالة أحمد محمد', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 9))]))]), const SizedBox(height: 15), Row(children: [_headerMeta('تاريخ الإصدار', '20 مارس 2026'), const Spacer(), _headerMeta('الحالة', 'محدّث')]) ]));
  Widget _headerMeta(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.cairo(color: Colors.white60, fontSize: 8)), const SizedBox(height: 3), Text(value, style: GoogleFonts.cairo(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))]);
  Widget _section(String title, String body) => Container(padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTheme.subheadingStyle.copyWith(fontSize: 15)), const SizedBox(height: 8), Text(body, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 11, height: 1.8))]));
  Widget _sectionTitle(String title) => Text(title, style: AppTheme.subheadingStyle.copyWith(fontSize: 16));
  Widget _metrics() => Row(children: [_metric('التعليم', 'ممتاز', Icons.school_rounded, AppTheme.primaryColor), const SizedBox(width: 9), _metric('الصحة', 'مستقرة', Icons.health_and_safety_rounded, AppTheme.successColor), const SizedBox(width: 9), _metric('الحضور', '92%', Icons.event_available_rounded, const Color(0xFFC18320))]);
  Widget _metric(String label, String value, IconData icon, Color color) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5), decoration: AppTheme.cardDecoration, child: Column(children: [Icon(icon, color: color, size: 19), const SizedBox(height: 5), Text(value, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, fontWeight: FontWeight.w800)), Text(label, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8))]));
  Widget _timeline() => Column(children: [_event('تحسن في المواظبة الدراسية', 'حضر أحمد 92% من الحصص هذا الشهر.', Icons.trending_up_rounded, AppTheme.successColor), _event('فحص صحي دوري', 'تم إجراء الفحص وكانت النتائج مستقرة.', 'health', AppTheme.primaryColor), _event('نشاط تعليمي جديد', 'شارك في ورشة القراءة الأسبوعية.', Icons.auto_stories_rounded, const Color(0xFFC18320))]);
  Widget _event(String title, String body, dynamic icon, Color color) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 35, height: 35, decoration: BoxDecoration(color: color.withOpacity(.12), shape: BoxShape.circle), child: Icon(icon is IconData ? icon : Icons.health_and_safety_rounded, color: color, size: 17)), const SizedBox(width: 10), Expanded(child: Container(padding: const EdgeInsets.only(bottom: 10), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE9E8F2)))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(body, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9, height: 1.6))]))]));
  Widget _downloadCard() => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.softGold, borderRadius: BorderRadius.circular(19)), child: Row(children: [const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFC18320), size: 26), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('نسخة PDF من التقرير', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, fontWeight: FontWeight.w800)), Text('احتفظي بنسخة من التقرير للرجوع إليها لاحقًا', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8))])), const SizedBox(width: 8), OutlinedButton(onPressed: _downloading ? null : _downloadPdf, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC18320), side: const BorderSide(color: Color(0xFFC18320)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))), child: _downloading ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : Text('تنزيل', style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w700))) ]));
}

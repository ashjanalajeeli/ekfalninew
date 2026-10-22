import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class FinancialHistoryScreen extends StatefulWidget {
  const FinancialHistoryScreen({super.key});
  @override
  State<FinancialHistoryScreen> createState() => _FinancialHistoryScreenState();
}

class _FinancialHistoryScreenState extends State<FinancialHistoryScreen> {
  String _filter = 'الكل';
  final _operations = const [
    _FinancialOperation('كفالة أحمد محمد', 'اشتراك شهري · مارس 2026', '1,250 ر.س', 'ناجحة', '18 مارس 2026', Icons.volunteer_activism_rounded, Color(0xFF38B982)),
    _FinancialOperation('تعليم يصنع غدًا', 'تبرع لمرة واحدة', '250 ر.س', 'ناجحة', '12 مارس 2026', Icons.school_rounded, Color(0xFF7657E8)),
    _FinancialOperation('كفالة سارة عبدالله', 'اشتراك شهري · فبراير 2026', '450 ر.س', 'قيد المراجعة', '28 فبراير 2026', Icons.favorite_rounded, Color(0xFFC18320)),
    _FinancialOperation('سلة الخير الشهرية', 'تبرع لمرة واحدة', '150 ر.س', 'ملغاة', '15 فبراير 2026', Icons.shopping_basket_rounded, Color(0xFFE06A78)),
  ];

  List<_FinancialOperation> get _visible => _filter == 'الكل' ? _operations : _operations.where((item) => item.status == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: AppTheme.backgroundColor, appBar: AppBar(backgroundColor: AppTheme.backgroundColor, foregroundColor: AppTheme.textColor, surfaceTintColor: Colors.transparent, elevation: 0, centerTitle: true, title: Text('السجل المالي', style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: () => _showExportMessage(context), icon: const Icon(Icons.download_outlined), tooltip: 'تنزيل السجل')]), body: ListView(padding: const EdgeInsets.fromLTRB(20, 6, 20, 30), children: [_summaryCard(), const SizedBox(height: 20), _sectionTitle('العمليات المالية'), const SizedBox(height: 11), _filters(), const SizedBox(height: 13), if (_visible.isEmpty) _emptyState() else ..._visible.map(_operationTile)]));
  }

  Widget _summaryCard() => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(23), boxShadow: const [BoxShadow(color: Color(0x287657E8), blurRadius: 18, offset: Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.secondaryColor), const SizedBox(width: 9), Text('ملخص المساهمات', style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))]), const SizedBox(height: 15), Text('2,100 ر.س', style: GoogleFonts.cairo(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)), Text('إجمالي العمليات خلال 2026', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10)), const SizedBox(height: 15), Row(children: [_miniStat('4', 'عمليات'), const SizedBox(width: 8), _miniStat('3', 'ناجحة'), const SizedBox(width: 8), _miniStat('1,250 ر.س', 'شهريًا')])])));
  Widget _miniStat(String value, String label) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(value, style: GoogleFonts.cairo(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)), Text(label, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 8))])));
  Widget _sectionTitle(String title) => Text(title, style: AppTheme.subheadingStyle.copyWith(fontSize: 16));
  Widget _filters() => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['الكل', 'ناجحة', 'قيد المراجعة', 'ملغاة'].map((filter) => Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: ChoiceChip(label: Text(filter, style: GoogleFonts.cairo(fontSize: 10, color: _filter == filter ? Colors.white : AppTheme.subtitleColor, fontWeight: FontWeight.w700)), selected: _filter == filter, selectedColor: AppTheme.primaryColor, backgroundColor: Colors.white, side: BorderSide(color: _filter == filter ? AppTheme.primaryColor : const Color(0xFFE9E8F2)), onSelected: (_) => setState(() => _filter = filter))).toList()));
  Widget _operationTile(_FinancialOperation operation) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: AppTheme.cardDecoration, child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: operation.color.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(operation.icon, color: operation.color, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(operation.title, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(operation.subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9)), const SizedBox(height: 6), Row(children: [Text(operation.date, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8)), const SizedBox(width: 7), _status(operation.status)])])), Text(operation.amount, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.w800))]));
  Widget _status(String value) { final color = value == 'ناجحة' ? AppTheme.successColor : value == 'قيد المراجعة' ? const Color(0xFFC18320) : const Color(0xFFE06A78); return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(.11), borderRadius: BorderRadius.circular(7)), child: Text(value, style: GoogleFonts.cairo(color: color, fontSize: 8, fontWeight: FontWeight.w700))); }
  Widget _emptyState() => Padding(padding: const EdgeInsets.all(30), child: Column(children: [const Icon(Icons.receipt_long_outlined, color: AppTheme.subtitleColor, size: 42), const SizedBox(height: 10), Text('لا توجد عمليات بهذا التصنيف', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 11))]));
  void _showExportMessage(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('سيتم تجهيز كشف العمليات من الخادم عند تفعيل الخدمة.', style: GoogleFonts.cairo()), behavior: SnackBarBehavior.floating));
}

class _FinancialOperation { final String title, subtitle, amount, status, date; final IconData icon; final Color color; const _FinancialOperation(this.title, this.subtitle, this.amount, this.status, this.date, this.icon, this.color); }

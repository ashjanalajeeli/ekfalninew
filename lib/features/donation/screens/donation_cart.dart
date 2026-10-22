import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import 'donation.dart';

class DonationCartScreen extends StatefulWidget {
  const DonationCartScreen({super.key});
  @override
  State<DonationCartScreen> createState() => _DonationCartScreenState();
}

class _DonationCartScreenState extends State<DonationCartScreen> {
  final List<_CartItem> _items = [
    _CartItem(title: 'تعليم يصنع غدًا', subtitle: 'تبرع لمرة واحدة', amount: 250, image: 'images/child_donation.png', color: AppTheme.primaryColor),
    _CartItem(title: 'سلة الخير الشهرية', subtitle: 'تبرع شهري', amount: 150, image: 'images/food.png', color: const Color(0xFFC18320)),
  ];

  double get _total => _items.fold(0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: AppTheme.backgroundColor, appBar: AppBar(title: Text('سلة التبرعات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800)), centerTitle: true, backgroundColor: AppTheme.backgroundColor, foregroundColor: AppTheme.textColor, surfaceTintColor: Colors.transparent, elevation: 0, actions: [if (_items.isNotEmpty) IconButton(onPressed: () => setState(_items.clear), icon: const Icon(Icons.delete_sweep_outlined))]), body: _items.isEmpty ? _emptyState() : ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [_cartHeader(), const SizedBox(height: 15), ..._items.asMap().entries.map((entry) => _itemCard(entry.key, entry.value)), const SizedBox(height: 20), _summary(), const SizedBox(height: 16), SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _continueDonation, icon: const Icon(Icons.arrow_back_rounded, size: 18), label: Text('المتابعة إلى بيانات التبرع', style: AppTheme.buttonTextStyle), style: AppTheme.elevatedButtonStyle)), const SizedBox(height: 8), Center(child: Text('هذه الخطوة تجريبية ولا يتم خصم أي مبلغ', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))) ])));
  }

  Widget _cartHeader() => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.shopping_bag_outlined, color: Colors.white)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تبرعاتك تصنع فرقًا', style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)), Text('${_items.length} عناصر جاهزة للمراجعة', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10))]))]));
  Widget _itemCard(int index, _CartItem item) => Container(margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(10), decoration: AppTheme.cardDecoration, child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.asset(item.image, width: 68, height: 68, fit: BoxFit.cover)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(item.subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9)), const SizedBox(height: 8), Text('${item.amount.toStringAsFixed(0)} ر.س', style: GoogleFonts.cairo(color: item.color, fontSize: 12, fontWeight: FontWeight.w800))])), IconButton(onPressed: () => setState(() => _items.removeAt(index)), icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.subtitleColor))]));
  Widget _summary() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE9E8F2))), child: Column(children: [_summaryRow('مجموع التبرعات', '${_total.toStringAsFixed(0)} ر.س'), _summaryRow('رسوم المعالجة', '0 ر.س'), const Divider(height: 22), _summaryRow('الإجمالي', '${_total.toStringAsFixed(0)} ر.س', strong: true)]));
  Widget _summaryRow(String label, String value, {bool strong = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.cairo(color: strong ? AppTheme.textColor : AppTheme.subtitleColor, fontSize: strong ? 13 : 10, fontWeight: strong ? FontWeight.w800 : FontWeight.w500)), Text(value, style: GoogleFonts.cairo(color: strong ? AppTheme.primaryColor : AppTheme.textColor, fontSize: strong ? 15 : 11, fontWeight: FontWeight.w800))]));
  Widget _emptyState() => Center(child: Padding(padding: const EdgeInsets.all(35), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.softPurple, borderRadius: BorderRadius.circular(25)), child: const Icon(Icons.shopping_bag_outlined, size: 38, color: AppTheme.primaryColor)), const SizedBox(height: 18), Text('السلة فارغة', style: AppTheme.subheadingStyle), const SizedBox(height: 5), Text('أضيفي حملة أو كفالة لتظهر هنا قبل المتابعة.', textAlign: TextAlign.center, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 11)), const SizedBox(height: 18), ElevatedButton(onPressed: () => Navigator.pop(context), style: AppTheme.elevatedButtonStyle, child: Text('استعرض الحملات', style: AppTheme.buttonTextStyle))]));
  void _continueDonation() => Navigator.push(context, MaterialPageRoute(builder: (_) => const donation(donationType: 'project', projectTitle: 'سلة التبرعات', projectDescription: 'مراجعة التبرعات المختارة قبل إتمام الخطوة التالية.')));
}

class _CartItem { final String title, subtitle, image; final double amount; final Color color; const _CartItem({required this.title, required this.subtitle, required this.amount, required this.image, required this.color}); }

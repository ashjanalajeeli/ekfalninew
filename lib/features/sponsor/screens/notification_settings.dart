import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/notification_service.dart';
import '../../../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _emailController = TextEditingController();
  bool _emailReports = true;
  bool _pushReports = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _emailController.dispose(); super.dispose(); }

  Future<void> _load() async {
    final settings = await NotificationService.instance.loadPreferences();
    if (!mounted) return;
    setState(() { _emailReports = settings.emailReports; _pushReports = settings.pushReports; _emailController.text = settings.emailAddress; _loading = false; });
  }

  Future<void> _save() async {
    if (_emailReports && !_emailController.text.trim().contains('@')) { _showMessage('أدخلي بريدًا صحيحًا لتفعيل التنبيهات البريدية'); return; }
    setState(() => _saving = true);
    await NotificationService.instance.savePreferences(NotificationPreferences(emailReports: _emailReports, pushReports: _pushReports, emailAddress: _emailController.text.trim()));
    if (!mounted) return;
    setState(() => _saving = false);
    _showMessage('تم حفظ تفضيلات التنبيهات');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: AppTheme.backgroundColor, appBar: AppBar(backgroundColor: AppTheme.backgroundColor, foregroundColor: AppTheme.textColor, surfaceTintColor: Colors.transparent, elevation: 0, centerTitle: true, title: Text('إعدادات التنبيهات', style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800))), body: _loading ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)) : ListView(padding: const EdgeInsets.fromLTRB(20, 7, 20, 30), children: [Text('اختاري كيف تريدين معرفة آخر أخبار الكفالات والتقارير الدورية.', style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 11, height: 1.7)), const SizedBox(height: 18), _channelCard(icon: Icons.notifications_active_rounded, title: 'إشعارات فورية', subtitle: 'تنبيه داخل التطبيق عند صدور تقرير جديد', value: _pushReports, color: AppTheme.primaryColor, onChanged: (value) => setState(() => _pushReports = value)), const SizedBox(height: 11), _channelCard(icon: Icons.mark_email_unread_rounded, title: 'تنبيهات بريدية', subtitle: 'إرسال ملخص التقرير إلى بريدك الإلكتروني', value: _emailReports, color: const Color(0xFFC18320), onChanged: (value) => setState(() => _emailReports = value)), if (_emailReports) ...[const SizedBox(height: 13), TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: AppTheme.inputDecoration('البريد الإلكتروني').copyWith(prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppTheme.primaryColor)))], const SizedBox(height: 22), _privacyNote(), const SizedBox(height: 20), SizedBox(height: 52, child: ElevatedButton(onPressed: _saving ? null : _save, style: AppTheme.elevatedButtonStyle, child: _saving ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('حفظ التفضيلات', style: AppTheme.buttonTextStyle))) ]));
  }

  Widget _channelCard({required IconData icon, required String title, required String subtitle, required bool value, required Color color, required ValueChanged<bool> onChanged}) => Container(padding: const EdgeInsets.all(13), decoration: AppTheme.cardDecoration, child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))])), Switch.adaptive(value: value, activeColor: AppTheme.primaryColor, onChanged: onChanged)]));
  Widget _privacyNote() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.softPurple, borderRadius: BorderRadius.circular(17)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryColor, size: 19), const SizedBox(width: 9), Expanded(child: Text('لن نرسل أي رسالة إلا عند وجود تحديث مرتبط بكفالاتك أو دفعاتك. يمكنك إيقاف أي قناة في أي وقت.', style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 10, height: 1.7)))]));
  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: GoogleFonts.cairo()), behavior: SnackBarBehavior.floating));
}

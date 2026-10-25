import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/notification_service.dart';
import '../../../theme/app_theme.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});
  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  List<_DonorNotification> _notifications = [
    _DonorNotification('demo-report', 'تقرير جديد عن أحمد محمد', 'تقدم دراسي وصحي جديد متاح للمراجعة.', 'منذ يومين', Icons.description_rounded, AppTheme.primaryColor, true),
    _DonorNotification('demo-update', 'تحديث من جمعية كافل اليتيم', 'تمت إضافة صور من النشاط التعليمي.', 'منذ 8 أيام', Icons.photo_camera_back_rounded, const Color(0xFFC18320), false),
    _DonorNotification('demo-payment', 'تم تسجيل دفعة الكفالة', 'تم تسجيل كفالتك الشهرية بنجاح.', 'منذ 15 يومًا', Icons.check_circle_rounded, AppTheme.successColor, false),
  ];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadRemote(); }

  Future<void> _loadRemote() async {
    try {
      final remote = await NotificationService.instance.fetchInAppNotifications();
      if (remote.isNotEmpty && mounted) setState(() => _notifications = remote.map(_mapRemote).toList());
    } catch (_) {
      // Demo notifications remain visible when the API is not configured.
    }
    if (mounted) setState(() => _loading = false);
  }

  _DonorNotification _mapRemote(InAppNotification item) {
    final report = item.type.contains('report');
    return _DonorNotification(item.id, item.title, item.message, _dateLabel(item.createdAt), report ? Icons.description_rounded : Icons.notifications_active_rounded, report ? AppTheme.primaryColor : AppTheme.successColor, item.unread);
  }

  String _dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((item) => item.unread).length;
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: AppTheme.backgroundColor, appBar: AppBar(backgroundColor: AppTheme.backgroundColor, foregroundColor: AppTheme.textColor, surfaceTintColor: Colors.transparent, elevation: 0, centerTitle: true, title: Text('مركز التنبيهات', style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: _markAllRead, icon: const Icon(Icons.done_all_rounded), tooltip: 'قراءة الكل')]), body: ListView(padding: const EdgeInsets.fromLTRB(20, 5, 20, 30), children: [_header(unread), const SizedBox(height: 17), if (_loading) const LinearProgressIndicator(color: AppTheme.primaryColor, minHeight: 2), ..._notifications.map(_notificationTile), const SizedBox(height: 15), InkWell(onTap: () => Navigator.pushNamed(context, '/notification-settings'), borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(15), decoration: AppTheme.cardDecoration, child: Row(children: [Container(width: 39, height: 39, decoration: BoxDecoration(color: AppTheme.softPurple, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.tune_rounded, color: AppTheme.primaryColor, size: 19)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('إعدادات التنبيهات', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w700, fontSize: 12)), Text('اختاري كيف تريدين استلام تقارير الكفالة', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 9))])), const Icon(Icons.chevron_left_rounded, color: AppTheme.subtitleColor)]))) ]));
  }

  Widget _header(int unread) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(21)), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_active_rounded, color: AppTheme.secondaryColor)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(unread == 0 ? 'كل التنبيهات مقروءة' : 'لديك تنبيهات جديدة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)), Text(unread == 0 ? 'سنبقيك على اطلاع بأثر كفالتك' : '$unread تقرير يحتاج إلى مراجعتك', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10))]))]));
  Widget _notificationTile(_DonorNotification item) => InkWell(onTap: () => _markRead(item), borderRadius: BorderRadius.circular(18), child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: item.unread ? AppTheme.softPurple : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: item.unread ? AppTheme.primaryColor.withOpacity(.16) : const Color(0xFFE9E8F2))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: item.color.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(item.icon, color: item.color, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(item.title, overflow: TextOverflow.ellipsis, style: GoogleFonts.cairo(color: AppTheme.textColor, fontSize: 11, fontWeight: FontWeight.w800)), if (item.unread) ...[const SizedBox(width: 5), Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle))]]), const SizedBox(height: 3), Text(item.message, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 9))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(item.date, style: GoogleFonts.cairo(color: AppTheme.subtitleColor, fontSize: 8)), const SizedBox(height: 4), const Icon(Icons.chevron_left_rounded, color: AppTheme.subtitleColor, size: 17)])])));

  Future<void> _markRead(_DonorNotification item) async { if (!item.unread) return; setState(() => item.unread = false); if (!item.id.startsWith('demo-')) { try { await NotificationService.instance.markAsRead(item.id); } catch (_) {} } }
  Future<void> _markAllRead() async { setState(() { for (final item in _notifications) item.unread = false; }); try { await NotificationService.instance.markAllAsRead(); } catch (_) {} }
}

class _DonorNotification { final String id, title, message, date; final IconData icon; final Color color; bool unread; _DonorNotification(this.id, this.title, this.message, this.date, this.icon, this.color, this.unread); }

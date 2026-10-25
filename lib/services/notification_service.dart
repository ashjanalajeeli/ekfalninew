import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class NotificationPreferences {
  final bool emailReports;
  final bool pushReports;
  final String emailAddress;

  const NotificationPreferences({
    this.emailReports = true,
    this.pushReports = true,
    this.emailAddress = '',
  });

  NotificationPreferences copyWith({bool? emailReports, bool? pushReports, String? emailAddress}) => NotificationPreferences(
        emailReports: emailReports ?? this.emailReports,
        pushReports: pushReports ?? this.pushReports,
        emailAddress: emailAddress ?? this.emailAddress,
      );

  Map<String, dynamic> toJson() => {'emailReports': emailReports, 'pushReports': pushReports, 'emailAddress': emailAddress};
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _emailKey = 'notify_email_reports';
  static const _pushKey = 'notify_push_reports';
  static const _addressKey = 'notify_email_address';

  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      emailReports: prefs.getBool(_emailKey) ?? true,
      pushReports: prefs.getBool(_pushKey) ?? true,
      emailAddress: prefs.getString(_addressKey) ?? '',
    );
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    final local = await SharedPreferences.getInstance();
    await local.setBool(_emailKey, preferences.emailReports);
    await local.setBool(_pushKey, preferences.pushReports);
    await local.setString(_addressKey, preferences.emailAddress.trim());

    // The backend can use these values to send report.created notifications.
    // Keep the app usable when the API is not configured yet.
    try {
      await ApiService.instance.put('/notifications/preferences', data: preferences.toJson());
    } catch (_) {
      // Local preferences remain the source of truth until the backend is available.
    }
  }

  Future<void> registerPushToken(String token) async {
    try {
      await ApiService.instance.post('/notifications/device-token', data: {'token': token, 'platform': 'mobile'});
    } catch (_) {
      // FCM/APNs registration can be retried after the backend is configured.
    }
  }

  Future<List<InAppNotification>> fetchInAppNotifications() async {
    final response = await ApiService.instance.get('/notifications');
    final items = (response.data['notifications'] as List<dynamic>? ?? const []);
    return items.map((item) => InAppNotification.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead(String id) async {
    await ApiService.instance.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await ApiService.instance.post('/notifications/read-all');
  }
}

class InAppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool unread;

  const InAppNotification({required this.id, required this.type, required this.title, required this.message, required this.createdAt, required this.unread});

  factory InAppNotification.fromJson(Map<String, dynamic> json) => InAppNotification(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'general',
        title: json['title'] as String? ?? 'تنبيه جديد',
        message: json['message'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        unread: json['read_at'] == null,
      );
}

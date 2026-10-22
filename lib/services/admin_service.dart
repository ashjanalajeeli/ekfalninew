import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'api_service.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  final ApiService _api = ApiService.instance;

  Future<User> requireAdmin() async {
    final user = await AuthRepository().getProfile();
    if (!user.isAdmin) {
      throw const AdminAccessException('هذه الصفحة متاحة للمشرفين فقط');
    }
    return user;
  }

  Future<List<Map<String, dynamic>>> getPendingReports() async {
    await requireAdmin();
    final response = await _api.get(ApiConfig.adminReports);
    final data = response.data;
    if (data is Map && data['reports'] is List) {
      return List<Map<String, dynamic>>.from(data['reports']);
    }
    return const [];
  }

  Future<void> reviewReport({required String reportId, required bool approve, String? notes}) async {
    await requireAdmin();
    await _api.post('${ApiConfig.approveAdminReport}/$reportId/approve', data: {
      'decision': approve ? 'approved' : 'changes_requested',
      'notes': notes,
    });
  }

  Future<bool> openExport({required String report, required String format}) async {
    await requireAdmin();
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.adminExports}/$report?format=$format');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class AdminAccessException implements Exception {
  final String message;
  const AdminAccessException(this.message);
  @override
  String toString() => message;
}

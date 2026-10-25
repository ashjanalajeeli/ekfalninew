import '../config/api_config.dart';
import 'api_service.dart';

class CharityService {
  CharityService._();
  static final CharityService instance = CharityService._();
  final ApiService _api = ApiService.instance;

  Future<List<Map<String, dynamic>>> listCharities() async {
    final response = await _api.get(ApiConfig.charities, requiresAuth: false);
    return List<Map<String, dynamic>>.from(response.data['charities'] as List? ?? const []);
  }

  Future<Map<String, dynamic>> createSponsorshipRequest({required String orphanId, required double monthlyAmount, String? notes}) async {
    final response = await _api.post(ApiConfig.sponsorshipRequests, data: {'orphanId': orphanId, 'monthlyAmount': monthlyAmount, 'notes': notes});
    return Map<String, dynamic>.from(response.data['request'] as Map);
  }

  Future<List<Map<String, dynamic>>> mySponsorshipRequests() async {
    final response = await _api.get('${ApiConfig.sponsorshipRequests}/my');
    return List<Map<String, dynamic>>.from(response.data['requests'] as List? ?? const []);
  }

  Future<Map<String, dynamic>> createDonation({required double amount, required String category, required String paymentMethod, String? sponsorshipId, String? projectId}) async {
    final response = await _api.post(ApiConfig.donations, data: {'amount': amount, 'currency': 'SAR', 'category': category, 'paymentMethod': paymentMethod, 'sponsorshipId': sponsorshipId, 'projectId': projectId});
    return Map<String, dynamic>.from(response.data['donation'] as Map);
  }

  Future<Map<String, dynamic>> createPaymentIntent(String donationId) async {
    final response = await _api.post('${ApiConfig.donations}/$donationId/payment-intent');
    return Map<String, dynamic>.from(response.data['payment'] as Map);
  }

  Future<Map<String, dynamic>> createOrphanCase({required String orphanId, required String charityId, required String title, required String description}) async {
    final response = await _api.post(ApiConfig.charityCases, data: {'orphanId': orphanId, 'charityId': charityId, 'title': title, 'description': description});
    return Map<String, dynamic>.from(response.data['case'] as Map);
  }
}

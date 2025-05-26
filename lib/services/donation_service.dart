import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/services/base_api_service.dart';
import '../models/donation_model.dart';

class DonationService extends BaseApiService {
  Future<List<Donation>> getAllDonations() async {
    try {
      final response = await get(ApiConstants.donations);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Donation.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<List<Donation>> getMyDonations() async {
    try {
      final response = await get('${ApiConstants.users}/donations');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Donation.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<List<String>> getDonationCategories() async {
    try {
      final response = await get('${ApiConstants.donations}/categories');
      final List<dynamic> data = response.data['data'];
      return data.map((category) => category.toString()).toList();
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDonationStatistics() async {
    try {
      final response = await get('${ApiConstants.donations}/statistics');
      return response.data['data'];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<Donation> createDonation(Map<String, dynamic> donationData) async {
    try {
      final response = await post(
        ApiConstants.donations,
        data: donationData,
      );
      return Donation.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<void> updateDonationStatus(String donationId, String status) async {
    try {
      await put(
        '${ApiConstants.donations}/$donationId/status',
        data: {'status': status},
      );
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<String> createPaymentIntent(String donationId, String paymentMethod) async {
    try {
      final response = await post(
        '${ApiConstants.donations}/$donationId/payment',
        data: {
          'paymentMethod': paymentMethod,
        },
      );
      return response.data['clientSecret'];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<void> verifyPayment(String donationId, String paymentIntentId) async {
    try {
      await post(
        '${ApiConstants.donations}/$donationId/verify',
        data: {
          'paymentIntentId': paymentIntentId,
        },
      );
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        return Exception('Authentication required');
      case 403:
        return Exception('Access denied');
      case 404:
        return Exception('Donation not found');
      case 409:
        return Exception('Donation already exists');
      default:
        return Exception(error.response?.data?['message'] ?? 'An error occurred');
    }
  }

  getDonationsByUser(String userId) {}
} 
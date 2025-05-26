import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'base_api_service.dart';

class SponsorService extends BaseApiService {
  SponsorService(String? token);

  Future<List<Map<String, dynamic>>> getOrphans({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await get(
        ApiConstants.orphans,
        queryParameters: filters,
      );
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrphanDetails(String orphanId) async {
    try {
      final response = await get('${ApiConstants.orphans}/$orphanId');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSponsorship({
    required String orphanId,
    required double amount,
    required String frequency, // 'monthly', 'quarterly', 'yearly'
    String? notes, required int duration,
  }) async {
    try {
      final response = await post(
        '${ApiConstants.orphans}/$orphanId/sponsor',
        data: {
          'amount': amount,
          'frequency': frequency,
          if (notes != null) 'notes': notes,
        },
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserSponsorships() async {
    try {
      final response = await get('${ApiConstants.users}/sponsorships');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<void> cancelSponsorship(String sponsorshipId) async {
    try {
      await delete('${ApiConstants.users}/sponsorships/$sponsorshipId');
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSponsorship({
    required String sponsorshipId,
    double? amount,
    String? frequency,
    String? notes,
  }) async {
    try {
      final response = await put(
        '${ApiConstants.users}/sponsorships/$sponsorshipId',
        data: {
          if (amount != null) 'amount': amount,
          if (frequency != null) 'frequency': frequency,
          if (notes != null) 'notes': notes,
        },
      );
      return response.data;
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
        return Exception('Orphan or sponsorship not found');
      case 409:
        return Exception('Sponsorship already exists');
      default:
        return Exception(error.response?.data?['message'] ?? 'An error occurred');
    }
  }

  getAvailableOrphans() {}

  getSponsorshipById(String id) {}

  renewSponsorship({required sponsorshipId, required double amount, required int duration, required String frequency}) {}
} 
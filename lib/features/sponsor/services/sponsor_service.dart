import 'package:dio/dio.dart';
import '../../../core/services/base_api_service.dart';
import '../../../core/constants/api_constants.dart';

class SponsorService extends BaseApiService {
  final String? token;

  SponsorService(this.token);

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final mergedOptions = (options ?? Options()).copyWith(
      headers: {
        ...?options?.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return super.get<T>(
      path,
      queryParameters: queryParameters,
      options: mergedOptions,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final mergedOptions = (options ?? Options()).copyWith(
      headers: {
        ...?options?.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return super.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: mergedOptions,
    );
  }

  Future<List<Map<String, dynamic>>> getAllSponsors() async {
    try {
      final response = await get<List<dynamic>>(ApiConstants.orphans);
      return (response.data ?? []).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSponsorship({
    required String orphanId,
    required int duration,
    required double amount,
    String? notes,
  }) async {
    try {
      final response = await post<Map<String, dynamic>>(
        '${ApiConstants.orphans}/sponsor',
        data: {
          'orphanId': orphanId,
          'duration': duration,
          'amount': amount,
          if (notes != null) 'notes': notes,
        },
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserSponsorships() async {
    try {
      final response = await get<List<dynamic>>(
        '${ApiConstants.orphans}/user-sponsorships',
      );
      return (response.data ?? []).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSponsorshipById(String id) async {
    try {
      final response = await get<Map<String, dynamic>>(
        '${ApiConstants.orphans}/sponsorship/$id',
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableOrphans() async {
    try {
      final response = await get<List<dynamic>>(
        '${ApiConstants.orphans}/available',
      );
      return (response.data ?? []).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }
} 
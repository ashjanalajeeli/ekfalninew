import 'package:dio/dio.dart';
import '../../../core/services/base_api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DonationService extends BaseApiService {
  final String? token;

  DonationService(this.token);

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

  Future<List<Map<String, dynamic>>> getAllDonations() async {
    try {
      final response = await get<List<dynamic>>(ApiConstants.donations);
      return (response.data ?? []).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createDonation({
    required double amount,
    required String campaignId,
    String? description,
    String? type, // 'financial' or 'in-kind'
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await post<Map<String, dynamic>>(
        ApiConstants.donations,
        data: {
          'amount': amount,
          'campaignId': campaignId,
          if (description != null) 'description': description,
          if (type != null) 'type': type,
          if (additionalData != null) ...additionalData,
        },
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDonationById(String id) async {
    try {
      final response = await get<Map<String, dynamic>>(
        '${ApiConstants.donations}/$id',
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserDonations() async {
    try {
      final response = await get<List<dynamic>>(
        '${ApiConstants.donations}/user',
      );
      return (response.data ?? []).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createInKindDonation({
    required String type,
    required String description,
    String? estimatedValue,
    String? campaignId,
  }) async {
    return createDonation(
      amount: 0,
      campaignId: campaignId ?? '',
      type: 'in-kind',
      description: description,
      additionalData: {
        'inKindType': type,
        if (estimatedValue != null) 'estimatedValue': estimatedValue,
      },
    );
  }

  getMyDonations() {}

  updateDonationStatus(String donationId, String status) {}
} 
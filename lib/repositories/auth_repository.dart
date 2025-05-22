import 'dart:convert'; // لإستخدام jsonEncode و jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class AuthRepository {
  static const String _userKey = 'user_data';
  final ApiService _apiService = ApiService.instance;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String fullName,
  }) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      password: password,
      fullName: fullName,
    );

    // تخزين بيانات المستخدم بصيغة JSON
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.profile);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  ApiException _handleAuthError(DioException error) {
    if (error.response?.statusCode == 401) {
      return ApiException(
        message: 'Invalid credentials',
        statusCode: 401,
        data: error.response?.data,
      );
    }
    if (error.response?.statusCode == 422) {
      return ApiException(
        message: 'Validation error',
        statusCode: 422,
        data: error.response?.data,
      );
    }
    throw error;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {

  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImage,
  }) async {

  }
}

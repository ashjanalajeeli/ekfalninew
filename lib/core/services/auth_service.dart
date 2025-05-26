import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekfalninew/core/constants/api_constants.dart';
import 'base_api_service.dart';

class AuthService extends BaseApiService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      await _saveAuthData(response.data);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null) 'phone': phone,
        },
      );
      
      await _saveAuthData(response.data);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign In cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await post(
        '${ApiConstants.login}/google',
        data: {
          'token': googleAuth.idToken,
        },
      );
      
      await _saveAuthData(response.data);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await _googleSignIn.signOut();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return Map<String, dynamic>.from(
        const JsonDecoder().convert(userStr),
      );
    }
    return null;
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, data['token']);
    await prefs.setString(_userKey, const JsonEncoder().convert(data['user']));
  }

  Exception _handleDioError(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        return Exception('Invalid credentials');
      case 403:
        return Exception('Access denied');
      case 404:
        return Exception('Resource not found');
      default:
        return Exception(error.response?.data?['message'] ?? 'An error occurred');
    }
  }
}
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/base_api_service.dart';
import '../../../core/constants/api_constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends BaseApiService {
  static const String tokenKey = 'jwt_token';
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  // Get stored token
  String? getToken() {
    return _prefs.getString(tokenKey);
  }

  // Store token
  Future<void> setToken(String token) async {
    await _prefs.setString(tokenKey, token);
  }

  // Clear token
  Future<void> clearToken() async {
    await _prefs.remove(tokenKey);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data!;
      if (data['token'] != null) {
        await setToken(data['token']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final data = response.data!;
      if (data['token'] != null) {
        await setToken(data['token']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google Sign In cancelled';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final response = await post<Map<String, dynamic>>(
        '${ApiConstants.login}/google',
        data: {
          'idToken': googleAuth.idToken,
          'accessToken': googleAuth.accessToken,
        },
      );

      final data = response.data!;
      if (data['token'] != null) {
        await setToken(data['token']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await clearToken();
    } catch (e) {
      rethrow;
    }
  }
}
import 'dart:convert'; // لإستخدام jsonEncode و jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const String _userKey = 'user_data';

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


  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData == null) {
      throw Exception('User not found');
    }
    // يمكن إضافة التحقق من البريد وكلمة المرور هنا
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

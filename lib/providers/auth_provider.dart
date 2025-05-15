import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    return _getUser();
  }

  Future<User?> _getUser() async {
    final authRepository = AuthRepository();
    return authRepository.getCurrentUser();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = AuthRepository();
      await authRepository.signIn(email: email, password: password);
      return _getUser();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String fullName,
    String? profileImage,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = AuthRepository();
      await authRepository.signUp(
        email: email,
        password: password,
        name: name,
        fullName: fullName,


      );
      return _getUser();
    });
  }




  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImage,
  }) async {
    final authRepository = AuthRepository();
    await authRepository.updateProfile(
      name: name,
      email: email,
      profileImage: profileImage,
    );
    // إعادة تحميل بيانات المستخدم المحدثة
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getUser();
    });
  }


  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final authRepository = AuthRepository();
    await authRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }


  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = AuthRepository();
      await authRepository.signOut();
      return null;
    });
  }
} 
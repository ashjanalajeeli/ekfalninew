import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      await authRepository.login(email: email, password: password);
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

/*
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(AuthRepository());
});
*/

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // ... existing methods ...
} 

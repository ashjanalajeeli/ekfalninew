import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

// SharedPreferences provider
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

// Service provider
@riverpod
AuthService authService(AuthServiceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) throw Exception('SharedPreferences not initialized');
  return AuthService(prefs);
}

// Auth state
@immutable
class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? error;
  final bool isLoading;
  final String? token;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isLoading = false,
    this.token,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    String? error,
    bool? isLoading,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
    );
  }
}

// Auth notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _initializeAuth();
    return const AuthState();
  }

  Future<void> _initializeAuth() async {
    final authService = ref.read(authServiceProvider);
    final token = authService.getToken();
    if (token != null) {
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
      );
      // Optionally fetch user profile here
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password);
      
      state = state.copyWith(
        isAuthenticated: true,
        user: response,
        token: response['token'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.register(
        email: email,
        password: password,
        name: name,
      );
      
      state = state.copyWith(
        isAuthenticated: true,
        user: response,
        token: response['token'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithGoogle();
      
      state = state.copyWith(
        isAuthenticated: true,
        user: response,
        token: response['token'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network/dio_client.dart';
import 'services/auth_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Create instances of services
    final authService = AuthService();

    // Initialize DioClient with AuthService for token management
    DioClient.initialize(authService);

    // Initialize other services if needed
  }
} 
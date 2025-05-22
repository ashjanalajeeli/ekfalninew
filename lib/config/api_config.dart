class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api'; // Change this to your actual API base URL
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';
  
  // Add more endpoints as needed
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
} 
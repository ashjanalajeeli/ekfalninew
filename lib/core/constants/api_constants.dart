class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000'; // For Android Emulator, use localhost for web
  
  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  
  // User endpoints
  static const String users = '/api/users';
  static const String profile = '/api/users/profile';
  
  // Donation endpoints
  static const String donations = '/api/donations';
  
  // Orphanage endpoints
  static const String orphanages = '/api/orphanages';
  
  // Orphan endpoints
  static const String orphans = '/api/orphans';
  
  // Campaign endpoints
  static const String campaigns = '/api/campaigns';
  
  // Cart endpoints
  static const String cart = '/api/cart';
} 
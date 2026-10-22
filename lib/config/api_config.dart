class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';

  // Donation endpoints
  static const String donations = '/donations';
  static const String myDonations = '/donations/my';
  static const String donationCategories = '/donations/categories';
  static const String donationStatistics = '/donations/statistics';

  // Sponsorship endpoints
  static const String sponsorships = '/sponsorships';
  static const String mySponsors = '/sponsorships/my';
  static const String orphans = '/orphans';
  static const String orphanDetails = '/orphans/details';
  static const String sponsorshipReportPdf = '/sponsorship-reports';

  // Admin and reporting endpoints
  static const String adminOrphans = '/admin/orphans';
  static const String adminReports = '/admin/sponsorship-reports';
  static const String approveAdminReport = '/admin/sponsorship-reports';
  static const String adminExports = '/admin/exports';

  // Payment endpoints
  static const String createPayment = '/payments/create';
  static const String verifyPayment = '/payments/verify';
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

import '../../Flavors/config/flavor_config.dart';

/// API constants for the application.
/// Base URL comes from [FlavorConfig] (dev/prod set at startup).
class ApiConstants {
  /// Current base URL from active flavor (dev or prod).
  static String get baseUrl => FlavorConfig.instance.baseUrl;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String checkEmail = '/auth/check-email';

  // Auth API v3 (base path /api/v3/auth)
  static const String authV3 = '/api/v3/auth';
  static String get authV3CreateAccount => '$baseUrl$authV3/createAccount';
  static String authV3SendOtp(int accountId) =>
      '$baseUrl/$authV3/sendOtp/$accountId';
  static String authV3VerifyOtp(int accountId) =>
      '$baseUrl/$authV3/verifyOtp/$accountId';
  static String get authV3Login => '$baseUrl/api/v3/auth/login';
  static String get authV3PasswordReset =>
      '$baseUrl/api/v3/auth/password-reset';
  /// Lookup account by phone; returns { accountId } or 404.
  static String get authV3LookupByPhone =>
      '$baseUrl/api/v3/auth/lookupByPhone';

  // User endpoints
  static const String getUserProfile = '/user/profile';
  static const String updateUserProfile = '/user/profile';
  static const String deleteAccount = '/user/delete';

  // LiveKit endpoints
  static const String getLiveKitToken = '/livekit/token';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}

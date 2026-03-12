/// API constants for the application
/// All API endpoints should be defined here
class ApiConstants {
  // Base URL - Replace with your actual API base URL
  static const String baseUrl = 'https://openmic-staging-backend-744913677085.us-central1.run.app';

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
  static String authV3SendOtp(int accountId) => '$baseUrl/$authV3/sendOtp/$accountId';
  static String authV3VerifyOtp(int accountId) => '$baseUrl/$authV3/verifyOtp/$accountId';
  static const String authV3Login = '$baseUrl/api/v3/auth/login';
  static const String authV3PasswordReset = '$baseUrl/api/v3/auth/password-reset';
  /// Lookup account by phone; returns { accountId } or 404. Adjust path if your backend differs.
  static const String authV3LookupByPhone = '$baseUrl/api/v3/auth/lookupByPhone';

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

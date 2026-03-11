/// API constants for the application
/// All API endpoints should be defined here
class ApiConstants {
  // Base URL - Replace with your actual API base URL
  static const String baseUrl = 'https://api.example.com/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String checkEmail = '/auth/check-email';

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

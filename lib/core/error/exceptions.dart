/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Cache exception
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Thrown when login returns 403 PHONE_NOT_VERIFIED; [accountId] is used to resume OTP flow.
class PhoneNotVerifiedException extends AuthException {
  final int accountId;

  const PhoneNotVerifiedException(super.message, {required this.accountId})
      : super(code: 'PHONE_NOT_VERIFIED');
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// LiveKit exception (renamed to avoid conflict with livekit_client package)
class AppLiveKitException extends AppException {
  const AppLiveKitException(super.message, {super.code});
}

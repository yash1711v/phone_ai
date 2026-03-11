import 'package:equatable/equatable.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login with email event
class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Signup with email event
class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Login with Google event
class LoginWithGoogleEvent extends AuthEvent {
  const LoginWithGoogleEvent();
}

/// Login with Apple event
class LoginWithAppleEvent extends AuthEvent {
  const LoginWithAppleEvent();
}

/// Check email event
class CheckEmailEvent extends AuthEvent {
  final String email;

  const CheckEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Send OTP event
class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const SendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify OTP event
class VerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;
  final String? verificationId;

  const VerifyOtpEvent({
    required this.phoneNumber,
    required this.otp,
    this.verificationId,
  });

  @override
  List<Object?> get props => [phoneNumber, otp, verificationId];
}

/// Sign out event
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Get current user event
class GetCurrentUserEvent extends AuthEvent {
  const GetCurrentUserEvent();
}

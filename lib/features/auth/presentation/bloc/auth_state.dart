import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Email check state
class EmailCheckState extends AuthState {
  final bool isRegistered;
  final String email;

  const EmailCheckState({
    required this.isRegistered,
    required this.email,
  });

  @override
  List<Object?> get props => [isRegistered, email];
}

/// OTP sent state
class OtpSentState extends AuthState {
  final String phoneNumber;
  final String verificationId;

  const OtpSentState({
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  List<Object?> get props => [phoneNumber, verificationId];
}

/// OTP verification state
class OtpVerificationState extends AuthState {
  final bool isVerified;

  const OtpVerificationState(this.isVerified);

  @override
  List<Object?> get props => [isVerified];
}

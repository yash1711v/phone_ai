import 'package:equatable/equatable.dart';

import '../../data/models/account_model.dart';

/// Auth cubit states (Equatable for clear state comparison)
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Account found by phone; proceed to send OTP
class AuthPhoneLookupSuccess extends AuthState {
  final int accountId;

  const AuthPhoneLookupSuccess(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// No account for this phone; show create-account flow
class AuthAccountNotFound extends AuthState {
  const AuthAccountNotFound();
}

/// OTP sent to masked phone
class AuthOtpSent extends AuthState {
  final int accountId;
  final String maskedPhone;

  const AuthOtpSent({required this.accountId, required this.maskedPhone});

  @override
  List<Object?> get props => [accountId, maskedPhone];
}

/// OTP verified; caller should then call login with idToken
class AuthOtpVerified extends AuthState {
  final int accountId;

  const AuthOtpVerified(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Logged in with v3 account (persist and redirect to home or onboarding)
class AuthAuthenticated extends AuthState {
  final AccountModel account;
  /// When true, user just completed signup and should see onboarding before home.
  final bool needsOnboarding;

  const AuthAuthenticated(this.account, {this.needsOnboarding = false});

  @override
  List<Object?> get props => [account, needsOnboarding];
}

/// Login returned 403 PHONE_NOT_VERIFIED; resume OTP flow with [accountId]
class AuthPhoneNotVerified extends AuthState {
  final int accountId;

  const AuthPhoneNotVerified(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Create-account form should be shown
class AuthCreateAccountForm extends AuthState {
  const AuthCreateAccountForm();
}

/// Account created; [accountId] is used to send OTP and verify phone, then redirect to login.
class AuthAccountCreated extends AuthState {
  final int accountId;

  const AuthAccountCreated(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

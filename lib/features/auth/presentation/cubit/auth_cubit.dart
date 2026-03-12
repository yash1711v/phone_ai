import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';

import 'auth_state.dart';

/// Auth cubit for v3 auth flow: phone lookup → OTP → login, or create account.
/// Uses [AuthRepository] and [Equatable] states for loading/error handling.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  /// Call on app start to restore session. Emits [AuthAuthenticated] if cached account exists.
  Future<void> checkLoggedIn() async {
    final account = await _repository.getCachedAccount();
    if (account != null) {
      emit(AuthAuthenticated(account));
    } else {
      emit(const AuthInitial());
    }
  }

  /// Lookup account by phone. Emits [AuthPhoneLookupSuccess], [AuthAccountNotFound], or [AuthError].
  Future<void> lookupByPhone(String phoneNumber, String recaptchaToken) async {
    emit(const AuthLoading());
    final result = await _repository.lookupByPhone(phoneNumber);
    result.fold(
      (failure) {
        if (failure.code == 'NOT_FOUND') {
          emit(const AuthAccountNotFound());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (accountId) => emit(AuthPhoneLookupSuccess(accountId)),
    );
  }

  /// Lookup by phone then send OTP with the same [recaptchaToken]. One token for both steps.
  /// Emits [AuthOtpSent], [AuthAccountNotFound], or [AuthError].
  Future<void> requestOtp(String phoneNumber, String recaptchaToken) async {
    emit(const AuthLoading());
    final lookupResult = await _repository.lookupByPhone(phoneNumber);
    await lookupResult.fold(
      (failure) async {
        if (failure.code == 'NOT_FOUND') {
          emit(const AuthAccountNotFound());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (accountId) async {
        final sendResult = await _repository.sendOtpV3(accountId, recaptchaToken);
        sendResult.fold(
          (f) => emit(AuthError(f.message)),
          (maskedPhone) => emit(AuthOtpSent(accountId: accountId, maskedPhone: maskedPhone)),
        );
      },
    );
  }

  /// Send OTP to [accountId]. Emits [AuthOtpSent] or [AuthError].
  Future<void> sendOtp(int accountId, String recaptchaToken) async {
    emit(const AuthLoading());
    final result = await _repository.sendOtpV3(accountId, recaptchaToken);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (maskedPhone) => emit(AuthOtpSent(accountId: accountId, maskedPhone: maskedPhone)),
    );
  }

  /// Verify OTP. Emits [AuthOtpVerified] or [AuthError]. Caller must then call [loginWithIdToken].
  Future<void> verifyOtp(int accountId, String otp) async {
    emit(const AuthLoading());
    final result = await _repository.verifyOtpV3(accountId, otp);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpVerified(accountId)),
    );
  }

  /// Login with Firebase idToken. Persists account and emits [AuthAuthenticated], or [AuthPhoneNotVerified], or [AuthError].
  Future<void> loginWithIdToken(String idToken) async {
    emit(const AuthLoading());
    final result = await _repository.loginV3(idToken);
    await result.fold(
      (failure) async {
        if (failure is PhoneNotVerifiedFailure) {
          emit(AuthPhoneNotVerified(failure.accountId));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (account) async {
        await _repository.cacheLoggedInAccount(account);
        emit(AuthAuthenticated(account));
      },
    );
  }

  /// Create account (v3). Call after Firebase sign-up. Emits success with no payload; UI should then send OTP, verify, then redirect to login.
  Future<void> createAccount({
    required String name,
    required String email,
    required String phoneNumber,
    required String idToken,
    required String recaptchaToken,
    String? inviteToken,
  }) async {
    emit(const AuthLoading());
    final result = await _repository.createAccountV3(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      idToken: idToken,
      recaptchaToken: recaptchaToken,
      inviteToken: inviteToken,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (account) => emit(AuthAccountCreated(account.id)),
    );
  }

  /// Clear session and emit initial (or error).
  Future<void> signOut() async {
    final result = await _repository.signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthInitial()),
    );
  }
}

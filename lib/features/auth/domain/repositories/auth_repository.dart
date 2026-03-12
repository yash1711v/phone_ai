import '../entities/user.dart';
import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../data/models/account_model.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Lookup account by phone. Returns accountId if found.
  /// Left with code NOT_FOUND when account does not exist.
  Future<Either<Failure, int>> lookupByPhone(String phoneNumber);

  /// Send OTP (v3) to account. Requires recaptchaToken.
  Future<Either<Failure, String>> sendOtpV3(int accountId, String recaptchaToken);

  /// Verify OTP (v3).
  Future<Either<Failure, void>> verifyOtpV3(int accountId, String otp);

  /// Create account (v3). Requires idToken and recaptchaToken.
  Future<Either<Failure, AccountModel>> createAccountV3({
    required String name,
    required String email,
    required String phoneNumber,
    required String idToken,
    required String recaptchaToken,
    String? inviteToken,
  });

  /// Login (v3). Returns account with organizations.
  Future<Either<Failure, AccountModel>> loginV3(String idToken);

  /// Get cached v3 account (if logged in).
  Future<AccountModel?> getCachedAccount();

  /// Persist account as logged in (after successful login v3).
  Future<void> cacheLoggedInAccount(AccountModel account);

  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<Failure, User>> signInWithApple();

  /// Check if email is registered
  Future<Either<Failure, bool>> checkEmailRegistered(String email);

  /// Send OTP to phone number
  Future<Either<Failure, String>> sendOtpToPhone(String phoneNumber);

  /// Verify OTP
  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? verificationId,
  });

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Refresh token
  Future<Either<Failure, void>> refreshToken();
}

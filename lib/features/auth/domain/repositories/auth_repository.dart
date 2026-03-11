import '../entities/user.dart';
import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Auth repository interface
abstract class AuthRepository {
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

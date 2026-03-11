import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Verify OTP use case
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  /// Verify OTP
  /// 
  /// [phoneNumber] - Phone number
  /// [otp] - OTP code to verify
  /// [verificationId] - Optional verification ID from send OTP
  /// Returns [User] on success or [Failure] on error
  Future<Either<Failure, User>> call({
    required String phoneNumber,
    required String otp,
    String? verificationId,
  }) async {
    return await repository.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
      verificationId: verificationId,
    );
  }
}

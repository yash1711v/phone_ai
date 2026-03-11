import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Send OTP use case
class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  /// Send OTP to phone number
  /// 
  /// [phoneNumber] - Phone number to send OTP to
  /// Returns [String] verification ID on success
  Future<Either<Failure, String>> call(String phoneNumber) async {
    return await repository.sendOtpToPhone(phoneNumber);
  }
}

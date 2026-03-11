import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Check email use case
class CheckEmailUseCase {
  final AuthRepository repository;

  CheckEmailUseCase(this.repository);

  /// Check if email is registered
  /// 
  /// [email] - Email address to check
  /// Returns [bool] indicating if email is registered
  Future<Either<Failure, bool>> call(String email) async {
    return await repository.checkEmailRegistered(email);
  }
}

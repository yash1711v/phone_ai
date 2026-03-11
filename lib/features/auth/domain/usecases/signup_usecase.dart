import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Signup use case
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  /// Execute signup with email and password
  /// 
  /// [email] - User email address
  /// [password] - User password
  /// [displayName] - Optional display name
  /// Returns [User] on success or [Failure] on error
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

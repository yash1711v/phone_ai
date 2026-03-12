import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_ds.dart';
import '../datasources/auth_remote_ds.dart';
import '../models/account_model.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, int>> lookupByPhone(String phoneNumber) async {
    try {
      final accountId = await remoteDataSource.lookupByPhone(phoneNumber);
      return Right(accountId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendOtpV3(int accountId, String recaptchaToken) async {
    try {
      final maskedPhone = await remoteDataSource.sendOtpV3(accountId, recaptchaToken);
      return Right(maskedPhone);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtpV3(int accountId, String otp) async {
    try {
      await remoteDataSource.verifyOtpV3(accountId, otp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> createAccountV3({
    required String name,
    required String email,
    required String phoneNumber,
    required String idToken,
    required String recaptchaToken,
    String? inviteToken,
  }) async {
    try {
      final account = await remoteDataSource.createAccountV3(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        idToken: idToken,
        recaptchaToken: recaptchaToken,
        inviteToken: inviteToken,
      );
      debugPrint("Account created: $account");
      return Right(account);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> loginV3(String idToken) async {
    try {
      final account = await remoteDataSource.loginV3(idToken);
      return Right(account);
    } on PhoneNotVerifiedException catch (e) {
      return Left(PhoneNotVerifiedFailure(e.message, accountId: e.accountId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<AccountModel?> getCachedAccount() async {
    return localDataSource.getCachedAccount();
  }

  @override
  Future<void> cacheLoggedInAccount(AccountModel account) async {
    await localDataSource.cacheAccountAndSetLoggedIn(account);
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final user = await remoteDataSource.signInWithApple();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailRegistered(String email) async {
    try {
      final isRegistered = await remoteDataSource.checkEmailRegistered(email);
      return Right(isRegistered);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendOtpToPhone(String phoneNumber) async {
    try {
      final verificationId = await remoteDataSource.sendOtpToPhone(phoneNumber);
      return Right(verificationId);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? verificationId,
  }) async {
    try {
      final user = await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
        verificationId: verificationId,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      await remoteDataSource.refreshToken();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_email_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../shared/services/analytics_service.dart';

/// Auth bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final CheckEmailUseCase checkEmailUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final AuthRepository authRepository;
  final AnalyticsService analyticsService;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.checkEmailUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.authRepository,
    required this.analyticsService,
  }) : super(const AuthInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LoginWithAppleEvent>(_onLoginWithApple);
    on<CheckEmailEvent>(_onCheckEmail);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SignOutEvent>(_onSignOut);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        analyticsService.logLogin(loginMethod: 'email');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signUpUseCase(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        analyticsService.logSignUp(signUpMethod: 'email');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.signInWithGoogle();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        analyticsService.logLogin(loginMethod: 'google');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginWithApple(
    LoginWithAppleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.signInWithApple();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        analyticsService.logLogin(loginMethod: 'apple');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onCheckEmail(
    CheckEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await checkEmailUseCase(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (isRegistered) => emit(EmailCheckState(
        isRegistered: isRegistered,
        email: event.email,
      )),
    );
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await sendOtpUseCase(event.phoneNumber);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (verificationId) => emit(OtpSentState(
        phoneNumber: event.phoneNumber,
        verificationId: verificationId,
      )),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await verifyOtpUseCase(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
      verificationId: event.verificationId,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        analyticsService.logLogin(loginMethod: 'phone');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }
}

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_interceptor.dart';
import '../core/network/network_info.dart';
import '../core/theme/theme_cubit.dart';
import '../core/database/objectbox_service.dart';
import '../shared/services/analytics_service.dart';
import '../shared/services/notification_service.dart';
import '../shared/services/livekit_service.dart';

import '../features/auth/data/datasources/auth_remote_ds.dart';
import '../features/auth/data/datasources/auth_local_ds.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/signup_usecase.dart';
import '../features/auth/domain/usecases/check_email_usecase.dart';
import '../features/auth/domain/usecases/send_otp_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
@InjectableInit()
Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  final firebaseAuth = FirebaseAuth.instance;
  getIt.registerSingleton<FirebaseAuth>(firebaseAuth);

  final firebaseAnalytics = FirebaseAnalytics.instance;
  getIt.registerSingleton<FirebaseAnalytics>(firebaseAnalytics);

  final googleSignIn = GoogleSignIn();
  getIt.registerSingleton<GoogleSignIn>(googleSignIn);

  final connectivity = Connectivity();
  getIt.registerSingleton<Connectivity>(connectivity);

  final internetChecker = InternetConnectionChecker();
  getIt.registerSingleton<InternetConnectionChecker>(internetChecker);

  // Core services
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectionChecker: getIt(),
      connectivity: getIt(),
    ),
  );

  // Dio setup
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.accept,
      },
    ),
  );

  dio.interceptors.addAll([
    AppInterceptor(),
    AuthInterceptor(
      getToken: () async {
        final user = firebaseAuth.currentUser;
        if (user != null) {
          return await user.getIdToken();
        }
        return null;
      },
    ),
  ]);

  getIt.registerSingleton<Dio>(dio);

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Database
  await ObjectBoxService.init();

  // Theme
  getIt.registerFactory<ThemeCubit>(
    () => ThemeCubit(prefs: getIt()),
  );

  // Analytics
  getIt.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(analytics: getIt()),
  );

  // Notification
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  // LiveKit
  getIt.registerLazySingleton<LiveKitService>(
    () => LiveKitService(),
  );

  // Auth data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      googleSignIn: getIt(),
      apiClient: getIt(),
    ),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(prefs: getIt()),
  );

  // Auth repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Auth use cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt()),
  );

  getIt.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(getIt()),
  );

  getIt.registerLazySingleton<CheckEmailUseCase>(
    () => CheckEmailUseCase(getIt()),
  );

  getIt.registerLazySingleton<SendOtpUseCase>(
    () => SendOtpUseCase(getIt()),
  );

  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(getIt()),
  );

  // Auth bloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt(),
      signUpUseCase: getIt(),
      checkEmailUseCase: getIt(),
      sendOtpUseCase: getIt(),
      verifyOtpUseCase: getIt(),
      authRepository: getIt(),
      analyticsService: getIt(),
    ),
  );

  // Auth cubit (v3 flow: phone → OTP → login)
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );
}

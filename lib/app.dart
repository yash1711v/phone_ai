import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import 'core/constants/recaptcha_constants.dart';
import 'core/theme/theme_cubit.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';
import 'core/theme/theme_data.dart';
import 'core/routes/app_router.dart';
import 'di/injection.dart';
import 'shared/widgets/recaptcha_webview_dialog.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'core/utils/logger.dart';
import 'shared/services/notification_service.dart';

/// Main app widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => getIt<ThemeCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const GetCurrentUserEvent()),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..checkLoggedIn(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Openmic',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
            localizationsDelegates: [
              CountryLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Stack(
                children: [
                  BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        context.goNamed('home');
                      }
                    },
                    child: child ?? const SizedBox.shrink(),
                  ),
                  const Positioned(
                    left: -200,
                    top: -200,
                    child: HiddenRecaptchaWebView(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Initialize app services
Future<void> initializeApp() async {
  LogLevel.info('App initialization started');

  WidgetsFlutterBinding.ensureInitialized();
  LogLevel.info('WidgetsFlutterBinding initialized');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  LogLevel.info('Orientation locked');

  LogLevel.info('Initializing Firebase...');
  await Firebase.initializeApp();
  LogLevel.info('Firebase initialized');

  FlutterError.onError = (errorDetails) {
    LogLevel.error('Flutter Error', errorDetails.exception);
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // Don't report reCAPTCHA WebView JS evaluation errors as fatal (e.g. page not loaded or wrong URL).
    if (error is PlatformException &&
        error.code == 'FWFEvaluateJavaScriptError') {
      LogLevel.error('reCAPTCHA WebView JS error (ensure openmic.ai/recaptcha.html is deployed)', error);
      return true;
    }
    LogLevel.error('Platform Error', error);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  LogLevel.info('Crashlytics configured');

  LogLevel.info('Configuring Dependencies...');
  await configureDependencies();
  LogLevel.info('Dependencies configured');

  RecaptchaHandler.instance.setupSiteKey(dataSiteKey: kRecaptchaSiteKey);
  LogLevel.info('reCAPTCHA v3 site key configured for openmic.ai');

  LogLevel.info('Initializing Notification Service...');
  await getIt<NotificationService>().initialize();
  LogLevel.info('Notification Service initialized');

  LogLevel.info('Requesting Notification Permission...');
  await getIt<NotificationService>().requestPermission();
  LogLevel.info('Notification Permission done');

  LogLevel.info('App initialization completed');
}


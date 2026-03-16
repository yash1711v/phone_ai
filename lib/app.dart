import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';

import 'core/theme/theme_cubit.dart';
import 'core/constants/recaptcha_constants.dart';
import 'core/theme/theme_data.dart';
import 'core/routes/app_router.dart';
import 'di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'core/utils/logger.dart';
import 'Flavors/config/build_flavor.dart';
import 'Flavors/config/flavor_config.dart';
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
            title: FlavorConfig.instance.appName,
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
              return BlocListener<AuthCubit, AuthState>(
                listener: (_, state) {
                  if (state is AuthAuthenticated) {
                    if (state.needsOnboarding) {
                      AppRouter.router.goNamed('onboarding');
                    } else {
                      AppRouter.router.goNamed('home');
                    }
                  } else if (state is AuthInitial) {
                    // After logout or no cached session: show login and remember state
                    AppRouter.router.goNamed('login');
                  }
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    // Only dismiss keyboard on user-initiated scroll (drag), not on
                    // layout-driven scroll (e.g. when keyboard opens and view adjusts).
                    if (notification is UserScrollNotification) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    return false;
                  },
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Initialize app services.
/// [flavor] is required so [FlavorConfig] (and thus [ApiConstants.baseUrl]) is set before [configureDependencies].
Future<void> initializeApp({required BuildFlavor flavor}) async {
  debugPrint('[initializeApp] 1. App initialization started');
  LogLevel.info('App initialization started');

  debugPrint('[initializeApp] 1a. Setting up flavor');
  await FlavorConfig.instance.setupFlavor(flavor: flavor);
  debugPrint('[initializeApp] 1a. Flavor configured');

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[initializeApp] 2. WidgetsFlutterBinding initialized');
  LogLevel.info('WidgetsFlutterBinding initialized');

  debugPrint('[initializeApp] 3. Setting preferred orientations');
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('[initializeApp] 3. Orientation locked');
  LogLevel.info('Orientation locked');

  // Firebase is initialized in main.dart / dev.dart / prod.dart with flavor-specific options.

  debugPrint('[initializeApp] 4. Configuring FlutterError and PlatformDispatcher');
  FlutterError.onError = (errorDetails) {
    LogLevel.error('Flutter Error', errorDetails.exception);
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LogLevel.error('Platform Error', error);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  debugPrint('[initializeApp] 4. Crashlytics configured');
  LogLevel.info('Crashlytics configured');

  debugPrint('[initializeApp] 5. Configuring Dependencies...');
  LogLevel.info('Configuring Dependencies...');
  await configureDependencies();
  debugPrint('[initializeApp] 5. Dependencies configured');
  LogLevel.info('Dependencies configured');

  debugPrint('[initializeApp] 6. Setting up reCAPTCHA site key');
  RecaptchaHandler.instance.setupSiteKey(dataSiteKey: kRecaptchaSiteKey);
  debugPrint('[initializeApp] 6. reCAPTCHA configured');
  LogLevel.info('reCAPTCHA v3 site key configured for openmic.ai');

  debugPrint('[initializeApp] 7. Initializing Notification Service...');
  LogLevel.info('Initializing Notification Service...');
  await getIt<NotificationService>().initialize();
  debugPrint('[initializeApp] 7. Notification Service initialized');
  LogLevel.info('Notification Service initialized');

  debugPrint('[initializeApp] 8. Requesting Notification Permission...');
  LogLevel.info('Requesting Notification Permission...');
  await getIt<NotificationService>().requestPermission();
  debugPrint('[initializeApp] 8. Notification Permission done');
  LogLevel.info('Notification Permission done');

  debugPrint('[initializeApp] 9. App initialization completed');
  LogLevel.info('App initialization completed');
}

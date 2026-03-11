import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_data.dart';
import 'core/routes/app_router.dart';
import 'di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
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
          );
        },
      ),
    );
  }
}

/// Initialize app services
Future<void> initializeApp() async {
  print("🚀 App initialization started");

  WidgetsFlutterBinding.ensureInitialized();
  print("✅ WidgetsFlutterBinding initialized");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  print("✅ Orientation locked");

  print("⏳ Initializing Firebase...");
  await Firebase.initializeApp();
  print("✅ Firebase initialized");

  FlutterError.onError = (errorDetails) {
    print("❌ Flutter Error: ${errorDetails.exception}");
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    print("❌ Platform Error: $error");
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  print("✅ Crashlytics configured");

  print("⏳ Configuring Dependencies...");
  await configureDependencies();
  print("✅ Dependencies configured");

  print("⏳ Initializing Notification Service...");
  await getIt<NotificationService>().initialize();
  print("✅ Notification Service initialized");

  print("⏳ Requesting Notification Permission...");
  await getIt<NotificationService>().requestPermission();
  print("✅ Notification Permission done");

  print("🎉 App initialization completed");
}


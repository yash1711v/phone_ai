import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/phone_otp_page.dart';
import '../../features/home/presentation/pages/home.dart';

/// App router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            ).animate().fadeIn(duration: 300.ms);
          },
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ).animate().slideX(duration: 300.ms);
          },
        ),
      ),
      GoRoute(
        path: '/phone-otp',
        name: 'phone-otp',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? 
                       (state.extra as Map<String, dynamic>?)?['email'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: PhoneOtpPage(email: email),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ).animate().slideY(duration: 300.ms);
            },
          );
        },
      ),
      // TODO: Add home route when home feature is implemented
      // lib/core/routes/app_router.dart

      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) =>
            CustomTransitionPage(
              key: state.pageKey,
              child: const HomePage(), // Added const here
              transitionsBuilder: (context, animation, secondaryAnimation,
                  child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
      ),
    ],
  );
}

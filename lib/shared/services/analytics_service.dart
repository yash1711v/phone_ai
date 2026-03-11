import 'package:firebase_analytics/firebase_analytics.dart';
import '../../core/utils/logger.dart';

/// Analytics service for tracking user events
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({required FirebaseAnalytics analytics}) : _analytics = analytics;

  /// Log event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
      );
      LogLevel.debug('Analytics event logged: $name');
    } catch (e) {
      LogLevel.error('Failed to log analytics event', e);
    }
  }

  /// Log login event
  Future<void> logLogin({String? loginMethod}) async {
    await logEvent(
      name: 'login',
      parameters: {
        'method': loginMethod ?? 'email',
      },
    );
  }

  /// Log signup event
  Future<void> logSignUp({String? signUpMethod}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {
        'method': signUpMethod ?? 'email',
      },
    );
  }

  /// Set user property
  Future<void> setUserProperty({required String name, String? value}) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      LogLevel.error('Failed to set user property', e);
    }
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      LogLevel.error('Failed to set user ID', e);
    }
  }
}

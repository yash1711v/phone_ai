import 'package:logger/logger.dart';

/// Application logger instance
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

/// Log levels
class LogLevel {
  static void debug(String message) => appLogger.d(message);
  static void info(String message) => appLogger.i(message);
  static void warning(String message) => appLogger.w(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.e(message, error: error, stackTrace: stackTrace);
  }
}

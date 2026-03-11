import 'package:permission_handler/permission_handler.dart' as ph;
import '../../core/constants/app_strings.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';

/// Permission handler utility
class AppPermissionHandler {
  /// Request microphone permission
  /// 
  /// Returns [true] if permission is granted, [false] otherwise
  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await ph.Permission.microphone.request();
      
      if (status.isGranted) {
        LogLevel.info('Microphone permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        LogLevel.warning('Microphone permission permanently denied');
        throw PermissionException(AppStrings.permissionPermanentlyDenied);
      } else {
        LogLevel.warning('Microphone permission denied');
        throw PermissionException(AppStrings.permissionDenied);
      }
    } catch (e) {
      LogLevel.error('Failed to request microphone permission', e);
      rethrow;
    }
  }

  /// Check microphone permission status
  static Future<bool> checkMicrophonePermission() async {
    final status = await ph.Permission.microphone.status;
    return status.isGranted;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  /// Request camera permission (for future use)
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await ph.Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      LogLevel.error('Failed to request camera permission', e);
      return false;
    }
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await ph.Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      LogLevel.error('Failed to request notification permission', e);
      return false;
    }
  }
}

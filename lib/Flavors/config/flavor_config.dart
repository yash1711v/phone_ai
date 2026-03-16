import 'package:flutter/foundation.dart';

import '../../core/constants/env_constants.dart';
import 'build_flavor.dart';

/// Holds flavor-specific config (base URL, app name). Setup once at startup.
class FlavorConfig {
  static final FlavorConfig _instance = FlavorConfig._internal();
  static FlavorConfig get instance => _instance;

  FlavorConfig._internal();

  BuildFlavor? buildFlavor;

  late String baseUrl;
  late String appName;

  bool _initialized = false;

  factory FlavorConfig() =>
      throw Exception('Use FlavorConfig.instance, not FlavorConfig().');

  /// Call from main_dev.dart / main_prod.dart before runApp.
  Future<void> setupFlavor({required BuildFlavor flavor}) async {
    if (_initialized) {
      debugPrint('FlavorConfig already initialized, skipping.');
      return;
    }

    switch (flavor) {
      case BuildFlavor.dev:
        buildFlavor = BuildFlavor.dev;
        baseUrl = EnvConstants.baseUrlDev;
        appName = 'OpenmicDev';
        break;
      case BuildFlavor.prod:
        buildFlavor = BuildFlavor.prod;
        baseUrl = EnvConstants.baseUrlProd;
        appName = 'Openmic';
        break;
    }

    _initialized = true;
    debugPrint('Flavor: $buildFlavor | baseUrl: $baseUrl | appName: $appName');
  }

  void ensureInitialized() {
    if (!_initialized || buildFlavor == null || baseUrl.isEmpty) {
      throw Exception(
          'FlavorConfig not initialized. Call setupFlavor() before use.');
    }
  }
}

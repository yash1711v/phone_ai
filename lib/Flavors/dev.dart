import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../firebase_options_dev.dart';
import 'package:phone_ai/Flavors/config/build_flavor.dart';
import 'package:phone_ai/Flavors/config/flavor_config.dart';

void main() async {
  debugPrint('[main:dev] 1. Starting main()');
  try {
    debugPrint('[main:dev] 2. Calling WidgetsFlutterBinding.ensureInitialized()');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[main:dev] 2. Done WidgetsFlutterBinding.ensureInitialized()');

    debugPrint('[main:dev] 3. Calling Firebase.initializeApp()');
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptionsDev.currentPlatform,
        );
        debugPrint('[main:dev] 3. Done Firebase.initializeApp()');
      } catch (e) {
        if (e.toString().contains('duplicate-app')) {
          debugPrint('[main:dev] 3. Firebase [DEFAULT] already exists on platform, using existing app');
          final currentProjectId = Firebase.apps.isNotEmpty ? Firebase.app().options.projectId : null;
          const expectedProjectId = 'openmic-staging-6f504';
          if (currentProjectId != null && currentProjectId != expectedProjectId) {
            debugPrint('[main:dev] WARNING: Running Firebase project is "$currentProjectId" but dev expects "$expectedProjectId". Uninstall the app and run again to use dev Firebase (backend may reject tokens otherwise).');
          }
        } else {
          rethrow;
        }
      }
    } else {
      debugPrint('[main:dev] 3. Firebase already initialized, skipping');
    }

    debugPrint('[main:dev] 4. Calling initializeApp(dev)');
    await initializeApp(flavor: BuildFlavor.dev);
    debugPrint('[main:dev] 4. Done initializeApp()');

    debugPrint('[main:dev] 5. Calling runApp()');
    runApp(const App());
    debugPrint('[main:dev] 5. Done runApp() - app should be running');
  } catch (e, stack) {
    debugPrint('[main:dev] ERROR: $e');
    debugPrint('[main:dev] STACK: $stack');
    rethrow;
  }
}

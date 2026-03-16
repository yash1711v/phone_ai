import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../firebase_options_prod.dart';
import 'package:phone_ai/Flavors/config/build_flavor.dart';
import 'package:phone_ai/Flavors/config/flavor_config.dart';

void main() async {
  debugPrint('[main:prod] 1. Starting main()');
  try {
    debugPrint('[main:prod] 2. Calling WidgetsFlutterBinding.ensureInitialized()');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[main:prod] 2. Done WidgetsFlutterBinding.ensureInitialized()');

    debugPrint('[main:prod] 3. Calling Firebase.initializeApp()');
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptionsProd.currentPlatform,
        );
        debugPrint('[main:prod] 3. Done Firebase.initializeApp()');
      } catch (e) {
        if (e.toString().contains('duplicate-app')) {
          debugPrint('[main:prod] 3. Firebase [DEFAULT] already exists on platform, using existing app');
          final currentProjectId = Firebase.apps.isNotEmpty ? Firebase.app().options.projectId : null;
          const expectedProjectId = 'om-101';
          if (currentProjectId != null && currentProjectId != expectedProjectId) {
            debugPrint('[main:prod] WARNING: Running Firebase project is "$currentProjectId" but prod expects "$expectedProjectId". Uninstall the app and run again to use prod Firebase (backend may reject tokens otherwise).');
          }
        } else {
          rethrow;
        }
      }
    } else {
      debugPrint('[main:prod] 3. Firebase already initialized, skipping');
    }

    debugPrint('[main:prod] 4. Calling initializeApp(prod)');
    await initializeApp(flavor: BuildFlavor.prod);
    debugPrint('[main:prod] 4. Done initializeApp()');

    debugPrint('[main:prod] 5. Calling runApp()');
    runApp(const App());
    debugPrint('[main:prod] 5. Done runApp() - app should be running');
  } catch (e, stack) {
    debugPrint('[main:prod] ERROR: $e');
    debugPrint('[main:prod] STACK: $stack');
    rethrow;
  }
}

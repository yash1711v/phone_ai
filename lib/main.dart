import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options_prod.dart';
import 'Flavors/config/build_flavor.dart';

void main() async {
  debugPrint('[main] 1. Starting main()');
  try {
    debugPrint('[main] 2. Calling WidgetsFlutterBinding.ensureInitialized()');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[main] 2. Done WidgetsFlutterBinding.ensureInitialized()');

    debugPrint('[main] 3. Calling Firebase.initializeApp()');
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptionsProd.currentPlatform,
        );
        debugPrint('[main] 3. Done Firebase.initializeApp()');
      } catch (e) {
        if (e.toString().contains('duplicate-app')) {
          debugPrint('[main] 3. Firebase [DEFAULT] already exists on platform, using existing app');
        } else {
          rethrow;
        }
      }
    } else {
      debugPrint('[main] 3. Firebase already initialized, skipping');
    }

    debugPrint('[main] 4. Calling initializeApp(prod)');
    await initializeApp(flavor: BuildFlavor.prod);
    debugPrint('[main] 4. Done initializeApp()');

    debugPrint('[main] 5. Calling runApp()');
    runApp(const App());
    debugPrint('[main] 5. Done runApp() - app should be running');
  } catch (e, stack) {
    debugPrint('[main] ERROR: $e');
    debugPrint('[main] STACK: $stack');
    rethrow;
  }
}

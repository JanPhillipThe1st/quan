// test_driver/app.dart
import 'package:flutter_driver/driver_extension.dart';
import 'package:quan/main.dart'
    as app; // Assuming your main app is in lib/main.dart

void main() {
  // This line enables the extension.
  enableFlutterDriverExtension();

  // Call the main() function of your app.
  app.main();
}

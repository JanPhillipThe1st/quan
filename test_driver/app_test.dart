// test_driver/app_test.dart
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('App Screenshot Test', () {
    FlutterDriver? driver;

    // Connect to the Flutter driver before the tests run.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
      }
    });

    // Helper function to take and save a screenshot
    Future<void> takeScreenshot(FlutterDriver driver, String name) async {
      // Ensure the screenshots directory exists
      final screenshotsDir = Directory('screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create();
      }

      final pixels = await driver.screenshot();
      final file = File('screenshots/$name.png');
      await file.writeAsBytes(pixels);
      print('Screenshot $name.png saved.');
    }

    test('Take screenshot of Home Screen', () async {
      // You might need to wait for certain elements to appear
      // Example: await driver.waitFor(find.byValueKey('homeScreenReady'));

      await takeScreenshot(driver!, '01_home_screen');
    });

    test('Navigate to Login and take screenshot', () async {
      // Example: Find a button by tooltip or key and tap it
      // final SerializableFinder loginButton = find.byTooltip('Navigate to Login');
      // await driver.tap(loginButton);

      // Wait for the login screen to be visible
      // await driver.waitFor(find.byValueKey('loginScreenReady'));

      await takeScreenshot(driver!, '02_login_screen');
      // Add more navigation and screenshot steps here
    });

    // Add more tests for other screens
    // test('Navigate to Profile Screen and take screenshot', () async {
    //   // ... navigation logic ...
    //   await takeScreenshot(driver, '03_profile_screen');
    // });
  });
}

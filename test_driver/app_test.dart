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

    test('Navigate to Scan MCQ Papers Screen and take screenshot', () async {
      // Example: Find a button by tooltip or key and tap it
      final SerializableFinder loginButton = find.text('Scan MCQ Papers');
      await driver!.tap(loginButton);

      // Wait for the login screen to be visible
      await driver!.waitFor(find.byValueKey('cameraSnackbar'));

      await takeScreenshot(driver!, '02_scanning_screen');
      // Add more navigation and screenshot steps here
    });
    test('Navigate to Quizzes Screen and take screenshot', () async {
      // Example: Find a button by tooltip or key and tap it
      // Emulate back button press to return to the dashboard
      await driver!.tap(find.byTooltip('Back'));
      await driver!.waitFor(find.text('Teacher Dashboard'));
      ;
      final SerializableFinder loginButton = find.text('My Quizzes');
      await driver!.tap(loginButton);

      // Wait for the login screen to be visible
      await driver!.waitFor(find.byValueKey('quizzesConsumer'));

      await takeScreenshot(driver!, '03_quizzes_screen');

      final SerializableFinder createQuizButton = find.text('New Quiz');
      await driver!.tap(createQuizButton);

      await takeScreenshot(driver!, '04_my_quizzes_screen');
      // Add more navigation and screenshot steps here
    });
  });
}

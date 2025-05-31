import 'package:flutter/material.dart';
import 'package:quan/screens/auto_quiz_screen.dart';
import 'package:quan/screens/scan_screen.dart';
import 'screens/my_quizzes_screen.dart'; // Was create_question_screen, changed to my_quizzes_screen based on recent context
import 'screens/quiz_config_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/question_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/quiz_provider.dart';

class DashboardScreen extends StatelessWidget {
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color shadowLight = Colors.white;
  static const Color shadowDark = Color(
    0xFFBEBEBE,
  ); // Slightly softer dark shadow
  static const Color iconColor = Color.fromARGB(255, 10, 208, 0);

  Widget neumorphicCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.green, width: 1),
          boxShadow: [BoxShadow(offset: Offset(0, 4), color: Colors.green)],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(
                icon,
                color: const Color.fromARGB(255, 82, 189, 0),
                size: 32,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 178, 0),
        elevation: 0,
        title: Text('Teacher Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuizSettingsApp()),
              );
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: ShapeDecoration(
                color: const Color.fromARGB(255, 9, 178, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150),
                    bottomRight: Radius.circular(150),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ListView(
              // Changed Column to ListView
              // crossAxisAlignment: CrossAxisAlignment.start, // Not applicable for ListView directly
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Welcome, Teacher!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Manage and grade your MCQ exams efficiently.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 32),
                neumorphicCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan MCQ Papers',
                  subtitle: 'Scan and auto-grade answer sheets',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanScreen(),
                    ), // Navigate to ScanScreen
                  ),
                ),
                neumorphicCard(
                  icon: Icons.add_circle_outline,
                  title:
                      'My Quizzes', // Keeping the "My Quizzes" change from previous context
                  subtitle:
                      'Create and manage your quizzes', // Keeping the "My Quizzes" change
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyQuizzesScreen()),
                  ),
                ),
                neumorphicCard(
                  icon: Icons.record_voice_over,
                  title: 'Auto Quiz Mode',
                  subtitle: 'Read questions aloud for oral quizzes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AutoQuizScreen()),
                  ),
                ),
                neumorphicCard(
                  icon: Icons.analytics,
                  title: 'Results & Analytics',
                  subtitle: 'View and export student results',
                  onTap: () {
                    // TODO: Implement results screen navigation
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for Supabase init

  await Supabase.initialize(
    url: 'https://urzntxniabiujldwgxuo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVyem50eG5pYWJpdWpsZHdneHVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NTgxOTcsImV4cCI6MjA2MzMzNDE5N30.U3Lo2-KADyYLFct32q-P_LoHAdWMH2UpqMltCXUfvZ4',
  );

  runApp(const AppWithProviders()); // Run the app with providers
}

// Wrapper for Providers
class AppWithProviders extends StatelessWidget {
  const AppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const ProfileApp(), // Your existing ProfileApp
    );
  }
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Dashboard',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F0F3),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.black87, displayColor: Colors.black87),
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

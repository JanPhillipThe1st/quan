import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const QuizSettingsApp());
}

class QuizSettingsApp extends StatelessWidget {
  const QuizSettingsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Settings',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QuizSettingsScreen(),
    );
  }
}

class QuizSettingsScreen extends StatefulWidget {
  const QuizSettingsScreen({Key? key}) : super(key: key);

  @override
  State<QuizSettingsScreen> createState() => _QuizSettingsScreenState();
}

class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
  int _timePerQuestion = 30; // seconds
  int _repeatCount = 2;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timePerQuestion = prefs.getInt('timePerQuestion') ?? 30;
      _repeatCount = prefs.getInt('repeatCount') ?? 2;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timePerQuestion', _timePerQuestion);
    await prefs.setInt('repeatCount', _repeatCount);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Time per question: $_timePerQuestion seconds',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              min: 5,
              max: 120,
              divisions: 23,
              value: _timePerQuestion.toDouble(),
              label: '$_timePerQuestion',
              onChanged: (value) {
                setState(() {
                  _timePerQuestion = value.round();
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Repeat each question: $_repeatCount times',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: _repeatCount.toDouble(),
              label: '$_repeatCount',
              onChanged: (value) {
                setState(() {
                  _repeatCount = value.round();
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

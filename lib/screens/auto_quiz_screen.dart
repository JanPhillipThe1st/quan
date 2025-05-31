import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class AutoQuizScreen extends StatefulWidget {
  const AutoQuizScreen({super.key});

  @override
  State<AutoQuizScreen> createState() => _AutoQuizScreenState();
}

class _AutoQuizScreenState extends State<AutoQuizScreen> {
  final TtsService _ttsService = TtsService();
  int _timePerQuestion = 10; // seconds
  int _repeatCount = 2;
  bool _isRunning = false;
  int _currentQuestion = 0;
  List<String> _questions = [
    'What is the capital of France?',
    'Who wrote Hamlet?',
    'What is the boiling point of water?',
  ];

  Future<void> _startQuiz() async {
    setState(() {
      _isRunning = true;
      _currentQuestion = 0;
    });
    for (int i = 0; i < _questions.length && _isRunning; i++) {
      for (int r = 0; r < _repeatCount && _isRunning; r++) {
        await _ttsService.speak(_questions[i]);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      setState(() {
        _currentQuestion = i + 1;
      });
      if (i < _questions.length - 1 && _isRunning) {
        await Future.delayed(Duration(seconds: _timePerQuestion));
      }
    }
    setState(() {
      _isRunning = false;
    });
  }

  void _stopQuiz() {
    setState(() {
      _isRunning = false;
    });
    _ttsService.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Quiz Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time per question: $_timePerQuestion seconds'),
            Slider(
              value: _timePerQuestion.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$_timePerQuestion',
              onChanged: _isRunning
                  ? null
                  : (v) => setState(() => _timePerQuestion = v.round()),
            ),
            const SizedBox(height: 16),
            Text('Repeat each question: $_repeatCount times'),
            Slider(
              value: _repeatCount.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_repeatCount',
              onChanged: _isRunning
                  ? null
                  : (v) => setState(() => _repeatCount = v.round()),
            ),
            const SizedBox(height: 32),
            if (_isRunning)
              Center(
                child: Column(
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1} of ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _stopQuiz,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  onPressed: _startQuiz,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Auto Quiz'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

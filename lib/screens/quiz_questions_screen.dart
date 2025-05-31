import 'package:flutter/material.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const QuizQuestionsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        backgroundColor: const Color(0xFFF0F0F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFF0F0F3),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Managing questions for "${widget.quizTitle}" (ID: ${widget.quizId})',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Text(
                'Here, you will be able to add questions from your question bank or create new ones specifically for this quiz.',
                textAlign: TextAlign.center,
              ),
              // TODO: Implement UI to list, add, remove questions for this quiz.
              // This will involve interacting with the 'quiz_questions' join table.
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement action to add a new question to this quiz
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Add question to "${widget.quizTitle}" (not implemented yet)',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}

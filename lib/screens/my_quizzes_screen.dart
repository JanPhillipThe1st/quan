import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan/screens/manage_quiz_questions.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import 'quiz_questions_screen.dart'; // Import the new screen
import 'create_quiz_screen.dart'; // Import the CreateQuizScreen

class MyQuizzesScreen extends StatefulWidget {
  const MyQuizzesScreen({super.key});

  @override
  State<MyQuizzesScreen> createState() => _MyQuizzesScreenState();
}

class _MyQuizzesScreenState extends State<MyQuizzesScreen> {
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  @override
  void initState() {
    super.initState();
    // Fetch quizzes when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).fetchQuizzes();
    });
  }

  void _navigateToCreateQuizScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
    ).then(
      (_) => Provider.of<QuizProvider>(context, listen: false).fetchQuizzes(),
    ); // Refresh list after returning
  }

  @override
  Widget build(BuildContext context) {
    // final quizProvider = Provider.of<QuizProvider>(context); // Use Consumer for more fine-grained rebuilds

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quizzes'),
        backgroundColor: const Color(0xFFF0F0F3), // Match dashboard theme
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.green,
        ), // Match dashboard icon theme
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFF0F0F3),
      body: Consumer<QuizProvider>(
        key: const Key('quizzesConsumer'),
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${provider.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          if (provider.quizzes.isEmpty) {
            return const Center(
              child: Text(
                'No quizzes yet. Tap + to create one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = provider.quizzes[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.green, width: 1),
                  boxShadow: [
                    BoxShadow(offset: Offset(0, 4), color: Colors.green),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    quiz.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: quiz.description != null
                      ? Text(quiz.description!)
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageQuizQuestionsScreen(quiz: quiz),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateQuizScreen,
        icon: const Icon(Icons.add, color: Colors.black87),
        label: const Text('New Quiz', style: TextStyle(color: Colors.black87)),
        backgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ), // Match icon color
      ),
    );
  }
}

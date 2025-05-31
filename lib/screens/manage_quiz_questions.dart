import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart'; // Assuming Quiz model is in lib/models/
import '../models/question_model.dart';
import '../providers/question_provider.dart';

class ManageQuizQuestionsScreen extends StatefulWidget {
  final Quiz quiz;

  const ManageQuizQuestionsScreen({Key? key, required this.quiz})
    : super(key: key);

  @override
  State<ManageQuizQuestionsScreen> createState() =>
      _ManageQuizQuestionsScreenState();
}

class _ManageQuizQuestionsScreenState extends State<ManageQuizQuestionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch questions for the current quiz when the screen loads
    // Use Future.microtask to ensure context is available and provider is ready
    Future.microtask(() {
      Provider.of<QuestionProvider>(
        context,
        listen: false,
      ).fetchQuestions(widget.quiz.id);
    });
  }

  void _navigateToAddQuestionScreen() {
    // TODO: Implement navigation to a dedicated Add/Edit Question Screen
    // For example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddEditQuestionScreen(quizId: widget.quiz.id),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Add Question Screen (TODO)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage: ${widget.quiz.title}')),
      body: Consumer<QuestionProvider>(
        builder: (context, questionProvider, child) {
          if (questionProvider.isLoading &&
              questionProvider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (questionProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${questionProvider.errorMessage}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (questionProvider.questions.isEmpty) {
            return const Center(
              child: Text('No questions yet. Tap the + button to add one!'),
            );
          }

          return ListView.builder(
            itemCount: questionProvider.questions.length,
            itemBuilder: (context, index) {
              final question = questionProvider.questions[index];
              return ListTile(
                title: Text(question.text),
                subtitle: Text(
                  'Options: ${question.options.length}, Correct: ${question.options[question.correctOptionIndex]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        /* TODO: Implement Edit */
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        /* TODO: Implement Delete */
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddQuestionScreen,
        tooltip: 'Add Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart'; // Assuming Quiz model is in lib/models/
import '../models/question_model.dart';
import '../providers/question_provider.dart';
import './add_edit_question_screen.dart'; // Import the new screen

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQuestionScreen(
          quizId: widget.quiz.id,
          // question is null for add mode
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage: ${widget.quiz.title}',
          style: TextStyle(fontSize: 16),
        ),
      ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditQuestionScreen(
                              quizId: widget.quiz.id,
                              question:
                                  question, // Pass the question for edit mode
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text(
                                'Are you sure you want to delete "${question.text}"?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          try {
                            await Provider.of<QuestionProvider>(
                              context,
                              listen: false,
                            ).deleteQuestion(question.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Question deleted successfully!'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete question: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
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
        child: const Icon(Icons.add, color: Colors.green),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.green),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

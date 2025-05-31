import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart';

class QuestionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Question> _questions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchQuestions(String quizId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('questions')
          .select('*, quiz_questions(*), quizzes(*)')
          .eq('id', quizId)
          .order('created_at', ascending: true); // Or your preferred order

      _questions = response.map((item) => Question.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching questions for quiz $quizId: $e');
      _errorMessage = "Failed to load questions. Please try again.";
      _questions = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addQuestion({
    required String quizId,
    required String text,
    required List<String> options,
    required int correctOptionIndex,
  }) async {
    _isLoading = true; // Consider a more specific 'isAdding' flag if needed
    _errorMessage = null;
    // notifyListeners(); // Optional: notify for 'adding' state if UI needs it

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = "User not authenticated. Cannot add question.";
      _isLoading = false;
      notifyListeners(); // Notify UI about the error
      throw Exception('User must be authenticated to add a question.');
    }

    try {
      final newQuestionData = {
        'quiz_id': quizId,
        'text': text,
        'options':
            options, // Ensure your Supabase column can handle List<String> (e.g., text[], jsonb)
        'correct_option_index': correctOptionIndex,
        'user_id': userId, // Assuming 'questions' table has a 'user_id' column
      };

      final response = await _supabase
          .from('questions')
          .insert(newQuestionData)
          .select() // Select the newly inserted row
          .single(); // Expect a single row back

      final newQuestion = Question.fromJson(response);
      _questions.add(
        newQuestion,
      ); // Add to the end, or use insert(0, newQuestion) for beginning
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error adding question: $e');
      _errorMessage = "Failed to save question. Please try again.";
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to save question to the database.');
    }
  }

  Future<void> updateQuestion({
    required String questionId,
    required String text,
    required List<String> options,
    required int correctOptionIndex,
    // Add other fields that can be updated
  }) async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners(); // Optional

    try {
      final updateData = {
        'text': text,
        'options': options,
        'correct_option_index': correctOptionIndex,
        // 'updated_at' can be handled by Supabase triggers
      };

      final response = await _supabase
          .from('questions')
          .update(updateData)
          .eq('id', questionId)
          .select()
          .single();

      final updatedQuestion = Question.fromJson(response);
      final index = _questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _questions[index] = updatedQuestion;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error updating question $questionId: $e');
      _errorMessage = "Failed to update question.";
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to update question in the database.');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners(); // Optional

    try {
      await _supabase.from('questions').delete().eq('id', questionId);
      _questions.removeWhere((q) => q.id == questionId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error deleting question $questionId: $e');
      _errorMessage = "Failed to delete question.";
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to delete question from the database.');
    }
  }
}

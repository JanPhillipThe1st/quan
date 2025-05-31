import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Quiz> _quizzes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Quiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // final userId = _supabase.auth.currentUser?.id;
      // if (userId == null) {
      //   _errorMessage = "User not authenticated. Please log in.";
      //   _isLoading = false;
      //   notifyListeners();
      //   return;
      // }

      final response = await _supabase
          .from('quizzes')
          .select()
          // .eq('user_id', userId) // Removed user ID filter to fetch all quizzes
          .order('created_at', ascending: false);

      _quizzes = response.map((item) => Quiz.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching quizzes: $e');
      _errorMessage = "Failed to load quizzes. Please try again.";
      _quizzes = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addQuiz({required String title, String? description}) async {
    final userId = _supabase.auth.currentUser?.id;
    // if (userId == null) {
    //   // This matches the RLS policy that requires an authenticated user to insert.
    //   throw Exception('User must be authenticated to create a quiz.');
    // }

    try {
      final newQuizData = {
        'title': title,
        'description': description,
        'user_id': userId,
        // 'created_at' and 'updated_at' will be handled by Supabase defaults/triggers
      };

      final response = await _supabase
          .from('quizzes')
          .insert(newQuizData)
          .select() // Select the newly inserted row
          .single(); // Expect a single row back

      final newQuiz = Quiz.fromJson(response);
      _quizzes.insert(
        0,
        newQuiz,
      ); // Add to the beginning of the list for immediate UI update
      notifyListeners();
    } catch (e) {
      print('Error adding quiz: $e');
      throw Exception('Failed to save quiz to the database.');
    }
  }
}

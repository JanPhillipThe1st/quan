class Question {
  final String id;
  final String quizId;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final DateTime createdAt;
  // final String? userId; // Optional: if you need to store/access who created the question directly in the model

  Question({
    required this.id,
    required this.quizId,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.createdAt,
    // this.userId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      correctOptionIndex: json['correct_option_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      // userId: json['user_id'] as String?, // If you add userId to the model
    );
  }

  Map<String, dynamic> toJson() {
    // Primarily for serialization if needed, not typically for inserts directly
    return {
      'id': id,
      'quiz_id': quizId,
      'text': text,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'created_at': createdAt.toIso8601String(),
      // 'user_id': userId, // If you add userId to the model
    };
  }
}

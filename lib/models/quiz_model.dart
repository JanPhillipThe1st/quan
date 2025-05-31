class Quiz {
  final String id;
  final String title;
  final String? description;
  final String? userId; // ID of the user who created the quiz
  final DateTime createdAt;
  final DateTime updatedAt;
  // We might add a list of question IDs or Question objects here later
  // final List<String> questionIds;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    // this.questionIds = const [],
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

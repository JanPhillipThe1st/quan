// f:\quan\lib\screens\add_edit_question_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/question_model.dart';
import '../providers/question_provider.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final String quizId;
  final Question? question; // Nullable for add mode

  const AddEditQuestionScreen({Key? key, required this.quizId, this.question})
    : super(key: key);

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionTextController;
  List<TextEditingController> _optionControllers = [];
  int? _correctOptionIndex; // Can be null initially

  bool get _isEditMode => widget.question != null;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController(
      text: widget.question?.text ?? '',
    );

    if (_isEditMode && widget.question!.options.isNotEmpty) {
      _optionControllers = widget.question!.options
          .map((option) => TextEditingController(text: option))
          .toList();
      _correctOptionIndex = widget.question!.correctOptionIndex;
    } else {
      // Start with 2 empty options for new questions
      _optionControllers = [TextEditingController(), TextEditingController()];
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      // Limit max options
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 6 options allowed.')),
      );
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      // Keep at least 2 options
      setState(() {
        // If the removed option was the correct one, reset _correctOptionIndex
        if (_correctOptionIndex == index) {
          _correctOptionIndex = null;
        } else if (_correctOptionIndex != null &&
            _correctOptionIndex! > index) {
          _correctOptionIndex = _correctOptionIndex! - 1;
        }
        _optionControllers.removeAt(index).dispose();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum of 2 options required.')),
      );
    }
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      if (_correctOptionIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a correct option.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final questionProvider = Provider.of<QuestionProvider>(
        context,
        listen: false,
      );
      final options = _optionControllers.map((c) => c.text.trim()).toList();

      if (_isEditMode) {
        final updatedQuestion = Question(
          id: widget.question!.id,
          text: _questionTextController.text.trim(),
          options: options,
          correctOptionIndex: _correctOptionIndex!,
        );
        try {
          await questionProvider.updateQuestion(
            questionId: widget.question!.id,
            text: _questionTextController.text.trim(),
            options: options,
            correctOptionIndex: _correctOptionIndex!,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question updated successfully!')),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update question: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        try {
          await questionProvider.addQuestion(
            quizId: const Uuid().v4(),
            text: _questionTextController.text.trim(),
            options: options,
            correctOptionIndex: _correctOptionIndex!,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question added successfully!')),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add question: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Question' : 'Add New Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _questionTextController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the question text.';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text('Options:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _optionControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Option text cannot be empty.';
                              }
                              return null;
                            },
                          ),
                        ),
                        Radio<int>(
                          value: index,
                          groupValue: _correctOptionIndex,
                          onChanged: (int? value) {
                            setState(() {
                              _correctOptionIndex = value;
                            });
                          },
                        ),
                        if (_optionControllers.length > 2)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeOption(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              if (_optionControllers.length < 6)
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Option'),
                  onPressed: _addOption,
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  // backgroundColor: Theme.of(context).primaryColor,
                  // foregroundColor: Colors.white
                ),
                child: Text(_isEditMode ? 'Save Changes' : 'Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

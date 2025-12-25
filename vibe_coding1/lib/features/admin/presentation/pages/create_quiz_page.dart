import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/admin_bloc.dart';
import '../../../student/data/models/quiz_model.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _durationController = TextEditingController();
  final List<QuestionModel> _questions = [];
  final List<String> _selectedDepartments = [];
  bool _isPublished = true; // Default to published

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => AddQuestionDialog(
        onAdd: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _createQuiz() {
    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one question')),
        );
        return;
      }

      if (_selectedDepartments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select at least one department')),
        );
        return;
      }

      final totalMarks = _questions.fold(0, (sum, q) => sum + q.marks);

      final quiz = QuizModel(
        quizId: '',
        title: _titleController.text.trim(),
        instructions: _instructionsController.text.trim(),
        questions: _questions,
        duration: int.parse(_durationController.text.trim()),
        totalMarks: totalMarks,
        targetDepartments: _selectedDepartments,
        isPublished: _isPublished,
        createdAt: DateTime.now(),
      );

      context.read<AdminBloc>().add(CreateQuiz(quiz));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is QuizCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quiz created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Quiz Title',
                    hint: 'Enter quiz title',
                    prefixIcon: Icons.title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quiz title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  CustomTextField(
                    controller: _instructionsController,
                    label: 'Instructions',
                    hint: 'Enter quiz instructions',
                    prefixIcon: Icons.info,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter instructions';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Duration
                  CustomTextField(
                    controller: _durationController,
                    label: 'Duration (minutes)',
                    hint: 'Enter duration in minutes',
                    prefixIcon: Icons.timer,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter duration';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Target Departments
                  const Text(
                    'Target Departments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _departments.map((dept) {
                      final isSelected = _selectedDepartments.contains(dept);
                      return FilterChip(
                        label: Text(dept),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDepartments.add(dept);
                            } else {
                              _selectedDepartments.remove(dept);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.3),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Publish Checkbox
                  Card(
                    child: SwitchListTile(
                      title: const Text(
                        'Publish Quiz',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Students will be able to see and take this quiz',
                      ),
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() {
                          _isPublished = value;
                        });
                      },
                      activeColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Questions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions (${_questions.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_questions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Text('No questions added yet'),
                      ),
                    )
                  else
                    ..._questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      question.question,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _removeQuestion(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...question.options.asMap().entries.map((opt) {
                                final isCorrect =
                                    opt.key == question.correctAnswer;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 40, bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCorrect
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 16,
                                        color: isCorrect
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          opt.value,
                                          style: TextStyle(
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.grey[700],
                                            fontWeight: isCorrect
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, top: 8),
                                child: Text(
                                  'Marks: ${question.marks}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 32),

                  // Create Button
                  CustomButton(
                    text: 'Create Quiz',
                    onPressed: _createQuiz,
                    icon: Icons.quiz,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Add Question Dialog
class AddQuestionDialog extends StatefulWidget {
  final Function(QuestionModel) onAdd;

  const AddQuestionDialog({super.key, required this.onAdd});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _questionController = TextEditingController();
  final _marksController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswer = 0;

  @override
  void dispose() {
    _questionController.dispose();
    _marksController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
        if (_correctAnswer >= _optionControllers.length) {
          _correctAnswer = 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Marks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Options',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._optionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio(
                      value: index,
                      groupValue: _correctAnswer,
                      onChanged: (value) {
                        setState(() {
                          _correctAnswer = value as int;
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _removeOption(index),
                      ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_questionController.text.trim().isEmpty ||
                _marksController.text.trim().isEmpty ||
                _optionControllers.any((c) => c.text.trim().isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }

            final question = QuestionModel(
              question: _questionController.text.trim(),
              options: _optionControllers.map((c) => c.text.trim()).toList(),
              correctAnswer: _correctAnswer,
              marks: int.parse(_marksController.text.trim()),
            );

            widget.onAdd(question);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

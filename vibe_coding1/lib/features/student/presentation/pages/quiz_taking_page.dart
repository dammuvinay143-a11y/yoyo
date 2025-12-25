import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/quiz_bloc.dart';
import '../../data/models/quiz_model.dart';

class QuizTakingPage extends StatefulWidget {
  final String quizId;
  final String attemptId;

  const QuizTakingPage({
    super.key,
    required this.quizId,
    required this.attemptId,
  });

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  late Timer _timer;
  int _remainingSeconds = 0;
  int _currentQuestionIndex = 0;
  final Map<int, int> _answers = {};
  QuizModel? _quiz;

  @override
  void initState() {
    super.initState();
    context.read<QuizBloc>().add(LoadQuizDetail(widget.quizId));
  }

  void _startTimer(int durationMinutes) {
    _remainingSeconds = durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    _submitQuiz();
  }

  void _submitQuiz() {
    context.read<QuizBloc>().add(
          SubmitQuiz(
            attemptId: widget.attemptId,
            quizId: widget.quizId,
            answers: _answers,
          ),
        );
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content: const Text(
              'Are you sure you want to exit? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _remainingSeconds < 60 ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: _remainingSeconds < 60 ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        color: _remainingSeconds < 60 ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizDetailLoaded && _quiz == null) {
              setState(() {
                _quiz = state.quiz;
              });
              _startTimer(state.quiz.duration);
            } else if (state is QuizSubmitted) {
              _timer.cancel();
              _showResultDialog(state.score, state.totalMarks);
            } else if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (_quiz == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final question = _quiz!.questions[_currentQuestionIndex];
            final progress = (_currentQuestionIndex + 1) / _quiz!.questions.length;

            return Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question counter
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_quiz!.questions.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question
                        Card(
                          elevation: 0,
                          color: AppColors.primary.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Options
                        ...question.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final isSelected = _answers[_currentQuestionIndex] == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _answers[_currentQuestionIndex] = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey[800],
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            },
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentQuestionIndex < _quiz!.questions.length - 1) {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            } else {
                              _showSubmitConfirmation();
                            }
                          },
                          child: Text(
                            _currentQuestionIndex < _quiz!.questions.length - 1
                                ? 'Next'
                                : 'Submit',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz?'),
        content: Text(
          'You have answered ${_answers.length} out of ${_quiz!.questions.length} questions.\n\nAre you sure you want to submit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitQuiz();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(int score, int totalMarks) {
    final percentage = (score / totalMarks * 100).toStringAsFixed(1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              score >= totalMarks * 0.6 ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: score >= totalMarks * 0.6 ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '$score / $totalMarks',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

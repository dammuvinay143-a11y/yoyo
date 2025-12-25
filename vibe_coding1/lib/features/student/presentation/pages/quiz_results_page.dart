import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class QuizResultsPage extends StatelessWidget {
  const QuizResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text('Please login to view results')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quiz Results'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quiz_attempts')
            .where('studentId', isEqualTo: authState.user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          var attempts = snapshot.data?.docs ?? [];
          
          // Filter out incomplete attempts (where endTime is null)
          attempts = attempts.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['endTime'] != null;
          }).toList();
          
          // Sort attempts by endTime in descending order (most recent first)
          attempts.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['endTime'] as Timestamp?)?.toDate();
            final bTime = (bData['endTime'] as Timestamp?)?.toDate();
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          if (attempts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No quiz attempts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a quiz to see your results here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attempts.length,
            itemBuilder: (context, index) {
              final attemptData = attempts[index].data() as Map<String, dynamic>;
              return _QuizResultCard(
                attemptId: attempts[index].id,
                attemptData: attemptData,
              );
            },
          );
        },
      ),
    );
  }
}

class _QuizResultCard extends StatelessWidget {
  final String attemptId;
  final Map<String, dynamic> attemptData;

  const _QuizResultCard({
    required this.attemptId,
    required this.attemptData,
  });

  @override
  Widget build(BuildContext context) {
    final quizId = attemptData['quizId'] as String;
    final score = attemptData['score'] as int? ?? 0;
    final completedAt = (attemptData['endTime'] as Timestamp?)?.toDate();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('quizzes').doc(quizId).get(),
      builder: (context, quizSnapshot) {
        if (!quizSnapshot.hasData) {
          return const Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final quizData = quizSnapshot.data!.data() as Map<String, dynamic>?;
        if (quizData == null) {
          return const SizedBox.shrink();
        }

        final quizTitle = quizData['title'] as String? ?? 'Unknown Quiz';
        final questions = quizData['questions'] as List<dynamic>? ?? [];
        final totalQuestions = questions.length;
        final percentage = totalQuestions > 0 ? (score / totalQuestions * 100) : 0;
        final isPassed = percentage >= 60;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPassed ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => _showDetailedResults(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          quizTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPassed ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPassed ? 'PASS' : 'FAIL',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.check_circle,
                          'Score: $score/$totalQuestions',
                          isPassed ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.percent,
                          '${percentage.toStringAsFixed(1)}%',
                          isPassed ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (completedAt != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Completed: ${DateFormat('MMM dd, yyyy hh:mm a').format(completedAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showDetailedResults(context),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedResults(BuildContext context) {
    final score = attemptData['score'] as int? ?? 0;
    final answers = attemptData['answers'] as Map<String, dynamic>? ?? {};
    final quizId = attemptData['quizId'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('quizzes').doc(quizId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final quizData = snapshot.data!.data() as Map<String, dynamic>?;
              if (quizData == null) {
                return const Center(child: Text('Quiz not found'));
              }

              final questions = quizData['questions'] as List<dynamic>? ?? [];
              final totalQuestions = questions.length;
              final percentage = totalQuestions > 0 ? (score / totalQuestions * 100) : 0;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: percentage >= 60 ? AppColors.primaryGradient : LinearGradient(
                        colors: [Colors.red.shade700, Colors.red.shade500],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Quiz Results',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$score/$totalQuestions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index] as Map<String, dynamic>;
                        final questionText = question['question'] as String? ?? '';
                        final correctAnswer = question['correctAnswer'] as int? ?? 0;
                        final userAnswer = answers['$index'] as int? ?? -1;
                        final isCorrect = userAnswer == correctAnswer;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check_circle : Icons.cancel,
                                      color: isCorrect ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Question ${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(questionText),
                                const SizedBox(height: 8),
                                if (userAnswer >= 0)
                                  Text(
                                    'Your answer: ${_getOptionText(question, userAnswer)}',
                                    style: TextStyle(
                                      color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (!isCorrect)
                                  Text(
                                    'Correct answer: ${_getOptionText(question, correctAnswer)}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _getOptionText(Map<String, dynamic> question, int index) {
    final options = question['options'] as List<dynamic>? ?? [];
    if (index >= 0 && index < options.length) {
      return options[index] as String;
    }
    return 'N/A';
  }
}

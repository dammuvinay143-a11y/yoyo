import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/data/models/quiz_model.dart';
import '../../data/repositories/admin_repository.dart';

class ViewQuizResultsPage extends StatelessWidget {
  const ViewQuizResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminRepo = RepositoryProvider.of<AdminRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
      ),
      body: StreamBuilder<List<QuizModel>>(
        stream: adminRepo.getAllQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return const Center(
              child: Text('No quizzes found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _QuizResultCard(quiz: quiz, adminRepo: adminRepo);
            },
          );
        },
      ),
    );
  }
}

class _QuizResultCard extends StatelessWidget {
  final QuizModel quiz;
  final AdminRepository adminRepo;

  const _QuizResultCard({
    required this.quiz,
    required this.adminRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          quiz.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Created: ${DateFormat('MMM dd, yyyy').format(quiz.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: quiz.isPublished ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quiz.isPublished ? 'Published' : 'Draft',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${quiz.questions.length} questions • ${quiz.duration} min',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getQuizAttempts(quiz.quizId),
            builder: (context, attemptSnapshot) {
              if (attemptSnapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (attemptSnapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${attemptSnapshot.error}'),
                );
              }

              final attempts = attemptSnapshot.data ?? [];

              if (attempts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No attempts yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Total Attempts',
                              attempts.length.toString(),
                              Icons.people,
                              AppColors.primary,
                            ),
                            _buildStatCard(
                              'Avg Score',
                              '${_calculateAverageScore(attempts, quiz.questions.length).toStringAsFixed(1)}%',
                              Icons.assessment,
                              AppColors.success,
                            ),
                            _buildStatCard(
                              'Pass Rate',
                              '${_calculatePassRate(attempts, quiz.questions.length).toStringAsFixed(0)}%',
                              Icons.check_circle,
                              AppColors.info,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Student Results',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...attempts.map((attempt) => _AttemptTile(
                        attempt: attempt,
                        totalQuestions: quiz.questions.length,
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getQuizAttempts(String quizId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quiz_attempts')
          .where('quizId', isEqualTo: quizId)
          .get();

      final attempts = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Skip incomplete attempts (where endTime is null)
        if (data['endTime'] == null) continue;
        
        final studentId = data['studentId'] as String;
        final studentName = await adminRepo.getStudentName(studentId);
        
        attempts.add({
          'attemptId': doc.id,
          'studentId': studentId,
          'studentName': studentName,
          'score': data['score'] ?? 0,
          'endTime': data['endTime'],
        });
      }

      // Sort by score descending
      attempts.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      return attempts;
    } catch (e) {
      return [];
    }
  }

  double _calculateAverageScore(List<Map<String, dynamic>> attempts, int totalQuestions) {
    if (attempts.isEmpty) return 0;
    final totalScore = attempts.fold<int>(0, (sum, attempt) => sum + (attempt['score'] as int));
    return (totalScore / attempts.length / totalQuestions) * 100;
  }

  double _calculatePassRate(List<Map<String, dynamic>> attempts, int totalQuestions) {
    if (attempts.isEmpty) return 0;
    final passCount = attempts.where((attempt) {
      final percentage = (attempt['score'] as int) / totalQuestions * 100;
      return percentage >= 60; // 60% passing grade
    }).length;
    return (passCount / attempts.length) * 100;
  }
}

class _AttemptTile extends StatelessWidget {
  final Map<String, dynamic> attempt;
  final int totalQuestions;

  const _AttemptTile({
    required this.attempt,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final score = attempt['score'] as int;
    final percentage = (score / totalQuestions * 100);
    final isPassed = percentage >= 60;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPassed ? Colors.green : Colors.red,
        child: Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        attempt['studentName'] as String,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Score: $score/$totalQuestions${attempt['endTime'] != null ? ' • ${DateFormat('MMM dd, yyyy hh:mm a').format((attempt['endTime'] as Timestamp).toDate())}' : ''}',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPassed ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(12),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/data/models/submission_model.dart';
import '../../../student/data/models/task_model.dart';
import '../../data/repositories/admin_repository.dart';

class TaskSubmissionsPage extends StatelessWidget {
  const TaskSubmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminRepo = RepositoryProvider.of<AdminRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Submissions'),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: adminRepo.getAllTasks(),
        builder: (context, taskSnapshot) {
          if (taskSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskSnapshot.hasError) {
            return Center(
              child: Text('Error: ${taskSnapshot.error}'),
            );
          }

          final tasks = taskSnapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskSubmissionCard(
                task: task,
                adminRepo: adminRepo,
              );
            },
          );
        },
      ),
    );
  }
}

class TaskSubmissionCard extends StatelessWidget {
  final TaskModel task;
  final AdminRepository adminRepo;

  const TaskSubmissionCard({
    super.key,
    required this.task,
    required this.adminRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          StreamBuilder<List<SubmissionModel>>(
            stream: adminRepo.getTaskSubmissions(task.taskId),
            builder: (context, submissionSnapshot) {
              if (submissionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (submissionSnapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${submissionSnapshot.error}'),
                );
              }

              final submissions = submissionSnapshot.data ?? [];

              if (submissions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No submissions yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${submissions.length} submission(s)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...submissions.map((submission) => SubmissionTile(
                        submission: submission,
                        task: task,
                        adminRepo: adminRepo,
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SubmissionTile extends StatelessWidget {
  final SubmissionModel submission;
  final TaskModel task;
  final AdminRepository adminRepo;

  const SubmissionTile({
    super.key,
    required this.submission,
    required this.task,
    required this.adminRepo,
  });

  @override
  Widget build(BuildContext context) {
    final isGraded = submission.isGraded;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isGraded ? Colors.green : Colors.orange,
        child: Icon(
          isGraded ? Icons.check : Icons.pending,
          color: Colors.white,
        ),
      ),
      title: FutureBuilder<String>(
        future: _getStudentName(submission.studentId),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ?? 'Loading...',
            style: const TextStyle(fontWeight: FontWeight.w600),
          );
        },
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submitted: ${DateFormat('MMM dd, yyyy hh:mm a').format(submission.submittedAt)}',
          ),
          if (isGraded)
            Text(
              'Grade: ${submission.grade}/${task.marks}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const Text(
              'Status: Pending Review',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      trailing: !isGraded
          ? IconButton(
              icon: const Icon(Icons.rate_review, color: AppColors.primary),
              onPressed: () => _showGradeDialog(context),
            )
          : null,
      onTap: () => _showSubmissionDetails(context),
    );
  }

  Future<String> _getStudentName(String studentId) async {
    return await adminRepo.getStudentName(studentId);
  }

  void _showSubmissionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submission Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Submitted: ${DateFormat('MMM dd, yyyy hh:mm a').format(submission.submittedAt)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (submission.textSubmission.isNotEmpty) ...[
                const Text(
                  'Text Submission:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(submission.textSubmission),
                const SizedBox(height: 12),
              ],
              if (submission.files.isNotEmpty) ...[
                const Text(
                  'Attached Files:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...submission.files.map((file) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              file.split('/').last,
                              style: const TextStyle(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
              ],
              if (submission.isGraded) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Grade: ${submission.grade}/${task.marks}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                if (submission.feedback != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Feedback:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(submission.feedback!),
                ],
              ],
            ],
          ),
        ),
        actions: [
          if (!submission.isGraded)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showGradeDialog(context);
              },
              child: const Text('Grade Submission'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGradeDialog(BuildContext context) {
    final gradeController = TextEditingController();
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Grade Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Grade (out of ${task.marks})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final grade = int.tryParse(gradeController.text);
              if (grade == null || grade < 0 || grade > task.marks) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Please enter a valid grade between 0 and ${task.marks}'),
                  ),
                );
                return;
              }

              try {
                await adminRepo.gradeSubmission(
                  submission.submissionId,
                  grade,
                  feedbackController.text.trim().isEmpty
                      ? null
                      : feedbackController.text.trim(),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Submission graded successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Submit Grade'),
          ),
        ],
      ),
    );
  }
}

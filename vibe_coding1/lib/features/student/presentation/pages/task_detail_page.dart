import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/task_bloc.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _textController = TextEditingController();
  final List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTaskDetail(widget.taskId));
    _loadSubmission();
  }

  void _loadSubmission() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TaskBloc>().add(
            LoadSubmission(widget.taskId, authState.user.uid),
          );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: true, // Important for web
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _submitTask() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    if (_selectedFiles.isEmpty && _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add files or text submission')),
      );
      return;
    }

    context.read<TaskBloc>().add(
          SubmitTask(
            taskId: widget.taskId,
            studentId: authState.user.uid,
            files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
            textSubmission: _textController.text.trim().isNotEmpty
                ? _textController.text.trim()
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TaskSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskDetailLoaded) {
            final task = state.task;
            final submission = state.submission;
            final hasSubmission = submission != null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.event,
                                'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                                task.isOverdue ? Colors.red : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.star,
                                '${task.marks} Points',
                                AppColors.warning,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          if (task.attachments.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Attachments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...task.attachments.map((url) {
                              final fileName = url.split('/').last;
                              return ListTile(
                                leading: const Icon(Icons.attachment),
                                title: Text(fileName),
                                trailing: IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () async {
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submission Section
                  if (hasSubmission) ...[
                    const Text(
                      'Your Submission',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                const Text(
                                  'Submitted',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Submitted on: ${DateFormat('MMM dd, yyyy hh:mm a').format(submission.submittedAt)}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            if (submission.isGraded) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Grade: ${submission.grade}/${task.marks}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (submission.feedback != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Feedback: ${submission.feedback}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Submit Your Work',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Text Submission (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _textController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'Enter your response here...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'File Attachments',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedFiles.isNotEmpty) ...[
                              ..._selectedFiles.asMap().entries.map((entry) {
                                return ListTile(
                                  leading: const Icon(Icons.insert_drive_file),
                                  title: Text(entry.value.name),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => _removeFile(entry.key),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                            ],
                            OutlinedButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Add Files'),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Submit Task',
                              onPressed: task.isOverdue ? () {} : _submitTask,
                              icon: Icons.send,
                            ),
                            if (task.isOverdue)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Submission closed - Task is overdue',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const Center(child: Text('Failed to load task'));
        },
      ),
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
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

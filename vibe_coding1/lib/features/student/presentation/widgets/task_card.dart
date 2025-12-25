import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = task.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
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
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${task.marks} pts',
                      style: TextStyle(
                        color: isOverdue ? AppColors.error : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(task.dueDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!isOverdue) ...[
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: daysLeft <= 2 ? Colors.orange : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      daysLeft == 0
                          ? 'Due today'
                          : daysLeft == 1
                              ? '1 day left'
                              : '$daysLeft days left',
                      style: TextStyle(
                        fontSize: 14,
                        color: daysLeft <= 2 ? Colors.orange : Colors.grey[600],
                        fontWeight:
                            daysLeft <= 2 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ] else
                    Text(
                      'Overdue',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              if (task.attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '${task.attachments.length} attachment(s)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

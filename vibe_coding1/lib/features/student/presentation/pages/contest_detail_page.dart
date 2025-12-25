import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../contests/data/models/contest_model.dart';
import '../../../contests/data/repositories/contest_repository.dart';
import 'package:intl/intl.dart';

class ContestDetailPage extends StatelessWidget {
  final String contestId;

  const ContestDetailPage({super.key, required this.contestId});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ContestRepository>();

    return FutureBuilder<ContestModel?>(
      future: repository.getContest(contestId),
      builder: (context, contestSnapshot) {
        if (contestSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final contest = contestSnapshot.data;
        if (contest == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Contest')),
            body: const Center(child: Text('Contest not found')),
          );
        }

        return FutureBuilder<List<ProblemModel>>(
          future: repository.getContestProblems(contest.problems),
          builder: (context, problemsSnapshot) {
            final problems = problemsSnapshot.data ?? [];

            return Scaffold(
              appBar: AppBar(
                title: Text(contest.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.leaderboard),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.leaderboard,
                        arguments: contestId,
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contest Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade400, Colors.purple.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contest.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _InfoItem(
                                icon: Icons.timer,
                                label: '${contest.durationMinutes} minutes',
                              ),
                              const SizedBox(width: 16),
                              _InfoItem(
                                icon: Icons.code,
                                label: '${problems.length} problems',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start: ${DateFormat('MMM dd, yyyy • hh:mm a').format(contest.startTime)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'End: ${DateFormat('MMM dd, yyyy • hh:mm a').format(contest.endTime)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Problems List
                    const Text(
                      'Problems',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (problemsSnapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (problems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No problems added yet'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: problems.length,
                        itemBuilder: (context, index) {
                          final problem = problems[index];
                          return _ProblemCard(
                            problem: problem,
                            index: index,
                            contestId: contestId,
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final ProblemModel problem;
  final int index;
  final String contestId;

  const _ProblemCard({
    required this.problem,
    required this.index,
    required this.contestId,
  });

  Color _getDifficultyColor() {
    switch (problem.difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (problem.platform != ProblemPlatform.custom && 
              problem.platformLink != null) {
            // Show dialog for external link
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(problem.title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This problem is hosted on ${problem.platform.name}'),
                    const SizedBox(height: 16),
                    Text('Link: ${problem.platformLink}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Open in browser or submission page
                      Navigator.pushNamed(
                        context,
                        AppRouter.problemSolving,
                        arguments: {
                          'problemId': problem.problemId,
                          'contestId': contestId,
                        },
                      );
                    },
                    child: const Text('Solve'),
                  ),
                ],
              ),
            );
          } else {
            Navigator.pushNamed(
              context,
              AppRouter.problemSolving,
              arguments: {
                'problemId': problem.problemId,
                'contestId': contestId,
              },
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          problem.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          problem.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getDifficultyColor()),
                    ),
                    child: Text(
                      problem.difficulty.toUpperCase(),
                      style: TextStyle(
                        color: _getDifficultyColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${problem.points} points',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (problem.platform != ProblemPlatform.custom)
                    Chip(
                      label: Text(
                        problem.platform.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

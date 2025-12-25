import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class ContestWinnersPage extends StatelessWidget {
  const ContestWinnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contest Winners'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contests')
            .where('isActive', isEqualTo: false)
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

          final contests = snapshot.data?.docs ?? [];

          if (contests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No completed contests yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contests.length,
            itemBuilder: (context, index) {
              final contestData = contests[index].data() as Map<String, dynamic>;
              final contestId = contests[index].id;
              return _ContestWinnerCard(
                contestId: contestId,
                contestData: contestData,
              );
            },
          );
        },
      ),
    );
  }
}

class _ContestWinnerCard extends StatelessWidget {
  final String contestId;
  final Map<String, dynamic> contestData;

  const _ContestWinnerCard({
    required this.contestId,
    required this.contestData,
  });

  @override
  Widget build(BuildContext context) {
    final title = contestData['title'] as String? ?? 'Unknown Contest';
    final endTime = (contestData['endTime'] as Timestamp?)?.toDate();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: endTime != null
            ? Text(
                'Ended: ${DateFormat('MMM dd, yyyy').format(endTime)}',
                style: TextStyle(color: Colors.grey[600]),
              )
            : null,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getContestWinners(contestId),
            builder: (context, winnerSnapshot) {
              if (winnerSnapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (winnerSnapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${winnerSnapshot.error}'),
                );
              }

              final winners = winnerSnapshot.data ?? [];

              if (winners.isEmpty) {
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
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '🏆 Leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...winners.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final winner = entry.value;
                    return _WinnerTile(
                      rank: rank,
                      studentName: winner['studentName'] as String,
                      score: winner['score'] as int,
                      totalScore: winner['totalScore'] as int,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getContestWinners(String contestId) async {
    try {
      // Get all submissions for this contest
      final submissionsSnapshot = await FirebaseFirestore.instance
          .collection('submissions')
          .where('contestId', isEqualTo: contestId)
          .get();

      // Group by student and calculate total score
      final studentScores = <String, int>{};
      final studentNames = <String, String>{};

      for (var doc in submissionsSnapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'] as String;
        final score = data['score'] as int? ?? 0;

        studentScores[studentId] = (studentScores[studentId] ?? 0) + score;

        // Get student name if not already fetched
        if (!studentNames.containsKey(studentId)) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            studentNames[studentId] = userData['name'] as String? ?? 'Unknown';
          }
        }
      }

      // Calculate total possible score from contest problems
      final contestDoc = await FirebaseFirestore.instance
          .collection('contests')
          .doc(contestId)
          .get();
      
      final contestData = contestDoc.data() as Map<String, dynamic>;
      final problemIds = List<String>.from(contestData['problems'] ?? []);
      
      int totalScore = 0;
      for (var problemId in problemIds) {
        final problemDoc = await FirebaseFirestore.instance
            .collection('contest_problems')
            .doc(problemId)
            .get();
        if (problemDoc.exists) {
          final problemData = problemDoc.data() as Map<String, dynamic>;
          totalScore += problemData['points'] as int? ?? 0;
        }
      }

      // Sort by score descending
      final winners = studentScores.entries.map((entry) {
        return {
          'studentId': entry.key,
          'studentName': studentNames[entry.key] ?? 'Unknown',
          'score': entry.value,
          'totalScore': totalScore,
        };
      }).toList();

      winners.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      return winners.take(10).toList(); // Top 10 winners
    } catch (e) {
      return [];
    }
  }
}

class _WinnerTile extends StatelessWidget {
  final int rank;
  final String studentName;
  final int score;
  final int totalScore;

  const _WinnerTile({
    required this.rank,
    required this.studentName,
    required this.score,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    IconData rankIcon;
    
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        rankIcon = Icons.looks_one;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        rankIcon = Icons.looks_two;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        rankIcon = Icons.looks_3;
        break;
      default:
        rankColor = Colors.grey;
        rankIcon = Icons.person;
    }

    final percentage = totalScore > 0 ? (score / totalScore * 100).toStringAsFixed(1) : '0';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rankColor,
        child: rank <= 3
            ? Icon(rankIcon, color: Colors.white)
            : Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      title: Text(
        studentName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Score: $score/$totalScore'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$percentage%',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

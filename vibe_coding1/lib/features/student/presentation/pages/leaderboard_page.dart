import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../contests/data/models/contest_model.dart';
import '../../../contests/data/repositories/contest_repository.dart';

class LeaderboardPage extends StatelessWidget {
  final String contestId;

  const LeaderboardPage({super.key, required this.contestId});

  @override
  Widget build(BuildContext context) {
    return _LeaderboardContent(contestId: contestId);
  }
}

class _LeaderboardContent extends StatefulWidget {
  final String contestId;

  const _LeaderboardContent({required this.contestId});

  @override
  State<_LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends State<_LeaderboardContent> {
  late Future<List<LeaderboardEntry>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _refreshLeaderboard();
  }

  void _refreshLeaderboard() {
    final repository = context.read<ContestRepository>();
    setState(() {
      _leaderboardFuture = repository.getLeaderboard(widget.contestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLeaderboard,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final leaderboard = snapshot.data ?? [];

          if (leaderboard.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.leaderboard, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No submissions yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Top 3 Podium
              if (leaderboard.isNotEmpty)
                _TopThreePodium(topThree: leaderboard.take(3).toList()),

              // Rest of the list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    return _LeaderboardTile(
                      entry: entry,
                      contestId: widget.contestId,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const _TopThreePodium({required this.topThree});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (topThree.length > 1)
            _PodiumSpot(
              entry: topThree[1],
              rank: 2,
              height: 120,
              color: Colors.grey,
            ),
          const SizedBox(width: 16),
          // 1st Place
          if (topThree.isNotEmpty)
            _PodiumSpot(
              entry: topThree[0],
              rank: 1,
              height: 160,
              color: Colors.amber,
            ),
          const SizedBox(width: 16),
          // 3rd Place
          if (topThree.length > 2)
            _PodiumSpot(
              entry: topThree[2],
              rank: 3,
              height: 100,
              color: Colors.brown,
            ),
        ],
      ),
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final Color color;

  const _PodiumSpot({
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: color.withOpacity(0.2),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: entry.photoUrl != null
                    ? NetworkImage(entry.photoUrl!)
                    : null,
                child: entry.photoUrl == null
                    ? Text(
                        entry.studentName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            entry.studentName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${entry.totalScore} pts',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                rank == 1
                    ? Icons.emoji_events
                    : rank == 2
                        ? Icons.military_tech
                        : Icons.workspace_premium,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final String contestId;

  const _LeaderboardTile({
    required this.entry,
    required this.contestId,
  });

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTopThree = entry.rank <= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isTopThree ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTopThree
            ? BorderSide(color: _getRankColor(entry.rank), width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(entry.rank).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    color: _getRankColor(entry.rank),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundImage: entry.photoUrl != null
                  ? NetworkImage(entry.photoUrl!)
                  : null,
              child: entry.photoUrl == null
                  ? Text(entry.studentName[0].toUpperCase())
                  : null,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.studentName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isTopThree)
              Icon(
                _getRankIcon(entry.rank),
                color: _getRankColor(entry.rank),
                size: 20,
              ),
          ],
        ),
        subtitle: Text(
          '${entry.problemsSolved} problems solved • ${entry.totalTime}s',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalScore}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getRankColor(entry.rank),
              ),
            ),
            const Text(
              'points',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: isTopThree
            ? () {
                _showCertificateDialog(context, entry, contestId);
              }
            : null,
      ),
    );
  }

  void _showCertificateDialog(
    BuildContext context,
    LeaderboardEntry entry,
    String contestId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You ranked #${entry.rank} in this contest!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 You are eligible for a certificate! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _generateCertificate(context, entry, contestId);
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Get Certificate',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateCertificate(
    BuildContext context,
    LeaderboardEntry entry,
    String contestId,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your certificate...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate certificate generation
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Certificate generated for ${entry.studentName}! (Rank #${entry.rank})',
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              // In a real app, this would open the certificate PDF
            },
          ),
        ),
      );
    }
  }
}

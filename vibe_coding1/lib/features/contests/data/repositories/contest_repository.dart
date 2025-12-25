import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contest_model.dart';

class ContestRepository {
  final FirebaseFirestore _firestore;

  ContestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get active contests for student
  Stream<List<ContestModel>> getActiveContests(String department, int year) {
    return _firestore
        .collection('contests')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final contests = snapshot.docs
              .map((doc) => ContestModel.fromFirestore(doc))
              .where((contest) {
                final now = DateTime.now();
                final isTimeValid = contest.startTime.isBefore(now) &&
                    contest.endTime.isAfter(now);
                final departmentMatch = contest.targetDepartments.isEmpty ||
                    contest.targetDepartments.contains(department);
                final yearMatch = contest.targetYears.isEmpty ||
                    contest.targetYears.contains(year);
                return isTimeValid && departmentMatch && yearMatch;
              })
              .toList();
          contests.sort((a, b) => a.startTime.compareTo(b.startTime));
          return contests;
        });
  }

  // Get all contests (admin)
  Stream<List<ContestModel>> getAllContests() {
    return _firestore
        .collection('contests')
        .snapshots()
        .map((snapshot) {
          final contests = snapshot.docs
              .map((doc) => ContestModel.fromFirestore(doc))
              .toList();
          contests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return contests;
        });
  }

  // Create contest
  Future<void> createContest(ContestModel contest) async {
    try {
      await _firestore.collection('contests').add(contest.toFirestore());
    } catch (e) {
      throw Exception('Failed to create contest: $e');
    }
  }

  // Get contest details
  Future<ContestModel?> getContest(String contestId) async {
    try {
      final doc = await _firestore.collection('contests').doc(contestId).get();
      if (doc.exists) {
        return ContestModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get contest: $e');
    }
  }

  // Create problem
  Future<String> createProblem(ProblemModel problem) async {
    try {
      final docRef =
          await _firestore.collection('problems').add(problem.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create problem: $e');
    }
  }

  // Get problem
  Future<ProblemModel?> getProblem(String problemId) async {
    try {
      // First try contest_problems collection (for problem references with test cases)
      var doc = await _firestore.collection('contest_problems').doc(problemId).get();
      
      if (doc.exists) {
        // Convert contest_problem to ProblemModel with test cases
        final data = doc.data() as Map<String, dynamic>;
        
        // Parse test cases
        final testCasesList = (data['testCases'] as List<dynamic>?)
            ?.map((tc) {
              final tcMap = tc as Map<String, dynamic>;
              return TestCase(
                input: tcMap['input'] as String? ?? '',
                expectedOutput: tcMap['expectedOutput'] as String? ?? '',
                explanation: tcMap['explanation'] as String?,
              );
            })
            .toList() ?? [];
        
        return ProblemModel(
          problemId: doc.id,
          title: data['title'] as String? ?? '',
          description: data['description'] as String? ?? '',
          problemStatement: data['problemStatement'] as String? ?? data['link'] as String? ?? '',
          difficulty: (data['difficulty'] as String? ?? 'Medium').toLowerCase(),
          points: data['points'] as int? ?? 100,
          timeLimit: data['timeLimit'] as int? ?? 1,
          memoryLimit: data['memoryLimit'] as int? ?? 256,
          testCases: testCasesList,
          platform: _getPlatformEnum(data['platform'] as String? ?? 'Custom'),
          platformLink: data['link'] as String?,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          createdBy: data['createdBy'] as String? ?? '',
        );
      }
      
      // Fallback to problems collection (for full problem definitions)
      doc = await _firestore.collection('problems').doc(problemId).get();
      if (doc.exists) {
        return ProblemModel.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get problem: $e');
    }
  }
  
  ProblemPlatform _getPlatformEnum(String platform) {
    switch (platform.toLowerCase()) {
      case 'leetcode':
        return ProblemPlatform.leetcode;
      case 'hackerrank':
        return ProblemPlatform.hackerrank;
      default:
        return ProblemPlatform.custom;
    }
  }

  // Get problems for contest
  Future<List<ProblemModel>> getContestProblems(List<String> problemIds) async {
    try {
      final problems = <ProblemModel>[];
      for (final id in problemIds) {
        final problem = await getProblem(id);
        if (problem != null) {
          problems.add(problem);
        }
      }
      return problems;
    } catch (e) {
      throw Exception('Failed to get contest problems: $e');
    }
  }

  // Submit solution
  Future<String> submitSolution(SubmissionModel submission) async {
    try {
      final docRef = await _firestore
          .collection('submissions')
          .add(submission.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit solution: $e');
    }
  }

  // Get student submissions for contest
  Stream<List<SubmissionModel>> getStudentSubmissions(
      String contestId, String studentId) {
    return _firestore
        .collection('submissions')
        .where('contestId', isEqualTo: contestId)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final submissions = snapshot.docs
              .map((doc) => SubmissionModel.fromFirestore(doc))
              .toList();
          submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          return submissions;
        });
  }

  // Get leaderboard for contest
  Future<List<LeaderboardEntry>> getLeaderboard(String contestId) async {
    try {
      final submissions = await _firestore
          .collection('submissions')
          .where('contestId', isEqualTo: contestId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // Group by student
      final Map<String, LeaderboardEntry> leaderboardMap = {};

      for (final doc in submissions.docs) {
        final sub = SubmissionModel.fromFirestore(doc);
        final studentId = sub.studentId;

        if (leaderboardMap.containsKey(studentId)) {
          final existing = leaderboardMap[studentId]!;
          leaderboardMap[studentId] = LeaderboardEntry(
            studentId: studentId,
            studentName: existing.studentName,
            photoUrl: existing.photoUrl,
            totalScore: existing.totalScore + (sub.score ?? 0),
            problemsSolved: existing.problemsSolved + 1,
            totalTime: existing.totalTime + (sub.executionTime ?? 0),
            lastSubmission: sub.submittedAt.isAfter(existing.lastSubmission)
                ? sub.submittedAt
                : existing.lastSubmission,
          );
        } else {
          // Get student info
          final userDoc =
              await _firestore.collection('users').doc(studentId).get();
          final userData = userDoc.data();

          leaderboardMap[studentId] = LeaderboardEntry(
            studentId: studentId,
            studentName: userData?['name'] ?? 'Unknown',
            photoUrl: userData?['photoUrl'],
            totalScore: sub.score ?? 0,
            problemsSolved: 1,
            totalTime: sub.executionTime ?? 0,
            lastSubmission: sub.submittedAt,
          );
        }
      }

      // Sort and assign ranks
      final leaderboard = leaderboardMap.values.toList();
      leaderboard.sort((a, b) {
        final scoreCompare = b.totalScore.compareTo(a.totalScore);
        if (scoreCompare != 0) return scoreCompare;
        return a.totalTime.compareTo(b.totalTime);
      });

      // Assign ranks
      for (int i = 0; i < leaderboard.length; i++) {
        final entry = leaderboard[i];
        leaderboard[i] = LeaderboardEntry(
          studentId: entry.studentId,
          studentName: entry.studentName,
          photoUrl: entry.photoUrl,
          totalScore: entry.totalScore,
          problemsSolved: entry.problemsSolved,
          totalTime: entry.totalTime,
          lastSubmission: entry.lastSubmission,
          rank: i + 1,
        );
      }

      return leaderboard;
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  // Update submission status
  Future<void> updateSubmissionStatus(
    String submissionId,
    SubmissionStatus status,
    int? score,
    List<TestCaseResult> testResults,
    String? errorMessage,
  ) async {
    try {
      await _firestore.collection('submissions').doc(submissionId).update({
        'status': status.name,
        'score': score,
        'testResults': testResults.map((tr) => tr.toMap()).toList(),
        'errorMessage': errorMessage,
      });
    } catch (e) {
      throw Exception('Failed to update submission: $e');
    }
  }
}

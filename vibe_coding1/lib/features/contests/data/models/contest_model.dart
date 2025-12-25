import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ContestModel extends Equatable {
  final String contestId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final List<String> problems; // Problem IDs
  final List<String> targetDepartments;
  final List<int> targetYears;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final int maxParticipants;
  final ContestType type; // individual or team

  const ContestModel({
    required this.contestId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.problems = const [],
    this.targetDepartments = const [],
    this.targetYears = const [],
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.maxParticipants = 0,
    this.type = ContestType.individual,
  });

  factory ContestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContestModel(
      contestId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 60,
      problems: List<String>.from(data['problems'] ?? []),
      targetDepartments: List<String>.from(data['targetDepartments'] ?? []),
      targetYears: List<int>.from(data['targetYears'] ?? []),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      maxParticipants: data['maxParticipants'] ?? 0,
      type: ContestType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'individual'),
        orElse: () => ContestType.individual,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMinutes': durationMinutes,
      'problems': problems,
      'targetDepartments': targetDepartments,
      'targetYears': targetYears,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'maxParticipants': maxParticipants,
      'type': type.name,
    };
  }

  @override
  List<Object?> get props => [
        contestId,
        title,
        description,
        startTime,
        endTime,
        durationMinutes,
        problems,
        targetDepartments,
        targetYears,
        isActive,
        createdBy,
        createdAt,
        maxParticipants,
        type,
      ];
}

enum ContestType { individual, team }

class ProblemModel extends Equatable {
  final String problemId;
  final String title;
  final String description;
  final String difficulty; // easy, medium, hard
  final List<String> tags;
  final String problemStatement;
  final List<TestCase> testCases;
  final List<TestCase> hiddenTestCases;
  final int points;
  final int timeLimit; // in seconds
  final int memoryLimit; // in MB
  final ProblemPlatform platform; // leetcode, hackerrank, custom
  final String? platformLink; // External link if leetcode/hackerrank
  final String? solutionTemplate;
  final DateTime createdAt;
  final String createdBy;

  const ProblemModel({
    required this.problemId,
    required this.title,
    required this.description,
    this.difficulty = 'medium',
    this.tags = const [],
    required this.problemStatement,
    this.testCases = const [],
    this.hiddenTestCases = const [],
    this.points = 100,
    this.timeLimit = 1,
    this.memoryLimit = 256,
    this.platform = ProblemPlatform.custom,
    this.platformLink,
    this.solutionTemplate,
    required this.createdAt,
    required this.createdBy,
  });

  factory ProblemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProblemModel(
      problemId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      tags: List<String>.from(data['tags'] ?? []),
      problemStatement: data['problemStatement'] ?? '',
      testCases: (data['testCases'] as List<dynamic>?)
              ?.map((tc) => TestCase.fromMap(tc as Map<String, dynamic>))
              .toList() ??
          [],
      hiddenTestCases: (data['hiddenTestCases'] as List<dynamic>?)
              ?.map((tc) => TestCase.fromMap(tc as Map<String, dynamic>))
              .toList() ??
          [],
      points: data['points'] ?? 100,
      timeLimit: data['timeLimit'] ?? 1,
      memoryLimit: data['memoryLimit'] ?? 256,
      platform: ProblemPlatform.values.firstWhere(
        (e) => e.name == (data['platform'] ?? 'custom'),
        orElse: () => ProblemPlatform.custom,
      ),
      platformLink: data['platformLink'],
      solutionTemplate: data['solutionTemplate'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'tags': tags,
      'problemStatement': problemStatement,
      'testCases': testCases.map((tc) => tc.toMap()).toList(),
      'hiddenTestCases': hiddenTestCases.map((tc) => tc.toMap()).toList(),
      'points': points,
      'timeLimit': timeLimit,
      'memoryLimit': memoryLimit,
      'platform': platform.name,
      'platformLink': platformLink,
      'solutionTemplate': solutionTemplate,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        problemId,
        title,
        description,
        difficulty,
        tags,
        problemStatement,
        testCases,
        hiddenTestCases,
        points,
        timeLimit,
        memoryLimit,
        platform,
        platformLink,
        solutionTemplate,
        createdAt,
        createdBy,
      ];
}

enum ProblemPlatform { leetcode, hackerrank, custom }

class TestCase extends Equatable {
  final String input;
  final String expectedOutput;
  final String? explanation;

  const TestCase({
    required this.input,
    required this.expectedOutput,
    this.explanation,
  });

  factory TestCase.fromMap(Map<String, dynamic> map) {
    return TestCase(
      input: map['input'] ?? '',
      expectedOutput: map['expectedOutput'] ?? '',
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
      'explanation': explanation,
    };
  }

  @override
  List<Object?> get props => [input, expectedOutput, explanation];
}

class SubmissionModel extends Equatable {
  final String submissionId;
  final String contestId;
  final String problemId;
  final String studentId;
  final String code;
  final String language;
  final SubmissionStatus status;
  final int? score;
  final int? executionTime;
  final String? errorMessage;
  final List<TestCaseResult> testResults;
  final DateTime submittedAt;

  const SubmissionModel({
    required this.submissionId,
    required this.contestId,
    required this.problemId,
    required this.studentId,
    required this.code,
    required this.language,
    this.status = SubmissionStatus.pending,
    this.score,
    this.executionTime,
    this.errorMessage,
    this.testResults = const [],
    required this.submittedAt,
  });

  factory SubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubmissionModel(
      submissionId: doc.id,
      contestId: data['contestId'] ?? '',
      problemId: data['problemId'] ?? '',
      studentId: data['studentId'] ?? '',
      code: data['code'] ?? '',
      language: data['language'] ?? 'python',
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => SubmissionStatus.pending,
      ),
      score: data['score'],
      executionTime: data['executionTime'],
      errorMessage: data['errorMessage'],
      testResults: (data['testResults'] as List<dynamic>?)
              ?.map((tr) =>
                  TestCaseResult.fromMap(tr as Map<String, dynamic>))
              .toList() ??
          [],
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'contestId': contestId,
      'problemId': problemId,
      'studentId': studentId,
      'code': code,
      'language': language,
      'status': status.name,
      'score': score,
      'executionTime': executionTime,
      'errorMessage': errorMessage,
      'testResults': testResults.map((tr) => tr.toMap()).toList(),
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  @override
  List<Object?> get props => [
        submissionId,
        contestId,
        problemId,
        studentId,
        code,
        language,
        status,
        score,
        executionTime,
        errorMessage,
        testResults,
        submittedAt,
      ];
}

enum SubmissionStatus { pending, running, accepted, wrongAnswer, timeLimit, memoryLimit, runtimeError, compileError }

class TestCaseResult extends Equatable {
  final bool passed;
  final String? actualOutput;
  final int? executionTime;

  const TestCaseResult({
    required this.passed,
    this.actualOutput,
    this.executionTime,
  });

  factory TestCaseResult.fromMap(Map<String, dynamic> map) {
    return TestCaseResult(
      passed: map['passed'] ?? false,
      actualOutput: map['actualOutput'],
      executionTime: map['executionTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passed': passed,
      'actualOutput': actualOutput,
      'executionTime': executionTime,
    };
  }

  @override
  List<Object?> get props => [passed, actualOutput, executionTime];
}

class LeaderboardEntry extends Equatable {
  final String studentId;
  final String studentName;
  final String? photoUrl;
  final int totalScore;
  final int problemsSolved;
  final int totalTime; // in seconds
  final DateTime lastSubmission;
  final int rank;

  const LeaderboardEntry({
    required this.studentId,
    required this.studentName,
    this.photoUrl,
    required this.totalScore,
    required this.problemsSolved,
    required this.totalTime,
    required this.lastSubmission,
    this.rank = 0,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      studentId: doc.id,
      studentName: data['studentName'] ?? '',
      photoUrl: data['photoUrl'],
      totalScore: data['totalScore'] ?? 0,
      problemsSolved: data['problemsSolved'] ?? 0,
      totalTime: data['totalTime'] ?? 0,
      lastSubmission: (data['lastSubmission'] as Timestamp).toDate(),
      rank: data['rank'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentName': studentName,
      'photoUrl': photoUrl,
      'totalScore': totalScore,
      'problemsSolved': problemsSolved,
      'totalTime': totalTime,
      'lastSubmission': Timestamp.fromDate(lastSubmission),
      'rank': rank,
    };
  }

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        photoUrl,
        totalScore,
        problemsSolved,
        totalTime,
        lastSubmission,
        rank,
      ];
}

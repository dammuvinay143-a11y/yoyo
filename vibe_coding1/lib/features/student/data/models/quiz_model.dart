import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class QuizModel extends Equatable {
  final String quizId;
  final String title;
  final String instructions;
  final List<QuestionModel> questions;
  final int duration; // in minutes
  final int totalMarks;
  final List<String> targetDepartments;
  final bool isPublished;
  final DateTime createdAt;

  const QuizModel({
    required this.quizId,
    required this.title,
    required this.instructions,
    required this.questions,
    required this.duration,
    required this.totalMarks,
    this.targetDepartments = const [],
    this.isPublished = false,
    required this.createdAt,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      quizId: doc.id,
      title: data['title'] ?? '',
      instructions: data['instructions'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromMap(q))
              .toList() ??
          [],
      duration: data['duration'] ?? 30,
      totalMarks: data['totalMarks'] ?? 0,
      targetDepartments: List<String>.from(data['targetDepartments'] ?? []),
      isPublished: data['isPublished'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'instructions': instructions,
      'questions': questions.map((q) => q.toMap()).toList(),
      'duration': duration,
      'totalMarks': totalMarks,
      'targetDepartments': targetDepartments,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [quizId, title, questions, duration, totalMarks];
}

class QuestionModel extends Equatable {
  final String question;
  final List<String> options;
  final int correctAnswer; // index of correct option
  final int marks;
  final String type; // 'mcq', 'true_false'

  const QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.marks,
    this.type = 'mcq',
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      marks: map['marks'] ?? 1,
      type: map['type'] ?? 'mcq',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'marks': marks,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [question, options, correctAnswer, marks];
}

class QuizAttemptModel extends Equatable {
  final String attemptId;
  final String quizId;
  final String studentId;
  final Map<int, int> answers; // question index -> selected option index
  final int score;
  final DateTime startTime;
  final DateTime? endTime;

  const QuizAttemptModel({
    required this.attemptId,
    required this.quizId,
    required this.studentId,
    required this.answers,
    required this.score,
    required this.startTime,
    this.endTime,
  });

  factory QuizAttemptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert answers from Firestore (string keys) to Map<int, int>
    final answersData = data['answers'] as Map<String, dynamic>? ?? {};
    final answers = <int, int>{};
    answersData.forEach((key, value) {
      answers[int.parse(key)] = value as int;
    });
    
    return QuizAttemptModel(
      attemptId: doc.id,
      quizId: data['quizId'] ?? '',
      studentId: data['studentId'] ?? '',
      answers: answers,
      score: data['score'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    // Convert int keys to string keys for Firestore
    final answersMap = answers.map((key, value) => MapEntry(key.toString(), value));
    
    return {
      'quizId': quizId,
      'studentId': studentId,
      'answers': answersMap,
      'score': score,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    };
  }

  bool get isCompleted => endTime != null;

  @override
  List<Object?> get props => [attemptId, quizId, studentId, score, startTime];
}

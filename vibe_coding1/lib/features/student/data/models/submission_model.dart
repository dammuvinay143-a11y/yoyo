import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SubmissionModel extends Equatable {
  final String submissionId;
  final String taskId;
  final String studentId;
  final List<String> files;
  final String textSubmission;
  final DateTime submittedAt;
  final int? grade;
  final String? feedback;

  const SubmissionModel({
    required this.submissionId,
    required this.taskId,
    required this.studentId,
    this.files = const [],
    this.textSubmission = '',
    required this.submittedAt,
    this.grade,
    this.feedback,
  });

  factory SubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubmissionModel(
      submissionId: doc.id,
      taskId: data['taskId'] ?? '',
      studentId: data['studentId'] ?? '',
      files: List<String>.from(data['files'] ?? []),
      textSubmission: data['textSubmission'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      grade: data['grade'],
      feedback: data['feedback'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'studentId': studentId,
      'files': files,
      'textSubmission': textSubmission,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'grade': grade,
      'feedback': feedback,
    };
  }

  bool get isGraded => grade != null;

  @override
  List<Object?> get props => [submissionId, taskId, studentId, submittedAt];
}

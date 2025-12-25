import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String taskId;
  final String title;
  final String description;
  final DateTime dueDate;
  final List<String> attachments;
  final List<String> targetDepartments;
  final List<int> targetYears;
  final int marks;
  final String createdBy;
  final DateTime createdAt;

  const TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.attachments = const [],
    this.targetDepartments = const [],
    this.targetYears = const [],
    required this.marks,
    required this.createdBy,
    required this.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      taskId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      attachments: List<String>.from(data['attachments'] ?? []),
      targetDepartments: List<String>.from(data['targetDepartments'] ?? []),
      targetYears: List<int>.from(data['targetYears'] ?? []),
      marks: data['marks'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'attachments': attachments,
      'targetDepartments': targetDepartments,
      'targetYears': targetYears,
      'marks': marks,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  @override
  List<Object?> get props => [taskId, title, dueDate, marks];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/task_model.dart';
import '../models/submission_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  TaskRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Get tasks for student
  Stream<List<TaskModel>> getTasksForStudent(String department, int year) {
    return _firestore
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .where((task) {
                // Filter by department - check if empty or contains student's department
                final departmentMatch = task.targetDepartments.isEmpty || 
                    task.targetDepartments.contains(department);
                // Filter by year - check if empty or contains student's year
                final yearMatch = task.targetYears.isEmpty || 
                    task.targetYears.contains(year);
                return departmentMatch && yearMatch;
              })
              .toList();
          // Sort in memory to avoid index requirement
          tasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
          return tasks;
        });
  }

  // Get single task
  Future<TaskModel?> getTask(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (doc.exists) {
        return TaskModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  // Submit task
  Future<void> submitTask({
    required String taskId,
    required String studentId,
    List<PlatformFile>? files,
    String? textSubmission,
  }) async {
    try {
      List<String> fileUrls = [];

      // Upload files if any
      if (files != null && files.isNotEmpty) {
        for (var i = 0; i < files.length; i++) {
          final platformFile = files[i];
          final fileName =
              '${studentId}_${DateTime.now().millisecondsSinceEpoch}_${platformFile.name}';
          final ref = _storage.ref().child('task_submissions').child(fileName);
          
          // Upload using bytes for web compatibility
          if (platformFile.bytes != null) {
            await ref.putData(platformFile.bytes!);
          }
          
          final url = await ref.getDownloadURL();
          fileUrls.add(url);
        }
      }

      final submission = SubmissionModel(
        submissionId: '',
        taskId: taskId,
        studentId: studentId,
        files: fileUrls,
        textSubmission: textSubmission ?? '',
        submittedAt: DateTime.now(),
      );

      await _firestore
          .collection('task_submissions')
          .add(submission.toFirestore());
    } catch (e) {
      throw Exception('Failed to submit task: $e');
    }
  }

  // Get student's submission for a task
  Future<SubmissionModel?> getSubmission(
      String taskId, String studentId) async {
    try {
      final query = await _firestore
          .collection('task_submissions')
          .where('taskId', isEqualTo: taskId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return SubmissionModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get submission: $e');
    }
  }

  // Get all submissions by student
  Stream<List<SubmissionModel>> getStudentSubmissions(String studentId) {
    return _firestore
        .collection('task_submissions')
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromFirestore(doc))
            .toList());
  }
}

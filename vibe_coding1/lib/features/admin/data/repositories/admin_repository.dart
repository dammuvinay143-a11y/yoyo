import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../student/data/models/task_model.dart';
import '../../../student/data/models/quiz_model.dart';
import '../../../student/data/models/post_model.dart';
import '../../../student/data/models/submission_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Student Management
  Stream<List<UserModel>> getAllStudents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<void> toggleStudentStatus(String uid, bool isActive) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'isActive': isActive});
  }

  Future<void> deleteStudent(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
    await _firestore.collection('student_profiles').doc(uid).delete();
  }

  // Task Management
  Future<void> createTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toFirestore());
  }

  Stream<List<TaskModel>> getAllTasks() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  Future<void> updateTask(String taskId, TaskModel task) async {
    await _firestore.collection('tasks').doc(taskId).update(task.toFirestore());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // Get submissions for a task
  Stream<List<SubmissionModel>> getTaskSubmissions(String taskId) {
    return _firestore
        .collection('task_submissions')
        .where('taskId', isEqualTo: taskId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromFirestore(doc))
            .toList());
  }

  // Grade submission
  Future<void> gradeSubmission(
      String submissionId, int grade, String? feedback) async {
    await _firestore.collection('task_submissions').doc(submissionId).update({
      'grade': grade,
      'feedback': feedback,
    });
  }

  // Quiz Management
  Future<void> createQuiz(QuizModel quiz) async {
    await _firestore.collection('quizzes').add(quiz.toFirestore());
  }

  Stream<List<QuizModel>> getAllQuizzes() {
    return _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => QuizModel.fromFirestore(doc)).toList());
  }

  Future<void> updateQuiz(String quizId, QuizModel quiz) async {
    await _firestore
        .collection('quizzes')
        .doc(quizId)
        .update(quiz.toFirestore());
  }

  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
  }

  Future<void> toggleQuizPublish(String quizId, bool isPublished) async {
    await _firestore.collection('quizzes').doc(quizId).update({
      'isPublished': isPublished,
    });
  }

  // Post Moderation
  Stream<List<PostModel>> getFlaggedPosts() {
    return _firestore
        .collection('posts')
        .where('isFlagged', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
          // Sort in memory to avoid Firestore index requirement
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return posts;
        });
  }

  Stream<List<PostModel>> getAllPosts() {
    return _firestore
        .collection('posts')
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
          // Sort in memory by creation date
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return posts;
        });
  }

  Future<void> approvePost(String postId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .update({'isFlagged': false});
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // Get student name
  Future<String> getStudentName(String studentId) async {
    try {
      final doc = await _firestore.collection('users').doc(studentId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Unknown Student';
      }
    } catch (e) {
      return 'Unknown Student';
    }
    return 'Unknown Student';
  }

  // Get all submissions count
  Future<int> getTotalSubmissions() async {
    final count = await _firestore.collection('task_submissions').count().get();
    return count.count ?? 0;
  }

  // Get pending submissions count
  Future<int> getPendingSubmissions() async {
    final snapshot = await _firestore
        .collection('task_submissions')
        .where('grade', isNull: true)
        .get();
    return snapshot.docs.length;
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    final studentsCount = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .count()
        .get();

    final tasksCount = await _firestore.collection('tasks').count().get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();

    final postsCount = await _firestore.collection('posts').count().get();

    final contestsCount = await _firestore.collection('contests').count().get();

    final submissionsCount = await getTotalSubmissions();
    final pendingCount = await getPendingSubmissions();

    return {
      'totalStudents': studentsCount.count,
      'totalTasks': tasksCount.count,
      'totalQuizzes': quizzesCount.count,
      'totalPosts': postsCount.count,
      'totalContests': contestsCount.count,
      'totalSubmissions': submissionsCount,
      'pendingSubmissions': pendingCount,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore;

  QuizRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get published quizzes for department
  Stream<List<QuizModel>> getQuizzesForStudent(String department) {
    return _firestore
        .collection('quizzes')
        .snapshots()
        .map((snapshot) {
          final quizzes = snapshot.docs
              .map((doc) => QuizModel.fromFirestore(doc))
              .where((quiz) {
                // Only show published quizzes
                final isPublished = quiz.isPublished;
                // Filter by department - check if empty or contains student's department
                final departmentMatch = quiz.targetDepartments.isEmpty || 
                    quiz.targetDepartments.contains(department);
                return isPublished && departmentMatch;
              })
              .toList();
          
          // Sort in memory to avoid index requirement
          quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return quizzes;
        });
  }

  // Get single quiz
  Future<QuizModel?> getQuiz(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        return QuizModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  // Start quiz attempt
  Future<String> startQuizAttempt(String quizId, String studentId) async {
    try {
      final attempt = QuizAttemptModel(
        attemptId: '',
        quizId: quizId,
        studentId: studentId,
        answers: {},
        score: 0,
        startTime: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('quiz_attempts')
          .add(attempt.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start quiz: $e');
    }
  }

  // Submit quiz attempt
  Future<int> submitQuizAttempt({
    required String attemptId,
    required String quizId,
    required Map<int, int> answers,
  }) async {
    try {
      // Get quiz to calculate score
      final quiz = await getQuiz(quizId);
      if (quiz == null) throw Exception('Quiz not found');

      int score = 0;
      for (var i = 0; i < quiz.questions.length; i++) {
        if (answers[i] == quiz.questions[i].correctAnswer) {
          score += quiz.questions[i].marks;
        }
      }

      // Convert int keys to string keys for Firestore
      final answersMap = answers.map((key, value) => MapEntry(key.toString(), value));

      await _firestore.collection('quiz_attempts').doc(attemptId).update({
        'answers': answersMap,
        'score': score,
        'endTime': Timestamp.now(),
      });

      return score;
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  // Get student's attempt for a quiz
  Future<QuizAttemptModel?> getQuizAttempt(
      String quizId, String studentId) async {
    try {
      final query = await _firestore
          .collection('quiz_attempts')
          .where('quizId', isEqualTo: quizId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return QuizAttemptModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get quiz attempt: $e');
    }
  }

  // Get all attempts by student
  Stream<List<QuizAttemptModel>> getStudentAttempts(String studentId) {
    return _firestore
        .collection('quiz_attempts')
        .where('studentId', isEqualTo: studentId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizAttemptModel.fromFirestore(doc))
            .toList());
  }
}

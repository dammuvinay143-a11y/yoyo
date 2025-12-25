import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

class LoadQuizzes extends QuizEvent {
  final String department;
  const LoadQuizzes(this.department);
  @override
  List<Object?> get props => [department];
}

class LoadQuizDetail extends QuizEvent {
  final String quizId;
  const LoadQuizDetail(this.quizId);
  @override
  List<Object?> get props => [quizId];
}

class StartQuiz extends QuizEvent {
  final String quizId;
  final String studentId;
  const StartQuiz(this.quizId, this.studentId);
  @override
  List<Object?> get props => [quizId, studentId];
}

class SubmitQuiz extends QuizEvent {
  final String attemptId;
  final String quizId;
  final Map<int, int> answers;

  const SubmitQuiz({
    required this.attemptId,
    required this.quizId,
    required this.answers,
  });

  @override
  List<Object?> get props => [attemptId, quizId, answers];
}

class LoadQuizAttempt extends QuizEvent {
  final String quizId;
  final String studentId;
  const LoadQuizAttempt(this.quizId, this.studentId);
  @override
  List<Object?> get props => [quizId, studentId];
}

class LoadStudentAttempts extends QuizEvent {
  final String studentId;
  const LoadStudentAttempts(this.studentId);
  @override
  List<Object?> get props => [studentId];
}

// States
abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizzesLoaded extends QuizState {
  final List<QuizModel> quizzes;
  const QuizzesLoaded(this.quizzes);
  @override
  List<Object?> get props => [quizzes];
}

class QuizDetailLoaded extends QuizState {
  final QuizModel quiz;
  final QuizAttemptModel? attempt;
  const QuizDetailLoaded(this.quiz, this.attempt);
  @override
  List<Object?> get props => [quiz, attempt];
}

class QuizStarted extends QuizState {
  final String attemptId;
  final QuizModel quiz;
  const QuizStarted(this.attemptId, this.quiz);
  @override
  List<Object?> get props => [attemptId, quiz];
}

class QuizSubmitted extends QuizState {
  final int score;
  final int totalMarks;
  const QuizSubmitted(this.score, this.totalMarks);
  @override
  List<Object?> get props => [score, totalMarks];
}

class QuizAttemptLoaded extends QuizState {
  final QuizAttemptModel attempt;
  const QuizAttemptLoaded(this.attempt);
  @override
  List<Object?> get props => [attempt];
}

class StudentAttemptsLoaded extends QuizState {
  final List<QuizAttemptModel> attempts;
  const StudentAttemptsLoaded(this.attempts);
  @override
  List<Object?> get props => [attempts];
}

class QuizError extends QuizState {
  final String message;
  const QuizError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository _repository;

  QuizBloc({required QuizRepository repository})
      : _repository = repository,
        super(QuizInitial()) {
    on<LoadQuizzes>(_onLoadQuizzes);
    on<LoadQuizDetail>(_onLoadQuizDetail);
    on<StartQuiz>(_onStartQuiz);
    on<SubmitQuiz>(_onSubmitQuiz);
    on<LoadQuizAttempt>(_onLoadQuizAttempt);
    on<LoadStudentAttempts>(_onLoadStudentAttempts);
  }

  Future<void> _onLoadQuizzes(
      LoadQuizzes event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      await emit.forEach(
        _repository.getQuizzesForStudent(event.department),
        onData: (List<QuizModel> quizzes) => QuizzesLoaded(quizzes),
        onError: (error, stackTrace) => QuizError(error.toString()),
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onLoadQuizDetail(
    LoadQuizDetail event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final quiz = await _repository.getQuiz(event.quizId);
      if (quiz != null) {
        emit(QuizDetailLoaded(quiz, null));
      } else {
        emit(const QuizError('Quiz not found'));
      }
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onStartQuiz(StartQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final quiz = await _repository.getQuiz(event.quizId);
      if (quiz == null) {
        emit(const QuizError('Quiz not found'));
        return;
      }

      final attemptId = await _repository.startQuizAttempt(
        event.quizId,
        event.studentId,
      );
      emit(QuizStarted(attemptId, quiz));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onSubmitQuiz(SubmitQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final score = await _repository.submitQuizAttempt(
        attemptId: event.attemptId,
        quizId: event.quizId,
        answers: event.answers,
      );

      final quiz = await _repository.getQuiz(event.quizId);
      emit(QuizSubmitted(score, quiz?.totalMarks ?? 0));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onLoadQuizAttempt(
    LoadQuizAttempt event,
    Emitter<QuizState> emit,
  ) async {
    try {
      final attempt = await _repository.getQuizAttempt(
        event.quizId,
        event.studentId,
      );
      if (attempt != null) {
        emit(QuizAttemptLoaded(attempt));
      }
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onLoadStudentAttempts(
    LoadStudentAttempts event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await emit.forEach(
        _repository.getStudentAttempts(event.studentId),
        onData: (List<QuizAttemptModel> attempts) =>
            StudentAttemptsLoaded(attempts),
        onError: (error, stackTrace) => QuizError(error.toString()),
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }
}

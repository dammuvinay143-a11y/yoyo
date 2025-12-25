import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/admin_repository.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../student/data/models/task_model.dart';
import '../../../student/data/models/quiz_model.dart';
import '../../../student/data/models/post_model.dart';

// Events
abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllStudents extends AdminEvent {}

class ToggleStudentStatus extends AdminEvent {
  final String uid;
  final bool isActive;
  const ToggleStudentStatus(this.uid, this.isActive);
  @override
  List<Object?> get props => [uid, isActive];
}

class DeleteStudent extends AdminEvent {
  final String uid;
  const DeleteStudent(this.uid);
  @override
  List<Object?> get props => [uid];
}

class CreateTask extends AdminEvent {
  final TaskModel task;
  const CreateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class LoadAllTasks extends AdminEvent {}

class DeleteTask extends AdminEvent {
  final String taskId;
  const DeleteTask(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class CreateQuiz extends AdminEvent {
  final QuizModel quiz;
  const CreateQuiz(this.quiz);
  @override
  List<Object?> get props => [quiz];
}

class LoadAllQuizzes extends AdminEvent {}

class ToggleQuizPublish extends AdminEvent {
  final String quizId;
  final bool isPublished;
  const ToggleQuizPublish(this.quizId, this.isPublished);
  @override
  List<Object?> get props => [quizId, isPublished];
}

class DeleteQuiz extends AdminEvent {
  final String quizId;
  const DeleteQuiz(this.quizId);
  @override
  List<Object?> get props => [quizId];
}

class LoadFlaggedPosts extends AdminEvent {}

class LoadAllPosts extends AdminEvent {}

class ApprovePost extends AdminEvent {
  final String postId;
  const ApprovePost(this.postId);
  @override
  List<Object?> get props => [postId];
}

class DeletePostAdmin extends AdminEvent {
  final String postId;
  const DeletePostAdmin(this.postId);
  @override
  List<Object?> get props => [postId];
}

class LoadAnalytics extends AdminEvent {}

// States
abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class StudentsLoaded extends AdminState {
  final List<UserModel> students;
  const StudentsLoaded(this.students);
  @override
  List<Object?> get props => [students];
}

class TasksLoaded extends AdminState {
  final List<TaskModel> tasks;
  const TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskCreated extends AdminState {}

class QuizzesLoaded extends AdminState {
  final List<QuizModel> quizzes;
  const QuizzesLoaded(this.quizzes);
  @override
  List<Object?> get props => [quizzes];
}

class QuizCreated extends AdminState {}

class FlaggedPostsLoaded extends AdminState {
  final List<PostModel> posts;
  const FlaggedPostsLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class AllPostsLoaded extends AdminState {
  final List<PostModel> posts;
  const AllPostsLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class AnalyticsLoaded extends AdminState {
  final Map<String, dynamic> analytics;
  const AnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc({required AdminRepository repository})
      : _repository = repository,
        super(AdminInitial()) {
    on<LoadAllStudents>(_onLoadAllStudents);
    on<ToggleStudentStatus>(_onToggleStudentStatus);
    on<DeleteStudent>(_onDeleteStudent);
    on<CreateTask>(_onCreateTask);
    on<LoadAllTasks>(_onLoadAllTasks);
    on<DeleteTask>(_onDeleteTask);
    on<CreateQuiz>(_onCreateQuiz);
    on<LoadAllQuizzes>(_onLoadAllQuizzes);
    on<ToggleQuizPublish>(_onToggleQuizPublish);
    on<DeleteQuiz>(_onDeleteQuiz);
    on<LoadFlaggedPosts>(_onLoadFlaggedPosts);
    on<LoadAllPosts>(_onLoadAllPosts);
    on<ApprovePost>(_onApprovePost);
    on<DeletePostAdmin>(_onDeletePostAdmin);
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAllStudents(
    LoadAllStudents event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await emit.forEach(
        _repository.getAllStudents(),
        onData: (List<UserModel> students) => StudentsLoaded(students),
        onError: (error, stackTrace) => AdminError(error.toString()),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onToggleStudentStatus(
    ToggleStudentStatus event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.toggleStudentStatus(event.uid, event.isActive);
      emit(AdminActionSuccess(
          'Student ${event.isActive ? "activated" : "deactivated"}'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.deleteStudent(event.uid);
      emit(const AdminActionSuccess('Student deleted'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await _repository.createTask(event.task);
      emit(TaskCreated());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadAllTasks(
    LoadAllTasks event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await emit.forEach(
        _repository.getAllTasks(),
        onData: (List<TaskModel> tasks) => TasksLoaded(tasks),
        onError: (error, stackTrace) => AdminError(error.toString()),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<AdminState> emit) async {
    try {
      await _repository.deleteTask(event.taskId);
      emit(const AdminActionSuccess('Task deleted'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onCreateQuiz(CreateQuiz event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await _repository.createQuiz(event.quiz);
      emit(QuizCreated());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadAllQuizzes(
    LoadAllQuizzes event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await emit.forEach(
        _repository.getAllQuizzes(),
        onData: (List<QuizModel> quizzes) => QuizzesLoaded(quizzes),
        onError: (error, stackTrace) => AdminError(error.toString()),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onToggleQuizPublish(
    ToggleQuizPublish event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.toggleQuizPublish(event.quizId, event.isPublished);
      emit(AdminActionSuccess(
          'Quiz ${event.isPublished ? "published" : "unpublished"}'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteQuiz(DeleteQuiz event, Emitter<AdminState> emit) async {
    try {
      await _repository.deleteQuiz(event.quizId);
      emit(const AdminActionSuccess('Quiz deleted'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadFlaggedPosts(
    LoadFlaggedPosts event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await emit.forEach(
        _repository.getFlaggedPosts(),
        onData: (List<PostModel> posts) => FlaggedPostsLoaded(posts),
        onError: (error, stackTrace) => AdminError(error.toString()),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadAllPosts(
    LoadAllPosts event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await emit.forEach(
        _repository.getAllPosts(),
        onData: (List<PostModel> posts) => AllPostsLoaded(posts),
        onError: (error, stackTrace) => AdminError(error.toString()),
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onApprovePost(
      ApprovePost event, Emitter<AdminState> emit) async {
    try {
      await _repository.approvePost(event.postId);
      emit(const AdminActionSuccess('Post approved'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeletePostAdmin(
    DeletePostAdmin event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _repository.deletePost(event.postId);
      emit(const AdminActionSuccess('Post deleted'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final analytics = await _repository.getAnalytics();
      emit(AnalyticsLoaded(analytics));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}

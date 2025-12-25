import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/task_model.dart';
import '../../data/models/submission_model.dart';
import '../../data/repositories/task_repository.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String department;
  final int year;
  const LoadTasks(this.department, this.year);
  @override
  List<Object?> get props => [department, year];
}

class LoadTaskDetail extends TaskEvent {
  final String taskId;
  const LoadTaskDetail(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class SubmitTask extends TaskEvent {
  final String taskId;
  final String studentId;
  final List<PlatformFile>? files;
  final String? textSubmission;

  const SubmitTask({
    required this.taskId,
    required this.studentId,
    this.files,
    this.textSubmission,
  });

  @override
  List<Object?> get props => [taskId, studentId, files, textSubmission];
}

class LoadSubmission extends TaskEvent {
  final String taskId;
  final String studentId;
  const LoadSubmission(this.taskId, this.studentId);
  @override
  List<Object?> get props => [taskId, studentId];
}

class LoadStudentSubmissions extends TaskEvent {
  final String studentId;
  const LoadStudentSubmissions(this.studentId);
  @override
  List<Object?> get props => [studentId];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;
  const TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskDetailLoaded extends TaskState {
  final TaskModel task;
  final SubmissionModel? submission;
  const TaskDetailLoaded(this.task, this.submission);
  @override
  List<Object?> get props => [task, submission];
}

class TaskSubmitted extends TaskState {}

class SubmissionLoaded extends TaskState {
  final SubmissionModel submission;
  const SubmissionLoaded(this.submission);
  @override
  List<Object?> get props => [submission];
}

class StudentSubmissionsLoaded extends TaskState {
  final List<SubmissionModel> submissions;
  const StudentSubmissionsLoaded(this.submissions);
  @override
  List<Object?> get props => [submissions];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;

  TaskBloc({required TaskRepository repository})
      : _repository = repository,
        super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTaskDetail>(_onLoadTaskDetail);
    on<SubmitTask>(_onSubmitTask);
    on<LoadSubmission>(_onLoadSubmission);
    on<LoadStudentSubmissions>(_onLoadStudentSubmissions);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await emit.forEach(
        _repository.getTasksForStudent(event.department, event.year),
        onData: (List<TaskModel> tasks) => TasksLoaded(tasks),
        onError: (error, stackTrace) => TaskError(error.toString()),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onLoadTaskDetail(
    LoadTaskDetail event,
    Emitter<TaskState> emit,
  ) async {
    // Don't emit loading if we already have task detail loaded
    // This prevents the UI from being replaced when loading submission
    if (state is! TaskDetailLoaded) {
      emit(TaskLoading());
    }
    try {
      final task = await _repository.getTask(event.taskId);
      if (task != null) {
        // Preserve existing submission if we already have it
        final currentSubmission = state is TaskDetailLoaded 
            ? (state as TaskDetailLoaded).submission 
            : null;
        emit(TaskDetailLoaded(task, currentSubmission));
      } else {
        emit(const TaskError('Task not found'));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onSubmitTask(SubmitTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _repository.submitTask(
        taskId: event.taskId,
        studentId: event.studentId,
        files: event.files,
        textSubmission: event.textSubmission,
      );
      emit(TaskSubmitted());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onLoadSubmission(
    LoadSubmission event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final submission = await _repository.getSubmission(
        event.taskId,
        event.studentId,
      );
      
      // If we have task detail loaded, update it with the submission
      if (state is TaskDetailLoaded) {
        final currentTask = (state as TaskDetailLoaded).task;
        emit(TaskDetailLoaded(currentTask, submission));
      } else {
        // Otherwise, load the task first
        final task = await _repository.getTask(event.taskId);
        if (task != null) {
          emit(TaskDetailLoaded(task, submission));
        }
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onLoadStudentSubmissions(
    LoadStudentSubmissions event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await emit.forEach(
        _repository.getStudentSubmissions(event.studentId),
        onData: (List<SubmissionModel> submissions) =>
            StudentSubmissionsLoaded(submissions),
        onError: (error, stackTrace) => TaskError(error.toString()),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}

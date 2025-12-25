import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/student_profile_model.dart';
import '../../data/repositories/student_repository.dart';
import '../../../auth/data/models/user_model.dart';
import 'dart:io';

// Events
abstract class StudentEvent extends Equatable {
  const StudentEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudentProfile extends StudentEvent {
  final String uid;
  const LoadStudentProfile(this.uid);
  @override
  List<Object?> get props => [uid];
}

class UpdateStudentProfile extends StudentEvent {
  final StudentProfileModel profile;
  const UpdateStudentProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}

class UpdateUserBasicInfo extends StudentEvent {
  final UserModel user;
  const UpdateUserBasicInfo(this.user);
  @override
  List<Object?> get props => [user];
}

class UploadProfilePhoto extends StudentEvent {
  final String uid;
  final File imageFile;
  const UploadProfilePhoto(this.uid, this.imageFile);
  @override
  List<Object?> get props => [uid, imageFile];
}

class LoadAllStudents extends StudentEvent {}

class LoadStudentsByDepartment extends StudentEvent {
  final String department;
  const LoadStudentsByDepartment(this.department);
  @override
  List<Object?> get props => [department];
}

// States
abstract class StudentState extends Equatable {
  const StudentState();
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentProfileLoaded extends StudentState {
  final StudentProfileModel profile;
  final UserModel user;
  const StudentProfileLoaded(this.profile, this.user);
  @override
  List<Object?> get props => [profile, user];
}

class StudentProfileUpdated extends StudentState {}

class ProfilePhotoUploaded extends StudentState {
  final String photoUrl;
  const ProfilePhotoUploaded(this.photoUrl);
  @override
  List<Object?> get props => [photoUrl];
}

class StudentsListLoaded extends StudentState {
  final List<UserModel> students;
  const StudentsListLoaded(this.students);
  @override
  List<Object?> get props => [students];
}

class StudentError extends StudentState {
  final String message;
  const StudentError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _repository;

  StudentBloc({required StudentRepository repository})
      : _repository = repository,
        super(StudentInitial()) {
    on<LoadStudentProfile>(_onLoadStudentProfile);
    on<UpdateStudentProfile>(_onUpdateStudentProfile);
    on<UpdateUserBasicInfo>(_onUpdateUserBasicInfo);
    on<UploadProfilePhoto>(_onUploadProfilePhoto);
    on<LoadAllStudents>(_onLoadAllStudents);
    on<LoadStudentsByDepartment>(_onLoadStudentsByDepartment);
  }

  Future<void> _onLoadStudentProfile(
    LoadStudentProfile event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final profile = await _repository.getStudentProfile(event.uid);
      final user = await _repository.getUserById(event.uid);

      if (profile != null && user != null) {
        emit(StudentProfileLoaded(profile, user));
      } else {
        emit(const StudentError('Profile not found'));
      }
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUpdateStudentProfile(
    UpdateStudentProfile event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await _repository.updateStudentProfile(event.profile);
      emit(StudentProfileUpdated());
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUpdateUserBasicInfo(
    UpdateUserBasicInfo event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await _repository.updateUserInfo(event.user);
      emit(StudentProfileUpdated());
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUploadProfilePhoto(
    UploadProfilePhoto event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final photoUrl = await _repository.uploadProfilePhoto(
        event.uid,
        event.imageFile,
      );
      emit(ProfilePhotoUploaded(photoUrl));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadAllStudents(
    LoadAllStudents event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await emit.forEach(
        _repository.getAllStudents(),
        onData: (List<UserModel> students) => StudentsListLoaded(students),
        onError: (error, stackTrace) => StudentError(error.toString()),
      );
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadStudentsByDepartment(
    LoadStudentsByDepartment event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await emit.forEach(
        _repository.getStudentsByDepartment(event.department),
        onData: (List<UserModel> students) => StudentsListLoaded(students),
        onError: (error, stackTrace) => StudentError(error.toString()),
      );
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}

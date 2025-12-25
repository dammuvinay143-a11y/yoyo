import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Auth
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Student
import 'features/student/data/repositories/student_repository.dart';
import 'features/student/data/repositories/feed_repository.dart';
import 'features/student/data/repositories/task_repository.dart';
import 'features/student/data/repositories/quiz_repository.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/student/presentation/bloc/feed_bloc.dart';
import 'features/student/presentation/bloc/task_bloc.dart';
import 'features/student/presentation/bloc/quiz_bloc.dart';

// Admin
import 'features/admin/data/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';

// Contests
import 'features/contests/data/repositories/contest_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => StudentBloc(repository: sl()));
  sl.registerFactory(() => FeedBloc(repository: sl()));
  sl.registerFactory(() => TaskBloc(repository: sl()));
  sl.registerFactory(() => QuizBloc(repository: sl()));
  sl.registerFactory(() => AdminBloc(repository: sl()));

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(
        firebaseAuth: sl(),
        firestore: sl(),
      ));
  sl.registerLazySingleton(() => StudentRepository(
        firestore: sl(),
        storage: sl(),
      ));
  sl.registerLazySingleton(() => FeedRepository(
        firestore: sl(),
        storage: sl(),
      ));
  sl.registerLazySingleton(() => TaskRepository(
        firestore: sl(),
        storage: sl(),
      ));
  sl.registerLazySingleton(() => QuizRepository(firestore: sl()));
  sl.registerLazySingleton(() => AdminRepository(firestore: sl()));
  sl.registerLazySingleton(() => ContestRepository(firestore: sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
}

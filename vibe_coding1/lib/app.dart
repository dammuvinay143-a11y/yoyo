import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/routes/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/student/presentation/bloc/feed_bloc.dart';
import 'features/student/presentation/bloc/task_bloc.dart';
import 'features/student/presentation/bloc/quiz_bloc.dart';
import 'features/student/data/repositories/student_repository.dart';
import 'features/contests/data/repositories/contest_repository.dart';
import 'features/admin/data/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'injection_container.dart' as di;

class CollegeConnectApp extends StatelessWidget {
  const CollegeConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => di.sl<StudentRepository>()),
        RepositoryProvider(create: (_) => di.sl<ContestRepository>()),
        RepositoryProvider(create: (_) => di.sl<AdminRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus())),
          BlocProvider(create: (_) => di.sl<StudentBloc>()),
          BlocProvider(create: (_) => di.sl<FeedBloc>()),
          BlocProvider(create: (_) => di.sl<TaskBloc>()),
          BlocProvider(create: (_) => di.sl<QuizBloc>()),
          BlocProvider(create: (_) => di.sl<AdminBloc>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Vibe Connect',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: AppRouter.splash,
            );
          },
        ),
      ),
    );
  }
}

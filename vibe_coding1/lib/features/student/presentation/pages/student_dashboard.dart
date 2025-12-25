import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/stat_card.dart';
import '../bloc/task_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../../data/repositories/student_repository.dart';
import 'feed_page.dart';
import 'tasks_page.dart';
import 'quizzes_page.dart';
import 'contests_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const FeedPage(),
    const TasksPage(),
    const QuizzesPage(),
    const ContestsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, AppRouter.login);
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.feed),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz),
                label: 'Quizzes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events),
                label: 'Contests',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    // Load tasks and quizzes when dashboard loads
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final department = authState.user.department ?? 'Computer Science';
      final year = authState.user.year ?? 1;
      context.read<TaskBloc>().add(
        LoadTasks(department, year),
      );
      context.read<QuizBloc>().add(
        LoadQuizzes(department),
      );
      setState(() {
        _refreshKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authState.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('College Connect'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
              PopupMenuButton(
                icon: CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.profile,
                          arguments: user.uid,
                        );
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Profile'),
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        Navigator.pushNamed(context, AppRouter.editProfile);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        return ListTile(
                          leading: Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          title: Text(
                            themeMode == ThemeMode.dark
                                ? 'Light Mode'
                                : 'Dark Mode',
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                  const PopupMenuItem(
                    height: 1,
                    child: Divider(),
                    enabled: false,
                  ),
                  PopupMenuItem(
                    child: const ListTile(
                      leading: Icon(Icons.people),
                      title: Text('Network'),
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        Navigator.pushNamed(context, AppRouter.network);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title:
                          Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                    onTap: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _loadData,
            child: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with enhanced design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                        AppColors.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${user.department} • Year ${user.year}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats
                const Text(
                  'Quick Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<int>(
                        key: ValueKey('pending_$_refreshKey'),
                        future: _getPendingTasksCount(context),
                        builder: (context, snapshot) {
                          return StatCard(
                            title: 'Pending Tasks',
                            value: (snapshot.data ?? 0).toString(),
                            icon: Icons.pending_actions,
                            color: AppColors.warning,
                            onTap: () {
                              final parent = context.findAncestorStateOfType<_StudentDashboardState>();
                              parent?.setState(() {
                                parent._selectedIndex = 2; // Tasks tab
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BlocBuilder<QuizBloc, QuizState>(
                        builder: (context, quizState) {
                          int quizCount = 0;
                          if (quizState is QuizzesLoaded) {
                            quizCount = quizState.quizzes.length;
                          }
                          return StatCard(
                            title: 'Quizzes',
                            value: quizCount.toString(),
                            icon: Icons.quiz,
                            color: AppColors.info,
                            onTap: () {
                              final parent = context.findAncestorStateOfType<_StudentDashboardState>();
                              parent?.setState(() {
                                parent._selectedIndex = 3; // Quizzes tab
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<int>(
                        key: ValueKey('graded_$_refreshKey'),
                        future: _getGradedSubmissionsCount(context),
                        builder: (context, snapshot) {
                          return StatCard(
                            title: 'Graded',
                            value: (snapshot.data ?? 0).toString(),
                            icon: Icons.check_circle,
                            color: AppColors.success,
                            onTap: () {
                              final parent = context.findAncestorStateOfType<_StudentDashboardState>();
                              parent?.setState(() {
                                parent._selectedIndex = 2; // Tasks tab
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder<int>(
                        future: _getNetworkCount(context),
                        builder: (context, snapshot) {
                          return StatCard(
                            title: 'Network',
                            value: (snapshot.data ?? 0).toString(),
                            icon: Icons.people,
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.network);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildActionCard(
                      context,
                      'View Profile',
                      Icons.person,
                      AppColors.primary,
                      () => Navigator.pushNamed(
                        context,
                        AppRouter.profile,
                        arguments: user.uid,
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'My Tasks',
                      Icons.task_alt,
                      AppColors.success,
                      () {
                        final parent = context.findAncestorStateOfType<_StudentDashboardState>();
                        parent?.setState(() {
                          parent._selectedIndex = 2; // Navigate to Tasks tab
                        });
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Take Quiz',
                      Icons.quiz,
                      AppColors.info,
                      () {
                        final parent = context.findAncestorStateOfType<_StudentDashboardState>();
                        parent?.setState(() {
                          parent._selectedIndex = 3; // Navigate to Quizzes tab
                        });
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Find Students',
                      Icons.search,
                      AppColors.accent,
                      () => Navigator.pushNamed(context, AppRouter.network),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<int> _getPendingTasksCount(BuildContext context) async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) return 0;

      // Get all tasks for the student
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .get();
      
      final allTasks = tasksSnapshot.docs.where((doc) {
        final data = doc.data();
        final targetDepts = List<String>.from(data['targetDepartments'] ?? []);
        final targetYears = List<int>.from(data['targetYears'] ?? []);
        return (targetDepts.isEmpty || targetDepts.contains(authState.user.department)) &&
               (targetYears.isEmpty || targetYears.contains(authState.user.year));
      }).toList();
      
      // Get all submissions for this student
      final submissionsSnapshot = await FirebaseFirestore.instance
          .collection('task_submissions')
          .where('studentId', isEqualTo: authState.user.uid)
          .get();
      
      final submittedTaskIds = submissionsSnapshot.docs
          .map((doc) => doc.data()['taskId'] as String)
          .toSet();
      
      // Count tasks without submissions
      int pendingCount = 0;
      for (var taskDoc in allTasks) {
        if (!submittedTaskIds.contains(taskDoc.id)) {
          pendingCount++;
        }
      }
      
      return pendingCount;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getGradedSubmissionsCount(BuildContext context) async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) return 0;

      // Get all submissions for this student
      final snapshot = await FirebaseFirestore.instance
          .collection('task_submissions')
          .where('studentId', isEqualTo: authState.user.uid)
          .get();
      
      // Count submissions that have a grade (grade field is not null)
      int gradedCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['grade'] != null) {
          gradedCount++;
        }
      }
      
      return gradedCount;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getNetworkCount(BuildContext context) async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) return 0;
      
      final repository = context.read<StudentRepository>();
      final snapshot = await repository.getAllStudents().first;
      return snapshot.length;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

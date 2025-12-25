import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/sample_data_initializer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/dashboard_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, AppRouter.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
                onTap: () {
                  context.read<AdminBloc>().add(LoadAnalytics());
                },
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.data_object),
                  title: Text('Initialize Sample Data'),
                ),
                onTap: () async {
                  final initializer = SampleDataInitializer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Initializing sample data...')),
                  );
                  await initializer.initializeSampleData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sample data initialized successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.read<AdminBloc>().add(LoadAnalytics());
                  }
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
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
                onTap: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                },
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> analytics = {};
          if (state is AnalyticsLoaded) {
            analytics = state.analytics;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage your college platform',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Analytics Overview
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Students',
                        value: '${analytics['totalStudents'] ?? 0}',
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardCard(
                        title: 'Tasks',
                        value: '${analytics['totalTasks'] ?? 0}',
                        icon: Icons.task,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Quizzes',
                        value: '${analytics['totalQuizzes'] ?? 0}',
                        icon: Icons.quiz,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardCard(
                        title: 'Contests',
                        value: '${analytics['totalContests'] ?? 0}',
                        icon: Icons.emoji_events,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Submissions',
                        value: '${analytics['totalSubmissions'] ?? 0}',
                        icon: Icons.assignment_turned_in,
                        color: const Color(0xFF00BCD4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardCard(
                        title: 'Pending',
                        value: '${analytics['pendingSubmissions'] ?? 0}',
                        icon: Icons.pending_actions,
                        color: Colors.orange,
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
                  childAspectRatio: 1.3,
                  children: [
                    _buildActionCard(
                      context,
                      'Manage Students',
                      Icons.people_alt,
                      AppColors.primary,
                      () => Navigator.pushNamed(
                          context, AppRouter.manageStudents),
                    ),
                    _buildActionCard(
                      context,
                      'View All Posts',
                      Icons.post_add,
                      const Color(0xFF9C27B0),
                      () => Navigator.pushNamed(context, AppRouter.viewAllPosts),
                    ),
                    _buildActionCard(
                      context,
                      'Create Task',
                      Icons.add_task,
                      AppColors.success,
                      () => Navigator.pushNamed(context, AppRouter.createTask),
                    ),
                    _buildActionCard(
                      context,
                      'View Submissions',
                      Icons.assignment_turned_in,
                      const Color(0xFF00BCD4),
                      () => Navigator.pushNamed(context, AppRouter.taskSubmissions),
                    ),
                    _buildActionCard(
                      context,
                      'Create Quiz',
                      Icons.quiz,
                      AppColors.info,
                      () => Navigator.pushNamed(context, AppRouter.createQuiz),
                    ),
                    _buildActionCard(
                      context,
                      'View Quiz Results',
                      Icons.assessment,
                      const Color(0xFF9C27B0),
                      () => Navigator.pushNamed(context, AppRouter.viewQuizResults),
                    ),
                    _buildActionCard(
                      context,
                      'Create Contest',
                      Icons.add_circle,
                      const Color(0xFFFF9800),
                      () =>
                          Navigator.pushNamed(context, AppRouter.createContest),
                    ),
                    _buildActionCard(
                      context,
                      'Contest Winners',
                      Icons.emoji_events,
                      const Color(0xFFFFD700),
                      () => Navigator.pushNamed(context, AppRouter.contestWinners),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ]
                : [
                    Colors.white,
                    color.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.8),
                    color,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

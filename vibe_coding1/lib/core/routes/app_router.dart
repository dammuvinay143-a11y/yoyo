import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/admin_login_page.dart';
import '../../features/student/presentation/pages/student_dashboard.dart';
import '../../features/student/presentation/pages/profile_page.dart';
import '../../features/student/presentation/pages/edit_profile_page.dart';
import '../../features/student/presentation/pages/feed_page.dart';
import '../../features/student/presentation/pages/tasks_page.dart';
import '../../features/student/presentation/pages/task_detail_page.dart';
import '../../features/student/presentation/pages/quizzes_page.dart';
import '../../features/student/presentation/pages/quiz_taking_page.dart';
import '../../features/student/presentation/pages/quiz_results_page.dart';
import '../../features/student/presentation/pages/network_page.dart';
import '../../features/student/presentation/pages/contests_page.dart';
import '../../features/student/presentation/pages/contest_detail_page.dart';
import '../../features/student/presentation/pages/problem_solving_page.dart';
import '../../features/student/presentation/pages/leaderboard_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/admin/presentation/pages/manage_students_page.dart';
import '../../features/admin/presentation/pages/create_task_page.dart';
import '../../features/admin/presentation/pages/create_quiz_page.dart';
import '../../features/admin/presentation/pages/moderate_posts_page.dart';
import '../../features/admin/presentation/pages/view_all_posts_page.dart';
import '../../features/admin/presentation/pages/analytics_page.dart';
import '../../features/admin/presentation/pages/create_contest_page.dart';
import '../../features/admin/presentation/pages/task_submissions_page.dart';
import '../../features/admin/presentation/pages/view_quiz_results_page.dart';
import '../../features/admin/presentation/pages/contest_winners_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String adminLogin = '/admin/login';

  // Student routes
  static const String studentDashboard = '/student/dashboard';
  static const String profile = '/student/profile';
  static const String editProfile = '/student/edit-profile';
  static const String feed = '/student/feed';
  static const String tasks = '/student/tasks';
  static const String taskDetail = '/student/task-detail';
  static const String quizzes = '/student/quizzes';
  static const String quizTaking = '/student/quiz-taking';
  static const String quizResults = '/student/quiz-results';
  static const String network = '/student/network';
  static const String contests = '/student/contests';
  static const String contestDetail = '/student/contest-detail';
  static const String problemSolving = '/student/problem-solving';
  static const String leaderboard = '/student/leaderboard';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String manageStudents = '/admin/manage-students';
  static const String createTask = '/admin/create-task';
  static const String createQuiz = '/admin/create-quiz';
  static const String moderatePosts = '/admin/moderate-posts';
  static const String viewAllPosts = '/admin/view-all-posts';
  static const String analytics = '/admin/analytics';
  static const String createContest = '/admin/create-contest';
  static const String taskSubmissions = '/admin/task-submissions';
  static const String viewQuizResults = '/admin/view-quiz-results';
  static const String contestWinners = '/admin/contest-winners';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());

      // Student routes
      case studentDashboard:
        return MaterialPageRoute(builder: (_) => const StudentDashboard());

      case profile:
        final uid = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ProfilePage(uid: uid));

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());

      case feed:
        return MaterialPageRoute(builder: (_) => const FeedPage());

      case tasks:
        return MaterialPageRoute(builder: (_) => const TasksPage());

      case taskDetail:
        final taskId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => TaskDetailPage(taskId: taskId));

      case quizzes:
        return MaterialPageRoute(builder: (_) => const QuizzesPage());

      case quizTaking:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => QuizTakingPage(
            quizId: args['quizId']!,
            attemptId: args['attemptId']!,
          ),
        );

      case quizResults:
        return MaterialPageRoute(builder: (_) => const QuizResultsPage());

      case network:
        return MaterialPageRoute(builder: (_) => const NetworkPage());

      case contests:
        return MaterialPageRoute(builder: (_) => const ContestsPage());

      case contestDetail:
        final contestId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ContestDetailPage(contestId: contestId),
        );

      case problemSolving:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => ProblemSolvingPage(
            problemId: args['problemId']!,
            contestId: args['contestId']!,
          ),
        );

      case leaderboard:
        final contestId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => LeaderboardPage(contestId: contestId),
        );

      // Admin routes
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case manageStudents:
        return MaterialPageRoute(builder: (_) => const ManageStudentsPage());

      case createTask:
        return MaterialPageRoute(builder: (_) => const CreateTaskPage());

      case createQuiz:
        return MaterialPageRoute(builder: (_) => const CreateQuizPage());

      case moderatePosts:
        return MaterialPageRoute(builder: (_) => const ModeratePostsPage());

      case viewAllPosts:
        return MaterialPageRoute(builder: (_) => const ViewAllPostsPage());

      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsPage());

      case createContest:
        return MaterialPageRoute(builder: (_) => const CreateContestPage());

      case taskSubmissions:
        return MaterialPageRoute(builder: (_) => const TaskSubmissionsPage());

      case viewQuizResults:
        return MaterialPageRoute(builder: (_) => const ViewQuizResultsPage());

      case contestWinners:
        return MaterialPageRoute(builder: (_) => const ContestWinnersPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

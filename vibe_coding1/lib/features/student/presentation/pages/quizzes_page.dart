import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/quiz_bloc.dart';
import '../widgets/quiz_card.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<QuizBloc>().add(LoadQuizzes(authState.user.department!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.quizResults);
            },
            tooltip: 'My Results',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
          ),
        ],
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is QuizStarted) {
            Navigator.pushNamed(
              context,
              AppRouter.quizTaking,
              arguments: {
                'quizId': state.quiz.quizId,
                'attemptId': state.attemptId,
              },
            );
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizzesLoaded) {
            if (state.quizzes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No quizzes available',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadQuizzes();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.quizzes.length,
                itemBuilder: (context, index) {
                  return QuizCard(
                    quiz: state.quizzes[index],
                    onStart: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is Authenticated) {
                        context.read<QuizBloc>().add(
                              StartQuiz(
                                state.quizzes[index].quizId,
                                authState.user.uid,
                              ),
                            );
                      }
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
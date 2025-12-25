import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/student_bloc.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadStudentProfile(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isOwnProfile =
        authState is Authenticated && authState.user.uid == widget.uid;

    return Scaffold(
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentProfileLoaded) {
            final user = state.user;
            final profile = state.profile;

            return CustomScrollView(
              slivers: [
                // App Bar with cover
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: user.photoUrl == null
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    if (isOwnProfile)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.editProfile);
                        },
                      ),
                  ],
                ),

                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Info
                        Center(
                          child: Column(
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildInfoChip(
                                    Icons.school,
                                    user.department ?? 'N/A',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.class_,
                                    'Year ${user.year ?? 'N/A'}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bio
                        if (profile.bio.isNotEmpty) ...[
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.bio,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Contact Info
                        if (profile.phone.isNotEmpty) ...[
                          const Text(
                            'Contact',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.phone,
                                  color: AppColors.primary),
                              title: const Text('Phone'),
                              subtitle: Text(profile.phone),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Coding Profiles
                        if (profile.githubUrl != null ||
                            profile.leetcodeUrl != null ||
                            profile.hackerrankUrl != null ||
                            profile.linkedinUrl != null ||
                            profile.portfolioUrl != null) ...[
                          const Text(
                            'Profiles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (profile.githubUrl != null)
                            _buildProfileLink(
                              'GitHub',
                              profile.githubUrl!,
                              Icons.code,
                              Colors.black,
                            ),
                          if (profile.leetcodeUrl != null)
                            _buildProfileLink(
                              'LeetCode',
                              profile.leetcodeUrl!,
                              Icons.terminal,
                              Colors.orange,
                            ),
                          if (profile.hackerrankUrl != null)
                            _buildProfileLink(
                              'HackerRank',
                              profile.hackerrankUrl!,
                              Icons.code_outlined,
                              Colors.green,
                            ),
                          if (profile.linkedinUrl != null)
                            _buildProfileLink(
                              'LinkedIn',
                              profile.linkedinUrl!,
                              Icons.work,
                              Colors.blue,
                            ),
                          if (profile.portfolioUrl != null)
                            _buildProfileLink(
                              'Portfolio',
                              profile.portfolioUrl!,
                              Icons.web,
                              AppColors.primary,
                            ),
                          const SizedBox(height: 24),
                        ],

                        // Skills
                        if (profile.skills.isNotEmpty) ...[
                          const Text(
                            'Skills',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.skills.map((skill) {
                              return Chip(
                                label: Text(skill),
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                labelStyle: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Projects
                        if (profile.projects.isNotEmpty) ...[
                          const Text(
                            'Projects',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...profile.projects.map((project) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            project.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (project.url != null)
                                          IconButton(
                                            icon: const Icon(Icons.link),
                                            onPressed: () async {
                                              final uri =
                                                  Uri.parse(project.url!);
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri);
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      project.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    if (project.technologies.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children:
                                            project.technologies.map((tech) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.info
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              tech,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.info,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Failed to load profile'));
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLink(
      String label, String url, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
      ),
    );
  }
}

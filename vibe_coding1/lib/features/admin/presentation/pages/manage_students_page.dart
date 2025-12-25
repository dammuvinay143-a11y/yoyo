import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/admin_bloc.dart';

// Helper function to fetch student social accounts from Firestore
Future<Map<String, String?>> _getStudentSocialAccounts(String uid) async {
  try {
    final profileDoc = await FirebaseFirestore.instance
        .collection('student_profiles')
        .doc(uid)
        .get();

    if (profileDoc.exists) {
      final data = profileDoc.data()!;
      return {
        'linkedinUrl': data['linkedinUrl'] as String?,
        'githubUrl': data['githubUrl'] as String?,
        'twitterUrl': data['twitterUrl'] as String?,
        'portfolioUrl': data['portfolioUrl'] as String?,
        'leetcodeUrl': data['leetcodeUrl'] as String?,
        'hackerrankUrl': data['hackerrankUrl'] as String?,
      };
    }

    // Also check user collection for social accounts
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      return {
        'linkedinUrl': data['linkedinUrl'] as String?,
        'githubUrl': data['githubUrl'] as String?,
        'twitterUrl': data['twitterUrl'] as String?,
        'portfolioUrl': data['portfolioUrl'] as String?,
        'leetcodeUrl': null,
        'hackerrankUrl': null,
      };
    }
  } catch (e) {
    debugPrint('Error fetching social accounts: $e');
  }

  return {
    'linkedinUrl': null,
    'githubUrl': null,
    'twitterUrl': null,
    'portfolioUrl': null,
    'leetcodeUrl': null,
    'hackerrankUrl': null,
  };
}

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadAllStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminBloc>().add(LoadAllStudents());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardTheme.color,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or roll number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['All', 'Computer Science', 'Electronics', 'Mechanical', 'Civil']
                            .map((dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sort By',
                          prefixIcon: const Icon(Icons.sort),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'name', child: Text('Name')),
                          const DropdownMenuItem(value: 'rollNumber', child: Text('Roll Number')),
                          const DropdownMenuItem(value: 'department', child: Text('Department')),
                          const DropdownMenuItem(value: 'year', child: Text('Year')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Students List
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StudentsLoaded) {
                  var students = state.students.where((student) {
                    final matchesSearch = student.name.toLowerCase().contains(_searchQuery) ||
                        student.email.toLowerCase().contains(_searchQuery) ||
                        (student.rollNumber?.toLowerCase().contains(_searchQuery) ?? false);

                    final matchesDepartment = _selectedDepartment == 'All' ||
                        student.department == _selectedDepartment;

                    return matchesSearch && matchesDepartment;
                  }).toList();

                  // Sort students
                  students.sort((a, b) {
                    switch (_sortBy) {
                      case 'name':
                        return a.name.compareTo(b.name);
                      case 'rollNumber':
                        return (a.rollNumber ?? '').compareTo(b.rollNumber ?? '');
                      case 'department':
                        return (a.department ?? '').compareTo(b.department ?? '');
                      case 'year':
                        return (a.year ?? 0).compareTo(b.year ?? 0);
                      default:
                        return 0;
                    }
                  });

                  if (students.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No students found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _StudentCard(
                        student: student,
                        onTap: () {
                          _showStudentDetails(context, student);
                        },
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('Unable to load students'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(BuildContext context, dynamic student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StudentDetailsSheet(student: student),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final dynamic student;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: student.photoUrl != null
                    ? NetworkImage(student.photoUrl!)
                    : null,
                child: student.photoUrl == null
                    ? Text(
                        student.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (student.headline != null)
                      Text(
                        student.headline!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.school, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${student.department ?? 'N/A'} • Year ${student.year ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (student.rollNumber != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Roll: ${student.rollNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: student.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  student.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: student.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentDetailsSheet extends StatelessWidget {
  final dynamic student;

  const _StudentDetailsSheet({required this.student});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: student.photoUrl != null
                                ? NetworkImage(student.photoUrl!)
                                : null,
                            child: student.photoUrl == null
                                ? Text(
                                    student.name[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (student.headline != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              student.headline!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatItem(
                                label: 'Posts',
                                value: student.postsCount?.toString() ?? '0',
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: 'Followers',
                                value: student.followersCount?.toString() ?? '0',
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: 'Following',
                                value: student.followingCount?.toString() ?? '0',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),

                    // Basic Information
                    _SectionHeader(title: 'Basic Information'),
                    _InfoRow(icon: Icons.email, label: 'Email', value: student.email),
                    if (student.phone != null)
                      _InfoRow(icon: Icons.phone, label: 'Phone', value: student.phone!),
                    if (student.location != null)
                      _InfoRow(icon: Icons.location_on, label: 'Location', value: student.location!),
                    if (student.rollNumber != null)
                      _InfoRow(icon: Icons.badge, label: 'Roll Number', value: student.rollNumber!),
                    if (student.department != null)
                      _InfoRow(icon: Icons.business, label: 'Department', value: student.department!),
                    if (student.year != null)
                      _InfoRow(icon: Icons.school, label: 'Year', value: 'Year ${student.year}'),

                    if (student.bio != null) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'About'),
                      Text(
                        student.bio!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],

                    // Skills
                    if (student.skills != null && student.skills.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'Skills'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: student.skills
                            .map<Widget>((skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                ))
                            .toList(),
                      ),
                    ],

                    // Interests
                    if (student.interests != null && student.interests.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'Interests'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: student.interests
                            .map<Widget>((interest) => Chip(
                                  label: Text(interest),
                                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                                ))
                            .toList(),
                      ),
                    ],

                    // Social Accounts - Fetch from Firestore
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Social Accounts'),
                    FutureBuilder<Map<String, String?>>(
                      future: _getStudentSocialAccounts(student.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Text(
                            'No social accounts added yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }

                        final socialAccounts = snapshot.data!;
                        final hasSocialAccounts = socialAccounts.values.any((url) => url != null && url.isNotEmpty);

                        if (!hasSocialAccounts) {
                          return Text(
                            'No social accounts added yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }

                        return Column(
                          children: [
                            if (socialAccounts['linkedinUrl'] != null && socialAccounts['linkedinUrl']!.isNotEmpty)
                              _SocialLink(
                                icon: Icons.work,
                                label: 'LinkedIn',
                                url: socialAccounts['linkedinUrl']!,
                                color: const Color(0xFF0077B5),
                              ),
                            if (socialAccounts['githubUrl'] != null && socialAccounts['githubUrl']!.isNotEmpty)
                              _SocialLink(
                                icon: Icons.code,
                                label: 'GitHub',
                                url: socialAccounts['githubUrl']!,
                                color: const Color(0xFF333333),
                              ),
                            if (socialAccounts['twitterUrl'] != null && socialAccounts['twitterUrl']!.isNotEmpty)
                              _SocialLink(
                                icon: Icons.chat_bubble,
                                label: 'Twitter',
                                url: socialAccounts['twitterUrl']!,
                                color: const Color(0xFF1DA1F2),
                              ),
                            if (socialAccounts['portfolioUrl'] != null && socialAccounts['portfolioUrl']!.isNotEmpty)
                              _SocialLink(
                                icon: Icons.language,
                                label: 'Portfolio',
                                url: socialAccounts['portfolioUrl']!,
                                color: AppColors.primary,
                              ),
                            if (socialAccounts['leetcodeUrl'] != null && socialAccounts['leetcodeUrl']!.isNotEmpty)
                              _SocialLink(
                                icon: Icons.terminal,
                                label: 'LeetCode',
                                url: socialAccounts['leetcodeUrl']!,
                                color: Colors.orange,
                              ),
                            if (socialAccounts['hackerrankUrl'] != null && socialAccounts['hackerrankUrl']!.isNotEmpty)
                              _SocialLink(
                                icon: Icons.code_outlined,
                                label: 'HackerRank',
                                url: socialAccounts['hackerrankUrl']!,
                                color: Colors.green,
                              ),
                          ],
                        );
                      },
                    ),

                    // Account Actions
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Account Actions'),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<AdminBloc>().add(
                                    ToggleStudentStatus(student.uid, !student.isActive),
                                  );
                              Navigator.pop(context);
                            },
                            icon: Icon(student.isActive ? Icons.block : Icons.check_circle),
                            label: Text(student.isActive ? 'Deactivate' : 'Activate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: student.isActive ? Colors.red : Colors.green,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showDeleteConfirmation(context, student);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Delete', style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Member since ${DateFormat('MMM d, yyyy').format(student.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteStudent(student.uid));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const _SocialLink({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label),
        subtitle: Text(
          url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

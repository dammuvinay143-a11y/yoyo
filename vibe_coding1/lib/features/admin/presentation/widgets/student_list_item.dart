import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../bloc/admin_bloc.dart';

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadAllStudents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Students list
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StudentsLoaded) {
                  final students = state.students.where((student) {
                    return student.name.toLowerCase().contains(_searchQuery) ||
                        (student.department ?? '')
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        student.rollNumber!
                            .toLowerCase()
                            .contains(_searchQuery);
                  }).toList();

                  if (students.isEmpty) {
                    return const Center(child: Text('No students found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: student.isActive
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.3),
                            backgroundImage: student.photoUrl != null
                                ? NetworkImage(student.photoUrl!)
                                : null,
                            child: student.photoUrl == null
                                ? Text(student.name[0].toUpperCase())
                                : null,
                          ),
                          title: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${student.rollNumber} • ${student.department}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: student.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              student.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: student.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                      Icons.email, 'Email', student.email),
                                  _buildInfoRow(Icons.school, 'Department',
                                      student.department ?? 'N/A'),
                                  _buildInfoRow(Icons.class_, 'Year',
                                      'Year ${student.year ?? 'N/A'}'),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRouter.profile,
                                              arguments: student.uid,
                                            );
                                          },
                                          icon: const Icon(Icons.person),
                                          label: const Text('View Profile'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.read<AdminBloc>().add(
                                                  ToggleStudentStatus(
                                                    student.uid,
                                                    !student.isActive,
                                                  ),
                                                );
                                          },
                                          icon: Icon(student.isActive
                                              ? Icons.block
                                              : Icons.check_circle),
                                          label: Text(
                                            student.isActive
                                                ? 'Deactivate'
                                                : 'Activate',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: student.isActive
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showDeleteConfirmation(
                                            context, student.uid, student.name);
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      label: const Text(
                                        'Delete Student',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side:
                                            const BorderSide(color: Colors.red),
                                      ),
                                    ),
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

                return const Center(child: Text('Failed to load students'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String uid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
            'Are you sure you want to delete $name? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteStudent(uid));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

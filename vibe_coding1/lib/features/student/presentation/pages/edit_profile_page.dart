import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/student_bloc.dart';
import '../../data/models/student_profile_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _githubController = TextEditingController();
  final _leetcodeController = TextEditingController();
  final _hackerrankController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _skillController = TextEditingController();
  final _projectTitleController = TextEditingController();
  final _projectDescController = TextEditingController();
  final _projectUrlController = TextEditingController();

  List<String> _skills = [];
  List<ProjectModel> _projects = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<StudentBloc>().add(LoadStudentProfile(authState.user.uid));
    }
  }

  void _populateFields(StudentProfileModel profile) {
    _bioController.text = profile.bio;
    _phoneController.text = profile.phone;
    _githubController.text = profile.githubUrl ?? '';
    _leetcodeController.text = profile.leetcodeUrl ?? '';
    _hackerrankController.text = profile.hackerrankUrl ?? '';
    _linkedinController.text = profile.linkedinUrl ?? '';
    _portfolioController.text = profile.portfolioUrl ?? '';
    _skills = List.from(profile.skills);
    _projects = List.from(profile.projects);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<StudentBloc>().add(
              UploadProfilePhoto(authState.user.uid, _selectedImage!),
            );
      }
    }
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _projectTitleController,
                decoration: const InputDecoration(
                  labelText: 'Project Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _projectDescController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _projectUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_projectTitleController.text.trim().isNotEmpty &&
                  _projectDescController.text.trim().isNotEmpty) {
                setState(() {
                  _projects.add(
                    ProjectModel(
                      title: _projectTitleController.text.trim(),
                      description: _projectDescController.text.trim(),
                      url: _projectUrlController.text.trim().isNotEmpty
                          ? _projectUrlController.text.trim()
                          : null,
                      technologies: [],
                    ),
                  );
                });
                _projectTitleController.clear();
                _projectDescController.clear();
                _projectUrlController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeProject(int index) {
    setState(() {
      _projects.removeAt(index);
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) return;

      final profile = StudentProfileModel(
        uid: authState.user.uid,
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        githubUrl: _githubController.text.trim().isNotEmpty
            ? _githubController.text.trim()
            : null,
        leetcodeUrl: _leetcodeController.text.trim().isNotEmpty
            ? _leetcodeController.text.trim()
            : null,
        hackerrankUrl: _hackerrankController.text.trim().isNotEmpty
            ? _hackerrankController.text.trim()
            : null,
        linkedinUrl: _linkedinController.text.trim().isNotEmpty
            ? _linkedinController.text.trim()
            : null,
        portfolioUrl: _portfolioController.text.trim().isNotEmpty
            ? _portfolioController.text.trim()
            : null,
        skills: _skills,
        projects: _projects,
      );

      context.read<StudentBloc>().add(UpdateStudentProfile(profile));
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _githubController.dispose();
    _leetcodeController.dispose();
    _hackerrankController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _skillController.dispose();
    _projectTitleController.dispose();
    _projectDescController.dispose();
    _projectUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentProfileLoaded) {
            _populateFields(state.profile);
          } else if (state is StudentProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfilePhotoUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo
                  Center(
                    child: Stack(
                      children: [
                        BlocBuilder<StudentBloc, StudentState>(
                          builder: (context, studentState) {
                            // Show uploaded photo from user profile
                            final authState = context.read<AuthBloc>().state;
                            String? photoUrl;
                            if (authState is Authenticated) {
                              photoUrl = authState.user.photoUrl;
                            }
                            if (studentState is ProfilePhotoUploaded) {
                              photoUrl = studentState.photoUrl;
                            }

                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bio
                  const Text(
                    'Bio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _bioController,
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                  ),
                  const SizedBox(height: 24),

                  // Coding Profiles
                  const Text(
                    'Coding Profiles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _githubController,
                    label: 'GitHub',
                    hint: 'https://github.com/username',
                    prefixIcon: Icons.code,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _leetcodeController,
                    label: 'LeetCode',
                    hint: 'https://leetcode.com/username',
                    prefixIcon: Icons.terminal,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _hackerrankController,
                    label: 'HackerRank',
                    hint: 'https://hackerrank.com/username',
                    prefixIcon: Icons.code_outlined,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _linkedinController,
                    label: 'LinkedIn',
                    hint: 'https://linkedin.com/in/username',
                    prefixIcon: Icons.work,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _portfolioController,
                    label: 'Portfolio',
                    hint: 'https://yourportfolio.com',
                    prefixIcon: Icons.web,
                  ),
                  const SizedBox(height: 24),

                  // Skills
                  const Text(
                    'Skills',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          decoration: const InputDecoration(
                            hintText: 'Add a skill',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: AppColors.primary),
                        iconSize: 36,
                        onPressed: _addSkill,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.asMap().entries.map((entry) {
                      return Chip(
                        label: Text(entry.value),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSkill(entry.key),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppColors.primary),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Projects
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Projects',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _showAddProjectDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Project'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._projects.asMap().entries.map((entry) {
                    final project = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(project.title),
                        subtitle: Text(
                          project.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeProject(entry.key),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    text: 'Save Profile',
                    onPressed: _saveProfile,
                    icon: Icons.save,
                    isLoading: state is StudentLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

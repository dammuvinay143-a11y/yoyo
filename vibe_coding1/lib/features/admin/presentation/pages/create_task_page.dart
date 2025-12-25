import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../../../student/data/models/task_model.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _marksController = TextEditingController();
  DateTime? _dueDate;
  final List<String> _selectedDepartments = [];
  final List<int> _selectedYears = [];

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
  ];

  final List<int> _years = [1, 2, 3, 4];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _createTask() {
    if (_formKey.currentState!.validate()) {
      if (_dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select due date')),
        );
        return;
      }

      if (_selectedDepartments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select at least one department')),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) return;

      final task = TaskModel(
        taskId: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate!,
        targetDepartments: _selectedDepartments,
        targetYears: _selectedYears,
        marks: int.parse(_marksController.text.trim()),
        createdBy: authState.user.uid,
        createdAt: DateTime.now(),
      );

      context.read<AdminBloc>().add(CreateTask(task));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is TaskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
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
          final isLoading = state is AdminLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Task Title',
                    hint: 'Enter task title',
                    prefixIcon: Icons.title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter task description',
                    prefixIcon: Icons.description,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Marks
                  CustomTextField(
                    controller: _marksController,
                    label: 'Marks',
                    hint: 'Enter marks',
                    prefixIcon: Icons.grade,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter marks';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Due Date
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _dueDate == null
                            ? 'Select Due Date'
                            : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} ${_dueDate!.hour}:${_dueDate!.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDueDate,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Target Departments
                  const Text(
                    'Target Departments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _departments.map((dept) {
                      final isSelected = _selectedDepartments.contains(dept);
                      return FilterChip(
                        label: Text(dept),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDepartments.add(dept);
                            } else {
                              _selectedDepartments.remove(dept);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.3),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Target Years (Optional)
                  const Text(
                    'Target Years (Optional - Leave empty for all)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _years.map((year) {
                      final isSelected = _selectedYears.contains(year);
                      return FilterChip(
                        label: Text('Year $year'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedYears.add(year);
                            } else {
                              _selectedYears.remove(year);
                            }
                          });
                        },
                        selectedColor: AppColors.info.withOpacity(0.3),
                        checkmarkColor: AppColors.info,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Create Button
                  CustomButton(
                    text: 'Create Task',
                    onPressed: _createTask,
                    icon: Icons.add_task,
                    isLoading: isLoading,
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

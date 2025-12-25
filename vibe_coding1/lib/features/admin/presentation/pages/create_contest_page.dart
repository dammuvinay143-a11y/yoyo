import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../contests/data/models/contest_model.dart';
import '../../../contests/data/repositories/contest_repository.dart';

class CreateContestPage extends StatefulWidget {
  const CreateContestPage({super.key});

  @override
  State<CreateContestPage> createState() => _CreateContestPageState();
}

class _CreateContestPageState extends State<CreateContestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '120');
  final _maxParticipantsController = TextEditingController(text: '0');

  DateTime? _startTime;
  DateTime? _endTime;
  ContestType _contestType = ContestType.individual;
  final List<String> _selectedDepartments = [];
  final List<int> _selectedYears = [];
  final List<Map<String, dynamic>> _problems = []; // List of problems to add

  final List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
  ];

  final List<int> years = [1, 2, 3, 4];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStartTime) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  void _showAddProblemDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddProblemDialog(
        onAdd: (problem) {
          setState(() {
            _problems.add(problem);
          });
        },
      ),
    );
  }

  void _removeProblem(int index) {
    setState(() {
      _problems.removeAt(index);
    });
  }

  Future<void> _createContest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start time')),
      );
      return;
    }

    if (_endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select end time')),
      );
      return;
    }

    if (_endTime!.isBefore(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    setState(() => _isLoading = true);

    try {
      // First, create problem documents and get their IDs
      final repository = context.read<ContestRepository>();
      final problemIds = <String>[];
      
      for (final problemData in _problems) {
        // Create a problem document with all fields including test cases
        final testCases = (problemData['testCases'] as List<Map<String, String>>?) ?? [];
        
        final problemDoc = await FirebaseFirestore.instance.collection('contest_problems').add({
          'title': problemData['title'],
          'platform': problemData['platform'],
          'link': problemData['link'],
          'difficulty': problemData['difficulty'],
          'points': problemData['points'],
          'description': problemData['description'] ?? '',
          'problemStatement': problemData['problemStatement'] ?? '',
          'timeLimit': problemData['timeLimit'] ?? 1,
          'memoryLimit': problemData['memoryLimit'] ?? 256,
          'testCases': testCases.map((tc) => {
            'input': tc['input'],
            'expectedOutput': tc['output'],
            'explanation': tc['explanation'] ?? '',
          }).toList(),
          'createdAt': Timestamp.now(),
          'createdBy': authState.user.uid,
        });
        problemIds.add(problemDoc.id);
      }

      final contest = ContestModel(
        contestId: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        durationMinutes: int.parse(_durationController.text.trim()),
        problems: problemIds,
        targetDepartments: _selectedDepartments,
        targetYears: _selectedYears,
        isActive: true,
        createdBy: authState.user.uid,
        createdAt: DateTime.now(),
        maxParticipants: int.parse(_maxParticipantsController.text.trim()),
        type: _contestType,
      );

      await repository.createContest(contest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contest created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Contest'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Contest Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contest title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Time'),
                            subtitle: Text(_startTime?.toString() ?? 'Not set'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDateTime(true),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('End Time'),
                            subtitle: Text(_endTime?.toString() ?? 'Not set'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDateTime(false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter duration';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Contest Type',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<ContestType>(
                            title: const Text('Individual'),
                            value: ContestType.individual,
                            groupValue: _contestType,
                            onChanged: (value) {
                              setState(() => _contestType = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<ContestType>(
                            title: const Text('Team'),
                            value: ContestType.team,
                            groupValue: _contestType,
                            onChanged: (value) {
                              setState(() => _contestType = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Target Departments (Optional)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: departments.map((dept) {
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
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Target Years (Optional)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: years.map((year) {
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
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Problems Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Problems',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddProblemDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Problem'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_problems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Text('No problems added yet'),
                        ),
                      )
                    else
                      ..._problems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final problem = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              problem['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${problem['platform']} • ${problem['difficulty']} • ${problem['points']} points',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeProblem(index),
                            ),
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _createContest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Create Contest',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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

// Dialog for adding problems
class _AddProblemDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _AddProblemDialog({required this.onAdd});

  @override
  State<_AddProblemDialog> createState() => _AddProblemDialogState();
}

class _AddProblemDialogState extends State<_AddProblemDialog> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _pointsController = TextEditingController(text: '100');
  final _descriptionController = TextEditingController();
  final _problemStatementController = TextEditingController();
  final _timeLimitController = TextEditingController(text: '1');
  final _memoryLimitController = TextEditingController(text: '256');
  String _platform = 'LeetCode';
  String _difficulty = 'Medium';
  List<Map<String, String>> _testCases = [];

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _pointsController.dispose();
    _descriptionController.dispose();
    _problemStatementController.dispose();
    _timeLimitController.dispose();
    _memoryLimitController.dispose();
    super.dispose();
  }

  void _addTestCase() {
    showDialog(
      context: context,
      builder: (context) {
        final inputController = TextEditingController();
        final outputController = TextEditingController();
        final explanationController = TextEditingController();
        
        return AlertDialog(
          title: const Text(
            'Add Test Case',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: 'Test Case Input',
                      border: const OutlineInputBorder(),
                      hintText: 'e.g., [2,7,11,15], 9',
                      filled: true,
                      fillColor: Colors.grey[50],
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Expected Output:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: outputController,
                    decoration: InputDecoration(
                      labelText: 'Expected Result',
                      border: const OutlineInputBorder(),
                      hintText: 'e.g., [0,1]',
                      filled: true,
                      fillColor: Colors.grey[50],
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Explanation (Optional):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: explanationController,
                    decoration: InputDecoration(
                      labelText: 'Explain the test case',
                      border: const OutlineInputBorder(),
                      hintText: 'Why this test case is important...',
                      filled: true,
                      fillColor: Colors.grey[50],
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (inputController.text.trim().isEmpty ||
                    outputController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Input and output are required'),
                    ),
                  );
                  return;
                }
                
                setState(() {
                  _testCases.add({
                    'input': inputController.text.trim(),
                    'output': outputController.text.trim(),
                    'explanation': explanationController.text.trim(),
                  });
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Add Test Case'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Problem'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Problem Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _platform,
                decoration: const InputDecoration(
                  labelText: 'Platform',
                  border: OutlineInputBorder(),
                ),
                items: ['LeetCode', 'HackerRank', 'CodeChef', 'Codeforces', 'Custom']
                    .map((platform) => DropdownMenuItem(
                          value: platform,
                          child: Text(platform),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _platform = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Problem Link ${_platform == 'Custom' ? '(Optional)' : ''}',
                  border: const OutlineInputBorder(),
                  hintText: 'https://leetcode.com/problems/...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Brief description of the problem',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _problemStatementController,
                decoration: const InputDecoration(
                  labelText: 'Problem Statement',
                  border: OutlineInputBorder(),
                  hintText: 'Detailed problem statement',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Easy', 'Medium', 'Hard']
                          .map((diff) => DropdownMenuItem(
                                value: diff,
                                child: Text(diff),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _difficulty = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _pointsController,
                      decoration: const InputDecoration(
                        labelText: 'Points',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _timeLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Time Limit (seconds)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _memoryLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Memory Limit (MB)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Test Cases',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addTestCase,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Test Case'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_testCases.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('No test cases added yet'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _testCases.length,
                  itemBuilder: (context, index) {
                    final testCase = _testCases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('Test Case ${index + 1}'),
                        subtitle: Text(
                          'Input: ${testCase['input']}\nOutput: ${testCase['output']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _testCases.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter problem title')),
              );
              return;
            }

            if (_descriptionController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter problem description')),
              );
              return;
            }

            if (_problemStatementController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter problem statement')),
              );
              return;
            }

            widget.onAdd({
              'title': _titleController.text.trim(),
              'platform': _platform,
              'link': _linkController.text.trim(),
              'difficulty': _difficulty,
              'points': int.tryParse(_pointsController.text.trim()) ?? 100,
              'description': _descriptionController.text.trim(),
              'problemStatement': _problemStatementController.text.trim(),
              'timeLimit': int.tryParse(_timeLimitController.text.trim()) ?? 1,
              'memoryLimit': int.tryParse(_memoryLimitController.text.trim()) ?? 256,
              'testCases': _testCases,
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalTimeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _totalTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Time Entry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4DB6AC),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Project Dropdown
                  Text(
                    'Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildProjectDropdown(provider),
                  const SizedBox(height: 20),

                  // Task Dropdown
                  Text(
                    'Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTaskDropdown(provider),
                  const SizedBox(height: 20),

                  // Date Picker
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Select Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Total Time Input
                  Text(
                    'Total Time (in hours)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _totalTimeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Enter hours (e.g., 2.5)',
                      border: OutlineInputBorder(),
                      suffixText: 'hours',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the total time';
                      }
                      final time = double.tryParse(value.trim());
                      if (time == null) {
                        return 'Please enter a valid number';
                      }
                      if (time <= 0) {
                        return 'Time must be greater than 0';
                      }
                      if (time > 24) {
                        return 'Time cannot exceed 24 hours per day';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Notes Input
                  Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Create Time Entry Button
                  ElevatedButton(
                    onPressed: () => _saveTimeEntry(context, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB6AC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Create Time Entry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Project dropdown populated from provider data
  Widget _buildProjectDropdown(TimeEntryProvider provider) {
    if (provider.projects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'No projects available. Please add projects first.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedProjectId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select a project',
      ),
      items: provider.projects.map((Project project) {
        return DropdownMenuItem<String>(
          value: project.id,
          child: Text(project.name),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedProjectId = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a project';
        }
        return null;
      },
    );
  }

  // Task dropdown populated from provider data
  Widget _buildTaskDropdown(TimeEntryProvider provider) {
    if (provider.tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'No tasks available. Please add tasks first.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedTaskId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select a task',
      ),
      items: provider.tasks.map((Task task) {
        return DropdownMenuItem<String>(
          value: task.id,
          child: Text(task.name),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedTaskId = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a task';
        }
        return null;
      },
    );
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4DB6AC),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Save time entry with working save functionality
  Future<void> _saveTimeEntry(BuildContext context, TimeEntryProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if projects and tasks are available
    if (provider.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one project before creating a time entry.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (provider.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one task before creating a time entry.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create the time entry
      final timeEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: _selectedProjectId!,
        taskId: _selectedTaskId!,
        totalTime: double.parse(_totalTimeController.text.trim()),
        date: _selectedDate,
        notes: _notesController.text.trim(),
      );

      // Save to provider
      await provider.addTimeEntry(timeEntry);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time entry created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating time entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
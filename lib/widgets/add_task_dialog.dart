import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Task Name',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter task name',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task name';
                }
                if (value.trim().length < 2) {
                  return 'Task name must be at least 2 characters';
                }
                if (value.trim().length > 50) {
                  return 'Task name must be less than 50 characters';
                }
                
                // Check for duplicate task names
                final provider = Provider.of<TimeEntryProvider>(context, listen: false);
                final existingTask = provider.tasks.any(
                  (task) => task.name.toLowerCase() == value.trim().toLowerCase(),
                );
                if (existingTask) {
                  return 'A task with this name already exists';
                }
                
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: _addTask,
          child: const Text(
            'Add',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final provider = Provider.of<TimeEntryProvider>(context, listen: false);
      
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
      );

      await provider.addTask(newTask);

      if (context.mounted) {
        Navigator.of(context).pop(newTask); // Return the created task
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${newTask.name}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Static method to show the dialog
  static Future<Task?> show(BuildContext context) {
    return showDialog<Task>(
      context: context,
      builder: (BuildContext context) => const AddTaskDialog(),
    );
  }
}
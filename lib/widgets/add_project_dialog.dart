import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
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
      title: const Text('Add Project'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Project Name',
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
                hintText: 'Enter project name',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project name';
                }
                if (value.trim().length < 2) {
                  return 'Project name must be at least 2 characters';
                }
                if (value.trim().length > 50) {
                  return 'Project name must be less than 50 characters';
                }
                
                // Check for duplicate project names
                final provider = Provider.of<TimeEntryProvider>(context, listen: false);
                final existingProject = provider.projects.any(
                  (project) => project.name.toLowerCase() == value.trim().toLowerCase(),
                );
                if (existingProject) {
                  return 'A project with this name already exists';
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
          onPressed: _addProject,
          child: const Text(
            'Add',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Future<void> _addProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final provider = Provider.of<TimeEntryProvider>(context, listen: false);
      
      final newProject = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        isDefault: provider.projects.isEmpty, // First project becomes default
      );

      await provider.addProject(newProject);

      if (context.mounted) {
        Navigator.of(context).pop(newProject); // Return the created project
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${newProject.name}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Static method to show the dialog
  static Future<Project?> show(BuildContext context) {
    return showDialog<Project>(
      context: context,
      builder: (BuildContext context) => const AddProjectDialog(),
    );
  }
}
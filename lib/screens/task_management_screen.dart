import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Tasks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4DB6AC),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.tasks.isEmpty) {
            // Empty state when no tasks exist
            return _buildEmptyState();
          } else {
            // List of tasks with delete functionality
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return _buildTaskCard(context, task, provider);
              },
            );
          }
        },
      ),
      // (+) button to add a new task
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Empty state UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Task card with delete functionality
  Widget _buildTaskCard(BuildContext context, Task task, TimeEntryProvider provider) {
    final totalTime = provider.timeEntries
        .where((entry) => entry.taskId == task.id)
        .fold(0.0, (sum, entry) => sum + entry.totalTime);
    
    final entryCount = provider.timeEntries
        .where((entry) => entry.taskId == task.id)
        .length;

    final projectsUsingTask = provider.timeEntries
        .where((entry) => entry.taskId == task.id)
        .map((entry) => provider.getProjectName(entry.projectId))
        .toSet()
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4DB6AC),
          child: Icon(
            Icons.task,
            color: Colors.white,
          ),
        ),
        title: Text(
          task.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total time: ${totalTime.toStringAsFixed(1)} hours'),
            Text('Entries: $entryCount'),
            if (projectsUsingTask.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Used in: ${projectsUsingTask.take(2).join(', ')}${projectsUsingTask.length > 2 ? '...' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteTaskConfirmation(context, task, provider),
        ),
      ),
    );
  }

  // Add task dialog gets called using the (+) button
  void _showAddTaskDialog(BuildContext context) {
    showDialog<Task>(
      context: context,
      builder: (BuildContext context) => const AddTaskDialog(),
    );
  }

  // Delete task confirmation dialog
  void _showDeleteTaskConfirmation(BuildContext context, Task task, TimeEntryProvider provider) {
    final entryCount = provider.timeEntries
        .where((entry) => entry.taskId == task.id)
        .length;

    final projectsUsingTask = provider.timeEntries
        .where((entry) => entry.taskId == task.id)
        .map((entry) => provider.getProjectName(entry.projectId))
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete "${task.name}"?'),
              if (entryCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Warning: This will also delete $entryCount time ${entryCount == 1 ? 'entry' : 'entries'} associated with this task.',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (projectsUsingTask.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'This task is used in projects: ${projectsUsingTask.join(', ')}',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _deleteTask(context, task, provider),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Delete task functionality
  Future<void> _deleteTask(BuildContext context, Task task, TimeEntryProvider provider) async {
    try {
      await provider.deleteTask(task.id);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.name}" deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
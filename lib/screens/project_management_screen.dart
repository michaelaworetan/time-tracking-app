import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../widgets/add_project_dialog.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Projects',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4DB6AC),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            // Empty state when no projects exist
            return _buildEmptyState();
          } else {
            // List of projects with delete functionality
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.projects.length,
              itemBuilder: (context, index) {
                final project = provider.projects[index];
                return _buildProjectCard(context, project, provider);
              },
            );
          }
        },
      ),
      // (+) button to add a new project
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
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
            Icons.folder_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No projects yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first project.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Project card with delete functionality
  Widget _buildProjectCard(BuildContext context, Project project, TimeEntryProvider provider) {
    final totalTime = provider.getTotalTimeForProject(project.id);
    final entryCount = provider.timeEntries
        .where((entry) => entry.projectId == project.id)
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4DB6AC),
          child: Icon(
            Icons.folder,
            color: Colors.white,
          ),
        ),
        title: Text(
          project.name,
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
            if (project.isDefault)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteProjectConfirmation(context, project, provider),
        ),
      ),
    );
  }

  // Add project dialog gets called using the (+) button
  void _showAddProjectDialog(BuildContext context) {
    showDialog<Project>(
      context: context,
      builder: (BuildContext context) => const AddProjectDialog(),
    );
  }

  // Delete project confirmation dialog
  void _showDeleteProjectConfirmation(BuildContext context, Project project, TimeEntryProvider provider) {
    final entryCount = provider.timeEntries
        .where((entry) => entry.projectId == project.id)
        .length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete "${project.name}"?'),
              if (entryCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Warning: This will also delete $entryCount time ${entryCount == 1 ? 'entry' : 'entries'} associated with this project.',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (project.isDefault) ...[
                const SizedBox(height: 8),
                const Text(
                  'Note: This is marked as the default project.',
                  style: TextStyle(
                    color: Colors.orange,
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
              onPressed: () => _deleteProject(context, project, provider),
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

  // Delete project functionality
  Future<void> _deleteProject(BuildContext context, Project project, TimeEntryProvider provider) async {
    try {
      await provider.deleteProject(project.id);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
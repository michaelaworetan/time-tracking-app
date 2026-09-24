import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import 'add_time_entry_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Time Tracking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4DB6AC),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Entries'),
            Tab(text: 'Grouped by Projects'),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllEntriesTab(),
          _buildGroupedByProjectsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTimeEntryScreen(),
            ),
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Hamburger menu drawer with Projects and Tasks navigation
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF4DB6AC),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Projects'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text('Tasks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // All Entries tab - displays empty state when no entries exist, list when entries exist
  Widget _buildAllEntriesTab() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.timeEntries.isEmpty) {
          // Empty state UI when no entries exist
          return _buildEmptyState();
        } else {
          // Display list of time entries
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.timeEntries.length,
            itemBuilder: (context, index) {
              final entry = provider.timeEntries[index];
              return _buildTimeEntryCard(entry, provider);
            },
          );
        }
      },
    );
  }

  // Grouped by Projects tab - displays empty state when no entries exist, grouped entries when exist
  Widget _buildGroupedByProjectsTab() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.timeEntries.isEmpty) {
          // Empty state UI when no entries exist
          return _buildEmptyState();
        } else {
          // Display grouped entries by project
          final groupedEntries = provider.getTimeEntriesGroupedByProject();
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: groupedEntries.keys.length,
            itemBuilder: (context, index) {
              final projectName = groupedEntries.keys.elementAt(index);
              final entries = groupedEntries[projectName]!;
              return _buildProjectGroup(projectName, entries, provider);
            },
          );
        }
      },
    );
  }

  // Empty state UI matching the screenshot
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No time entries yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first entry.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Time entry card with delete functionality
  Widget _buildTimeEntryCard(TimeEntry entry, TimeEntryProvider provider) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4DB6AC),
          child: Text(
            '${entry.totalTime.toStringAsFixed(1)}h',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          provider.getProjectName(entry.projectId),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task: ${provider.getTaskName(entry.taskId)}'),
            Text('Date: ${dateFormat.format(entry.date)}'),
            if (entry.notes.isNotEmpty) Text('Notes: ${entry.notes}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(context, entry, provider),
        ),
      ),
    );
  }

  // Project group for the "Grouped by Projects" tab
  Widget _buildProjectGroup(String projectName, List<TimeEntry> entries, TimeEntryProvider provider) {
    final totalTime = entries.fold(0.0, (sum, entry) => sum + entry.totalTime);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ExpansionTile(
        leading: const Icon(Icons.folder, color: Color(0xFF4DB6AC)),
        title: Text(
          projectName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Total: ${totalTime.toStringAsFixed(1)} hours'),
        children: entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 16,
                child: Text(
                  '${entry.totalTime.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(provider.getTaskName(entry.taskId)),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(entry.date)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _showDeleteConfirmation(context, entry, provider),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, TimeEntry entry, TimeEntryProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this time entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTimeEntry(entry.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Time entry deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
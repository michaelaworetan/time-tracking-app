import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:collection/collection.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';
import '../services/logger_service.dart';

class TimeEntryProvider extends ChangeNotifier {
  // Initialize LocalStorage
  // final LocalStorage _storage = LocalStorage();
  // final LocalStorage localStorage;

  // Initialize empty lists
  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  // Getters
  List<TimeEntry> get timeEntries => List.unmodifiable(_timeEntries);
  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);

  // Constructor - Initialize the provider and load data from local storage
  TimeEntryProvider() {
    LoggerService.info('*** Initializing TimeEntryProvider ***');
    _loadFromStorage();
  }

  // Load data from local storage
  Future<void> _loadFromStorage() async {
    try {
      // Load time entries
      final timeEntriesJson = localStorage.getItem('timeEntries');
      if (timeEntriesJson != null) {
        final List<dynamic> entriesList = jsonDecode(timeEntriesJson);
        _timeEntries = entriesList.map((json) => TimeEntry.fromJson(json)).toList();
      }

      // Load projects
      final projectsJson = localStorage.getItem('projects');
      if (projectsJson != null) {
        final List<dynamic> projectsList = jsonDecode(projectsJson);
        _projects = projectsList.map((json) => Project.fromJson(json)).toList();
      }

      // Load tasks
      final tasksJson = localStorage.getItem('tasks');
      if (tasksJson != null) {
        final List<dynamic> tasksList = jsonDecode(tasksJson);
        _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
      }

      debugPrint('TIME ENTRIES: $timeEntriesJson');
      debugPrint('PROJECTS: $projectsJson');
      debugPrint('TASKS: $tasksJson');


      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data from storage: $e');
    }
  }

  // Save data to local storage
  Future<void> _saveToStorage() async {
    try {
      // Save time entries
      final timeEntriesJson = jsonEncode(_timeEntries.map((entry) => entry.toJson()).toList());
      localStorage.setItem('timeEntries', timeEntriesJson);

      // Save projects
      final projectsJson = jsonEncode(_projects.map((project) => project.toJson()).toList());
      localStorage.setItem('projects', projectsJson);

      // Save tasks
      final tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
      localStorage.setItem('tasks', tasksJson);
    } catch (e) {
      debugPrint('Error saving data to storage: $e');
    }
  }

  // Time Entry Operations
  Future<void> addTimeEntry(TimeEntry entry) async {
    _timeEntries.add(entry);
    _saveToStorage();
    notifyListeners();
  }

  Future<void> updateTimeEntry(TimeEntry updatedEntry) async {
    final index = _timeEntries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      _timeEntries[index] = updatedEntry;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteTimeEntry(String entryId) async {
    _timeEntries.removeWhere((entry) => entry.id == entryId);
    await _saveToStorage();
    notifyListeners();
  }

  // Project Operations
  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateProject(Project updatedProject) async {
    final index = _projects.indexWhere((project) => project.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    // Also delete all time entries associated with this project
    _timeEntries.removeWhere((entry) => entry.projectId == projectId);
    _projects.removeWhere((project) => project.id == projectId);
    await _saveToStorage();
    notifyListeners();
  }

  // Task Operations
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    // Also delete all time entries associated with this task
    _timeEntries.removeWhere((entry) => entry.taskId == taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveToStorage();
    notifyListeners();
  }

  // Helper methods for UI
  Project? getProjectById(String projectId) {
    return _projects.firstWhereOrNull((project) => project.id == projectId);
  }

  Task? getTaskById(String taskId) {
    return _tasks.firstWhereOrNull((task) => task.id == taskId);
  }

  String getProjectName(String projectId) {
    final project = getProjectById(projectId);
    return project?.name ?? 'Unknown Project';
  }

  String getTaskName(String taskId) {
    final task = getTaskById(taskId);
    return task?.name ?? 'Unknown Task';
  }

  // Group time entries by project for the "Grouped by Projects" tab
  Map<String, List<TimeEntry>> getTimeEntriesGroupedByProject() {
    final Map<String, List<TimeEntry>> groupedEntries = {};
    
    for (final entry in _timeEntries) {
      final projectName = getProjectName(entry.projectId);
      if (groupedEntries[projectName] == null) {
        groupedEntries[projectName] = [];
      }
      groupedEntries[projectName]!.add(entry);
    }
    
    return groupedEntries;
  }

  // Get total time for a specific project
  double getTotalTimeForProject(String projectId) {
    return _timeEntries
        .where((entry) => entry.projectId == projectId)
        .fold(0.0, (sum, entry) => sum + entry.totalTime);
  }

  // Get total time across all projects
  double getTotalTime() {
    return _timeEntries.fold(0.0, (sum, entry) => sum + entry.totalTime);
  }

  // Clear all data (useful for testing)
  Future<void> clearAllData() async {
    _timeEntries.clear();
    _projects.clear();
    _tasks.clear();
    await _saveToStorage();
    notifyListeners();
  }
}
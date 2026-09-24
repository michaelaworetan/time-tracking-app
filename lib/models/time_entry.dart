class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime; // Time in hours (decimal format like 2.5)
  final DateTime date;
  final String notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    this.notes = '',
  });

  // Convert TimeEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'totalTime': totalTime,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Create TimeEntry from JSON
  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      taskId: json['taskId'] as String,
      totalTime: (json['totalTime'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String? ?? '',
    );
  }

  // Create a copy with optional modifications
  TimeEntry copyWith({
    String? id,
    String? projectId,
    String? taskId,
    double? totalTime,
    DateTime? date,
    String? notes,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      totalTime: totalTime ?? this.totalTime,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'TimeEntry(id: $id, projectId: $projectId, taskId: $taskId, totalTime: $totalTime, date: $date, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeEntry &&
        other.id == id &&
        other.projectId == projectId &&
        other.taskId == taskId &&
        other.totalTime == totalTime &&
        other.date == date &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(id, projectId, taskId, totalTime, date, notes);
}
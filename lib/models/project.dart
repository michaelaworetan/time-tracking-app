class Project {
  final String id;
  final String name;
  final bool isDefault;

  Project({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  // Convert Project to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault,
    };
  }

  // Create Project from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  // Create a copy with optional modifications
  Project copyWith({
    String? id,
    String? name,
    bool? isDefault,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault);
}
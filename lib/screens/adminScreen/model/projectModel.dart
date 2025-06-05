class Project {
  final String id;
  final String projectName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String createdBy;
  final List<String> tasks;
  final bool isActive;
  final bool deleteStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.projectName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdBy,
    required this.tasks,
    required this.isActive,
    required this.deleteStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? '',
      projectName: json['project_name'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      createdBy: json['created_by'] ?? '',
      tasks: List<String>.from(json['tasks'] ?? []),
      isActive: json['is_active'] ?? true,
      deleteStatus: json['delete_status'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'project_name': projectName,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'created_by': createdBy,
      'tasks': tasks,
      'is_active': isActive,
      'delete_status': deleteStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedEndDate {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }
}
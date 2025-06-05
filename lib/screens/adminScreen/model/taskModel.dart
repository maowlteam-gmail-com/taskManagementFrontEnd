class TaskModel {
  final String id;
  final String taskName;
  final String status;
  final User createdBy;
  final User assignedTo;

  TaskModel({
    required this.id,
    required this.taskName,
    required this.status,
    required this.createdBy,
    required this.assignedTo,
  });
}

class User {
  final String id;
  final String username;

  User({
    required this.id,
    required this.username,
  });
}
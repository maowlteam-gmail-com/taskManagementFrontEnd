class TaskHistoryResponse {
  final bool success;
  final TaskDetails task;
  final List<HistoryItem> history;
  final Pagination pagination;

  TaskHistoryResponse({
    required this.success,
    required this.task,
    required this.history,
    required this.pagination,
  });

  factory TaskHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TaskHistoryResponse(
      success: json['success'] ?? false,
      task: TaskDetails.fromJson(json['task'] ?? {}),
      history: (json['history'] as List?)
          ?.map((item) => HistoryItem.fromJson(item))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class TaskDetails {
  final String taskName;
  final String createdBy;
  final String assignedTo;
  final String startDate;
  final String endDate;
  final String status;

  TaskDetails({
    required this.taskName,
    required this.createdBy,
    required this.assignedTo,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) {
    return TaskDetails(
      taskName: json['task_name'] ?? '',
      createdBy: json['created_by'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class HistoryItem {
  final String id;
  final String action;
  final PerformedBy performedBy;
  final String timestamp;
  final WorkDetails? details;
  final String comment;
  final List<FileItem>? files;

  HistoryItem({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.timestamp,
    this.details,
    required this.comment,
    this.files,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['_id'] ?? '',
      action: json['action'] ?? '',
      performedBy: PerformedBy.fromJson(json['performed_by'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      details: json['details'] != null ? WorkDetails.fromJson(json['details']) : null,
      comment: json['comment'] ?? '',
      files: json['files'] != null 
          ? (json['files'] as List).map((file) => FileItem.fromJson(file)).toList()
          : null,
    );
  }
}

class PerformedBy {
  final String id;
  final String username;

  PerformedBy({
    required this.id,
    required this.username,
  });

  factory PerformedBy.fromJson(Map<String, dynamic> json) {
    return PerformedBy(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class WorkDetails {
  final String description;
  final String caption;
  final String hoursSpent;

  WorkDetails({
    required this.description,
    required this.caption,
    required this.hoursSpent,
  });

  factory WorkDetails.fromJson(Map<String, dynamic> json) {
    return WorkDetails(
      description: json['description'] ?? '',
      caption: json['caption'] ?? '',
      hoursSpent: json['hours_spent']?.toString() ?? '0',
    );
  }
}

class FileItem {
  final String id;
  final String filename;
  final String caption;
  final String type;

  FileItem({
    required this.id,
    required this.filename,
    required this.caption,
    required this.type,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['_id'] ?? '',
      filename: json['filename'] ?? '',
      caption: json['caption'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}
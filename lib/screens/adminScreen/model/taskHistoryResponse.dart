class TaskHistoryResponse {
  final bool success;
  final String message;
  final TaskDetails task;
  final List<HistoryItem> history;
  final Pagination? pagination;

  TaskHistoryResponse({
    required this.success,
    required this.message,
    required this.task,
    required this.history,
    this.pagination,
  });

  factory TaskHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TaskHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      // Fixed: Remove the 'data' wrapper since task is at root level
      task: TaskDetails.fromJson(json['task'] ?? {}),
      history: (json['history'] as List<dynamic>?)
          ?.map((item) => HistoryItem.fromJson(item))
          .toList() ?? [],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }
}

class TaskDetails {
  final String id;
  final String taskName;
  final String createdBy;
  final String assignedTo;
  final String startDate;
  final String endDate;
  final String status;

  TaskDetails({
    required this.id,
    required this.taskName,
    required this.createdBy,
    required this.assignedTo,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) {
    return TaskDetails(
      id: json['_id'] ?? json['id'] ?? '',
      taskName: json['task_name'] ?? json['taskName'] ?? '',
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
      assignedTo: json['assigned_to'] ?? json['assignedTo'] ?? '',
      startDate: json['start_date'] ?? json['startDate'] ?? '',
      endDate: json['end_date'] ?? json['endDate'] ?? '',
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
  final List<FileItem>? files; // Added for other_update actions

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
      id: json['_id'] ?? json['id'] ?? '',
      action: json['action'] ?? '',
      performedBy: PerformedBy.fromJson(json['performed_by'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      details: json['details'] != null ? WorkDetails.fromJson(json['details']) : null,
      comment: json['comment'] ?? '',
      // Handle files at root level for other_update actions
      files: json['files'] != null 
          ? (json['files'] as List<dynamic>)
              .map((file) => FileItem.fromJson(file))
              .toList()
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
  final String? caption;
  final String hoursSpent;
  final List<FileItem>? files;
  // Additional fields for other_update actions
  final String? fileUrl;
  final String? fileType;
  final bool? relatedToWorkDetail;

  WorkDetails({
    required this.description,
    this.caption,
    required this.hoursSpent,
    this.files,
    this.fileUrl,
    this.fileType,
    this.relatedToWorkDetail,
  });

  factory WorkDetails.fromJson(Map<String, dynamic> json) {
    return WorkDetails(
      description: json['description'] ?? '',
      caption: json['caption'],
      hoursSpent: json['hours_spent'] ?? json['hoursSpent'] ?? '0',
      files: json['files'] != null 
          ? (json['files'] as List<dynamic>)
              .map((file) => FileItem.fromJson(file))
              .toList()
          : null,
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      relatedToWorkDetail: json['related_to_work_detail'],
    );
  }
}

class FileItem {
  final String fileId;
  final String filename;
  final String url;
  final String type;
  final String? caption;
  final String? uploadedAt;
  final String? uploadedBy;
  final String? downloadUrl;

  FileItem({
    required this.fileId,
    required this.filename,
    required this.url,
    required this.type,
    this.caption,
    this.uploadedAt,
    this.uploadedBy,
    this.downloadUrl,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      fileId: json['file_id'] ?? json['fileId'] ?? json['_id'] ?? '',
      filename: json['filename'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      caption: json['caption'],
      uploadedAt: json['uploaded_at'],
      uploadedBy: json['uploaded_by'],
      downloadUrl: json['download_url'],
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
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maowl/screens/adminScreen/controller/downloadService.dart';
import 'package:maowl/screens/adminScreen/widgets/collaboratorAvatar.dart';
import 'dart:html' as html;
// For Android MediaScanner (you might need a plugin for this)
import 'package:media_scanner/media_scanner.dart';

class EmployeeProjects extends StatefulWidget {
  final Map<String, dynamic> employee;
  final Function onBack;

  const EmployeeProjects({
    super.key,
    required this.employee,
    required this.onBack,
  });

  @override
  State<EmployeeProjects> createState() => _EmployeeProjectsState();
}

class _EmployeeProjectsState extends State<EmployeeProjects> {
  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Dio _dio = Dio();
  final box = GetStorage();

  // Task detail and history state
  final RxBool showTaskDetail = false.obs;
  final Rx<Map<String, dynamic>> selectedTask = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> taskHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHistory = false.obs;
  final RxString historyError = ''.obs;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = box.read('token');
      final employeeId = widget.employee['_id'];

      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return;
      }

      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/tasks/getTaskByUserId/$employeeId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          final dataList = responseBody['data'] as List;
          tasks.value = dataList.map((e) => e as Map<String, dynamic>).toList();
        } else {
          errorMessage.value =
              "Unexpected response format: missing 'data' array";
        }
      } else {
        errorMessage.value = "Failed to load tasks: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Error fetching tasks: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // Add this to your existing Obx variables
  var filterWorkDetails = [].obs;

  Future<void> fetchTaskHistory(String taskId) async {
    isLoadingHistory.value = true;
    historyError.value = '';

    try {
      final token = box.read('token');

      if (token == null) {
        historyError.value = 'Authentication token not found';
        return;
      }

      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/tasks/getTaskHistory/$taskId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody.containsKey('history') &&
            responseBody['history'] is List) {
          final historyList = responseBody['history'] as List;

          // Store all history items
          taskHistory.value =
              historyList.map((e) => e as Map<String, dynamic>).toList();

          // Filter work_detail_added items and store them separately
          filterWorkDetails.value =
              taskHistory.value
                  .where((item) => item['action'] == 'work_detail_added')
                  .toList();

          print("Work detail items: $filterWorkDetails");
          print("work details lemgth : ${filterWorkDetails.length}");
        } else {
          taskHistory.value = [];
          filterWorkDetails.value = [];
          historyError.value = "No history available for this task";
        }
      } else {
        historyError.value =
            "Failed to load task history: ${response.statusCode}";
      }
    } on DioException catch (e) {
      historyError.value = "Dio error: ${e.message}";
    } catch (e) {
      historyError.value = "Error fetching task history: $e";
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void viewTaskDetail(Map<String, dynamic> task) {
    selectedTask.value = task;
    showTaskDetail.value = true;

    // Fetch task history when viewing details
    if (task.containsKey('_id')) {
      fetchTaskHistory(task['_id']);
    } else {
      historyError.value = "Task ID not found";
      taskHistory.clear();
    }
  }

  void closeTaskDetail() {
    showTaskDetail.value = false;
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String capitalizeStatus(String status) {
    return status
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'warning':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getUsername(dynamic addedBy) {
    if (addedBy is Map<String, dynamic>) {
      return addedBy['username'] ?? 'Unknown User';
    } else if (addedBy is String) {
      return addedBy;
    }
    return 'Unknown User';
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication token not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await _dio.delete(
        '${dotenv.env['BASE_URL']}/api/tasks/deleteTask/$taskId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // Remove the task from the list and show success message
        tasks.removeWhere((task) => task['_id'] == taskId);
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete task: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error deleting task: $e");
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // show a confirmation dialog
  void showDeleteConfirmation(String taskId, String taskName) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "$taskName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[800]),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              deleteTask(taskId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? getLatestWorkDetail(List<dynamic>? workDetails) {
    if (workDetails == null || workDetails.isEmpty) {
      return null;
    }

    // Sort work details by date (newest first)
    final sorted = List<Map<String, dynamic>>.from(workDetails)..sort((a, b) {
      final dateA =
          a['date'] != null
              ? DateTime.parse(a['date'].toString())
              : DateTime(1900);
      final dateB =
          b['date'] != null
              ? DateTime.parse(b['date'].toString())
              : DateTime(1900);
      return dateB.compareTo(dateA);
    });

    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Obx(
        () =>
            showTaskDetail.value
                ? _buildTaskDetailView()
                : _buildTasksGridView(),
      ),
    );
  }

Widget _buildTasksGridView() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header section with modern styling
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => widget.onBack(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.employee['username']}\'s Tasks',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Obx(
                      () => Text(
                        '${tasks.length} ${tasks.length == 1 ? 'Task' : 'Tasks'} Assigned',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[700]!, Colors.grey[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton.icon(
                  onPressed: fetchTasks,
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text('Refresh', style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Content area
      Expanded(
        child: Container(
          color: Colors.white,
          child: Obx(() {
            if (isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: Colors.grey[800]),
              );
            }

            if (errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(
                      errorMessage.value,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: fetchTasks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 48.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No tasks assigned to this employee',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => fetchTasks(),
              color: Colors.grey[800],
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;

                    // Sort tasks by updatedAt date (latest first)
                    final sortedTasks = List.from(tasks);
                    sortedTasks.sort((a, b) {
                      final dateA = DateTime.tryParse(a['updatedAt'] ?? '') ?? DateTime(1970);
                      final dateB = DateTime.tryParse(b['updatedAt'] ?? '') ?? DateTime(1970);
                      return dateB.compareTo(dateA); // Latest first (descending order)
                    });

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        childAspectRatio: isMobile ? 0.85 : 1.2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        final projectName = task['project_name'] ?? 'Unknown Project';
                        final taskName = task['task_name'] ?? 'Unnamed Task';
                        final startDate = formatDate(task['start_date']);
                        final endDate = formatDate(task['end_date']);
                        final updatedAt = formatDate(task['updatedAt']);
                        final status = task['status'] ?? 'unknown';
                        
                        // User information
                        final assignedUser = task['assigned_to']?['username'] ?? 'Unknown User';
                        final createdBy = task['created_by']?['username'] ?? 'Unknown User';

                        // Get latest work detail
                        final workDetails = task['work_details'] as List<dynamic>?;
                        final latestWorkDetail = getLatestWorkDetail(workDetails);
                        final hasWorkDetails = latestWorkDetail != null;

                        // Get files and images from latest work detail
                        List<dynamic> files = [];
                        List<dynamic> images = [];
                        if (hasWorkDetails) {
                          files = latestWorkDetail['files'] ?? [];
                          images = latestWorkDetail['images'] ?? [];
                        }

                        return Card(
                          elevation: 8,
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => viewTaskDetail(task),
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Main content with gradient background
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[900]!,
                                        Colors.grey[800]!,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      16.w,
                                      16.h,
                                      80.w,
                                      16.h,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header with project name and delete button
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                projectName,
                                                style: TextStyle(
                                                  fontSize: isMobile ? 18.sp : 20.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.red.withOpacity(0.5),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  showDeleteConfirmation(
                                                    task['_id'],
                                                    taskName,
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(6),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.w),
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 16.sp,
                                                    color: Colors.red[300],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8.h),

                                        // Task name
                                        Text(
                                          taskName,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[300],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        SizedBox(height: 8.h),

                                        // User Information Section
                                        Container(
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[850],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey[700]!,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.person_outline,
                                                    size: 14.sp,
                                                    color: Colors.blue[300],
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    'Assigned to: ',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      assignedUser,
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.blue[300],
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.person_add_outlined,
                                                    size: 14.sp,
                                                    color: Colors.green[300],
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    'Created by: ',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      createdBy,
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.green[300],
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 12.h),

                                        // Latest Work Detail Section
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: hasWorkDetails
                                                ? Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Latest Update',
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                              vertical: 4.h,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.blue.withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(12),
                                                              border: Border.all(
                                                                color: Colors.blue.withOpacity(0.5),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              '${latestWorkDetail['hours_spent']} hrs',
                                                              style: TextStyle(
                                                                fontSize: 10.sp,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.blue[700],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8.h),
                                                      
                                                      // Work description
                                                      Expanded(
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                '${latestWorkDetail['description']}',
                                                                style: TextStyle(
                                                                  fontSize: 13.sp,
                                                                  color: Colors.black,
                                                                  height: 1.3,
                                                                ),
                                                                overflow: TextOverflow.fade,
                                                              ),
                                                              
                                                              // Files and Images Section
                                                              if (files.isNotEmpty || images.isNotEmpty) ...[
                                                                SizedBox(height: 8.h),
                                                                Container(
                                                                  padding: EdgeInsets.all(8.w),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.grey[50],
                                                                    borderRadius: BorderRadius.circular(6),
                                                                    border: Border.all(
                                                                      color: Colors.grey[300]!,
                                                                    ),
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        'Attachments:',
                                                                        style: TextStyle(
                                                                          fontSize: 11.sp,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.grey[700],
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 4.h),
                                                                      
                                                                      // Display files
                                                                      ...files.map((file) {
                                                                        String fileName = file['file_url']?.split('/').last ?? 'Unknown File';
                                                                        return Padding(
                                                                          padding: EdgeInsets.symmetric(vertical: 2.h),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.attachment,
                                                                                size: 12.sp,
                                                                                color: Colors.orange[600],
                                                                              ),
                                                                              SizedBox(width: 4.w),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  fileName,
                                                                                  style: TextStyle(
                                                                                    fontSize: 10.sp,
                                                                                    color: Colors.grey[800],
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }),
                                                                      
                                                                      // Display images
                                                                      ...images.map((image) {
                                                                        String imageName = image['file_url']?.split('/').last ?? 'Unknown Image';
                                                                        return Padding(
                                                                          padding: EdgeInsets.symmetric(vertical: 2.h),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.image,
                                                                                size: 12.sp,
                                                                                color: Colors.purple[600],
                                                                              ),
                                                                              SizedBox(width: 4.w),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  imageName,
                                                                                  style: TextStyle(
                                                                                    fontSize: 10.sp,
                                                                                    color: Colors.grey[800],
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      
                                                      SizedBox(height: 8.h),
                                                      
                                                      // Date info
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'Updated by: $createdBy',
                                                              style: TextStyle(
                                                                fontSize: 10.sp,
                                                                fontStyle: FontStyle.italic,
                                                                color: Colors.grey[600],
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Text(
                                                            formatDateTime(
                                                              latestWorkDetail['date'],
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              color: Colors.grey[700],
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.work_outline,
                                                          size: 24.sp,
                                                          color: Colors.grey[400],
                                                        ),
                                                        SizedBox(height: 8.h),
                                                        Text(
                                                          'No work updates yet',
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.grey[500],
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        SizedBox(height: 12.h),

                                        // Date information section
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTaskDateColumn(
                                                'START',
                                                startDate,
                                                Icons.play_arrow,
                                                Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: _buildTaskDateColumn(
                                                'DUE',
                                                endDate,
                                                Icons.stop,
                                                Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8.h),

                                        // Updated info
                                        Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(0.5),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.update,
                                                size: 12.sp,
                                                color: Colors.grey[400],
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                'Updated: $updatedAt',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Status container spanning full height on the right side
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 60.w,
                                    decoration: BoxDecoration(
                                      color: getStatusColor(status),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Center(
                                        child: Text(
                                          capitalizeStatus(status).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    ],
  );
}
  // Helper method for task date columns
  Widget _buildTaskDateColumn(
    String label,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: color),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            date,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailView() {
    final task = selectedTask.value;
    final projectName = task['project_name'] ?? 'Unknown Project';
    final taskName = task['task_name'] ?? 'Unnamed Task';
    final description = task['description'] ?? 'No description available';
    final startDate = formatDate(task['start_date']);
    final endDate = formatDate(task['end_date']);
    final status = task['status'] ?? 'unknown';
    final createdAt = formatDateTime(task['createdAt']);
    final updatedAt = formatDateTime(task['updatedAt']);
    final assignedTo = task['assignedTo'] ?? [];
    //final createdBy = task['created_by'] ?? 'Unknown User';

    // Get work details from task
    final List<dynamic> workDetailsRaw =
        task['work_details'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> workDetails =
        List<Map<String, dynamic>>.from(workDetailsRaw);

    // Get history from task if available
    final List<dynamic> historyRaw = task['history'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(
      historyRaw,
    );

    // Process files from history and add to work details
    if (history.isNotEmpty) {
      // Map to track work detail IDs
      final Map<String, int> workDetailIndexMap = {};

      // Create an index map for quick access to work details
      for (int i = 0; i < workDetails.length; i++) {
        final workDetailId = workDetails[i]['_id']?.toString();
        if (workDetailId != null) {
          workDetailIndexMap[workDetailId] = i;
        }
      }

      // Process history to find files
      for (final entry in history) {
        final String action = entry['action'] ?? '';

        if (action == 'image_added' || action == 'file_added') {
          final details = entry['details'] ?? {};
          final List<dynamic> filesRaw = entry['files'] as List<dynamic>? ?? [];

          if (filesRaw.isNotEmpty) {
            // Check if this file is related to work detail
            final bool relatedToWorkDetail =
                details['related_to_work_detail'] == true;
            final String workDetailId =
                details['work_detail_id']?.toString() ?? '';

            if (relatedToWorkDetail &&
                workDetailId.isNotEmpty &&
                workDetailIndexMap.containsKey(workDetailId)) {
              // Direct match with work detail ID
              final int workDetailIndex = workDetailIndexMap[workDetailId]!;

              // Convert files to expected format
              List<Map<String, dynamic>> formattedFiles =
                  filesRaw.map<Map<String, dynamic>>((file) {
                    return {
                      'id': file['_id']?.toString() ?? '',
                      'name': file['filename'] ?? 'Unknown File',
                      'description': file['caption'] ?? '',
                      'size': 0, // Size might not be available
                    };
                  }).toList();

              // Add files to work detail
              if (workDetails[workDetailIndex]['files'] == null) {
                workDetails[workDetailIndex]['files'] = [];
              }
              workDetails[workDetailIndex]['files'].addAll(formattedFiles);
            } else if (relatedToWorkDetail) {
              // Try to match by timestamp if no direct ID match
              final timestamp =
                  DateTime.tryParse(entry['timestamp'] ?? '') ?? DateTime.now();
              int? closestIndex;
              Duration closestDuration = Duration(
                hours: 1,
              ); // Max 1 hour difference

              for (int i = 0; i < workDetails.length; i++) {
                final workDetailDate =
                    DateTime.tryParse(
                      workDetails[i]['date']?.toString() ?? '',
                    ) ??
                    DateTime.now();
                final difference = timestamp.difference(workDetailDate).abs();

                if (difference < closestDuration) {
                  closestDuration = difference;
                  closestIndex = i;
                }
              }

              if (closestIndex != null) {
                // Convert files to expected format
                List<Map<String, dynamic>> formattedFiles =
                    filesRaw.map<Map<String, dynamic>>((file) {
                      return {
                        'id': file['_id']?.toString() ?? '',
                        'name': file['filename'] ?? 'Unknown File',
                        'description': file['caption'] ?? '',
                        'size': 0, // Size might not be available
                      };
                    }).toList();

                // Add files to work detail
                if (workDetails[closestIndex]['files'] == null) {
                  workDetails[closestIndex]['files'] = [];
                }
                workDetails[closestIndex]['files'].addAll(formattedFiles);
              }
            }
          }
        }
      }
    }

    // Sort work details by date (newest first)
    workDetails.sort((a, b) {
      final dateA =
          a['date'] != null
              ? DateTime.parse(a['date'].toString())
              : DateTime(1900);
      final dateB =
          b['date'] != null
              ? DateTime.parse(b['date'].toString())
              : DateTime(1900);
      return dateB.compareTo(dateA); // Newest first
    });

    // Use GetX to determine if we're on mobile view
    bool isMobileView = Get.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: closeTaskDetail,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      projectName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: getStatusColor(status).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  capitalizeStatus(status),
                  style: TextStyle(
                    fontSize: 14,
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Task details and history - Responsive layout
        Expanded(
          child:
              isMobileView
                  // Mobile layout (vertical)
                  ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task info card
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: _buildTaskInfoCard(
                            status,
                            description,
                            startDate,
                            endDate,
                            createdAt,
                            updatedAt,
                            assignedTo,
                          ),
                        ),

                        // Work Details Card
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: _buildWorkDetailsCard(),
                        ),
                      ],
                    ),
                  )
                  // Desktop layout (horizontal)
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left panel - Task details
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Task info card
                              _buildTaskInfoCard(
                                status,
                                description,
                                startDate,
                                endDate,
                                createdAt,
                                updatedAt,
                                assignedTo,
                              ),
                              SizedBox(height: 16),
                              // Work Details Card
                              _buildWorkDetailsCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  // Extract the Task Info Card to a separate method
  Widget _buildTaskInfoCard(
    String status,
    String description,
    String startDate,
    String endDate,
    String createdAt,
    String updatedAt,
    List<dynamic> assignedTo,
  ) {
    return Card(
      color: Color(0xff333333),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Main content
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[900]!, Colors.grey[800]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with task info title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Task Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 80), // Space for status container
                  ],
                ),

                SizedBox(height: 16),

                // Description
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[300],
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // User information
                if (assignedTo.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _buildUserColumn(
                          'ASSIGNED TO',
                          assignedTo.isNotEmpty
                              ? assignedTo.first.toString()
                              : 'Unassigned',
                          Icons.assignment_ind,
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildUserColumn(
                          'CREATED BY',
                          'System', // You can replace with actual createdBy if available
                          Icons.person_add,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),

                if (assignedTo.isNotEmpty) SizedBox(height: 16),

                // Date information
                Row(
                  children: [
                    Expanded(
                      child: _buildDateColumn(
                        'START DATE',
                        startDate,
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDateColumn(
                        'DUE DATE',
                        endDate,
                        Icons.event,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Timestamps
                Row(
                  children: [
                    Expanded(
                      child: _buildDateColumn(
                        'CREATED AT',
                        createdAt,
                        Icons.access_time,
                        Colors.cyan,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDateColumn(
                        'LAST UPDATED',
                        updatedAt,
                        Icons.update,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status container spanning full height on the right side
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: getStatusColor(status),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    capitalizeStatus(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserColumn(
    String label,
    String username,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            username,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(
    String label,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Extract the date field to a separate method
  Widget _buildDateField(String label, IconData icon, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.black87),
              SizedBox(width: 8),
              Text(date, style: TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  // Extract the timestamp field to a separate method
  Widget _buildTimestampField(String label, String timestamp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(timestamp, style: TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }
  Widget _buildWorkDetailsCard() {
    // Inject the DownloadService using GetX
    final DownloadService downloadService = Get.put(DownloadService());

    // Use Obx to reactively rebuild when filterWorkDetails.value changes
    return Obx(() {
      // Use filterWorkDetails.value directly throughout the widget
      return Card(
        color: Color(0xff333333),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Work Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${filterWorkDetails.value.length} ${filterWorkDetails.value.length == 1 ? 'Entry' : 'Entries'}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              if (filterWorkDetails.value.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 48.sp,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No work details available',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filterWorkDetails.value.length,
                  separatorBuilder: (context, index) => Divider(height: 24.h),
                  itemBuilder: (context, index) {
                    // Make sure to use .value consistently
                    final item = filterWorkDetails.value[index];

                    // Get description from the appropriate location in the structure
                    final description =
                        item['details']?['description'] ??
                        item['description'] ??
                        'No description';

                    // Get caption from details
                    final caption = item['details']?['caption'] ?? '';

                    final date = formatDateTime(
                      item['timestamp'] ?? item['date'],
                    );

                    // Get hours spent - ensure it's parsed as a numeric value
                    final hoursSpentRaw =
                        item['details']?['hours_spent'] ??
                        item['hours_spent'] ??
                        0;
                    // Convert to numeric safely
                    final hoursSpent =
                        hoursSpentRaw is String
                            ? double.tryParse(hoursSpentRaw) ?? 0
                            : (hoursSpentRaw is num ? hoursSpentRaw : 0);

                    // Get user information and extract username
                    final addedBy = item['performed_by'] ?? item['added_by'];
                    String addedByName = '';

                    // Handle different ways the username might be stored
                    if (addedBy is Map<String, dynamic>) {
                      addedByName = addedBy['username'] ?? 'Unknown User';
                    } else if (addedBy is String) {
                      addedByName = addedBy;
                    } else {
                      addedByName = 'Unknown User';
                    }

                    // Extract files from the API format - CORRECTED APPROACH
                    List<Map<String, dynamic>> files = [];

                    // Check if files exist in the details structure (correct according to API response)
                    if (item['details']?['files'] != null && item['details']['files'] is List) {
                      files = (item['details']['files'] as List).map<Map<String, dynamic>>((file) {
                        if (file is Map<String, dynamic>) {
                          return {
                            'id': file['file_id'] ?? '', // Use file_id from API response
                            'filename': file['filename'] ?? 'Unknown File',
                            'url': file['url'] ?? '', // Store the URL for downloading
                            'type': file['type'] ?? '',
                          };
                        } else {
                          return {
                            'id': '',
                            'filename': 'Unknown File',
                            'url': '',
                            'type': '',
                          };
                        }
                      }).toList();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CollaboratorAvatar(name: addedByName, size: 32.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addedByName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hoursSpent > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: Colors.blue[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$hoursSpent hrs',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        if (description.isNotEmpty || caption.isNotEmpty || files.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: Colors.grey[600]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show description
                                if (description.isNotEmpty) ...[
                                  Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                
                                // Show caption if present
                                if (caption.isNotEmpty) ...[
                                  if (description.isNotEmpty) SizedBox(height: 8.h),
                                  Text(
                                    'Caption:',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    caption,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                
                                // Show files if present
                                if (files.isNotEmpty) ...[
                                  if (description.isNotEmpty || caption.isNotEmpty)
                                    SizedBox(height: 12.h),
                                  Text(
                                    'Attached Files (${files.length})',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  ...files.map((file) => _buildWorkDetailFileItem(file)).toList(),
                                ],
                              ],
                            ),
                          ),
                        SizedBox(height: 8.h),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      );
    });
  }

  // Updated file item builder to handle the new structure
  Widget _buildWorkDetailFileItem(Map<String, dynamic> file) {
    // Inject the DownloadService using GetX inside the method
    final DownloadService downloadService = Get.find<DownloadService>();
    final String filename = file['filename'] ?? 'Unknown File';
    final String fileType = file['type'] ?? '';
    final String fileUrl = file['url'] ?? '';
    
    // Get appropriate icon based on file type
    IconData getFileIcon(String type) {
      switch (type.toLowerCase()) {
        case 'image':
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
          return Icons.image;
        case 'pdf':
          return Icons.picture_as_pdf;
        case 'doc':
        case 'docx':
          return Icons.description;
        case 'video':
        case 'mp4':
        case 'avi':
          return Icons.video_file;
        default:
          return Icons.attach_file;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Row(
        children: [
          Icon(
            getFileIcon(fileType),
            size: 20.sp,
            color: Colors.white70,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (fileType.isNotEmpty)
                  Text(
                    fileType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (file['id'].isNotEmpty) {
                // Use the file_id for download, not the URL
                await downloadService.downloadFile(file['id'], fileName: filename);
              }
            },
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                Icons.download,
                size: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  }

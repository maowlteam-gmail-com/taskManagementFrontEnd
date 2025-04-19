import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maowl/screens/adminScreen/widgets/collaboratorAvatar.dart';

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
        '${dotenv.env['BASE_URL']}/api/tasks/history/$taskId',
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
          taskHistory.value =
              historyList.map((e) => e as Map<String, dynamic>).toList();
        } else {
          taskHistory.value = [];
          historyError.value = "No history available for this task";
        }
      } else {
        historyError.value =
            "Failed to load task history: ${response.statusCode}";
      }
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

  // Add this method to show a confirmation dialog
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
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => widget.onBack(),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.employee['username']}\'s Tasks',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Obx(
                      () => Text(
                        '${tasks.length} ${tasks.length == 1 ? 'Task' : 'Tasks'} Assigned',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: fetchTasks,
                icon: Icon(Icons.refresh),
                label: Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
        Expanded(
          
          child: Obx(() {
            if (isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.black, size: 48),
                    SizedBox(height: 16),
                    Text(
                      errorMessage.value,
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: fetchTasks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
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
                    Icon(Icons.task_outlined, size: 48),
                    SizedBox(height: 16),
                    Text('No tasks assigned to this employee'),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(16.sp),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 16.sp,
                  mainAxisSpacing: 16.sp,
                ),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final projectName = task['project_name'] ?? 'Unknown Project';
                  final taskName = task['task_name'] ?? 'Unnamed Task';
                  final startDate = formatDate(task['start_date']);
                  final endDate = formatDate(task['end_date']);
                  final updatedAt = formatDate(task['updatedAt']);
                  final status = task['status'] ?? 'unknown';

                  // Get latest work detail
                  final workDetails = task['work_details'] as List<dynamic>?;
                  final latestWorkDetail = getLatestWorkDetail(workDetails);
                  final hasWorkDetails = latestWorkDetail != null;

                  // Modify the task card in the GridView.builder's itemBuilder
return InkWell(
  onTap: () => viewTaskDetail(task),
  borderRadius: BorderRadius.circular(8.sp),
  child: Card(
    color: Color(0xff333333),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.sp),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Stack(
      children: [
        // Status vertical line on the right side
     Positioned(
  top: 0,
  bottom: 0,
  right: 50,
  width: 150.w, // Thickness of the status line
  child: Container(
    decoration: BoxDecoration(
      color: getStatusColor(status),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(8.sp),
        bottomRight: Radius.circular(8.sp),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 6.sp,
            vertical: 3.sp,
          ),
          decoration: BoxDecoration(
            color: getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(3.sp),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Text(
            capitalizeStatus(status),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
),

        // Main content with padding to accommodate the status line
        Padding(
          padding: EdgeInsets.fromLTRB(12.sp, 12.sp, 20.sp, 12.sp), // Extra padding on right
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      projectName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Container(
                    // padding: EdgeInsets.symmetric(
                    //   horizontal: 8.sp,
                    //   vertical: 4.sp,
                    // ),
                    // decoration: BoxDecoration(
                    //   color: getStatusColor(status).withOpacity(0.1),
                    //   borderRadius: BorderRadius.circular(4.sp),
                    //   border: Border.all(
                    //     color: getStatusColor(status),
                    //     width: 1,
                    //   ),
                  //   ),
                  //   child: Text(
                  //     capitalizeStatus(status),
                  //     style: TextStyle(
                  //       fontSize: 10.sp,
                  //       color: getStatusColor(status),
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () {
                      showDeleteConfirmation(
                        task['_id'],
                        taskName,
                      );
                    },
                    borderRadius: BorderRadius.circular(4.sp),
                    child: Padding(
                      padding: EdgeInsets.all(4.sp),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                taskName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),

              // Latest Work Detail Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4.sp),
                    border: Border.all(color: Colors.grey[300]!),
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
                              Text(
                                '${latestWorkDetail['hours_spent']} hrs',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                '${latestWorkDetail['description']}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Caption: ${latestWorkDetail['caption'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                formatDateTime(
                                  latestWorkDetail['date'],
                                ),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          'No work updates yet',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                ),
              ),

              SizedBox(height: 8.h),
              _buildInfoRow(
                Icons.calendar_today,
                'Start: $startDate',
              ),
              SizedBox(height: 4.h),
              _buildInfoRow(Icons.event, 'Due: $endDate'),
              SizedBox(height: 4.h),
              _buildInfoRow(Icons.update, 'Updated: $updatedAt'),
            ],
          ),
        ),
      ],
    ),
  ),
);
                },
              ),
            );
          }),
        ),
      ],
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
    // final workDetails = task['work_details'] as List<dynamic>? ?? [];

    final List<dynamic> workDetailsRaw =
        task['work_details'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> workDetails =
        List<Map<String, dynamic>>.from(workDetailsRaw);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: closeTaskDetail,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      projectName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.sp,
                  vertical: 6.sp,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.sp),
                  border: Border.all(color: getStatusColor(status), width: 1),
                ),
                child: Text(
                  capitalizeStatus(status),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),

        // Task details and history
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel - Task details
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task info card
                      Card(
                        color: Color(0xff333333),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Stack(
                          children: [
                        Positioned(
  top: 0,
  bottom: 0,
  right: 50,
  width: 150.w, // Thickness of the status line
  child: Container(
    decoration: BoxDecoration(
      color: getStatusColor(status),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(8.sp),
        bottomRight: Radius.circular(8.sp),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 6.sp,
            vertical: 3.sp,
          ),
          decoration: BoxDecoration(
            color: getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(3.sp),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Text(
            capitalizeStatus(status),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
),
                            Padding(
                              padding: EdgeInsets.all(16.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Task Information',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                            
                                  // Description
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.all(12.sp),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4.sp),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                            
                                  // Dates
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Start Date',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Container(
                                              padding: EdgeInsets.all(8.sp),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(
                                                  4.sp,
                                                ),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 16.sp,
                                                    color: Colors.black87,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    startDate,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Due Date',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Container(
                                              padding: EdgeInsets.all(8.sp),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(
                                                  4.sp,
                                                ),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.event,
                                                    size: 16.sp,
                                                    color: Colors.black87,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    endDate,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                            
                                  // Timestamps
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Created At',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              createdAt,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Last Updated',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              updatedAt,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Work Details Card
                      Card(
                        color: Color(0xff333333),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Work Details',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                  Text(
                                    '${workDetails.length} ${workDetails.length == 1 ? 'Entry' : 'Entries'}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),

                              if (workDetails.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 24.h,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.work_outline,
                                          size: 48,
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
                                  itemCount: workDetails.length,
                                  separatorBuilder:
                                      (context, index) => Divider(height: 24.h),
                                  itemBuilder: (context, index) {
                                    final workDetail =
                                        workDetails[index];
                                    final description =
                                        workDetail['description'] ??
                                        'No description';
                                    // final caption =
                                    //     workDetail['caption'] ?? 'N/A';
                                    final date = formatDateTime(
                                      workDetail['date'],
                                    );
                                    final hoursSpent =
                                        workDetail['hours_spent'] ?? 0;
                                    final addedBy = workDetail['added_by'];
                                    String addedByName = getUsername(addedBy);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CollaboratorAvatar(
                                              name: addedByName,
                                              size: 32,
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    addedByName,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.white
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
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.sp,
                                                vertical: 4.sp,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(4.sp),
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
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12.sp),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              4.sp,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Text(
                                            description,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        // Text(
                                        //   'Caption: $caption',
                                        //   style: TextStyle(
                                        //     fontSize: 12.sp,
                                        //     fontStyle: FontStyle.italic,
                                        //     color: Colors.grey[600],
                                        //   ),
                                        // ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

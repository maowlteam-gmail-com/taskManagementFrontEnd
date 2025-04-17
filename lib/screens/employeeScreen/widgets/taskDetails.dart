import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/screens/employeeScreen/widgets/employeeProjects.dart';
import 'package:maowl/screens/employeeScreen/widgets/taskHistory.dart';
import 'package:maowl/screens/employeeScreen/widgets/taskUpdateScreen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Map<String, dynamic> _task;
  final Dio _dio = Dio();
  final box = GetStorage();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _task = Map<String, dynamic>.from(widget.task); // Create a copy to avoid reference issues
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

  String capitalizeStatus(String status) {
    return status.split('_').map((word) =>
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
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

  Future<void> refreshTaskData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication token not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: Duration(seconds: 3),
        );
        return;
      }

      final taskId = _task['_id'] ?? _task['id'];

      if (taskId == null) {
        Get.snackbar(
          'Error',
          'Task ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: Duration(seconds: 3),
        );
        return;
      }

      final response = await _dio.get(
        'http://localhost:5001/api/tasks/$taskId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null && responseData['data'] != null &&  responseData['data'] is Map<String, dynamic>) {
          setState(() {
           // _task = responseData['data'];
            _task = Map<String, dynamic>.from(responseData['data'] as Map);
          });

          Get.snackbar(
            'Success',
            'Task data refreshed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Error',
            'Invalid response format',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[800],
            duration: Duration(seconds: 3),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch task: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Error refreshing task: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _navigateToUpdateScreen() async {
  if (!mounted) return;

  try {
    // Use toNamed consistently with preventDuplicates
    final result = await Get.toNamed(
      '/taskUpdate',
      arguments: _task,
     
    );

    if (!mounted) return;

    if (result != null) {
      if (result is Map<String, dynamic>) {
        setState(() {
          _task = result;
        });
        Get.snackbar(
          'Success',
          'Task updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else if (result == true) {
        await refreshTaskData();
      }
    }
  } catch (e) {
    if (mounted) {
      Get.snackbar(
        'Error',
        'Error updating task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: Duration(seconds: 3),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    try {
      final projectName = _task['project_name'] ?? 'Unknown Project';
      final taskName = _task['task_name'] ?? 'Unnamed Task';
      final description = _task['description'] ?? 'No description available';
      final startDate = formatDate(_task['start_date']);
      final endDate = formatDate(_task['end_date']);
      final status = _task['status'] ?? 'unknown';
      final createdAt = formatDate(_task['createdAt']);
      final updatedAt = formatDate(_task['updatedAt']);

      String createdBy = 'Unknown';
      if (_task['created_by'] is Map) {
        final createdByMap = _task['created_by'] as Map;
        if (createdByMap.containsKey('username')) {
          createdBy = createdByMap['username']?.toString() ?? 'Unknown';
        }
      }

      String assignedTo = 'Unknown';
      if (_task['assigned_to'] is Map) {
        final assignedToMap = _task['assigned_to'] as Map;
        if (assignedToMap.containsKey('username')) {
          assignedTo = assignedToMap['username']?.toString() ?? 'Unknown';
        }
      }

      final List<dynamic> workDetails = _task['work_details'] is List
          ? List.from((_task['work_details'] as List).reversed)
          : [];

      return Scaffold(
        key: const Key('task_details_scaffold'),
        appBar: AppBar(
          title: const Text('Task Details'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.update),
              tooltip: 'Update Today\'s Progress',
              onPressed: _navigateToUpdateScreen,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Task Data',
              onPressed: refreshTaskData,
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // (UI building remains the same)
                        // [Omitted for brevity: unchanged UI code in your original script]
                        // Work History Section
                        Padding(
                          padding: EdgeInsets.all(20.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Work History',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              if (workDetails.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 30.h),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.history_outlined,
                                          size: 48.sp,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'No work history available',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: workDetails.length,
                                  itemBuilder: (context, index) {
                                    if (index >= workDetails.length) return Container();
                                    try {
                                      final workDetail = workDetails[index] as Map<String, dynamic>;
                                      return TaskHistoryItemWidget(
                                        key: ValueKey("work_detail_$index"),
                                        workDetail: workDetail,
                                        isLast: index == workDetails.length - 1,
                                      );
                                    } catch (e) {
                                      return Container();
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToUpdateScreen,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          tooltip: 'Update Today\'s Progress',
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading task details: ${e.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.to(() => EmployeeProjects()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
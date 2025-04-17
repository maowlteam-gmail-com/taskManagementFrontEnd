import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maowl/screens/employeeScreen/widgets/taskDetails.dart';

class EmployeeProjects extends StatefulWidget {
  const EmployeeProjects({Key? key}) : super(key: key);

  @override
  State<EmployeeProjects> createState() => _EmployeeProjectsState();
}

class _EmployeeProjectsState extends State<EmployeeProjects> {
  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Dio _dio = Dio();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    print("Starting fetchTasks method");
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = box.read('token');

      print(
        "Token: ${token != null ? (token.length > 10 ? token.substring(0, 10) + '...' : token) : 'null'}",
      );

      if (token == null) {
        print("Authentication failure: token is null");
        errorMessage.value = 'Authentication token not found';
        isLoading.value = false;
        return;
      }

      print("Making API request to: http://localhost:5001/api/tasks/myTasks");

      final response = await _dio.get(
        'http://localhost:5001/api/tasks/myTasks',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          // Add timeout to prevent infinite waiting
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      print("API Response status code: ${response.statusCode}");
      print("API Response body type: ${response.data.runtimeType}");
      if (response.data != null) {
        print(
          "API Response first few keys: ${response.data is Map ? (response.data as Map).keys.take(5).toList() : 'Not a Map'}",
        );
      }

      if (response.statusCode == 200) {
        try {
          final responseBody = response.data as Map<String, dynamic>;
          print("Response parsed as Map<String, dynamic>");

          if (responseBody.containsKey('data')) {
            print("Response contains 'data' key");
            if (responseBody['data'] is List) {
              print(
                "Data is a List with ${(responseBody['data'] as List).length} items",
              );
              final dataList = responseBody['data'] as List;
              tasks.value =
                  dataList.map((e) => e as Map<String, dynamic>).toList();
              print("Tasks list updated with ${tasks.length} items");
            } else {
              print(
                "'data' is not a List: ${responseBody['data'].runtimeType}",
              );
              errorMessage.value =
                  "Unexpected response format: 'data' is not a list";
            }
          } else {
            print(
              "Response doesn't contain 'data' key. Keys: ${responseBody.keys.toList()}",
            );
            errorMessage.value =
                "Unexpected response format: missing 'data' array";
          }
        } catch (e) {
          print("Error parsing response: $e");
          errorMessage.value = "Error parsing response: $e";
        }
      } else {
        print("Failed response: ${response.statusCode}");
        errorMessage.value = "Failed to load tasks: ${response.statusCode}";
      }
    } catch (e) {
      print("Exception in fetchTasks: $e");
      if (e is DioException) {
        print("DioException type: ${e.type}");
        print("DioException message: ${e.message}");
        print("DioException response: ${e.response?.data}");

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage.value =
              "Connection timeout. Please check your internet connection.";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage.value =
              "Connection error. Is the server running at http://localhost:5001?";
        } else {
          errorMessage.value = "Error fetching tasks: ${e.message}";
        }
      } else {
        errorMessage.value = "Error fetching tasks: $e";
      }
    } finally {
      print("Setting isLoading to false");
      isLoading.value = false;
      print("Current tasks: ${tasks.length}");
      print("Current error message: ${errorMessage.value}");
    }
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

  Map<String, dynamic>? getLatestWorkDetail(List<dynamic>? workDetails) {
    if (workDetails == null || workDetails.isEmpty) {
      return null;
    }

    try {
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
    } catch (e) {
      // Handle any casting or parsing errors
      return null;
    }
  }

  String getLatestDescription(Map<String, dynamic> task) {
    final workDetails = task['work_details'] as List?;
    if (workDetails == null || workDetails.isEmpty) {
      return task['description'] ?? 'No description available';
    }

    final latestWorkDetail = getLatestWorkDetail(workDetails);
    return latestWorkDetail?['description'] ??
        task['description'] ??
        'No description available';
  }

  void _openTaskDetail(Map<String, dynamic> task) {
    Get.toNamed('/taskDetails',arguments: task);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TaskDetailScreen(task: task),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    print("Building EmployeeProjects widget");
    return Container(color: Colors.white, child: _buildTasksGridView());
  }

  Widget _buildTasksGridView() {
    print("Building _buildTasksGridView");
    print("isLoading value: ${isLoading.value}");
    print("errorMessage value: ${errorMessage.value}");
    print("tasks length: ${tasks.length}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            children: [
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Tasks',
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
                onPressed: () {
                  print("Refresh button pressed");
                  fetchTasks();
                },
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
            print("Building Obx section in Expanded");
            print("isLoading: ${isLoading.value}");
            print("errorMessage: ${errorMessage.value}");
            print("tasks.isEmpty: ${tasks.isEmpty}");

            if (isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading tasks..."),
                  ],
                ),
              );
            } else if (errorMessage.value.isNotEmpty) {
              return _buildErrorView();
            } else if (tasks.isEmpty) {
              return _buildEmptyView();
            } else {
              return _buildTasksGrid();
            }
          }),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
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
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: fetchTasks,
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_outlined, size: 48),
          SizedBox(height: 16),
          Text('No tasks assigned to you'),
        ],
      ),
    );
  }

Widget _buildTasksGrid() {
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
        if (index >= tasks.length) return Container();
        
        final task = tasks[index];
        if (task == null) return Container();
        
        final projectName = task['project_name'] ?? 'Unknown Project';
        final taskName = task['task_name'] ?? 'Unnamed Task';
        final startDate = formatDate(task['start_date']);
        final endDate = formatDate(task['end_date']);
        final updatedAt = formatDate(task['updatedAt']);
        final status = task['status'] ?? 'unknown';
        
        // Get the latest work detail to display
        final latestWorkDetail = getLatestWorkDetail(task['work_details']);
        final latestWorkDescription = latestWorkDetail?['description'] ?? 
                                    task['description'] ?? 
                                    'No description available';
        
        return Card(
          color: Color(0xff333333),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: InkWell(
            onTap: () => _openTaskDetail(task),
            child: Stack(
              children: [
                // Top status bar
                Positioned(
                  top: 0,
                  right: 50,
                  height: 70.h, // Top portion height
                  width: 150.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: getStatusColor(status),
                      borderRadius: BorderRadius.only(
                       // topRight: Radius.circular(8.sp),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          SizedBox(height: 4.h,),
                          Container(
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
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom status bar (now contains only the Last Update)
                Positioned(
                  bottom: 0,
                  right: 50,
                  height: 70.h, // Bottom portion height
                  width: 150.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: getStatusColor(status),
                      borderRadius: BorderRadius.only(
                      //  bottomRight: Radius.circular(8.sp),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            
                              SizedBox(height: 4.h),
                              Text(
                                updatedAt,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Main card content
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              projectName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        taskName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                      SizedBox(height: 4.h),
                      Expanded(
                        child: Text(
                          latestWorkDescription,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Divider(),
                      // Timeline remains in original position
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timeline',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$startDate - $endDate',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white
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
        );
      },
    ),
  );
}
}

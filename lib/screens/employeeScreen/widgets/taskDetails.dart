import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/screens/adminScreen/controller/downloadService.dart';
import 'package:maowl/screens/employeeScreen/controller/employeeProjectController.dart';
import 'package:maowl/screens/employeeScreen/widgets/employeeProjects.dart';

class TaskDetailScreen extends StatefulWidget {
  final employeeProjectController = Get.find<EmployeeProjectsController>();
  final Map<String, dynamic> task;

  TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Map<String, dynamic> _task;
  final Dio _dio = Dio();
  final box = GetStorage();
  bool isLoading = false;

  // Add DownloadService
  late final DownloadService _downloadService;

  @override
  void initState() {
    super.initState();
    _task = Map<String, dynamic>.from(
      widget.task,
    ); // Create a copy to avoid reference issues

    // Initialize DownloadService
    _downloadService = Get.put(DownloadService());
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      print('Parsed date: $date'); // Debugging line
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
      case 'warning':
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
        '${dotenv.env['BASE_URL']}/api/tasks/$taskId',
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

        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data'] is Map<String, dynamic>) {
          setState(() {
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
      final result = await Get.toNamed('/taskUpdate', arguments: _task);

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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Updated method to build attachment widgets with download functionality
  Widget _buildAttachmentsSection(List<dynamic>? attachments) {
    if (attachments == null || attachments.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Text(
          'Attachments (${attachments.length}):',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Column(
          children: attachments
              .map((attachment) => _buildAttachmentItem(attachment))
              .toList(),
        ),
      ],
    );
  }

  // Updated attachment item with proper download functionality
 // Updated attachment item with proper download functionality
Widget _buildAttachmentItem(dynamic attachment) {
  if (attachment is! Map<String, dynamic>) return SizedBox.shrink();

  final fileName = attachment['filename'] ?? 
                  attachment['fileName'] ?? 
                  attachment['originalName'] ?? 
                  'Unknown File';
  
  // Fix: Use 'file_id' which matches your API response structure
  final fileId = attachment['file_id'] ?? 
                 attachment['_id'] ?? 
                 attachment['id'] ?? 
                 attachment['fileId'] ?? 
                 '';
  
  final fileType = attachment['type'] ?? 
                   attachment['fileType'] ?? 
                   attachment['mimetype'] ?? 
                   '';

  // Debug print to see what we're getting
  print('Attachment data: $attachment');
  print('Extracted fileId: $fileId');
  print('Extracted fileName: $fileName');
  print('Extracted fileType: $fileType');

  // Choose icon based on file type
  IconData fileIcon;
  Color iconColor;
  
  String typeCheck = fileType.toLowerCase();
  if (typeCheck.contains('image')) {
    fileIcon = Icons.image;
    iconColor = Colors.blue[400]!;
  } else if (typeCheck.contains('pdf')) {
    fileIcon = Icons.picture_as_pdf;
    iconColor = Colors.red[400]!;
  } else if (typeCheck.contains('doc')) {
    fileIcon = Icons.description;
    iconColor = Colors.blue[700]!;
  } else if (typeCheck.contains('xls') || typeCheck.contains('excel')) {
    fileIcon = Icons.table_chart;
    iconColor = Colors.green[600]!;
  } else if (typeCheck.contains('video')) {
    fileIcon = Icons.video_file;
    iconColor = Colors.purple[400]!;
  } else if (typeCheck.contains('audio')) {
    fileIcon = Icons.audio_file;
    iconColor = Colors.orange[400]!;
  } else {
    fileIcon = Icons.insert_drive_file;
    iconColor = Colors.grey[400]!;
  }

  return Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: InkWell(
      onTap: () async {
        if (fileId.isNotEmpty) {
          print('Attempting to download file with ID: $fileId');
          // Download file using the DownloadService
          await _downloadService.downloadFile(fileId, fileName: fileName);
        } else {
          print('File ID is empty. Attachment structure: $attachment');
          Get.snackbar(
            'Error',
            'File ID not available for download',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[800],
            duration: Duration(seconds: 2),
          );
        }
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              fileIcon,
              size: 24.sp,
              color: iconColor,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileType.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      fileType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.download,
                size: 18.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

      final List<dynamic> workDetails =
          _task['work_details'] is List
              ? List.from((_task['work_details'] as List).reversed)
              : [];

      return Scaffold(
        key: const Key('task_details_scaffold'),
        appBar: AppBar(
          title: const Text('Task Details'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 100.w),
              width: 150.w,
              decoration: BoxDecoration(
                color: getStatusColor(status),
                borderRadius: BorderRadius.circular(2.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
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
                        // Task Information Section
                        Container(
                          margin: EdgeInsets.all(20.sp),
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Task Information',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              _buildInfoRow('Task:', taskName),
                              _buildInfoRow('Description:', description),
                              _buildInfoRow('Start Date:', startDate),
                              _buildInfoRow('End Date:', endDate),
                              _buildInfoRow('Created By:', createdBy),
                              _buildInfoRow('Assigned To:', assignedTo),
                              _buildInfoRow('Updated:', updatedAt),
                            ],
                          ),
                        ),

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
                                    padding: EdgeInsets.symmetric(
                                      vertical: 30.h,
                                    ),
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
                                    if (index >= workDetails.length) {
                                      return Container();
                                    }
                                    try {
                                      final workDetail = workDetails[index]
                                          as Map<String, dynamic>;

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 16.h),
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Date and time
                                            if (workDetail['date'] != null)
                                              Text(
                                                formatDate(
                                                  workDetail['date'].toString(),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            SizedBox(height: 8.h),

                                            // Description
                                            if (workDetail['description'] !=
                                                    null &&
                                                workDetail['description']
                                                    .toString()
                                                    .isNotEmpty)
                                              Text(
                                                workDetail['description']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.black87,
                                                ),
                                              ),

                                            // Attachments with download functionality
                                            _buildAttachmentsSection(
                                              workDetail['attachments'] ??
                                                  workDetail['files'],
                                            ),
                                          ],
                                        ),
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
          tooltip: 'Update Today\'s Progress',
          child: const Icon(Icons.add),
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
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/adminScreen/controller/taskHistoryController.dart';
import 'package:maowl/screens/adminScreen/model/taskHistoryResponse.dart';
import 'package:maowl/screens/adminScreen/controller/downloadService.dart';

class TaskHistoryWidget extends StatelessWidget {
  const TaskHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskHistoryController historyController = Get.find<TaskHistoryController>();
     
    return Column(
      children: [
        // Header with back button and task name
        Container(
          padding: EdgeInsets.all(16.w),
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
                onPressed: () => historyController.backToTasks(),
              ),
              SizedBox(width: 8.w),
             Expanded(
  child: Obx(() => Text(
    historyController.selectedTaskName.value.isEmpty 
        ? 'Task History' 
        : '${historyController.selectedTaskName.value} - Task History',
    style: TextStyle(
      color: Colors.white,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none, // Add this line
    ),
  )),
),
            ],
          ),
        ),
        
        // Task history content
        Expanded(
          child: _buildTaskHistoryView(historyController),
        ),
      ],
    );
  }

  Widget _buildTaskHistoryView(TaskHistoryController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.grey,
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.refreshTaskHistory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.taskHistory.value == null) {
        return const Center(
          child: Text(
            'No task history found',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        );
      }

      final taskHistoryData = controller.taskHistory.value!;

      return RefreshIndicator(
        onRefresh: () => controller.refreshTaskHistory(),
        color: Colors.grey[900],
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Task Info Card
              _buildTaskInfoCard(taskHistoryData.task, controller),
              SizedBox(height: 16.h),
              
              // Work Details Card - Updated version
              _buildWorkDetailsCard(taskHistoryData.history, controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTaskInfoCard(TaskDetails task, TaskHistoryController controller) {
    return Card(
      color: Color(0xff333333),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Main content
          Container(
            padding: EdgeInsets.all(16.w),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with task name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.taskName,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 80.w), // Space for status container
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // User information
                Row(
                  children: [
                    Expanded(
                      child: _buildUserColumn(
                        'CREATED BY',
                        task.createdBy,
                        Icons.person_add,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildUserColumn(
                        'ASSIGNED TO',
                        task.assignedTo,
                        Icons.assignment_ind,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // Date information
                Row(
                  children: [
                    Expanded(
                      child: _buildDateColumn(
                        'START DATE',
                        controller.formatDateTime(task.startDate),
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDateColumn(
                        'DUE DATE',
                        controller.formatDateTime(task.endDate),
                        Icons.event,
                        Colors.purple,
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
              width: 60.w,
              decoration: BoxDecoration(
                color: controller.getStatusColor(task.status),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    controller.capitalizeStatus(task.status),
                    style: TextStyle(
                      fontSize: 11.sp,
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

  Widget _buildUserColumn(String label, String username, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
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
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            username,
            style: TextStyle(
              fontSize: 12.sp,
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

  Widget _buildDateColumn(String label, String date, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
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
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            date,
            style: TextStyle(
              fontSize: 12.sp,
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

  // Updated _buildWorkDetailsCard method
  Widget _buildWorkDetailsCard(List<HistoryItem> history, TaskHistoryController controller) {
    // Inject the DownloadService using GetX
    final DownloadService downloadService = Get.put(DownloadService());

    return Card(
      color: Color(0xff333333),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Work History',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${history.length} ${history.length == 1 ? 'Entry' : 'Entries'}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 48.sp,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No work history available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
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
                itemCount: history.length,
                separatorBuilder: (context, index) => Divider(
                  height: 24.h,
                  color: Colors.grey[600],
                ),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryItem(item, controller, downloadService);
                },
              ),
          ],
        ),
      ),
    );
  }
Widget _buildHistoryItem(HistoryItem item, TaskHistoryController controller, DownloadService downloadService) {
  final hoursSpent = double.tryParse(item.details?.hoursSpent ?? '0') ?? 0;
  
  // Check if there's any meaningful content to display
  final hasDescription = item.details?.description != null && item.details!.description.trim().isNotEmpty;
  final hasFiles = item.details?.files != null && item.details!.files!.isNotEmpty;
  final hasComment = item.comment.trim().isNotEmpty;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 16.sp,
            backgroundColor: Colors.blue[400],
            child: Text(
              item.performedBy.username.isNotEmpty 
                  ? item.performedBy.username[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.performedBy.username,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  controller.formatDateTime(item.timestamp),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
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
      
      // Work details - always show container if there's any content
      if (hasDescription || hasFiles || hasComment)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description section
              if (hasDescription) ...[
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
                  item.details!.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
              
              // Files section
              if (hasFiles) ...[
                if (hasDescription) SizedBox(height: 12.h),
                Text(
                  'Attached Files (${item.details!.files!.length})',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8.h),
                ...item.details!.files!.map((file) => _buildFileItem(file, downloadService)),
              ],
              
              // Comment section (if you want to show comments separately)
              if (hasComment) ...[
                if (hasDescription || hasFiles) SizedBox(height: 12.h),
                Text(
                  'Comment:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.comment,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      
      // Show a minimal entry if only hours are logged without description/files/comments
      if (!hasDescription && !hasFiles && !hasComment && hoursSpent > 0)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Text(
            'Time logged without additional details',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ],
  );
}

  Widget _buildFileItem(FileItem file, DownloadService downloadService) {
    // Choose icon based on file type
    IconData fileIcon;
    Color iconColor;
    
    switch (file.type.toLowerCase()) {
      case 'image':
        fileIcon = Icons.image;
        iconColor = Colors.blue[400]!;
        break;
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        iconColor = Colors.red[400]!;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description;
        iconColor = Colors.blue[700]!;
        break;
      case 'xls':
      case 'xlsx':
        fileIcon = Icons.table_chart;
        iconColor = Colors.green[600]!;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
        iconColor = Colors.grey[400]!;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () async {
          // Download file using the file_id
          await downloadService.downloadFile(file.fileId, fileName: file.filename);
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[500]!),
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
                      file.filename,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      file.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
}
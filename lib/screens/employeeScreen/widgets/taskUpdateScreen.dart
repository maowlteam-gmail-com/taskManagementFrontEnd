import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maowl/screens/employeeScreen/controller/taskUpdateController.dart';
import 'package:path/path.dart' as path;


class TaskUpdateScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskUpdateScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskUpdateController());
    controller.initializeTask(task);

    final taskName = task['task_name'] ?? 'Unnamed Task';
    final today = DateFormat('MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Task Progress'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskHeader(taskName, today, controller),
                SizedBox(height: 24.h),
                _buildWorkDetailsSection(controller),
                SizedBox(height: 16.h),
                _buildHoursSection(controller),
                SizedBox(height: 24.h),
                _buildFilePicker(controller),
                SizedBox(height: 20.h),
                _buildCollaboratorsSection(controller),
                SizedBox(height: 24.h),
                _buildActionButtons(controller),
                SizedBox(height: 20.h),
                _buildErrorDisplay(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(String taskName, String today, TaskUpdateController controller) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: const Color(0xff333333),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Today: $today',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Warning report button
              ElevatedButton.icon(
                onPressed: controller.reportWarning,
                icon: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Report Warning',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkDetailsSection(TaskUpdateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Progress Details',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.descriptionController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Describe what you worked on today...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHoursSection(TaskUpdateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hours Spent',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.hoursController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter hours worked',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.access_time),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(TaskUpdateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Upload your File',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Obx(() => InkWell(
          onTap: controller.pickFile,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 60.h,
              maxHeight: 80.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.isFileValid.value ? Colors.grey.shade300 : Colors.red,
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: controller.getFileName() != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _getFileTypeIcon(controller.getFileName() ?? ''),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          controller.getTruncatedFileName(controller.getFileName() ?? ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      InkWell(
                        onTap: controller.clearFile,
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 44.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 20.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Click to upload File',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        )),
        Obx(() => !controller.isFileValid.value && controller.fileErrorMessage.value.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(top: 4.h, left: 5.w),
                child: Text(
                  controller.fileErrorMessage.value,
                  style: TextStyle(color: Colors.red, fontSize: 12.sp),
                ),
              )
            : const SizedBox()),
      ],
    );
  }

  Widget _buildCollaboratorsSection(TaskUpdateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Collaborators',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.showAddCollaboratorDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() => controller.selectedCollaborators.isEmpty
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Text(
                  'No collaborators added yet',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: controller.selectedCollaborators.map((collaborator) {
                  return Chip(
                    label: Text(
                      collaborator['username'] ?? 'Unknown',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    deleteIcon: Icon(Icons.close, size: 16.sp),
                    onDeleted: () => controller.removeCollaborator(collaborator),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              )),
      ],
    );
  }

  Widget _buildActionButtons(TaskUpdateController controller) {
    return Column(
      children: [
        // Submit Work Details Button
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.submitWorkDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.sp),
              ),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Submit Work Details',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
          )),
        ),
        
        SizedBox(height: 16.h),
        
        // Complete Task Button
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.completeTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.sp),
              ),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline),
                      SizedBox(width: 8.w),
                      Text(
                        'Mark as Complete',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          )),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay(TaskUpdateController controller) {
    return Obx(() => controller.errorMessage.value.isNotEmpty
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8.sp),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[700],
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox());
  }

  Widget _getFileTypeIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    IconData iconData;
    Color iconColor;

    switch (extension) {
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      size: 24.sp,
      color: iconColor,
    );
  }
}
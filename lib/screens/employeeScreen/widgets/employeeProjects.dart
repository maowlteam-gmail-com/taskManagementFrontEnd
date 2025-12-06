import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/colors/app_colors.dart';
import 'package:maowl/screens/employeeScreen/controller/employeeProjectController.dart';

class EmployeeProjects extends StatelessWidget {
  final EmployeeProjectsController controller = Get.put(
    EmployeeProjectsController(),
  );

  EmployeeProjects({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: _buildTasksGridView());
  }

  Widget _buildTasksGridView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildHeader(), _buildContent()],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[850]!, Colors.grey[900]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            _buildHeaderIcon(),
            SizedBox(width: 12.w),
            Expanded(child: _buildHeaderText()),
            _buildRefreshButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(Icons.assignment, color: Colors.white, size: 24.sp),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(
          () => Text(
            _getTaskCountText(),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // String _getTaskCountText() {
  //   final count = controller.tasks.length;
  //   if (count == 0) return 'No tasks assigned';
  //   if (count == 1) return '1 Task Assigned';
  //   return '$count Tasks Assigned';
  // }
  String _getTaskCountText() {
    final count =
        controller.filteredTasks.length; // Change from tasks to filteredTasks
    final tabName =
        controller.selectedTabIndex.value == 0 ? 'Created' : 'Assigned';

    if (count == 0) return 'No $tabName tasks';
    if (count == 1) return '1 $tabName Task';
    return '$count $tabName Tasks';
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.fetchTasks(),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 18.sp, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildContent() {
  //   return Expanded(
  //     child: Container(
  //       color: Colors.grey[50],
  //       child: Obx(() => _buildContentBasedOnState()),
  //     ),
  //   );
  // }
  Widget _buildContent() {
    return Expanded(
      child: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            _buildTabBar(), // Add this
            Expanded(child: Obx(() => _buildContentBasedOnState())),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildTabItem(
                'Created',
                0,
                Icons.create_outlined,
                controller.selectedTabIndex.value == 0,
              ),
            ),
            Expanded(
              child: _buildTabItem(
                'Assigned',
                1,
                Icons.assignment_outlined,
                controller.selectedTabIndex.value == 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    String title,
    int index,
    IconData icon,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.switchTab(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [Colors.grey[800]!, Colors.grey[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildContentBasedOnState() {
  //   if (controller.isLoading.value) {
  //     return _buildLoadingState();
  //   }

  //   if (controller.errorMessage.value.isNotEmpty) {
  //     return _buildErrorState();
  //   }

  //   if (controller.tasks.isEmpty) {
  //     return _buildEmptyState();
  //   }

  //   return _buildTaskGrid();
  // }
  Widget _buildContentBasedOnState() {
    if (controller.isLoading.value) {
      return _buildLoadingState();
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return _buildErrorState();
    }

    if (controller.filteredTasks.isEmpty) {
      // Change from tasks to filteredTasks
      return _buildEmptyState();
    }

    return _buildTaskGrid();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.grey[800], strokeWidth: 3),
          SizedBox(height: 16.h),
          Text(
            'Loading your tasks...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red[600],
                size: 48.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: controller.fetchTasks,
              icon: Icon(Icons.refresh_rounded),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 64.sp,
              color: Colors.blue[300],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No tasks assigned to you at the moment',
            style: TextStyle(color: Colors.grey[500], fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  // Widget _buildTaskGrid() {
  //   return RefreshIndicator(
  //     onRefresh: () async => controller.fetchTasks(),
  //     color: Colors.grey[800],
  //     backgroundColor: Colors.white,
  //     child: Padding(
  //       padding: EdgeInsets.all(16.w),
  //       child: LayoutBuilder(
  //         builder: (context, constraints) {
  //           return _buildResponsiveGrid(constraints);
  //         },
  //       ),
  //     ),
  //   );
  // }
  Widget _buildTaskGrid() {
    return RefreshIndicator(
      onRefresh: () async => controller.fetchTasks(),
      color: Colors.grey[800],
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveGrid(constraints);
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 600;
    final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

    int crossAxisCount = 1;
    double childAspectRatio = 0.65; // Made taller to accommodate attachments

    if (isMobile) {
      crossAxisCount = 1;
      childAspectRatio = 0.65; // Taller cards for mobile
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 0.75; // Taller cards for tablet
    } else {
      crossAxisCount = 3;
      childAspectRatio = 0.8; // Taller cards for desktop
    }

    // return GridView.builder(
    //   physics: const AlwaysScrollableScrollPhysics(),
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: crossAxisCount,
    //     childAspectRatio: childAspectRatio,
    //     crossAxisSpacing: 16.w,
    //     mainAxisSpacing: 16.h,
    //   ),
    //   itemCount: controller.tasks.length,
    //   itemBuilder: (context, index) => _buildTaskCard(index, isMobile),
    // );
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount:
          controller.filteredTasks.length, // Change from tasks to filteredTasks
      itemBuilder: (context, index) => _buildTaskCard(index, isMobile),
    );
  }

  Widget _buildTaskCard(int index, bool isMobile) {
    if (index >= controller.tasks.length) return const SizedBox.shrink();

    // final task = controller.tasks[index];
    final task = controller.filteredTasks[index];
    return _TaskCard(task: task, controller: controller, isMobile: isMobile);
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final EmployeeProjectsController controller;
  final bool isMobile;

  const _TaskCard({
    required this.task,
    required this.controller,
    required this.isMobile,
  });
  Widget _buildEmptyState() {
    final String endateJson;
    final tabName =
        controller.selectedTabIndex.value == 0
            ? 'created by you'
            : 'assigned to you';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ... existing container and icon ...
          Text(
            'No tasks found!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No tasks $tabName at the moment',
            style: TextStyle(color: Colors.grey[500], fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskInfo = _extractTaskInfo();

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _onTaskTap(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[900]!, Colors.grey[800]!],
            ),
          ),
          child: Stack(
            children: [
              _buildMainContent(taskInfo),
              _buildStatusBadge(taskInfo.status),
            ],
          ),
        ),
      ),
    );
  }

  _TaskInfo _extractTaskInfo() {
    final workDetails = task['work_details'] as List<dynamic>?;
    final latestWorkDetail = controller.getLatestWorkDetail(workDetails);

    return _TaskInfo(
      projectName: task['project_id']?['project_name'] ?? 'Unknown Project',
      taskName: task['task_name'] ?? 'Unnamed Task',
      startDate: controller.formatDate(task['start_date']),
      endDate: controller.formatDate(task['end_date']),
      updatedAt: controller.formatDate(task['updatedAt']),
      status: task['status'] ?? 'unknown',
      assignedTo: task['assigned_to']?['username'] ?? 'Unassigned',
      createdBy: task['created_by']?['username'] ?? 'Unknown',
      latestWorkDetail: latestWorkDetail,
      attachments: _extractAttachments(latestWorkDetail),
    );
  }

  List<Map<String, dynamic>> _extractAttachments(
    Map<String, dynamic>? workDetail,
  ) {
    if (workDetail == null) return [];

    final files = workDetail['files'] as List<dynamic>?;
    if (files == null || files.isEmpty) return [];

    return files.map((file) => file as Map<String, dynamic>).toList();
  }

  void _onTaskTap() {
    controller.selectedTask.value = task;
    controller.openTaskDetail(task);
  }

  Widget _buildMainContent(_TaskInfo taskInfo) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 80.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectHeader(taskInfo),
          SizedBox(height: 12.h),
          _buildTaskName(taskInfo),
          SizedBox(height: 12.h),
          _buildUserInfo(taskInfo),
          SizedBox(height: 12.h),
          _buildWorkDetailsSection(taskInfo),
          SizedBox(height: 12.h),
          if (taskInfo.attachments.isNotEmpty) ...[
            _buildAttachmentsSection(taskInfo),
            SizedBox(height: 12.h),
          ],
          _buildDateSection(taskInfo),
          SizedBox(height: 8.h),
          _buildUpdateInfo(taskInfo),
        ],
      ),
    );
  }

  Widget _buildProjectHeader(_TaskInfo taskInfo) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.folder_outlined, color: Colors.white, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            taskInfo.projectName,
            style: TextStyle(
              fontSize: isMobile ? 16.sp : 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskName(_TaskInfo taskInfo) {
    return Text(
      taskInfo.taskName,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[300],
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUserInfo(_TaskInfo taskInfo) {
    return Row(
      children: [
        Expanded(
          child: _buildUserChip(
            'Assigned to',
            taskInfo.assignedTo,
            Icons.person_outline,
            Colors.blue,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildUserChip(
            'Created by',
            taskInfo.createdBy,
            Icons.person_add_outlined,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildUserChip(
    String label,
    String username,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
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
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            username,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkDetailsSection(_TaskInfo taskInfo) {
    return Container(
      height: 120.h, // Fixed height for work details
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          taskInfo.latestWorkDetail != null
              ? _buildWorkDetailContent(taskInfo)
              : _buildNoWorkDetailContent(),
    );
  }

  Widget _buildWorkDetailContent(_TaskInfo taskInfo) {
    final workDetail = taskInfo.latestWorkDetail!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latest Update',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            if (workDetail['hours_spent'] != null)
              _buildHoursBadge(workDetail, taskInfo),
          ],
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              workDetail['description'] ?? 'No description available',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        _buildWorkDetailFooter(taskInfo, workDetail),
      ],
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////
  bool isFirstDateBeforeOrSame(String date1, String date2) {
    // Convert string to DateTime
    DateTime d1 = DateTime.parse(date1);
    DateTime d2 = DateTime.parse(date2);

    // Check if d1 is before or equal to d2
    return d1.isBefore(d2) || d1.isAtSameMomentAs(d2);
  }

  Color getDateStatusColor(String date1, String date2) {
    try {
      DateTime d1 = DateTime.parse(date1).toLocal();
      DateTime d2 = DateTime.parse(date2).toLocal();

      // Difference in days (d2 - d1)
      int diff = d2.difference(d1).inDays;

      if (diff >= 0 && diff <= 2) {
        // d1 is same day or within 2 days before d2
        return AppColors.dueColor;
      } else if (diff > 2) {
        // d1 is further in the past than 2 days before d2
        return AppColors.inProgressColor;
      } else {
        // diff < 0 → d1 is after d2
        return AppColors.delayedColor;
      }
    } catch (e) {
      print("Error comparing dates: $e");
      return AppColors.inProgressColor; // fallback
    }
  }

  Color getDateStatusColorLight(String date1, String date2) {
    try {
      DateTime d1 = DateTime.parse(date1).toLocal();
      DateTime d2 = DateTime.parse(date2).toLocal();

      // Difference in days (d2 - d1)
      int diff = d2.difference(d1).inDays;

      if (diff >= 0 && diff <= 2) {
        // d1 is same day or within 2 days before d2
        return const Color.fromARGB(255, 255, 244, 203);
      } else if (diff > 2) {
        // d1 is further in the past than 2 days before d2
        return const Color.fromARGB(255, 225, 231, 255);
      } else {
        // diff < 0 → d1 is after d2
        return const Color.fromARGB(255, 255, 211, 211);
      }
    } catch (e) {
      print("Error comparing dates: $e");
      return const Color.fromARGB(255, 225, 231, 255); // fallback
    }
  }

  List<Color> getDateStatusColorGradient(String date1, String date2) {
    try {
      DateTime d1 = DateTime.parse(date1).toLocal();
      DateTime d2 = DateTime.parse(date2).toLocal();

      // Difference in days (d2 - d1)
      int diff = d2.difference(d1).inDays;

      if (diff >= 0 && diff <= 2) {
        // d1 is same day or within 2 days before d2
        return [const Color.fromARGB(255, 181, 142, 0), AppColors.dueColor];
      } else if (diff > 2) {
        // d1 is further in the past than 2 days before d2
        return [
          const Color.fromARGB(255, 12, 24, 79),
          AppColors.inProgressColor,
        ];
      } else {
        // diff < 0 → d1 is after d2
        return [const Color.fromARGB(255, 91, 3, 3), AppColors.delayedColor];
      }
    } catch (e) {
      print("Error comparing dates: $e");
      return [
        const Color.fromARGB(255, 12, 24, 79),
        AppColors.inProgressColor,
      ]; // fallback
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  Widget _buildHoursBadge(Map<String, dynamic> workDetail, _TaskInfo taskInfo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: getDateStatusColorGradient(
            workDetail['date'],
            task['end_date'],
          ),
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: getDateStatusColor(workDetail['date'], task['end_date']),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '${workDetail['hours_spent']} hrs',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWorkDetailFooter(
    _TaskInfo taskInfo,
    Map<String, dynamic> workDetail,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'By: ${workDetail['added_by']?['username'] ?? taskInfo.createdBy}',
            style: TextStyle(
              fontSize: 9.sp,
              fontStyle: FontStyle.italic,
              color: Colors.grey[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          controller.formatDate(workDetail['date']),
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoWorkDetailContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pending_actions_outlined,
            size: 28.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            'No work updates yet',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Start working to add updates',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(_TaskInfo taskInfo) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                size: 14.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 6.w),
              Text(
                'Attachments:',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...taskInfo.attachments.map(
            (attachment) => _buildAttachmentItem(attachment),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> attachment) {
    final filename = attachment['filename'] ?? 'Unknown file';
    final fileType = attachment['type'] ?? 'unknown';

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          _buildFileTypeIcon(fileType),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              filename,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeIcon(String fileType) {
    IconData iconData;
    Color iconColor;

    switch (fileType.toLowerCase()) {
      case 'image':
        iconData = Icons.image_outlined;
        iconColor = Colors.green[600]!;
        break;
      case 'pdf':
        iconData = Icons.picture_as_pdf_outlined;
        iconColor = Colors.red[600]!;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description_outlined;
        iconColor = Colors.blue[600]!;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart_outlined;
        iconColor = Colors.green[700]!;
        break;
      default:
        iconData = Icons.insert_drive_file_outlined;
        iconColor = Colors.grey[600]!;
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(iconData, size: 12.sp, color: iconColor),
    );
  }

  Widget _buildDateSection(_TaskInfo taskInfo) {
    return Row(
      children: [
        Expanded(
          child: _buildDateColumn(
            'START',
            taskInfo.startDate,
            Icons.play_arrow_rounded,
            Colors.green,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildDateColumn(
            'DUE',
            taskInfo.endDate,
            Icons.flag_rounded,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDateColumn(
    String label,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
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
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            date,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateInfo(_TaskInfo taskInfo) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.update_rounded, size: 12.sp, color: Colors.grey[400]),
          SizedBox(width: 6.w),
          Text(
            'Updated: ${taskInfo.updatedAt}',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      child: Container(
        width: 60.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              controller.getStatusColor(status),
              controller.getStatusColor(status).withOpacity(0.8),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: controller.getStatusColor(status).withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: Center(
            child: Text(
              controller.capitalizeStatus(status).toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskInfo {
  final String projectName;
  final String taskName;
  final String startDate;
  final String endDate;
  final String updatedAt;
  final String status;
  final String assignedTo;
  final String createdBy;
  final Map<String, dynamic>? latestWorkDetail;
  final List<Map<String, dynamic>> attachments;

  _TaskInfo({
    required this.projectName,
    required this.taskName,
    required this.startDate,
    required this.endDate,
    required this.updatedAt,
    required this.status,
    required this.assignedTo,
    required this.createdBy,
    this.latestWorkDetail,
    required this.attachments,
  });
}

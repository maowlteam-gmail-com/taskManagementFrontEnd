import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/colors/app_colors.dart';
import 'package:maowl/screens/adminScreen/controller/projectController.dart';
import 'package:maowl/screens/adminScreen/controller/projectTaskController.dart';
import 'package:maowl/screens/adminScreen/controller/taskHistoryController.dart';
import 'package:maowl/screens/adminScreen/model/taskModel.dart';
import 'package:maowl/screens/adminScreen/widgets/taskHistoryWidget.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectTaskController taskController =
        Get.find<ProjectTaskController>();
    final Projectcontroller projectController = Get.find<Projectcontroller>();

    return Column(
      children: [
        // Header with back button and project name (Fixed at top)
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
                onPressed: () => taskController.backToProjects(),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => Text(
                    taskController.selectedProjectName.value.isEmpty
                        ? 'Project Tasks'
                        : '${taskController.selectedProjectName.value} - Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Project Information Section
                Obx(() {
                  final projectId = taskController.selectedProjectId.value;
                  final project = projectController.getProjectById(projectId);

                  if (project != null) {
                    return Container(
                      margin: EdgeInsets.all(16.w),
                      child: Card(
                        color: Color(0xff333333),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left section (content)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Project Information',
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 80.w),
                                          ],
                                        ),

                                        SizedBox(height: 16.h),

                                        // Description container (auto width)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[600]!,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'DESCRIPTION',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue[300],
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                              SizedBox(height: 8.h),
                                              SelectableText(
                                                project.description.isNotEmpty
                                                    ? project.description
                                                    : 'No description available',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.white,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Space to prevent overlap with status bar
                                  SizedBox(width: 60.w),
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
                                  color: _getStatusColor(project.status),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Center(
                                    child: Text(
                                      project.status.toUpperCase().replaceAll(
                                        '_',
                                        ' ',
                                      ),
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
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),

                // Task grid view section
                _buildTaskGridView(taskController),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGridView(ProjectTaskController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          height: 300.h, // Give it a minimum height
          child: const Center(
            child: CircularProgressIndicator(color: Colors.grey),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Container(
          height: 300.h, // Give it a minimum height
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.refreshTasks(),
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

      if (controller.tasks.isEmpty) {
        return Container(
          height: 300.h, // Give it a minimum height
          child: const Center(
            child: Text(
              'No tasks found for this project',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;

            // Calculate the height needed for the grid
            int crossAxisCount = isMobile ? 1 : 2;
            double childAspectRatio = isMobile ? 2.2 : 2.5;
            int rowCount = (controller.tasks.length / crossAxisCount).ceil();
            double gridHeight =
                (rowCount *
                    (constraints.maxWidth /
                        crossAxisCount /
                        childAspectRatio)) +
                ((rowCount - 1) * 12.h); // Adding spacing

            return Container(
              height: gridHeight,
              child: GridView.builder(
                physics:
                    NeverScrollableScrollPhysics(), // Disable internal scrolling
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: controller.tasks.length,
                itemBuilder: (context, index) {
                  final task = controller.tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () => _navigateToTaskHistory(task, controller),
                  );
                },
              ),
            );
          },
        ),
      );
    });
  }

  void _navigateToTaskHistory(
    TaskModel task,
    ProjectTaskController projectController,
  ) {
    try {
      // Clean up existing TaskHistoryController if it exists
      if (Get.isRegistered<TaskHistoryController>()) {
        Get.delete<TaskHistoryController>();
      }

      // Create new TaskHistoryController
      final TaskHistoryController historyController = Get.put(
        TaskHistoryController(),
      );

      // Set the task information with project context
      historyController.selectTask(
        task.id,
        task.taskName,
        projectId: projectController.selectedProjectId.value,
        projectName: projectController.selectedProjectName.value,
      );

      // Navigate to task history (using Get.to instead of Get.offNamed to maintain navigation stack)
      Get.toNamed('/taskHistory');
    } catch (e) {
      print('Error navigating to task history: $e');
      Get.snackbar(
        'Error',
        'Failed to open task history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pendingColor;
      case 'due':
        return AppColors.dueColor;
      case 'in progress':
        return AppColors.inProgressColor;
      case 'completed':
        return AppColors.completedColor;
      case 'delayed':
        return AppColors.delayedColor;
      case 'warning':
        return AppColors.warningColor;
      default:
        return AppColors.inProgressColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'in_progress':
      case 'in progress':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }
}

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(task.status);

    return Card(
      elevation: 8,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Main content
            Container(
              padding: const EdgeInsets.all(16),
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
                  // Header with task name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.taskName,
                          style: TextStyle(
                            fontSize: 18.sp,
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
                          task.createdBy.username,
                          Icons.person_add,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildUserColumn(
                          'ASSIGNED TO',
                          task.assignedTo.username,
                          Icons.assignment_ind,
                          Colors.green,
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
                  color: statusColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Center(
                    child: Text(
                      task.status.toUpperCase().replaceAll('_', ' '),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pendingColor;
      case 'due':
        return AppColors.dueColor;
      case 'in progress':
        return AppColors.inProgressColor;
      case 'completed':
        return AppColors.completedColor;
      case 'delayed':
        return AppColors.delayedColor;
      case 'warning':
        return AppColors.warningColor;
      default:
        return AppColors.inProgressColor;
    }
  }
}

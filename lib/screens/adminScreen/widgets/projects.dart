import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/colors/app_colors.dart';
import 'package:maowl/screens/adminScreen/controller/projectController.dart';
import 'package:maowl/screens/adminScreen/controller/projectTaskController.dart';
import 'package:maowl/screens/adminScreen/model/projectModel.dart';
import 'package:maowl/screens/adminScreen/widgets/projectTaskScreen.dart';

class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize all controllers
    final ProjectTaskController taskController = Get.put(ProjectTaskController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Show tasks widget if a project is selected
        if (taskController.showTasks.value) {
          return const TaskWidget();
        }
        // Otherwise show projects grid
        return _buildProjectGridView();
      }),
    );
  }

  Widget _buildProjectGridView() {
    final Projectcontroller controller = Get.put(Projectcontroller());
    final ProjectTaskController taskController = Get.find<ProjectTaskController>();

    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
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
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => controller.refreshProjects(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.projects.isEmpty) {
              return const Center(
                child: Text(
                  'No projects found',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.refreshProjects(),
              color: Colors.white,
              backgroundColor: Colors.grey[800],
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        childAspectRatio: isMobile ? 2.5 : 2.8,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: controller.projects.length,
                      itemBuilder: (context, index) {
                        final project = controller.projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () => {
                            // Select project and show tasks
                            taskController.selectProject(
                              project.id,
                              project.projectName,
                            )
                          },
                          onDelete: () => controller.showDeleteConfirmationDialog(
                            project.id,
                            project.projectName,
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
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(project.status);
    final Projectcontroller controller = Get.find<Projectcontroller>();

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
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with project name and delete icon
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.projectName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            // maxLines: 2,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Delete icon button
                        Obx(() => IconButton(
                          onPressed: controller.isDeleting.value ? null : onDelete,
                          icon: controller.isDeleting.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                ),
                              )
                            : Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 24.sp,
                              ),
                          tooltip: 'Delete Project',
                          constraints: BoxConstraints(
                            minWidth: 30.w,
                            minHeight: 30.h,
                          ),
                          padding: EdgeInsets.all(4.w),
                          splashRadius: 20.r,
                        )),
                        SizedBox(width: 80.w), // Space for status container
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Description
                  // Text(
                  //   project.description,
                  //   style: TextStyle(
                  //     fontSize: 14.sp,
                  //     color: Colors.grey[300],
                  //     height: 1.3,
                  //   ),
                  //   maxLines: 3,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  
                  // SizedBox(height: 16.h),
                  
                  // Date information
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateColumn(
                          'START DATE',
                          project.formattedStartDate,
                          Icons.play_arrow,
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildDateColumn(
                          'END DATE',
                          project.formattedEndDate,
                          Icons.stop,
                          Colors.red,
                        ),
                      ),
                      SizedBox(width: 60.w),
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
                      project.status.toUpperCase(),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
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
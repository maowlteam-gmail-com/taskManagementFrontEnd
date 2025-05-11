import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/screens/employeeScreen/controller/employeeProjectController.dart';

class EmployeeProjects extends StatelessWidget {
  final EmployeeProjectsController controller = Get.put(
    EmployeeProjectsController(),
  );

  EmployeeProjects({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building EmployeeProjects widget");
    return Container(color: Colors.white, child: _buildTasksGridView());
  }

  Widget _buildTasksGridView() {
    print("Building _buildTasksGridView");
    print("isLoading value: ${controller.isLoading.value}");
    print("errorMessage value: ${controller.errorMessage.value}");
    print("tasks length: ${controller.tasks.length}");

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
                        '${controller.tasks.length} ${controller.tasks.length == 1 ? 'Task' : 'Tasks'} Assigned',
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
                  controller.fetchTasks();
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
            print("isLoading: ${controller.isLoading.value}");
            print("errorMessage: ${controller.errorMessage.value}");
            print("tasks.isEmpty: ${controller.tasks.isEmpty}");

            if (controller.isLoading.value) {
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
            } else if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorView();
            } else if (controller.tasks.isEmpty) {
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
            controller.errorMessage.value,
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchTasks,
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
        itemCount: controller.tasks.length,
        itemBuilder: (context, index) {
          if (index >= controller.tasks.length) return Container();

          final task = controller.tasks[index];

          final projectName = task['project_name'] ?? 'Unknown Project';
          final taskName = task['task_name'] ?? 'Unnamed Task';
          final startDate = controller.formatDate(task['start_date']);
          final endDate = controller.formatDate(task['end_date']);
          final updatedAt = controller.formatDate(task['updatedAt']);
          final status = task['status'] ?? 'unknown';

          // Get the latest work detail to display
          final latestWorkDetail = controller.getLatestWorkDetail(
            task['work_details'],
          );
          final latestWorkDescription =
              latestWorkDetail?['description'] ??
              task['description'] ??
              'No description available';

          return Card(
            color: Color(0xff333333),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: InkWell(
              onTap: () {
                controller.selectedTask.value = task;
                controller.openTaskDetail(task);
              },
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
                        color: controller.getStatusColor(status),
                        borderRadius: BorderRadius.only(
                          // topRight: Radius.circular(8.sp),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.sp,
                                vertical: 3.sp,
                              ),
                              decoration: BoxDecoration(
                                color: controller
                                    .getStatusColor(status)
                                    .withOpacity(0.1),
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
                                controller.capitalizeStatus(status),
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
                        color: controller.getStatusColor(status),
                        borderRadius: BorderRadius.only(
                          //  bottomRight: Radius.circular(8.sp),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 8.sp,
                        ),
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
                                    color: Colors.white,
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
                            color: Colors.white,
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
                                color: Colors.white,
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

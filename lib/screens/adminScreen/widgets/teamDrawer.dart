import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/adminScreen/controller/adminScreenController.dart';

class TeamDrawer extends StatelessWidget {
  const TeamDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminScreenController controller = Get.find<AdminScreenController>();
    
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 30.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  'Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  onPressed: () => controller.fetchEmployees(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => controller.fetchEmployees(),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (controller.employees.isEmpty) {
                return Center(
                  child: Text(
                    'No team members found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.employees.length,
                itemBuilder: (context, index) {
                  final employee = controller.employees[index];
                  return EmployeeListItem(employee: employee);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class EmployeeListItem extends StatelessWidget {
  final Map<String, dynamic> employee;
  
  const EmployeeListItem({
    super.key,
    required this.employee,
  });
  
  @override
  Widget build(BuildContext context) {
    final AdminScreenController controller = Get.find<AdminScreenController>();
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee name
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            child: Text(
              employee['name'] ?? 'Unknown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Password section
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Row(
              children: [
                Text(
                  'Password',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  employee['password'] ?? '••••••••',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  onPressed: () => _showPasswordEditDialog(context, employee, controller),
                  constraints: BoxConstraints(
                    minWidth: 36.w,
                    minHeight: 36.h,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPasswordEditDialog(
    BuildContext context,
    Map<String, dynamic> employee,
    AdminScreenController controller,
  ) {
    final TextEditingController passwordController = TextEditingController(
      text: employee['password'] ?? '',
    );
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'For ${employee['name']}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: passwordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    child: Text(''),
                    onPressed: () async {
                      final newPassword = passwordController.text.trim();
                      if (newPassword.isEmpty) {
                        return;
                      }
                      
                      Get.back(); // Close dialog
                      
                      // Show loading indicator
                      Get.dialog(
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        barrierDismissible: false,
                      );
                      
                      // Update password
                      final success = await controller.updateEmployeePassword(
                        employee['_id'].toString(), // Using '_id' instead of 'id' as per your API structure
                        newPassword,
                      );
                      
                      Get.back(); // Close loading dialog
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
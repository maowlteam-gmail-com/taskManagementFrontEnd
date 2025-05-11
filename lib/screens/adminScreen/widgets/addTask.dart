import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maowl/screens/adminScreen/controller/taskController.dart';
import 'package:maowl/screens/siteScreen/widgets/customButtom.dart';


class CreateTaskContent extends StatelessWidget {
  CreateTaskContent({super.key});

  final TaskController controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    // Get current screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshEmployeeList();
      if (controller.employees.isEmpty) {
        controller.fetchEmployees();
      }
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Create Task',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 24.h),

          _buildLabeledField('Project Name', controller.projectNameController),
          SizedBox(height: 16.h),

          _buildLabeledField('Task Name', controller.taskNameController),
          SizedBox(height: 16.h),

          // Responsive layout for employee selector and date fields
          isMobile
              ? _buildMobileFormLayout()
              : _buildDesktopFormLayout(),
          
          SizedBox(height: 16.h),

          Text(
            'Details',
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 200.h,
            child: TextField(
              controller: controller.detailsController,
              maxLines: null,
              minLines: 8,
              cursorColor: Colors.black,
              decoration: _inputDecoration(),
            ),
          ),
          SizedBox(height: 30.h),

          Center(
            child: SizedBox(
              width: 300.w,
              child: Obx(() => controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Submit', 
                    onPressed: () => controller.submitTask(),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile layout with stacked form elements
  Widget _buildMobileFormLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEmployeeSelector(fullWidth: true),
        SizedBox(height: 16.h),
        _buildDateField('Start Date', true, fullWidth: true),
        SizedBox(height: 16.h),
        _buildDateField('End Date', false, fullWidth: true),
      ],
    );
  }

  // Desktop layout with side-by-side form elements
  Widget _buildDesktopFormLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildEmployeeSelector(),
        _buildDateField('Start Date', true),
        _buildDateField('End Date', false),
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 8.h),
        TextField(
          controller: textController,
          cursorColor: Colors.black,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  // Employee selector with optional fullWidth parameter
  Widget _buildEmployeeSelector({bool fullWidth = false}) {
    final width = fullWidth ? double.infinity : 196.w;
    
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assign To', style: TextStyle(fontSize: 20.sp)),
          SizedBox(height: 8.h),
          Obx(() {
            return InkWell(
              onTap: () => _showEmployeeDialog(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Row(
                  children: [                
                     controller.selectedEmployee.value?.isNotEmpty == true
                      ? CircleAvatar(
                          radius: 10.sp,
                          backgroundColor: Colors.black,
                          child: Text(
                            controller.selectedEmployee.value![0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        )
                      : Icon(Icons.person, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        controller.selectedEmployee.value?.isNotEmpty == true
                            ? controller.selectedEmployee.value!
                            : 'Select Employee',
                        style: TextStyle(fontSize: 16.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, size: 24.sp),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showEmployeeDialog() {
    if (controller.employees.isEmpty) {
      controller.fetchEmployees();
      Get.snackbar('Notice', 'Loading employees...');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Select Employee'),
        content: SizedBox(
          width: 300.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.employees.map((employee) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      employee.isNotEmpty ? employee[0].toUpperCase() : '?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(employee),
                  onTap: () {
                    controller.selectEmployee(employee);
                    Get.back(); // Close dialog
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
    );
  }

  // Date field with optional fullWidth parameter
  Widget _buildDateField(String label, bool isStart, {bool fullWidth = false}) {
    final width = fullWidth ? double.infinity : 196.w;
    
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 20.sp)),
          SizedBox(height: 8.h),
          InkWell(
            onTap: () => _selectDate(isStart),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, size: 20.sp),
                  SizedBox(width: 8.w),
                  Obx(() {
                    String date = isStart
                        ? controller.startDate.value
                        : controller.endDate.value;
                    return Text(
                      date.isEmpty ? 'Select Date' : date,
                      style: TextStyle(fontSize: 16.sp),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted = DateFormat('yyyy-MM-dd').format(picked);
      if (isStart) {
        controller.startDate.value = formatted;
        controller.startDateController.text = formatted;
      } else {
        controller.endDate.value = formatted;
        controller.endDateController.text = formatted;
      }
    }
  }

  InputDecoration _inputDecoration({IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null
          ? Icon(icon, size: 24.sp, color: Colors.black)
          : null,
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

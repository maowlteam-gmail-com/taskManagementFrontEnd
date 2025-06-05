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
      controller.refreshProjectList();
      if (controller.employees.isEmpty) {
        controller.fetchEmployees();
      }
      if (controller.projects.isEmpty) {
        controller.fetchProjects();
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

          // Project dropdown replaces project name text field
          _buildProjectSelector(),
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

  // Project selector dropdown
  Widget _buildProjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Name', style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 8.h),
        Obx(() {
          return InkWell(
            onTap: () => _showProjectDialog(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.work, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      controller.selectedProject.value?.isNotEmpty == true
                          ? controller.selectedProject.value!
                          : 'Select Project',
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
    );
  }

  void _showProjectDialog() {
    if (controller.projects.isEmpty) {
      controller.fetchProjects();
      Get.snackbar('Notice', 'Loading projects...');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Select Project'),
        content: SizedBox(
          width: 300.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.projectNames.map((projectName) {
                return ListTile(
                  leading: Icon(
                    Icons.work,
                    color: Colors.black,
                  ),
                  title: Text(projectName),
                  onTap: () {
                    controller.selectProject(projectName);
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
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
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

  // Enhanced date field with manual override capability
  Widget _buildDateField(String label, bool isStart, {bool fullWidth = false}) {
    final width = fullWidth ? double.infinity : 196.w;
    
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
              // Show indicator if date was manually overridden
              Obx(() {
                String currentDate = isStart ? controller.startDate.value : controller.endDate.value;
                bool isManuallySet = _isDateManuallyOverridden(isStart);
                
                // if (isManuallySet && currentDate.isNotEmpty) {
                //   return Container(
                //     padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                //     decoration: BoxDecoration(
                //       color: Colors.blue,
                //       borderRadius: BorderRadius.circular(10.r),
                //     ),
                //     child: Text(
                //       'Custom',
                //       style: TextStyle(
                //         fontSize: 10.sp,
                //         color: Colors.white,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   );
                // }
                return SizedBox.shrink();
              }),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            String currentDate = isStart ? controller.startDate.value : controller.endDate.value;
            bool hasDate = currentDate.isNotEmpty;
            bool isManuallySet = _isDateManuallyOverridden(isStart);
            
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: hasDate ? Colors.white : Colors.grey[100],
                border: Border.all(
                 // color: isManuallySet ? Colors.black : Colors.grey,
                  width: isManuallySet ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month, 
                    size: 20.sp, 
                    color: isManuallySet ? Colors.black : Colors.grey[600],
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      hasDate ? currentDate : 'Auto-filled from project',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: hasDate ? Colors.black87 : Colors.grey[600],
                        fontStyle: hasDate ? FontStyle.normal : FontStyle.italic,
                        fontWeight: isManuallySet ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  // Edit/Override button
                  InkWell(
                    onTap: () => _selectDate(isStart),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasDate && !isManuallySet ? Icons.edit : Icons.calendar_today,
                            size: 14.sp,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            hasDate && !isManuallySet ? 'Edit' : 'Set',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Enhanced date selection with manual override capability
  Future<void> _selectDate(bool isStart) async {
    // Determine initial date - use currently set date or today
    DateTime initialDate;
    if (isStart && controller.startDate.value.isNotEmpty) {
      initialDate = DateTime.parse(controller.startDate.value);
    } else if (!isStart && controller.endDate.value.isNotEmpty) {
      initialDate = DateTime.parse(controller.endDate.value);
    } else {
      initialDate = DateTime.now();
    }

    // Set constraints for date selection
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime(2100);
    
    // If selecting end date and start date is set, ensure end date is after start date
    if (!isStart && controller.startDate.value.isNotEmpty) {
      DateTime startDateTime = DateTime.parse(controller.startDate.value);
      firstDate = startDateTime.add(Duration(days: 1)); // End date must be after start date
    }

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStart ? 'Select Start Date' : 'Select End Date',
      confirmText: 'SET',
      cancelText: 'CANCEL',
    );

    if (picked != null) {
      String formatted = DateFormat('yyyy-MM-dd').format(picked);
      
      if (isStart) {
        controller.startDate.value = formatted;
        controller.startDateController.text = formatted;
        
        // If end date is before new start date, clear it
        if (controller.endDate.value.isNotEmpty) {
          DateTime currentEndDate = DateTime.parse(controller.endDate.value);
          if (currentEndDate.isBefore(picked) || currentEndDate.isAtSameMomentAs(picked)) {
            controller.endDate.value = '';
            controller.endDateController.text = '';
            Get.snackbar(
              'Notice', 
              'End date cleared as it was before or same as new start date',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 2),
            );
          }
        }
      } else {
        controller.endDate.value = formatted;
        controller.endDateController.text = formatted;
      }
      
      // Show confirmation of manual override
     
    }
  }

  // Helper method to check if date was manually overridden
  bool _isDateManuallyOverridden(bool isStart) {
    if (controller.selectedProject.value == null) return false;
    
    final selectedProjectData = controller.projects.firstWhere(
      (project) => project['project_name'] == controller.selectedProject.value,
      orElse: () => {},
    );
    
    if (selectedProjectData.isEmpty) return false;
    
    String projectDate = isStart 
        ? selectedProjectData['start_date'] ?? ''
        : selectedProjectData['end_date'] ?? '';
        
    if (projectDate.isEmpty) return true; // If no project date, any date is manual
    
    DateTime projectDateTime = DateTime.parse(projectDate);
    String formattedProjectDate = "${projectDateTime.year}-${projectDateTime.month.toString().padLeft(2, '0')}-${projectDateTime.day.toString().padLeft(2, '0')}";
    
    String currentDate = isStart ? controller.startDate.value : controller.endDate.value;
    
    return currentDate.isNotEmpty && currentDate != formattedProjectDate;
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
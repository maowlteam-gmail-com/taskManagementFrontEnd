import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maowl/screens/adminScreen/controller/creatProjectController.dart';
import 'package:maowl/screens/siteScreen/widgets/customButtom.dart';

class CreateProject extends StatelessWidget {
  CreateProject({super.key});

  final CreateProjectController controller = Get.put(CreateProjectController());

  @override
  Widget build(BuildContext context) {
    // Get current screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Create Project',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 24.h),

          _buildProjectNameField(),
          SizedBox(height: 16.h),

          // Responsive layout for date fields
          isMobile
              ? _buildMobileFormLayout()
              : _buildDesktopFormLayout(),
          
          SizedBox(height: 16.h),

          Text(
            'Description',
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 200.h,
            child: _buildDescriptionField(),
          ),
          SizedBox(height: 30.h),

          Center(
            child: SizedBox(
              width: 300.w,
              child: Obx(() => controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Submit', 
                    onPressed: () => controller.submitProject(),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to preserve cursor position
  void _preserveCursorPosition(String controllerKey, String newValue) {
    // This method should be called when text changes to preserve cursor position
    // You might need to implement this in your controller to track cursor positions
    // For now, we'll use a simpler approach with individual controllers
  }

  // Mobile layout with stacked form elements
  Widget _buildMobileFormLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildDateField('Start Date', true),
        SizedBox(width: 16.w),
        _buildDateField('End Date', false),
      ],
    );
  }

  Widget _buildProjectNameField() {
    // Create a dedicated TextEditingController for project name
    final TextEditingController projectNameController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Name', style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 8.h),
        Obx(() {
          // Only update controller text if it's different to avoid cursor jump
          if (projectNameController.text != controller.projectName.value) {
            final selection = projectNameController.selection;
            projectNameController.text = controller.projectName.value;
            // Preserve cursor position if selection is still valid
            if (selection.isValid && selection.start <= controller.projectName.value.length) {
              projectNameController.selection = selection;
            }
          }
          
          return TextField(
            controller: projectNameController,
            onChanged: (value) {
              controller.updateProjectName(value);
            },
            cursorColor: Colors.black,
            decoration: _inputDecoration(),
          );
        }),
      ],
    );
  }

  Widget _buildDescriptionField() {
    // Create a dedicated TextEditingController for description
    final TextEditingController descriptionController = TextEditingController();
    
    return Obx(() {
      // Only update controller text if it's different to avoid cursor jump
      if (descriptionController.text != controller.description.value) {
        final selection = descriptionController.selection;
        descriptionController.text = controller.description.value;
        // Preserve cursor position if selection is still valid
        if (selection.isValid && selection.start <= controller.description.value.length) {
          descriptionController.selection = selection;
        }
      }
      
      return TextField(
        controller: descriptionController,
        onChanged: (value) {
          controller.updateDescription(value);
        },
        maxLines: null,
        minLines: 8,
        cursorColor: Colors.black,
        decoration: _inputDecoration(),
      );
    });
  }

  Widget _buildLabeledField(String label, {required String initialValue, required Function(String) onChanged}) {
    // Create a dedicated TextEditingController for this field
    final TextEditingController fieldController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 8.h),
        StatefulBuilder(
          builder: (context, setState) {
            // Only update controller text if it's different to avoid cursor jump
            if (fieldController.text != initialValue) {
              final selection = fieldController.selection;
              fieldController.text = initialValue;
              // Preserve cursor position if selection is still valid
              if (selection.isValid && selection.start <= initialValue.length) {
                fieldController.selection = selection;
              }
            }
            
            return TextField(
              controller: fieldController,
              onChanged: (value) {
                onChanged(value);
                setState(() {}); // Trigger rebuild to update the field
              },
              cursorColor: Colors.black,
              decoration: _inputDecoration(),
            );
          },
        ),
      ],
    );
  }

  // Date field with optional fullWidth parameter
  Widget _buildDateField(String label, bool isStart, {bool fullWidth = false}) {
    final width = fullWidth ? double.infinity : 250.w;
    
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
        controller.updateStartDate(formatted);
      } else {
        controller.updateEndDate(formatted);
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
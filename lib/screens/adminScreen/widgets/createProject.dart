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
            child: Obx(() => TextField(
              onChanged: controller.updateDescription,
              maxLines: null,
              minLines: 8,
              cursorColor: Colors.black,
              decoration: _inputDecoration(),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: controller.description.value,
                  selection: TextSelection.collapsed(offset: controller.description.value.length),
                ),
              ),
            )),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Name', style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 8.h),
        Obx(() => TextField(
          onChanged: controller.updateProjectName,
          cursorColor: Colors.black,
          decoration: _inputDecoration(),
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: controller.projectName.value,
              selection: TextSelection.collapsed(offset: controller.projectName.value.length),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildLabeledField(String label, {required String initialValue, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 8.h),
        Obx(() => TextField(
          onChanged: onChanged,
          cursorColor: Colors.black,
          decoration: _inputDecoration(),
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: initialValue,
              selection: TextSelection.collapsed(offset: initialValue.length),
            ),
          ),
        )),
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
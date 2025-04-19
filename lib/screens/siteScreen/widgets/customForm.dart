import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/siteScreen/controllers/requirementController.dart';
import 'package:maowl/screens/siteScreen/widgets/customButtom.dart';

class CustomFormWidget extends StatelessWidget {
  CustomFormWidget({super.key});

  final RequirementController controller = Get.put(RequirementController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() => SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Center(
                child: Container(
                  width: constraints.maxWidth > 600 ? 0.35.sw : 0.9.sw,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          'Share Your Requirement',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      if (controller.isSuccess.value)
                        //_buildSuccessBox(),
                      if (controller.errorMessage.value.isNotEmpty)
                        _buildErrorBox(),
                      _buildTextField(
                        'Name',
                        onChanged: controller.setName,
                        value: controller.nameController.value,
                        isValid: controller.isNameValid.value,
                        errorText: 'Name is required',
                      ),
                      SizedBox(height: 15.h),
                      _buildTextField(
                        'Phone Number',
                        onChanged: controller.setPhone,
                        value: controller.phoneController.value,
                        isValid: controller.isPhoneValid.value,
                        errorText: 'Phone number is required',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 15.h),
                      _buildTextField(
                        'Email Id',
                        onChanged: controller.setEmail,
                        value: controller.emailController.value,
                        isValid: controller.isEmailValid.value,
                        errorText: 'Valid email is required',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15.h),
                      _buildTextField(
                        'Message',
                        maxLines: 4,
                        onChanged: controller.setMessage,
                        value: controller.messageController.value,
                        isValid: controller.isMessageValid.value,
                        errorText: 'Message is required',
                      ),
                      SizedBox(height: 20.h),
                      _buildFilePicker(),
                      SizedBox(height: 10.h),
                    //  _buildDebugInfo(),
                      SizedBox(height: 30.h),
                      Center(
                        child: controller.isLoading.value
                            ? CircularProgressIndicator()
                            : CustomButton(
                                text: 'Submit',
                                onPressed: _submitForm,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  // Widget _buildSuccessBox() {
  //   return Container(
  //     padding: EdgeInsets.all(10.w),
  //     margin: EdgeInsets.only(bottom: 15.h),
  //     decoration: BoxDecoration(
  //       color: Colors.green.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(5.r),
  //     ),
  //     child: Text(
  //       'Your requirement has been submitted successfully!',
  //       style: TextStyle(color: Colors.green, fontSize: 16.sp),
  //     ),
  //   );
  // }

  Widget _buildErrorBox() {
    return Container(
      padding: EdgeInsets.all(10.w),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error:',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            controller.errorMessage.value,
            style: TextStyle(color: Colors.red, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  // Add debug info in development only
  // Widget _buildDebugInfo() {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 8.h),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Debug Info:',
  //           style: TextStyle(
  //             fontSize: 12.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.grey,
  //           ),
  //         ),
  //         SizedBox(height: 4.h),
  //         Text(
  //           'Platform: ${kIsWeb ? "Web" : (Platform.isAndroid ? "Android" : "iOS")}',
  //           style: TextStyle(fontSize: 12.sp, color: Colors.grey),
  //         ),
  //         Text(
  //           'API Endpoint: ${kIsWeb ? "http://localhost:5001" : (Platform.isAndroid ? "http://10.0.2.2:5001" : "http://localhost:5001")}/requirement/create',
  //           style: TextStyle(fontSize: 12.sp, color: Colors.grey),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTextField(
    String label, {
    int maxLines = 1,
    required Function(String) onChanged,
    required String value,
    required bool isValid,
    required String errorText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 5.h),
        TextField(
          maxLines: maxLines,
          onChanged: onChanged,
          keyboardType: keyboardType,
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: isValid ? Colors.grey.shade300 : Colors.red),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: isValid ? Colors.grey.shade300 : Colors.red),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: isValid ? Colors.black : Colors.red),
            ),
            errorText: isValid ? null : errorText,
            errorStyle: TextStyle(fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Upload your File', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _pickPdfFile,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 60.h, maxHeight: 80.h),
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(
                  color: controller.isPdfValid.value ? Colors.grey.shade300 : Colors.red),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: controller.getPdfFileName() != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.file_present, size: 24.sp, color: Colors.blue),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getFileName(controller.getPdfFileName()!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    InkWell(
                      onTap: () => controller.clearPdfFile(),
                      child: Icon(Icons.close, size: 20.sp, color: Colors.grey.shade600),
                    )
                  ],
                )
              : SizedBox(
                  height: 44.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 20.sp, color: Colors.grey.shade600),
                      SizedBox(width: 8.w),
                      Text(
                        'Click to upload PDF',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
          ),
        ),
        if (!controller.isPdfValid.value)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 5.w),
            child: Text(
              'PDF file is required',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  // Helper method to truncate filename
  String _getFileName(String path) {
    String fileName = path.contains('/') ? path.split('/').last : path;
    return fileName.length > 25 
        ? '${fileName.substring(0, 15)}...${fileName.substring(fileName.length - 7)}'
        : fileName;
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null) {
        if (kIsWeb) {
          // Web implementation
          Uint8List? bytes = result.files.single.bytes;
          String fileName = result.files.single.name;
          if (bytes != null) {
            controller.setWebPdfFile(bytes, fileName);
          }
        } else {
          // Native implementation
          File file = File(result.files.single.path!);
          controller.setPdfFile(file);
        }
      }
    } catch (e) {
      controller.errorMessage.value = "Error selecting file: ${e.toString()}";
    }
  }

  Future<void> _submitForm() async {
    try {
      await controller.submitRequirement();
      if (controller.isSuccess.value) {
        Get.snackbar(
          'Success',
          'Your requirement has been submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while submitting your requirement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
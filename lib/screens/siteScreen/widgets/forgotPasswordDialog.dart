import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/siteScreen/controllers/forgotPasswordController.dart';
import 'package:maowl/screens/siteScreen/widgets/customButtom.dart';

class ForgotPasswordDialogs {
  static final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  // Step 1: Show OTP Request Dialog
  static void showRequestOTPDialog() {
    controller.resetState();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500.w,
            minWidth: 300.w,
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'We will send a 6-digit OTP to your registered email address.',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),
                Obx(() => controller.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : controller.otpSent.value
                        ? _buildOTPVerificationContent()
                        : _buildRequestOTPButton()),
                SizedBox(height: 16.h),
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      )
                    : SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Content for requesting OTP
  static Widget _buildRequestOTPButton() {
    return Column(
      children: [
        Center(
          child: CustomButton(
            text: 'Send OTP',
            onPressed: () => controller.requestOTP(),
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // Content for OTP verification
  static Widget _buildOTPVerificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: TextStyle(fontSize: 18.sp),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '6-digit OTP',
            isDense: true,
            counterText: '',
            contentPadding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Center(
          child: CustomButton(
            text: 'Verify OTP',
            onPressed: () {
              controller.verifyOTP().then((_) {
                if (controller.otpVerified.value) {
                  Get.back(); // Close current dialog
                  showResetPasswordDialog(); // Open reset password dialog
                }
              });
            },
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Show Reset Password Dialog           
  static void showResetPasswordDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500.w,
            minWidth: 300.w,
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildPasswordField('New Password', controller.newPasswordController),
                SizedBox(height: 16.h),
                _buildPasswordField('Confirm Password', controller.confirmPasswordController),
                SizedBox(height: 24.h),
                Obx(() => controller.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: CustomButton(
                          text: 'Reset Password',
                          onPressed: () {
                            controller.resetPassword();
                            // No need to add additional logic here
                            // The controller will handle showing the snackbar after success
                          },
                        ),
                      )),
                SizedBox(height: 16.h),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      )
                    : SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Helper to build password fields
  static Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18.sp),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/siteScreen/controllers/forgotPasswordServices.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordService _service = ForgotPasswordService();
  
  // Text controllers for input fields
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Observable variables
  final isLoading = false.obs;
  final otpSent = false.obs;
  final otpVerified = false.obs;
  final passwordResetSuccess = false.obs;
  
  // Validation observables
  final isValidOTP = false.obs;
  final isValidPassword = false.obs;
  final passwordsMatch = false.obs;
  
  // Error messages
  final errorMessage = ''.obs;
  
  @override
  void onClose() {
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  // Step 1: Request OTP to be sent to email
  Future<void> requestOTP() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final result = await _service.requestOTP();
      if (result) {
        otpSent.value = true;
        Get.snackbar(
          "Success", 
          "OTP sent to email",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = "Failed to send OTP. Please try again.";
      }
    } catch (e) {
      errorMessage.value = "An error occurred. Please try again later.";
    } finally {
      isLoading.value = false;
    }
  }
  
  // Step 2: Verify the OTP entered by user
  Future<void> verifyOTP() async {
    if (!validateOTP()) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final result = await _service.verifyOTP(otpController.text);
      if (result) {
        otpVerified.value = true;
        Get.snackbar(
          "Success", 
          "OTP verified successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = "Invalid OTP. Please try again.";
      }
    } catch (e) {
      errorMessage.value = "An error occurred. Please try again later.";
    } finally {
      isLoading.value = false;
    }
  }
  
  // Step 3: Reset the password
  Future<void> resetPassword() async {
    if (!validatePasswords()) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final result = await _service.resetPassword(newPasswordController.text);
      if (result) {
        passwordResetSuccess.value = true;
        
        // Close all open dialogs (both OTP and Reset Password dialogs)
        Get.back(); // Close reset password dialog
        Get.back(); // Close OTP dialog if it's still in the stack
        
        // Show success snackbar after all dialogs are closed
        Get.snackbar(
          "Success", 
          "Password reset successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        errorMessage.value = "Failed to reset password. Please try again.";
      }
    } catch (e) {
      errorMessage.value = "An error occurred. Please try again later.";
    } finally {
      isLoading.value = false;
    }
  }
  
  // Validate OTP input
  bool validateOTP() {
    final otp = otpController.text;
    if (otp.length != 6 || !otp.isNumericOnly) {
      errorMessage.value = "Please enter a valid 6-digit OTP";
      isValidOTP.value = false;
      return false;
    }
    
    isValidOTP.value = true;
    return true;
  }
  
  // Validate password inputs
  bool validatePasswords() {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;
    
    // Check if password is at least 6 characters
    if (newPassword.length < 6) {
      errorMessage.value = "Password must be at least 6 characters";
      isValidPassword.value = false;
      return false;
    }
    isValidPassword.value = true;
    
    // Check if passwords match
    if (newPassword != confirmPassword) {
      errorMessage.value = "Passwords do not match";
      passwordsMatch.value = false;
      return false;
    }
    passwordsMatch.value = true;
    
    return true;
  }
  
  // Reset all states when starting over or closing dialog
  void resetState() {
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    otpSent.value = false;
    otpVerified.value = false;
    passwordResetSuccess.value = false;
    isValidOTP.value = false;
    isValidPassword.value = false;
    passwordsMatch.value = false;
    errorMessage.value = '';
  }
}
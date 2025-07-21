import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/util/dio_config.dart';

class Employeecontroller extends GetxController {
  final Rx<String> selectedOption = "Home".obs;
  final Rx<String> employeeName = "".obs;
  final box = GetStorage();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;

  void setSelectedOption(String option) {
    print("Setting selectedOption to: $option");
    selectedOption.value = option;
  }

  @override
  void onInit() {
    super.onInit();
    print("EmployeeController onInit");

    if (Get.arguments != null) {
      employeeName.value = Get.arguments.toString();
      box.write('employeeName', employeeName.value);
      print("Setting employeeName from arguments to: ${employeeName.value}");
    } else {
      final storedName = box.read('employeeName');
      if (storedName != null && storedName.isNotEmpty) {
        employeeName.value = storedName;
        print("Retrieved employeeName from storage: ${employeeName.value}");
      } else {
        final fallbackName = box.read('name');
        if (fallbackName != null && fallbackName.isNotEmpty) {
          employeeName.value = fallbackName;
          print("Using fallback employeeName from 'name': ${employeeName.value}");
        }
      }
    }

    selectedOption.value = "Home";
    print("Set default selectedOption to: ${selectedOption.value}");

    debugStoredValues();
  }

  void debugStoredValues() {
    final token = box.read('token');
    final userId = box.read('_id');
    final userName = box.read('name');
    final storedEmployeeName = box.read('employeeName');

    print('Stored token: ${token != null ? (token.length > 10 ? token.substring(0, 10) + '...' : token) : 'null'}');
    print('Stored userId: $userId');
    print('Stored userName: $userName');
    print('Stored employeeName: $storedEmployeeName');
  }

  // logout
  Future<void> logout() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await DioConfig.getDio().post(
        '${dotenv.env['BASE_URL']}/api/logout',
        options: Options(
          headers: {
            "Content-Type": "application/json", // token is injected automatically
          },
        ),
      );

      if (response.statusCode == 200) {
        // Clear stored data
        box.remove('token');
        box.remove('_id');
        box.remove('name');
        box.remove('employeeName');

        // Reset state
        employeeName.value = "";
        selectedOption.value = "Home";

        Get.snackbar(
          "Success",
          "Logged out successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        Future.delayed(Duration(milliseconds: 500), () {
          Get.offAllNamed('/mainsite');
        });
      } else {
        errorMessage.value = "Failed to logout: ${response.statusCode}";
        Get.snackbar(
          "Error",
          "Failed to logout: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      errorMessage.value = "Logout failed: ${e.message}";
      Get.snackbar(
        "Error",
        "Logout failed: ${e.message}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = "Unexpected error: $e";
      Get.snackbar(
        "Error",
        "Unexpected error: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

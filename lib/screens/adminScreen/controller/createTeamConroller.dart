import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/util/dio_config.dart'; 

class CreateTeamController extends GetxController {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final Dio _dio = DioConfig.getDio(); 
  final box = GetStorage();
  var obscureText = true.obs;

  void clearFields() {
    nameController.clear();
    passwordController.clear();
  }

  void togglePasswordVisbility() {
    obscureText.value = !obscureText.value;
  }

  void submitTeam() async {
    final String name = nameController.text.trim();
    final String password = passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final requestData = {
        "username": name,
        "password": password
      };

      print("Sending request to create employee: $requestData");

      final response = await _dio.post(
        '${dotenv.env['BASE_URL']}/api/createEmployee',
        data: requestData,
      );

      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearFields();

        Get.snackbar(
          "Success",
          "Team member created successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Failed",
          "Failed to create team member: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      print("DioError: ${e.type}");
      print("DioError response: ${e.response?.data}");
      print("DioError message: ${e.message}");

      String errorMessage = "Something went wrong";

      if (e.response != null) {
        errorMessage = "Server error: ${e.response?.statusCode} - ${e.response?.data}";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout. Check your network.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Connection error. Check if the server is running.";
      }

      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      print("General error: $e");
      Get.snackbar(
        "Error",
        "Unexpected error: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

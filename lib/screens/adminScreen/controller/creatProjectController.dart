import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/util/dio_config.dart'; 

class CreateProjectController extends GetxController {
  final box = GetStorage();
  final Dio _dio = DioConfig.getDio(); 
  // Reactive variables
  var projectName = ''.obs;
  var description = ''.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var isLoading = false.obs;

  // Form validation
  bool get isFormValid =>
      projectName.value.isNotEmpty &&
      startDate.value.isNotEmpty &&
      endDate.value.isNotEmpty;

  // Updaters
  void updateProjectName(String value) => projectName.value = value;
  void updateDescription(String value) => description.value = value;
  void updateStartDate(String value) => startDate.value = value;
  void updateEndDate(String value) => endDate.value = value;

  // Clear form
  void clearForm() {
    projectName.value = '';
    description.value = '';
    startDate.value = '';
    endDate.value = '';
  }

  Future<void> submitProject() async {
    if (!isFormValid) {
      Get.snackbar('Error', 'Please fill in all required fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      Map<String, dynamic> projectData = {
        "project_name": projectName.value,
        "description": description.value,
        "start_date": startDate.value,
        "end_date": endDate.value,
      };

      print("Creating project with data: $projectData");

      final token = box.read('token');

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'No authentication token found. Please login again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white);
        isLoading.value = false;
        return;
      }

      final response = await _dio.post(
        '${dotenv.env['BASE_URL']}/api/createProject',
        data: projectData,
      );

      print("API response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearForm();
        Get.snackbar(
          "Success",
          "Project created successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Failed",
          "Failed to create project: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      print("DioException: ${e.message}");
      Get.snackbar(
        "Error",
        e.response?.data.toString() ?? "Unexpected server error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("General error: $e");
      Get.snackbar(
        "Error",
        "Unexpected error: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class CreateProjectController extends GetxController {
  final box = GetStorage();
  
  // Reactive variables
  var projectName = ''.obs;
  var description = ''.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var isLoading = false.obs;


  // Getter methods for form validation
  bool get isFormValid => 
      projectName.value.isNotEmpty && 
      startDate.value.isNotEmpty && 
      endDate.value.isNotEmpty;

  // Methods to update reactive variables
  void updateProjectName(String value) => projectName.value = value;
  void updateDescription(String value) => description.value = value;
  void updateStartDate(String value) => startDate.value = value;
  void updateEndDate(String value) => endDate.value = value;

  // Clear form method
  void clearForm() {
    projectName.value = '';
    description.value = '';
    startDate.value = '';
    endDate.value = '';
  }

  Future<void> submitProject() async {
    if (!isFormValid) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    try {
      isLoading.value = true;
      
      // Create project payload
      Map<String, dynamic> projectData = {
        "project_name": projectName.value,
        "description": description.value,
        "start_date": startDate.value,
        "end_date": endDate.value,
      };
      
      print("Creating project with data: $projectData");
      
      // Get token from storage
      final token = box.read('token');
      
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'No authentication token found. Please login again.');
        isLoading.value = false;
        return;
      }
      
      // Make API call
      var response = await Dio().post(
        '${dotenv.env['BASE_URL']}/api/createProject',
        data: projectData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      
      print("API response: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear form fields
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
    } catch (e) {
      print("Error creating project: $e");
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
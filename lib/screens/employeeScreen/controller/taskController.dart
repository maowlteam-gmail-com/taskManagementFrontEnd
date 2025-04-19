import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class TaskController extends GetxController {
  final box = GetStorage();
  var employees = <String>[].obs;
  var employeeIds = <String, String>{}.obs; // Map to store employee names and IDs
  var selectedEmployee = Rxn<String>();
  var selectedEmployeeId = Rxn<String>();
  var startDate = ''.obs;
  var endDate = ''.obs;
  var isLoading = false.obs;

  // Text controllers for all form fields
  final projectNameController = TextEditingController();
  final taskNameController = TextEditingController();
  final detailsController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  @override
  void onClose() {
    // Dispose controllers when no longer needed
    projectNameController.dispose();
    taskNameController.dispose();
    detailsController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  // Method to refresh employee list
  Future<void> refreshEmployeeList() async {
    print("Refreshing employee list...");
    employees.clear();
    employeeIds.clear();
    selectedEmployee.value = null;
    selectedEmployeeId.value = null;
    await fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      print("Starting fetchEmployees...");
      
      final token = box.read('token');
      print("Token data from storage: ${token != null ? token.substring(0, Math.min(20, token.length)) : 'null'}...");
      
      if (token == null || token.isEmpty) {
        print("No valid token found, using test data");
        if (employees.isEmpty) {
          employees.assignAll(['John Doe', 'Jane Smith', 'Robert Johnson']);
          employeeIds.addAll({
            'John Doe': '67e2a71d8b1dc5a79a258937',
            'Jane Smith': '67e2a71d8b1dc5a79a258938',
            'Robert Johnson': '67e2a71d8b1dc5a79a258939'
          });
          selectedEmployee.value = employees.first;
          selectedEmployeeId.value = employeeIds[employees.first];
          print("Added test employees: $employees");
        }
        return;
      }
      
      print("Making API request to ${dotenv.env['BASE_URL']}/api/getEmployees");
      var response = await Dio().get(
        '${dotenv.env['BASE_URL']}/api/getEmployees',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      
      print("API Response status: ${response.statusCode}");
      print("API Response data type: ${response.data.runtimeType}");
      print("API Response data: ${response.data}");
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          print("Processing list response...");
          Map<String, String> idMap = {};
          List<String> names = (response.data as List)
              .map((e) {
                print("Processing employee: $e");
                String name = e['username']?.toString() ?? "Unknown";
                String id = e['_id']?.toString() ?? "";
                if (id.isNotEmpty) {
                  idMap[name] = id;
                }
                return name;
              })
              .toList();
          
          print("Extracted names: $names");
          print("Extracted IDs: $idMap");
          
          if (names.isNotEmpty) {
            employees.assignAll(names);
            employeeIds.clear();
            employeeIds.addAll(idMap);
            if (selectedEmployee.value == null) {
              selectedEmployee.value = names.first;
              selectedEmployeeId.value = idMap[names.first];
            }
            print("Employees list updated with API data: $employees");
          } else {
            print("API returned empty list of names");
          }
        } else if (response.data is Map) {
          print("Processing map response...");
          // Handle if response is a map with a data field containing employees
          if (response.data['data'] != null && response.data['data'] is List) {
            Map<String, String> idMap = {};
            List<String> names = (response.data['data'] as List)
                .map((e) {
                  String name = e['username']?.toString() ?? "Unknown";
                  String id = e['_id']?.toString() ?? "";
                  if (id.isNotEmpty) {
                    idMap[name] = id;
                  }
                  return name;
                })
                .toList();
            
            print("Extracted names from data field: $names");
            print("Extracted IDs: $idMap");
            
            if (names.isNotEmpty) {
              employees.assignAll(names);
              employeeIds.clear();
              employeeIds.addAll(idMap);
              if (selectedEmployee.value == null) {
                selectedEmployee.value = names.first;
                selectedEmployeeId.value = idMap[names.first];
              }
              print("Employees list updated: $employees");
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print("Error fetching employees: $e");
      print("Stack trace: $stackTrace");
      // Only add test data if API call fails and employees is empty
      if (employees.isEmpty) {
        employees.assignAll(['John Doe', 'Jane Smith', 'Robert Johnson']);
        employeeIds.addAll({
          'John Doe': '67e2a71d8b1dc5a79a258937',
          'Jane Smith': '67e2a71d8b1dc5a79a258938',
          'Robert Johnson': '67e2a71d8b1dc5a79a258939'
        });
        selectedEmployee.value = employees.first;
        selectedEmployeeId.value = employeeIds[employees.first];
        print("Using test data after error: $employees");
      }
    }
  }

  void selectEmployee(String employee) {
    selectedEmployee.value = employee;
    selectedEmployeeId.value = employeeIds[employee];
    print("Employee selected: ${selectedEmployee.value} with ID: ${selectedEmployeeId.value}");
  }

  Future<void> submitTask() async {
    if (selectedEmployee.value == null || selectedEmployee.value!.isEmpty) {
      Get.snackbar('Error', 'Please select an employee');
      return;
    }

    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      Get.snackbar('Error', 'Please select start and end dates');
      return;
    }

    if (projectNameController.text.isEmpty || taskNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    try {
      isLoading.value = true;
      
      // Format dates to ISO string format
      DateTime startDateTime = DateTime.parse(startDate.value);
      DateTime endDateTime = DateTime.parse(endDate.value);
      
      // Create task payload
      Map<String, dynamic> taskData = {
        "project_name": projectNameController.text,
        "task_name": taskNameController.text,
        "description": detailsController.text,
        "start_date": startDateTime.toIso8601String(),
        "end_date": endDateTime.toIso8601String(),
        "assigned_to": selectedEmployeeId.value
      };
      
      print("Creating task with data: $taskData");
      
      // Get token from storage
      final token = box.read('token');
      
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'No authentication token found. Please login again.');
        isLoading.value = false;
        return;
      }
      
      // Make API call
      var response = await Dio().post(
        '${dotenv.env['BASE_URL']}/api/tasks/createTask',
        data: taskData,
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
        projectNameController.clear();
        taskNameController.clear();
        detailsController.clear();
        startDate.value = '';
        endDate.value = '';
        startDateController.clear();
        endDateController.clear();
        
        Get.snackbar(
        "Success",
        "Task created successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      } else {
        Get.snackbar(
        "Failed",
        "Failed to create task: ${response.statusCode}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      }
    } catch (e) {
      print("Error creating task: $e");
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
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
  
  // Project related variables
  var projects = <Map<String, dynamic>>[].obs;
  var projectNames = <String>[].obs;
  var selectedProject = Rxn<String>();
  var selectedProjectId = Rxn<String>();
  
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
    fetchProjects();
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
    print("code updated");
    employees.clear();
    employeeIds.clear();
    selectedEmployee.value = null;
    selectedEmployeeId.value = null;
    await fetchEmployees();
  }

  // Method to refresh project list
  Future<void> refreshProjectList() async {
    print("Refreshing project list...");
    projects.clear();
    projectNames.clear();
    selectedProject.value = null;
    selectedProjectId.value = null;
    await fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      print("Starting fetchProjects...");
      
      final token = box.read('token');
      print("Token data from storage: ${token != null ? token.substring(0, Math.min(20, token.length)) : 'null'}...");
         
      // Updated API URL for getting all projects
      String apiUrl = '${dotenv.env['BASE_URL']}/api/getAllProject';
      print("Making API request to $apiUrl");
      
      var response = await Dio().get(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      
      print("API Response status: ${response.statusCode}");
      print("API Response data: ${response.data}");
      
      if (response.statusCode == 200) {
        if (response.data['success'] == true && response.data['data'] is List) {
          print("Processing project list response...");
          List<Map<String, dynamic>> projectList = [];
          List<String> names = [];
          
          for (var project in response.data['data']) {
            print("Processing project: $project");
            String projectName = project['project_name']?.toString() ?? "Unknown Project";
            String projectId = project['_id']?.toString() ?? "";
            
            if (projectName.isNotEmpty && projectId.isNotEmpty) {
              projectList.add({
                '_id': projectId,
                'project_name': projectName,
                'start_date': project['start_date']?.toString() ?? '',
                'end_date': project['end_date']?.toString() ?? '',
              });
              names.add(projectName);
            }
          }
          
          print("Extracted project names: $names");
          
          if (names.isNotEmpty) {
            projects.assignAll(projectList);
            projectNames.assignAll(names);
            if (selectedProject.value == null) {
              selectedProject.value = names.first;
              selectedProjectId.value = projectList.first['_id'];
            }
            print("Projects list updated with API data: $projectNames");
          } else {
            print("API returned empty list of projects");
          }
        }
      }
    } catch (e, stackTrace) {
      print("Error fetching projects: $e");
      print("Stack trace: $stackTrace");
      // Only add test data if API call fails and projects is empty
      
    }
  }

  void selectProject(String projectName) {
    selectedProject.value = projectName;
    
    // Find the selected project and get its details
    final selectedProjectData = projects.firstWhere(
      (project) => project['project_name'] == projectName,
      orElse: () => {},
    );
    
    if (selectedProjectData.isNotEmpty) {
      selectedProjectId.value = selectedProjectData['_id'];
      
      // Auto-fill start and end dates from project data
      String projectStartDate = selectedProjectData['start_date'] ?? '';
      String projectEndDate = selectedProjectData['end_date'] ?? '';
      
      if (projectStartDate.isNotEmpty) {
        DateTime startDateTime = DateTime.parse(projectStartDate);
        String formattedStartDate = "${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')}";
        startDate.value = formattedStartDate;
        startDateController.text = formattedStartDate;
      }
      
      if (projectEndDate.isNotEmpty) {
        DateTime endDateTime = DateTime.parse(projectEndDate);
        String formattedEndDate = "${endDateTime.year}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.day.toString().padLeft(2, '0')}";
        endDate.value = formattedEndDate;
        endDateController.text = formattedEndDate;
      }
      
      print("Project selected: ${selectedProject.value} with ID: ${selectedProjectId.value}");
      print("Auto-filled dates - Start: ${startDate.value}, End: ${endDate.value}");
    }
  }

  Future<void> fetchEmployees() async {
    try {
      print("Starting fetchEmployees...");
      
      final token = box.read('token');
      print("Token data from storage: ${token != null ? token.substring(0, Math.min(20, token.length)) : 'null'}...");
      
     
      
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

    if (selectedProject.value == null || selectedProject.value!.isEmpty) {
      Get.snackbar('Error', 'Please select a project');
      return;
    }

    if (selectedProjectId.value == null || selectedProjectId.value!.isEmpty) {
      Get.snackbar('Error', 'Project ID is missing. Please reselect the project.');
      return;
    }

    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      Get.snackbar('Error', 'Please select start and end dates');
      return;
    }

    if (taskNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in task name');
      return;
    }

    try {
      isLoading.value = true;
      
      // Format dates to ISO string format
      DateTime startDateTime = DateTime.parse(startDate.value);
      DateTime endDateTime = DateTime.parse(endDate.value);
      
      // Create task payload
      Map<String, dynamic> taskData = {
        "project_name": selectedProject.value,
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
      
      // Updated API URL with project ID parameter
      String createTaskUrl = '${dotenv.env['BASE_URL']}/api/tasks/createTask/${selectedProjectId.value}';
      print("Making API request to: $createTaskUrl");
      
      // Make API call
      var response = await Dio().post(
        createTaskUrl,
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
        taskNameController.clear();
        detailsController.clear();
        startDate.value = '';
        endDate.value = '';
        startDateController.clear();
        endDateController.clear();
        
        // Reset project selection but keep the list
        selectedProject.value = projectNames.isNotEmpty ? projectNames.first : null;
        selectedProjectId.value = projects.isNotEmpty ? projects.first['_id'] : null;
        
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
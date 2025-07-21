import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/util/dio_config.dart';



class TaskController extends GetxController {
  final box = GetStorage();
  final Dio _dio = DioConfig.getDio(); 

  var employees = <String>[].obs;
  var employeeIds = <String, String>{}.obs;
  var selectedEmployee = Rxn<String>();
  var selectedEmployeeId = Rxn<String>();

  var projects = <Map<String, dynamic>>[].obs;
  var projectNames = <String>[].obs;
  var selectedProject = Rxn<String>();
  var selectedProjectId = Rxn<String>();

  var startDate = ''.obs;
  var endDate = ''.obs;
  var isLoading = false.obs;

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
    projectNameController.dispose();
    taskNameController.dispose();
    detailsController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  Future<void> refreshEmployeeList() async {
    print("Refreshing employee list...");
    employees.clear();
    employeeIds.clear();
    selectedEmployee.value = null;
    selectedEmployeeId.value = null;
    await fetchEmployees();
  }

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
      print("Fetching projects...");
      final apiUrl = '${dotenv.env['BASE_URL']}/api/getAllProject';

      final response = await _dio.get(
        apiUrl,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200 &&
          response.data['success'] == true &&
          response.data['data'] is List) {
        final List<Map<String, dynamic>> projectList = [];
        final List<String> names = [];

        for (var project in response.data['data']) {
          final name = project['project_name']?.toString() ?? '';
          final id = project['_id']?.toString() ?? '';

          if (name.isNotEmpty && id.isNotEmpty) {
            projectList.add({
              '_id': id,
              'project_name': name,
              'start_date': project['start_date']?.toString() ?? '',
              'end_date': project['end_date']?.toString() ?? '',
            });
            names.add(name);
          }
        }

        if (names.isNotEmpty) {
          projects.assignAll(projectList);
          projectNames.assignAll(names);
          selectedProject.value = names.first;
          selectedProjectId.value = projectList.first['_id'];
        }
      }
    } catch (e, stackTrace) {
      print("Error fetching projects: $e");
      print(stackTrace);
    }
  }

  void selectProject(String projectName) {
    selectedProject.value = projectName;

    final selectedProjectData = projects.firstWhere(
      (p) => p['project_name'] == projectName,
      orElse: () => {},
    );

    if (selectedProjectData.isNotEmpty) {
      selectedProjectId.value = selectedProjectData['_id'];

      final start = selectedProjectData['start_date'];
      final end = selectedProjectData['end_date'];

      if (start != null && start.toString().isNotEmpty) {
        final dt = DateTime.parse(start);
        final formatted = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
        startDate.value = formatted;
        startDateController.text = formatted;
      }

      if (end != null && end.toString().isNotEmpty) {
        final dt = DateTime.parse(end);
        final formatted = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
        endDate.value = formatted;
        endDateController.text = formatted;
      }
    }
  }

  Future<void> fetchEmployees() async {
    try {
      print("Fetching employees...");
      final apiUrl = '${dotenv.env['BASE_URL']}/api/getEmployees';

      final response = await _dio.get(
        apiUrl,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List list = [];

        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('data')) {
          list = data['data'];
        }

        if (list.isNotEmpty) {
          final Map<String, String> idMap = {};
          final List<String> names = [];

          for (var emp in list) {
            final name = emp['username']?.toString() ?? 'Unknown';
            final id = emp['_id']?.toString() ?? '';
            if (name.isNotEmpty && id.isNotEmpty) {
              idMap[name] = id;
              names.add(name);
            }
          }

          employees.assignAll(names);
          employeeIds.assignAll(idMap);
          selectedEmployee.value = names.first;
          selectedEmployeeId.value = idMap[names.first];
        }
      }
    } catch (e, st) {
      print("Error fetching employees: $e");
      print(st);
    }
  }

  void selectEmployee(String employee) {
    selectedEmployee.value = employee;
    selectedEmployeeId.value = employeeIds[employee];
  }

  Future<void> submitTask() async {
    if (selectedEmployee.value == null ||
        selectedProject.value == null ||
        selectedProjectId.value == null ||
        startDate.value.isEmpty ||
        endDate.value.isEmpty ||
        taskNameController.text.isEmpty) {
      Get.snackbar("Error", "Please complete all required fields");
      return;
    }

    try {
      isLoading.value = true;

      final taskData = {
        "project_name": selectedProject.value,
        "task_name": taskNameController.text,
        "description": detailsController.text,
        "start_date": startDate.value,
        "end_date": endDate.value,
        "assigned_to": selectedEmployeeId.value,
      };

      final apiUrl = '${dotenv.env['BASE_URL']}/api/tasks/createTask/${selectedProjectId.value}';

      final response = await _dio.post(
        apiUrl,
        data: taskData,
        options: Options(
          headers: {"Content-Type": "application/json"},
          sendTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        taskNameController.clear();
        detailsController.clear();
        startDate.value = '';
        endDate.value = '';
        startDateController.clear();
        endDateController.clear();

        selectedProject.value = projectNames.isNotEmpty ? projectNames.first : null;
        selectedProjectId.value = projects.isNotEmpty ? projects.first['_id'] : null;

        Get.snackbar("Success", "Task created successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        Get.snackbar("Failed", "Error: ${response.statusCode}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } on DioException catch (e) {
      String errorMsg = "Error: ${e.message}";
      if (e.response?.statusCode == 400) {
        errorMsg = "Bad Request";
      } else if (e.response?.statusCode == 401) {
        errorMsg = "Unauthorized. Please log in again.";
      } else if (e.response?.statusCode == 500) {
        errorMsg = e.response?.data['message'] ?? "Server Error";
      }

      Get.snackbar("Error", errorMsg,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Unexpected error: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> testAPIConnection() async {
    try {
      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/test',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      print("Test API response: ${response.data}");
    } catch (e) {
      print("API test failed: $e");
    }
  }
}

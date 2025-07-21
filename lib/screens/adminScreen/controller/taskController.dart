import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maowl/util/dio_config.dart'; 
class TaskController extends GetxController {
  final Dio _dio = DioConfig.getDio();
  final GetStorage box = GetStorage();

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
    employees.clear();
    employeeIds.clear();
    selectedEmployee.value = null;
    selectedEmployeeId.value = null;
    await fetchEmployees();
  }

  Future<void> refreshProjectList() async {
    projects.clear();
    projectNames.clear();
    selectedProject.value = null;
    selectedProjectId.value = null;
    await fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final response = await _dio.get('${dotenv.env['BASE_URL']}/api/getAllProject');

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<Map<String, dynamic>> projectList = [];
        List<String> names = [];

        for (var project in response.data['data']) {
          String projectName = project['project_name'] ?? "Unknown";
          String projectId = project['_id'] ?? "";

          if (projectName.isNotEmpty && projectId.isNotEmpty) {
            projectList.add({
              '_id': projectId,
              'project_name': projectName,
              'start_date': project['start_date'] ?? '',
              'end_date': project['end_date'] ?? '',
            });
            names.add(projectName);
          }
        }

        if (names.isNotEmpty) {
          projects.assignAll(projectList);
          projectNames.assignAll(names);
          selectedProject.value = names.first;
          selectedProjectId.value = projectList.first['_id'];
        }
      }
    } on DioException catch (e) {
      _handleDioError(e, context: "fetching projects");
    }
  }

  void selectProject(String projectName) {
    selectedProject.value = projectName;
    final selectedData = projects.firstWhere((p) => p['project_name'] == projectName, orElse: () => {});
    if (selectedData.isNotEmpty) {
      selectedProjectId.value = selectedData['_id'];
      _setDateFromProject(selectedData);
    }
  }

  void _setDateFromProject(Map<String, dynamic> project) {
    final start = project['start_date'] ?? '';
    final end = project['end_date'] ?? '';

    if (start.isNotEmpty) {
      DateTime dt = DateTime.parse(start);
      final formatted = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      startDate.value = formatted;
      startDateController.text = formatted;
    }

    if (end.isNotEmpty) {
      DateTime dt = DateTime.parse(end);
      final formatted = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      endDate.value = formatted;
      endDateController.text = formatted;
    }
  }

  Future<void> fetchEmployees() async {
    try {
      final response = await _dio.get('${dotenv.env['BASE_URL']}/api/getEmployees');

      final dataList = response.data is List
          ? response.data
          : response.data['data'] ?? [];

      if (dataList is List) {
        final idMap = <String, String>{};
        final names = <String>[];

        for (var e in dataList) {
          String name = e['username'] ?? 'Unknown';
          String id = e['_id'] ?? '';
          if (id.isNotEmpty) {
            idMap[name] = id;
            names.add(name);
          }
        }

        if (names.isNotEmpty) {
          employees.assignAll(names);
          employeeIds.assignAll(idMap);
          selectedEmployee.value = names.first;
          selectedEmployeeId.value = idMap[names.first];
        }
      }
    } on DioException catch (e) {
      _handleDioError(e, context: "fetching employees");
    }
  }

  void selectEmployee(String employee) {
    selectedEmployee.value = employee;
    selectedEmployeeId.value = employeeIds[employee];
  }

  Future<void> submitTask() async {
    if (!_validateTaskInputs()) return;

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

      final response = await _dio.post(
        '${dotenv.env['BASE_URL']}/api/tasks/createTask/${selectedProjectId.value}',
        data: taskData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _clearTaskForm();

        Get.snackbar(
          "Success",
          "Task created successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Failed", "Task creation failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      _handleDioError(e, context: "creating task");
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateTaskInputs() {
    if (selectedEmployeeId.value == null || selectedProjectId.value == null || taskNameController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all required fields");
      return false;
    }
    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      Get.snackbar("Error", "Please select start and end dates");
      return false;
    }
    return true;
  }

  void _clearTaskForm() {
    taskNameController.clear();
    detailsController.clear();
    startDate.value = '';
    endDate.value = '';
    startDateController.clear();
    endDateController.clear();
  }

  void _handleDioError(DioException e, {String context = "request"}) {
    String msg = "An error occurred while $context.";

    if (e.response != null) {
      final code = e.response?.statusCode;
      switch (code) {
        case 400:
          msg = "Bad request. Check inputs.";
          break;
        case 401:
          msg = "Unauthorized. Login again.";
          break;
        case 403:
          msg = "Access denied.";
          break;
        case 500:
          msg = "Server error. Try again later.";
          break;
        default:
          msg = e.response?.data['message'] ?? "Unknown error";
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      msg = "Connection timeout. Check internet.";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      msg = "Response timeout. Try again.";
    }

    Get.snackbar("Error", msg, backgroundColor: Colors.red, colorText: Colors.white);
    print("[$context error] ${e.message}");
  }
}

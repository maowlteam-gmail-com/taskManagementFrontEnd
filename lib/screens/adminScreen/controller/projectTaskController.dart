import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/screens/adminScreen/model/taskModel.dart';
import 'package:maowl/util/dio_config.dart';

class ProjectTaskController extends GetxController {
  final Dio _dio = DioConfig.getDio();

  final GetStorage _storage = GetStorage();

  // State variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var tasks = <TaskModel>[].obs;

  // Current project state
  var selectedProjectId = ''.obs;
  var selectedProjectName = ''.obs;
  var showTasks = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchTasks(String projectId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Base URL not configured');
      }

      final response = await _dio.get(
        '$baseUrl/api/getTasksForProject/$projectId',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          final List taskList = data['data'] ?? [];
          debugPrint("Task Count: "+taskList.length.toString());

          tasks.value =
              taskList.map((taskData) {
                return TaskModel(
                  id: taskData['_id'] ?? '',
                  taskName: taskData['task_name'] ?? '',
                  status: taskData['status'] ?? '',
                  createdBy: User(
                    id: taskData['created_by']['_id'] ?? '',
                    username: taskData['created_by']['username'] ?? '',
                  ),
                  assignedTo: User(
                    id: taskData['assigned_to']?['_id'] ?? '',
                    username: taskData['assigned_to']?['username'] ?? '',
                  ),
                );
              }).toList();
          debugPrint("Task Count: "+tasks.length.toString());
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tasks');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      errorMessage.value = _handleDioError(e);
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Update project and load its tasks
  void selectProject(String projectId, String projectName) {
    selectedProjectId.value = projectId;
    selectedProjectName.value = projectName;
    showTasks.value = true;
    fetchTasks(projectId);
  }

  void backToProjects() {
    showTasks.value = false;
    selectedProjectId.value = '';
    selectedProjectName.value = '';
    tasks.clear();
    errorMessage.value = '';
    Get.back(); // Navigate back
  }

  void restoreProjectContext(String projectId, String projectName) {
    if (selectedProjectId.value != projectId) {
      selectedProjectId.value = projectId;
      selectedProjectName.value = projectName;
      showTasks.value = true;

      if (tasks.isEmpty || selectedProjectId.value != projectId) {
        fetchTasks(projectId);
      }
    }
  }

  Future<void> refreshTasks() async {
    if (selectedProjectId.value.isNotEmpty) {
      await fetchTasks(selectedProjectId.value);
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  bool isProjectSelected(String projectId) {
    return selectedProjectId.value == projectId && showTasks.value;
  }

  Map<String, String> getCurrentProjectInfo() {
    return {'id': selectedProjectId.value, 'name': selectedProjectName.value};
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode ?? 0;
      final responseData = e.response?.data;

      switch (statusCode) {
        case 401:
          return 'Authentication failed. Please login again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Project not found or no tasks available.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return responseData['message'] ?? 'Error: $statusCode';
      }
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server timeout. Try again later.';
    } else {
      return 'Network error: ${e.message}';
    }
  }

  @override
  void onClose() {
    tasks.clear();
    super.onClose();
  }
}

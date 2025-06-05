
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/screens/adminScreen/controller/projectTaskController.dart';
import 'package:maowl/screens/adminScreen/model/taskHistoryResponse.dart';

class TaskHistoryController extends GetxController {
  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();
  
  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var taskHistory = Rxn<TaskHistoryResponse>();
  
  // Current task info
  var selectedTaskId = ''.obs;
  var selectedTaskName = ''.obs;
  var selectedProjectId = ''.obs;
  var selectedProjectName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setupDioInterceptors();
  }

  void _setupDioInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST: ${options.method} ${options.uri}');
          print('HEADERS: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('ERROR: ${error.response?.statusCode} ${error.response?.data}');
          print('ERROR MESSAGE: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  String? _getAuthToken() {
    try {
      return _storage.read('auth_token') ?? _storage.read('token') ?? _storage.read('access_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchTaskHistory(String taskId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Base URL not configured');
      }

      final token = _getAuthToken();
      print('Auth token: ${token != null ? 'Found' : 'Not found'}');

      final response = await _dio.get(
        '$baseUrl/api/tasks/getTaskHistory/$taskId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Task History API Response: $data');
        
        if (data['success'] == true) {
          taskHistory.value = TaskHistoryResponse.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch task history');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error occurred';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        print('DioException - Status: $statusCode, Data: $responseData');
        
        switch (statusCode) {
          case 401:
            errorMsg = 'Authentication failed. Please login again.';
            break;
          case 403:
            errorMsg = 'Access denied. You don\'t have permission to view this task history.';
            break;
          case 404:
            errorMsg = 'Task not found or no history available.';
            break;
          case 500:
            errorMsg = 'Server error. Please try again later.';
            break;
          default:
            errorMsg = responseData['message'] ?? 'Server error: $statusCode';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Server response timeout. Please try again.';
      } else {
        errorMsg = 'Network error: ${e.message}';
      }
      
      errorMessage.value = errorMsg;
      print('Error fetching task history: $e');
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
      print('Error fetching task history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectTask(String taskId, String taskName, {String? projectId, String? projectName}) {
    selectedTaskId.value = taskId;
    selectedTaskName.value = taskName;
    selectedProjectId.value = projectId ?? '';
    selectedProjectName.value = projectName ?? '';
    fetchTaskHistory(taskId);
  }

  // Enhanced back navigation method
  void backToTasks() {
    try {
      // Clear the current state
      _clearHistoryState();
      
      // Check if we have project context to navigate back to
      if (selectedProjectId.value.isNotEmpty) {
        // Navigate back to TaskWidget with proper project context
        Get.back();
        
        // Ensure ProjectTaskController has the correct project selected
        if (Get.isRegistered<ProjectTaskController>()) {
          final projectController = Get.find<ProjectTaskController>();
          if (projectController.selectedProjectId.value != selectedProjectId.value) {
            projectController.selectProject(selectedProjectId.value, selectedProjectName.value);
          }
        }
      } else {
        // Fallback: just go back
        Get.back();
      }
    } catch (e) {
      print('Error in backToTasks: $e');
      // Fallback navigation
      Get.back();
    }
  }

  // Alternative method to navigate to tasks route directly
  void backToTasksRoute() {
    try {
      _clearHistoryState();
      
      // Navigate to tasks route directly
      Get.offNamed('/tasks');
    } catch (e) {
      print('Error in backToTasksRoute: $e');
      Get.back();
    }
  }

  // Method to navigate back to projects (if needed)
  void backToProjects() {
    try {
      _clearHistoryState();
      
      if (Get.isRegistered<ProjectTaskController>()) {
        final projectController = Get.find<ProjectTaskController>();
        projectController.backToProjects();
      }
      
      // Navigate back to projects
      Get.offAllNamed('/projects');
    } catch (e) {
      print('Error in backToProjects: $e');
      Get.back();
    }
  }

  // Helper method to clear history state
  void _clearHistoryState() {
    selectedTaskId.value = '';
    selectedTaskName.value = '';
    taskHistory.value = null;
    errorMessage.value = '';
    // Keep project info for proper navigation context
  }

  Future<void> refreshTaskHistory() async {
    if (selectedTaskId.value.isNotEmpty) {
      await fetchTaskHistory(selectedTaskId.value);
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Helper method to format date
  String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  // Helper method to get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'warning':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to capitalize status
  String capitalizeStatus(String status) {
    return status.toUpperCase().replaceAll('_', ' ');
  }

  @override
  void onClose() {
    _clearHistoryState();
    super.onClose();
  }
}
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maowl/colors/app_colors.dart';
import 'package:maowl/screens/adminScreen/controller/projectTaskController.dart';
import 'package:maowl/screens/adminScreen/model/taskHistoryResponse.dart';
import 'package:maowl/util/dio_config.dart';

class TaskHistoryController extends GetxController {
  final Dio _dio = DioConfig.getDio();
  final GetStorage _storage = GetStorage();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var taskHistory = Rxn<TaskHistoryResponse>();

  var selectedTaskId = ''.obs;
  var selectedTaskName = ''.obs;
  var selectedProjectId = ''.obs;
  var selectedProjectName = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchTaskHistory(String taskId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('Base URL not configured');
      }

      final response = await _dio.get(
        '$baseUrl/api/tasks/getTaskHistory/$taskId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          taskHistory.value = TaskHistoryResponse.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch task history');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      errorMessage.value = _handleDioError(e, context: "fetching task history");
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void selectTask(
    String taskId,
    String taskName, {
    String? projectId,
    String? projectName,
  }) {
    selectedTaskId.value = taskId;
    selectedTaskName.value = taskName;
    selectedProjectId.value = projectId ?? '';
    selectedProjectName.value = projectName ?? '';
    fetchTaskHistory(taskId);
  }

  void backToTasks() {
    try {
      if (selectedProjectId.value.isNotEmpty &&
          Get.isRegistered<ProjectTaskController>()) {
        final controller = Get.find<ProjectTaskController>();
        if (controller.selectedProjectId.value != selectedProjectId.value) {
          controller.selectProject(
            selectedProjectId.value,
            selectedProjectName.value,
          );
        }
      }
      Get.back();
      _clearHistoryState();
    } catch (e) {
      print('Error in backToTasks: $e');
      Get.back();
    }
  }

  void backToTasksRoute() {
    try {
      Get.offNamed('/tasks');
      _clearHistoryState();
    } catch (e) {
      print('Error in backToTasksRoute: $e');
      Get.back();
    }
  }

  void backToProjects() {
    try {
      if (Get.isRegistered<ProjectTaskController>()) {
        Get.find<ProjectTaskController>().backToProjects();
      }
      Get.offAllNamed('/projects');
      _clearHistoryState();
    } catch (e) {
      print('Error in backToProjects: $e');
      Get.back();
    }
  }

  void _clearHistoryState() {
    selectedTaskId.value = '';
    selectedTaskName.value = '';
    taskHistory.value = null;
    errorMessage.value = '';
  }

  Future<void> refreshTaskHistory() async {
    if (selectedTaskId.value.isNotEmpty) {
      await fetchTaskHistory(selectedTaskId.value);
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  String formatDateTime(String dateTimeString) {
    if (dateTimeString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateTimeString);
      // Convert UTC to local time
      final localDate = date.toLocal();
      return DateFormat('MMM d, yyyy - h:mm a').format(localDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String formatDateTimeIST(String dateTimeString) {
    if (dateTimeString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateTimeString);
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  bool isFirstDateBeforeOrSame(String date1, String date2) {
    // Convert string to DateTime
    DateTime d1 = DateTime.parse(date1);
    DateTime d2 = DateTime.parse(date2);
    
    // Check if d1 is before or equal to d2
    return d1.isBefore(d2) || d1.isAtSameMomentAs(d2);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pendingColor;
      case 'due':
        return AppColors.dueColor;
      case 'in progress':
        return AppColors.inProgressColor;
      case 'completed':
        return AppColors.completedColor;
      case 'delayed':
        return AppColors.delayedColor;
      case 'warning':
        return AppColors.warningColor;
      default:
        return AppColors.inProgressColor;
    }
  }

  String capitalizeStatus(String status) =>
      status.toUpperCase().replaceAll('_', ' ');

  String _handleDioError(DioException e, {String context = "API request"}) {
    String message = 'Error occurred during $context.';

    if (e.response != null) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      switch (status) {
        case 401:
          return 'Authentication failed. Please login again.';
        case 403:
          return 'Access denied. You don\'t have permission.';
        case 404:
          return 'Task not found or no history available.';
        case 500:
          return data?['message'] ?? 'Server error. Please try again.';
        default:
          return data?['message'] ?? 'Unexpected server error [$status]';
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Check your internet.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return 'Network connection error. Please try again.';
      default:
        return e.message ?? message;
    }
  }

  @override
  void onClose() {
    _clearHistoryState();
    super.onClose();
  }
}

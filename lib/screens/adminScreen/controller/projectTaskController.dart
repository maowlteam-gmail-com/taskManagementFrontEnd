import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/adminScreen/model/taskModel.dart';
import 'package:get_storage/get_storage.dart';

class ProjectTaskController extends GetxController {
  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();
  
  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var tasks = <TaskModel>[].obs;
  
  // Current project info
  var selectedProjectId = ''.obs;
  var selectedProjectName = ''.obs;
  var showTasks = false.obs;

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

  Future<void> fetchTasks(String projectId) async {
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
        '$baseUrl/api/getTasksForProject/$projectId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response: $data');
        
        if (data['success'] == true) {
          final List taskList = data['data'] ?? [];
          tasks.value = taskList.map((taskData) {
            return TaskModel(
              id: taskData['_id'] ?? '',
              taskName: taskData['task_name'] ?? '',
              status: taskData['status'] ?? '',
              createdBy: User(
                id: taskData['created_by']['_id'] ?? '',
                username: taskData['created_by']['username'] ?? '',
              ),
              assignedTo: User(
                id: taskData['assigned_to']['_id'] ?? '',
                username: taskData['assigned_to']['username'] ?? '',
              ),
            );
          }).toList();
          
          print('Loaded ${tasks.length} tasks for project: $projectId');
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tasks');
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
            errorMsg = 'Access denied. You don\'t have permission to view these tasks.';
            break;
          case 404:
            errorMsg = 'Project not found or no tasks available.';
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
      print('Error fetching tasks: $e');
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
      print('Error fetching tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to manually set auth token (call this after login)
  void setAuthToken(String token) {
    try {
      _storage.write('auth_token', token);
      print('Auth token saved successfully');
    } catch (e) {
      print('Error saving auth token: $e');
    }
  }

  // Method to clear auth token (call this on logout)
  void clearAuthToken() {
    try {
      _storage.remove('auth_token');
      _storage.remove('token');
      _storage.remove('access_token');
      print('Auth token cleared successfully');
    } catch (e) {
      print('Error clearing auth token: $e');
    }
  }

  void selectProject(String projectId, String projectName) {
    print('Selecting project: $projectName (ID: $projectId)');
    selectedProjectId.value = projectId;
    selectedProjectName.value = projectName;
    showTasks.value = true;
    fetchTasks(projectId);
  }

  void backToProjects() {
    print('Navigating back to projects');
    try {
      // Clear task-related state
      showTasks.value = false;
      selectedProjectId.value = '';
      selectedProjectName.value = '';
      tasks.clear();
      errorMessage.value = '';
      
      // Navigate back
      Get.back();
    } catch (e) {
      print('Error in backToProjects: $e');
      // Fallback navigation
      Get.offAllNamed('/projects');
    }
  }

  // Method to restore project context (useful when returning from task history)
  void restoreProjectContext(String projectId, String projectName) {
    if (selectedProjectId.value != projectId) {
      print('Restoring project context: $projectName (ID: $projectId)');
      selectedProjectId.value = projectId;
      selectedProjectName.value = projectName;
      showTasks.value = true;
      
      // Only fetch tasks if we don't have them or if it's a different project
      if (tasks.isEmpty || selectedProjectId.value != projectId) {
        fetchTasks(projectId);
      }
    }
  }

  Future<void> refreshTasks() async {
    if (selectedProjectId.value.isNotEmpty) {
      print('Refreshing tasks for project: ${selectedProjectName.value}');
      await fetchTasks(selectedProjectId.value);
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Method to check if project is currently selected
  bool isProjectSelected(String projectId) {
    return selectedProjectId.value == projectId && showTasks.value;
  }

  // Method to get current project info
  Map<String, String> getCurrentProjectInfo() {
    return {
      'id': selectedProjectId.value,
      'name': selectedProjectName.value,
    };
  }

  @override
  void onClose() {
    print('ProjectTaskController disposing');
    tasks.clear();
    super.onClose();
  }
}
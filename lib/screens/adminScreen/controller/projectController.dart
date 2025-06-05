import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maowl/screens/adminScreen/model/projectModel.dart';
import 'package:flutter/material.dart';

class Projectcontroller extends GetxController {
  final RxList<Project> projects = <Project>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  
  final Dio _dio = Dio();
  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Get token from storage
      final token = box.read('token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication token not found';
        return;
      }

      // Configure Dio with headers
      _dio.options.headers['Authorization'] = 'Bearer $token';
      _dio.options.headers['Content-Type'] = 'application/json';

      // Make API call
      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        errorMessage.value = 'Base URL not configured';
        return;
      }

      final response = await _dio.get('$baseUrl/api/getAllProject');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true) {
          final List<dynamic> projectsData = responseData['data'];
          
          // Clear existing projects and add new ones
          projects.clear();
          projects.addAll(
            projectsData.map((json) => Project.fromJson(json)).toList(),
          );
        } else {
          errorMessage.value = 'Failed to load projects';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage.value = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 403) {
          errorMessage.value = 'Access denied.';
        } else {
          errorMessage.value = 'Network error: ${e.message}';
        }
      } else {
        errorMessage.value = 'An unexpected error occurred: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProject(String projectId, String projectName) async {
    try {
      isDeleting.value = true;
      
      // Get token from storage
      final token = box.read('token');
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error',
          'Authentication token not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Configure Dio with headers
      _dio.options.headers['Authorization'] = 'Bearer $token';
      _dio.options.headers['Content-Type'] = 'application/json';

      // Make API call
      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Base URL not configured',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final response = await _dio.delete('$baseUrl/api/deleteProject/$projectId');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true) {
          // Remove project from local list
          projects.removeWhere((project) => project.id == projectId);
          
          // Show success message
          Get.snackbar(
            'Success',
            'Project "$projectName" deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
          
          // Refresh the projects list
          await refreshProjects();
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to delete project',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      if (e is DioException) {
        String errorMsg = 'An error occurred';
        if (e.response?.statusCode == 401) {
          errorMsg = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 403) {
          errorMsg = 'Access denied.';
        } else if (e.response?.statusCode == 404) {
          errorMsg = 'Project not found.';
        } else {
          errorMsg = 'Network error: ${e.message}';
        }
        
        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Error',
          'An unexpected error occurred: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      isDeleting.value = false;
    }
  }

  void showDeleteConfirmationDialog(String projectId, String projectName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text(
          'Delete Project',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$projectName"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Obx(() => TextButton(
            onPressed: isDeleting.value 
              ? null 
              : () {
                  Get.back();
                  deleteProject(projectId, projectName);
                },
            child: isDeleting.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
              : const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
          )),
        ],
      ),
    );
  }

  Future<void> refreshProjects() async {
    await loadProjects();
  }

  void addProject(Project project) {
    projects.add(project);
  }

  void removeProject(String projectId) {
    projects.removeWhere((project) => project.id == projectId);
  }

  Project? getProjectById(String id) {
    try {
      return projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
}
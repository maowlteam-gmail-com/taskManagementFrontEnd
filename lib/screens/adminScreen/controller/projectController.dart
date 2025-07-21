import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import 'package:maowl/screens/adminScreen/model/projectModel.dart';
import 'package:maowl/util/dio_config.dart'; 

class Projectcontroller extends GetxController {
  final RxList<Project> projects = <Project>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;

  final Dio _dio = DioConfig.getDio(); 
  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
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

          projects.clear();
          projects.addAll(
            projectsData.map((json) => Project.fromJson(json)).toList(),
          );
        } else {
          errorMessage.value = responseData['message'] ?? 'Failed to load projects';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } on DioException catch (e) {
      errorMessage.value = _handleDioError(e);
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProject(String projectId, String projectName) async {
    isDeleting.value = true;

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        _showErrorSnackbar('Base URL not configured');
        return;
      }

      final response = await _dio.delete('$baseUrl/api/deleteProject/$projectId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          projects.removeWhere((project) => project.id == projectId);

          _showSuccessSnackbar('Project "$projectName" deleted successfully');
          await refreshProjects();
        } else {
          _showErrorSnackbar(responseData['message'] ?? 'Failed to delete project');
        }
      } else {
        _showErrorSnackbar('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _showErrorSnackbar(_handleDioError(e));
    } catch (e) {
      _showErrorSnackbar('Unexpected error: $e');
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
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
                    : const Text('Delete', style: TextStyle(color: Colors.red)),
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
    } catch (_) {
      return null;
    }
  }

  // Snackbar helpers
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      default:
        return e.message ?? 'Network error occurred';
    }
  }
}

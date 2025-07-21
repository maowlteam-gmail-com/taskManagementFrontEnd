import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:maowl/util/dio_config.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class TaskUpdateController extends GetxController {
  // Text Controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();

  // Observable variables
  final RxList<Map<String, dynamic>> selectedCollaborators = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> employees = <Map<String, dynamic>>[].obs;

  // File picker variables
  final RxBool isFileValid = true.obs;
  final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);
  final RxString fileErrorMessage = ''.obs;

  // Supported file types
  final List<String> supportedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  // Max file size in bytes (10MB)
  final int maxFileSize = 10 * 1024 * 1024;

  // Current task
  late Map<String, dynamic> currentTask;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    hoursController.dispose();
    super.onClose();
  }

  // Initialize with task data
  void initializeTask(Map<String, dynamic> task) {
    currentTask = task;
  }

  // File picker methods
  String? getFileName() => selectedFile.value?.name;
  String? getFilePath() => selectedFile.value?.path;
  Uint8List? getFileBytes() => selectedFile.value?.bytes;

  // Method to get truncated file name for display
  String getTruncatedFileName(String fileName) {
    if (fileName.length <= 30) return fileName;

    final extension = path.extension(fileName);
    final nameWithoutExtension = path.basenameWithoutExtension(fileName);

    if (nameWithoutExtension.length <= 25) return fileName;

    return '${nameWithoutExtension.substring(0, 25)}...$extension';
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedFileTypes,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size
        if (file.size > maxFileSize) {
          isFileValid.value = false;
          fileErrorMessage.value = 'File size must be less than 10MB';
          return;
        }

        // Check file extension
        final extension = path.extension(file.name).toLowerCase().replaceAll('.', '');
        if (!supportedFileTypes.contains(extension)) {
          isFileValid.value = false;
          fileErrorMessage.value = 'Unsupported file type';
          return;
        }

        // File is valid
        selectedFile.value = file;
        isFileValid.value = true;
        fileErrorMessage.value = '';
      }
    } catch (e) {
      isFileValid.value = false;
      fileErrorMessage.value = 'Error picking file: $e';
    }
  }

  void clearFile() {
    selectedFile.value = null;
    isFileValid.value = true;
    fileErrorMessage.value = '';
  }

  Future<void> fetchEmployees() async {
    isLoadingEmployees.value = true;

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        isLoadingEmployees.value = false;
        return;
      }

     final dio = DioConfig.getDio();

      final response = await dio.get(
        '${dotenv.env['BASE_URL']}/api/getEmployees',
        options: dio_pkg.Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final employeeList = responseData['data'] as List;
          employees.value = employeeList.map((e) => e as Map<String, dynamic>).toList();
          isLoadingEmployees.value = false;
        } else {
          errorMessage.value = 'Invalid response format';
          isLoadingEmployees.value = false;
        }
      } else {
        errorMessage.value = 'Failed to load employees: ${response.statusCode}';
        isLoadingEmployees.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error fetching employees: $e';
      isLoadingEmployees.value = false;
    }
  }

  Future<void> reportWarning() async {
    final taskId = currentTask['_id'];

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Are You Stacked?'),
        content: const Text('Do you want to report a warning for this task?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close the dialog
              await _executeReportWarning(taskId);
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeReportWarning(String taskId) async {
    isLoading.value = true;

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication token not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
        isLoading.value = false;
        return;
      }

      final dio = dio_pkg.Dio();
      final response = await dio.post(
        '${dotenv.env['BASE_URL']}/api/tasks/reportWarning/$taskId',
        options: dio_pkg.Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Warning reported successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate back to employee screen
        await Future.delayed(const Duration(seconds: 1));
        Get.offNamed('/employee');
      } else {
        Get.snackbar(
          'Error',
          'Failed to report warning: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error reporting warning: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeTask() async {
    final taskId = currentTask['_id'];

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Task'),
        content: const Text('Are you sure you want to mark this entire task as completed?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close the dialog
              await _executeCompleteTask(taskId);
            },
            child: const Text('Complete', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeCompleteTask(String taskId) async {
    isLoading.value = true;

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication token not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
        isLoading.value = false;
        return;
      }

      final dio = dio_pkg.Dio();
      final response = await dio.put(
        '${dotenv.env['BASE_URL']}/api/tasks/completeTask/$taskId',
        options: dio_pkg.Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Task completed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate back to employee screen
        await Future.delayed(const Duration(seconds: 1));
        Get.offNamed('/employee');
      } else if (response.statusCode == 403) {
        // Handle 403 Forbidden error specifically
        Get.snackbar(
          'Access Denied',
          'You can\'t confirm task completion',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to complete task: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      }
    } on dio_pkg.DioException catch (dioError) {
      String errorMsg = 'Error completing task';

      // Handle 403 Forbidden error specifically
      if (dioError.response?.statusCode == 403) {
        Get.snackbar(
          'Access Denied',
          'You can\'t confirm task completion',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: const Duration(seconds: 4),
        );
        isLoading.value = false;
        return;
      }

      // Handle other Dio errors
      if (dioError.response?.data != null &&
          dioError.response?.data is Map &&
          dioError.response?.data['message'] != null) {
        errorMsg = dioError.response?.data['message'];
      } else if (dioError.type == dio_pkg.DioExceptionType.connectionTimeout) {
        errorMsg = "Connection timeout. Please check your internet connection.";
      } else if (dioError.type == dio_pkg.DioExceptionType.receiveTimeout) {
        errorMsg = "Server is taking too long to respond.";
      } else if (dioError.type == dio_pkg.DioExceptionType.sendTimeout) {
        errorMsg = "Sending request is taking too long.";
      } else if (dioError.type == dio_pkg.DioExceptionType.badResponse) {
        errorMsg = "Server responded with an error: ${dioError.response?.statusCode}";
      } else {
        errorMsg = "Network error occurred. Please check your connection.";
      }

      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error completing task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCollaboratorToBackend(String collaboratorId) async {
    final taskId = currentTask['_id'];
    final box = GetStorage();
    final token = box.read('token');

    try {
      final dio = dio_pkg.Dio();
      final response = await dio.patch(
        '${dotenv.env['BASE_URL']}/api/tasks/addCollaborator/$taskId',
        options: dio_pkg.Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        data: {"collaboratorId": collaboratorId},
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Collaborator added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.offNamed('/employee');
      } else {
        Get.snackbar(
          'Failure',
          'Failed to add collaborator',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error adding collaborator',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void clearFields() {
    descriptionController.clear();
    hoursController.clear();
    selectedCollaborators.clear();
  }

  Future<void> submitWorkDetails() async {
    // Validate input fields
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter work description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    if (hoursController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter hours spent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        isLoading.value = false;
        return;
      }

      final taskId = currentTask['_id'];
      final apiUrl = '${dotenv.env['BASE_URL']}/api/tasks/addWorkDetails/$taskId';

      // Create FormData for multipart request
      final dio_pkg.FormData formData = dio_pkg.FormData();

      // Add text fields
      formData.fields.add(MapEntry('description', descriptionController.text));
      formData.fields.add(MapEntry('hours_spent', hoursController.text));
      formData.fields.add(MapEntry('date', DateTime.now().toIso8601String()));

      // Handle collaborators
      if (selectedCollaborators.isNotEmpty) {
        final collabList = selectedCollaborators.map((collab) => {
          "_id": collab['_id'],
          "username": collab['username'],
        }).toList();
        formData.fields.add(MapEntry('collaborators', jsonEncode(collabList)));
      } else {
        formData.fields.add(MapEntry('collaborators', '[]'));
      }

      // Handle file upload
      if (selectedFile.value != null) {
        final file = selectedFile.value!;
        final String fileName = file.name;
        String mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

        try {
          if (kIsWeb && file.bytes != null) {
            formData.files.add(
              MapEntry(
                'file',
                dio_pkg.MultipartFile.fromBytes(
                  file.bytes!,
                  filename: fileName,
                  contentType: MediaType.parse(mimeType),
                ),
              ),
            );
          } else if (!kIsWeb && file.path != null) {
            formData.files.add(
              MapEntry(
                'file',
                await dio_pkg.MultipartFile.fromFile(
                  file.path!,
                  filename: fileName,
                  contentType: MediaType.parse(mimeType),
                ),
              ),
            );
          }
        } catch (fileError) {
          Get.snackbar(
            'Warning',
            'There was an issue with the file attachment, continuing without it',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[800],
          );
        }
      }

      // Configure Dio
      final dioClient = dio_pkg.Dio(dio_pkg.BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ));

      // Make the API call
      final response = await dioClient.post(
        apiUrl,
        options: dio_pkg.Options(
          headers: {
            "Authorization": "Bearer $token",
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearFields();
        Get.snackbar(
          'Success',
          'Work details added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.offNamed('/employee');
      } else {
        errorMessage.value = 'Failed to update task: ${response.statusCode}';
        isLoading.value = false;
      }
    } on dio_pkg.DioException catch (dioError) {
      String errorMsg = 'Error updating task';

      if (dioError.response?.data != null &&
          dioError.response?.data is Map &&
          dioError.response?.data['message'] != null) {
        errorMsg = dioError.response?.data['message'];
      } else if (dioError.type == dio_pkg.DioExceptionType.connectionTimeout) {
        errorMsg = "Connection timeout. Please check your internet connection.";
      } else if (dioError.type == dio_pkg.DioExceptionType.receiveTimeout) {
        errorMsg = "Server is taking too long to respond. The file might be too large.";
      } else if (dioError.type == dio_pkg.DioExceptionType.sendTimeout) {
        errorMsg = "Sending request is taking too long. The file might be too large.";
      } else if (dioError.type == dio_pkg.DioExceptionType.badResponse) {
        errorMsg = "Server responded with an error: ${dioError.response?.statusCode}";
      } else {
        errorMsg = "Network error occurred. Please check your connection.";
      }

      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 5),
      );

      errorMessage.value = errorMsg;
      isLoading.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );

      errorMessage.value = 'Error updating task: $e';
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'due':
        return Color(0xffFFC20A);
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'delayed':
        return const Color.fromARGB(255, 160, 35, 26);
      case 'warning':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void showAddCollaboratorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Collaborator'),
        content: Obx(() => isLoadingEmployees.value
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: employees.isEmpty
                    ? const Center(child: Text('No employees available'))
                    : ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final employee = employees[index];
                          final username = employee['username'] ?? 'Unknown';
                          final isSelected = selectedCollaborators.any(
                            (collab) => collab['_id'] == employee['_id'],
                          );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? Colors.green : Colors.black,
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(username),
                            selected: isSelected,
                            onTap: () {
                              Get.back(result: employee);
                            },
                          );
                        },
                      ),
              )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    ).then((selectedEmployee) {
      if (selectedEmployee != null) {
        final alreadyExists = selectedCollaborators.any(
          (collab) => collab['_id'] == selectedEmployee['_id'],
        );

        if (!alreadyExists) {
          selectedCollaborators.add(selectedEmployee);
          addCollaboratorToBackend(selectedEmployee['_id']);
        } else {
          selectedCollaborators.removeWhere(
            (collab) => collab['_id'] == selectedEmployee['_id'],
          );
        }
      }
    });
  }

  void removeCollaborator(Map<String, dynamic> collaborator) {
    selectedCollaborators.removeWhere(
      (collab) => collab['_id'] == collaborator['_id'],
    );
  }
}
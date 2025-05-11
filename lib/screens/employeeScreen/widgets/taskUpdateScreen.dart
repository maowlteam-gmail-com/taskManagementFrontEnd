import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path; // Import GetX package

class TaskUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskUpdateScreen({super.key, required this.task});

  @override
  State<TaskUpdateScreen> createState() => _TaskUpdateScreenState();
}

class _TaskUpdateScreenState extends State<TaskUpdateScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final List<Map<String, dynamic>> _selectedCollaborators = [];
  bool _isLoading = false;
  bool _isLoadingEmployees = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _employees = [];

  final ValueNotifier<bool> isFileValid = ValueNotifier(true);
  final ValueNotifier<PlatformFile?> selectedFile = ValueNotifier(null);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

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

  // Get the selected file name
  String? getFileName() {
    return selectedFile.value?.name;
  }

  // Get file path
  String? getFilePath() {
    return selectedFile.value?.path;
  }

  // Get file as bytes
  Uint8List? getFileBytes() {
    return selectedFile.value?.bytes;
  }

  // Get PDF file name specifically (for compatibility with your existing code)
  String? getPdfFileName() {
    return getFileName();
  }

  // Pick a file from device
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
          errorMessage.value = 'File size must be less than 10MB';
          return;
        }

        // Check file extension
        final extension = path
            .extension(file.name)
            .toLowerCase()
            .replaceAll('.', '');
        if (!supportedFileTypes.contains(extension)) {
          isFileValid.value = false;
          errorMessage.value = 'Unsupported file type';
          return;
        }

        // File is valid
        selectedFile.value = file;
        isFileValid.value = true;
        errorMessage.value = null;
      }
    } catch (e) {
      isFileValid.value = false;
      errorMessage.value = 'Error picking file: $e';
    }
  }

  // Clear selected file
  void clearFile() {
    selectedFile.value = null;
    isFileValid.value = true;
    errorMessage.value = null;
  }

  // Helper function to truncate long file names (called in your widget)
  String _getFileName(String fileName) {
    if (fileName.length <= 30) return fileName;

    final extension = path.extension(fileName);
    final nameWithoutExtension = path.basenameWithoutExtension(fileName);

    if (nameWithoutExtension.length <= 25) return fileName;

    return '${nameWithoutExtension.substring(0, 25)}...$extension';
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
    });

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found';
          _isLoadingEmployees = false;
        });
        return;
      }

      final dio = dio_pkg.Dio();
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
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final employeeList = responseData['data'] as List;
          setState(() {
            _employees =
                employeeList.map((e) => e as Map<String, dynamic>).toList();
            _isLoadingEmployees = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid response format';
            _isLoadingEmployees = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load employees: ${response.statusCode}';
          _isLoadingEmployees = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching employees: $e';
        _isLoadingEmployees = false;
      });
    }
  }

  // Report warning function
  Future<void> _reportWarning() async {
    final taskId = widget.task['_id'];

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: Text('Are You Stacked?'),
        content: Text('Do you want to report a warning for this task?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close the dialog

              setState(() {
                _isLoading = true;
              });

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
                  setState(() {
                    _isLoading = false;
                  });
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
                    duration: Duration(seconds: 3),
                  );

                  // Navigate back to employee screen
                  await Future.delayed(Duration(seconds: 1));
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
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _addCollaboratorToBackend(String collaboratorId) async {
    final taskId = widget.task['_id'];
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
        duration: Duration(seconds: 3),
      );
       Get.offNamed('/employee');
      // Get.offNamed('/employee');
        print('Collaborator added to backend');
      } else {
            
        print('Failed to add collaborator: ${response.statusCode}');
          Get.snackbar(
        'Failure',
        'Failed to add collaborator',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
       //  Get.offNamed('/employee');
      }
    } catch (e) {
        Get.snackbar(
        'error',
        'Error to add collaborator',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print('Error adding collaborator: $e');
    }
  }

  // Clear text fields method
  void _clearFields() {
    _descriptionController.clear();
    _hoursController.clear();
    setState(() {
      _selectedCollaborators.clear();
    });
  }

  Future<void> _submitWorkDetails() async {
  // Validate input fields
  if (_descriptionController.text.trim().isEmpty) {
    Get.snackbar(
      'Error',
      'Please enter work description',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
    );
    return;
  }

  if (_hoursController.text.trim().isEmpty) {
    Get.snackbar(
      'Error',
      'Please enter hours spent',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
    );
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      setState(() {
        _errorMessage = 'Authentication token not found';
        _isLoading = false;
      });
      return;
    }

    final taskId = widget.task['_id'];
    final apiUrl = '${dotenv.env['BASE_URL']}/api/tasks/addWorkDetails/$taskId';
    
    // Debug URL to check if it's correctly formed
    print('Making request to: $apiUrl');
    
    // Create FormData for multipart request with proper encoding
    final dio_pkg.FormData formData = dio_pkg.FormData();

    // Add text fields - making sure to encode strings properly
    formData.fields.add(MapEntry('description', _descriptionController.text));
    formData.fields.add(MapEntry('hours_spent', _hoursController.text));
    formData.fields.add(MapEntry('date', DateTime.now().toIso8601String()));
    
    // Handle collaborators more carefully
    if (_selectedCollaborators.isNotEmpty) {
      final collabList = _selectedCollaborators.map((collab) => {
        "_id": collab['_id'],
        "username": collab['username'],
      }).toList();
      
      // Use safe encoding for the collaborators
      formData.fields.add(MapEntry('collaborators', jsonEncode(collabList)));
    } else {
      formData.fields.add(MapEntry('collaborators', '[]'));
    }

    // Handle file upload more carefully
    if (selectedFile.value != null) {
      final file = selectedFile.value!;
      final String fileName = file.name;
      
      // Get a safe MIME type
      String mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      print('File name: $fileName, MIME type: $mimeType');

      try {
        if (kIsWeb && file.bytes != null) {
          // For Web platform - handle potential errors
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
          // For Mobile/Desktop platforms - handle potential errors
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
        print('Error adding file to form data: $fileError');
        // Continue with submission even if file attachment fails
        Get.snackbar(
          'Warning',
          'There was an issue with the file attachment, continuing without it',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      }
    }

    // Configure Dio with proper timeout settings
    final dioClient = dio_pkg.Dio(dio_pkg.BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
    
    // Add logging interceptor for debugging
    dioClient.interceptors.add(dio_pkg.LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
    
    // Make the API call
    final response = await dioClient.post(
      apiUrl,  // Use the previously defined URL
      options: dio_pkg.Options(
        headers: {
          "Authorization": "Bearer $token",
          // Don't set content-type manually for multipart/form-data
        },
        // Add retry options
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Clear fields first
      _clearFields();

      // Show success message
      Get.snackbar(
        'Success',
        'Work details added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Navigate back to employee page
      Get.offNamed('/employee');
    } else {
      setState(() {
        _errorMessage = 'Failed to update task: ${response.statusCode}';
        _isLoading = false;
      });
    }
  } on dio_pkg.DioException catch (dioError) {
    print('DioError: ${dioError.toString()}');
    print('Response data: ${dioError.response?.data}');
    
    String errorMsg = 'Error updating task';
    
    // Provide more specific error messages based on error type
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

    // Use GetX snackbar for user-friendly error messages
    Get.snackbar(
      'Error',
      errorMsg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      duration: Duration(seconds: 5),
    );

    setState(() {
      _errorMessage = errorMsg;
      _isLoading = false;
    });
  } catch (e) {
    print('General error: $e');
    
    Get.snackbar(
      'Error',
      'An unexpected error occurred',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
    );
    
    setState(() {
      _errorMessage = 'Error updating task: $e';
      _isLoading = false;
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddCollaboratorDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Add Collaborator'),
        content:
            _isLoadingEmployees
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.maxFinite,
                  height: 300.h,
                  child:
                      _employees.isEmpty
                          ? Center(child: Text('No employees available'))
                          : ListView.builder(
                            itemCount: _employees.length,
                            itemBuilder: (context, index) {
                              final employee = _employees[index];
                              final username =
                                  employee['username'] ?? 'Unknown';
                              final isSelected = _selectedCollaborators.any(
                                (collab) => collab['_id'] == employee['_id'],
                              );

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isSelected ? Colors.green : Colors.black,
                                  child: Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(username),
                                selected: isSelected,
                                onTap: () {
                                  Get.back(
                                    result: employee,
                                  ); // Using GetX navigation
                                },
                              );
                            },
                          ),
                ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    ).then((selectedEmployee) {
      if (selectedEmployee != null) {
        final alreadyExists = _selectedCollaborators.any(
          (collab) => collab['_id'] == selectedEmployee['_id'],
        );

        setState(() {
          if (!alreadyExists) {
            _selectedCollaborators.add(selectedEmployee);
            _addCollaboratorToBackend(selectedEmployee['_id']);
          } else {
            _selectedCollaborators.removeWhere(
              (collab) => collab['_id'] == selectedEmployee['_id'],
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskName = widget.task['task_name'] ?? 'Unnamed Task';
    final today = DateFormat('MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task Progress'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(), // Using GetX navigation
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: Color(0xff333333),
                    borderRadius: BorderRadius.circular(12.sp),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  taskName,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Today: $today',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Warning report button
                          ElevatedButton.icon(
                            onPressed: _reportWarning,
                            icon: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Report Warning',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  'Work Progress Details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _descriptionController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Describe what you worked on today...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'Hours Spent',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter hours worked',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),

                SizedBox(height: 24.h),
                buildFilePicker(),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitWorkDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Submit Update',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                  ),
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Collaborators',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle),
                      color: Colors.black,
                      onPressed: _showAddCollaboratorDialog,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                if (_selectedCollaborators.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        'No collaborators added',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children:
                        _selectedCollaborators.map((collaborator) {
                          final username =
                              collaborator['username'] ?? 'Unknown';
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Text(
                                username.isNotEmpty
                                    ? username[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            label: Text(username),
                            deleteIcon: Icon(Icons.close, size: 16.sp),
                            onDeleted: () {
                              setState(() {
                                _selectedCollaborators.removeWhere(
                                  (collab) =>
                                      collab['_id'] == collaborator['_id'],
                                );
                              });
                            },
                          );
                        }).toList(),
                  ),

                SizedBox(height: 16.h),

                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Upload your File',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        ValueListenableBuilder(
          valueListenable: selectedFile,
          builder: (context, selectedFile, _) {
            return ValueListenableBuilder(
              valueListenable: isFileValid,
              builder: (context, isFileValid, _) {
                return InkWell(
                  onTap: () => pickFile(),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: 60.h,
                      maxHeight: 80.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isFileValid ? Colors.grey.shade300 : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child:
                        getFileName() != null
                            ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Show different icons based on file type
                                _getFileTypeIcon(getFileName() ?? ''),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    _getFileName(getFileName() ?? ''),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                InkWell(
                                  onTap: () => clearFile(),
                                  child: Icon(
                                    Icons.close,
                                    size: 20.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            )
                            : SizedBox(
                              height: 44.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 20.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Click to upload File',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                );
              },
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: isFileValid,
          builder: (context, isFileValid, _) {
            return ValueListenableBuilder(
              valueListenable: errorMessage,
              builder: (context, errorMessage, _) {
                if (!isFileValid) {
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 5.w),
                    child: Text(
                      errorMessage ?? 'File is required',
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  );
                }
                return SizedBox();
              },
            );
          },
        ),
      ],
    );
  }

  // Function to get the appropriate icon based on file type
  Widget _getFileTypeIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.pdf':
        return Icon(Icons.picture_as_pdf, size: 24.sp, color: Colors.red);
      case '.doc':
      case '.docx':
        return Icon(Icons.description, size: 24.sp, color: Colors.blue);
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icon(Icons.image, size: 24.sp, color: Colors.green);
      default:
        return Icon(Icons.file_present, size: 24.sp, color: Colors.blue);
    }
  }
}

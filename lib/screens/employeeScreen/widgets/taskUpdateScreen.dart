import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart'; // Import GetX package

class TaskUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskUpdateScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

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

      final dio = Dio();
      final response = await dio.get(
        'http://localhost:5001/api/getEmployees',
        options: Options(
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
          setState(() {
            _employees = employeeList.map((e) => e as Map<String, dynamic>).toList();
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

  Future<void> _addCollaboratorToBackend(String collaboratorId) async {
    final taskId = widget.task['_id'];
    final box = GetStorage();
    final token = box.read('token');

    try {
      final dio = Dio();
      final response = await dio.patch(
        'http://localhost:5001/api/tasks/addCollaborator/$taskId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          "collaboratorId": collaboratorId,
        },
      );

      if (response.statusCode == 200) {
        print('Collaborator added to backend');
      } else {
        print('Failed to add collaborator: ${response.statusCode}');
      }
    } catch (e) {
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

      final collaborators = _selectedCollaborators.map((collab) => {
        "_id": collab['_id'],
        "username": collab['username']
      }).toList();

      final hoursSpent = int.tryParse(_hoursController.text) ?? 0;

      final requestData = {
        "description": _descriptionController.text,
        "hours_spent": hoursSpent,
        "collaborators": collaborators,
        "date": DateTime.now().toIso8601String(),
      };

      final dio = Dio();
      final response = await dio.post(
        'http://localhost:5001/api/tasks/addWorkDetails/$taskId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear fields first
        _clearFields();
        
        // Show success message with a short delay to ensure UI is updated first
        await Future.delayed(Duration(milliseconds: 100));
        
        Get.snackbar(
          'Success',
          'Work details added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        //
        
        // Navigate back with the result after a brief delay to allow snackbar to be visible
        await Future.delayed(Duration(seconds: 1));

       Get.offNamed('/employee');
      } else {
        setState(() {
          _errorMessage = 'Failed to update task: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on DioException catch (dioError) {
      String errorMsg = 'Error updating task';
      if (dioError.response?.data != null &&
          dioError.response?.data is Map &&
          dioError.response?.data['message'] != null) {
        errorMsg = dioError.response?.data['message'];
      } else if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        errorMsg = "Connection timeout. Is the server running?";
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
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

  void _showAddCollaboratorDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Add Collaborator'),
        content: _isLoadingEmployees
            ? Center(child: CircularProgressIndicator())
            : Container(
                width: double.maxFinite,
                height: 300.h,
                child: _employees.isEmpty
                    ? Center(child: Text('No employees available'))
                    : ListView.builder(
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          final username = employee['username'] ?? 'Unknown';
                          final isSelected = _selectedCollaborators.any(
                            (collab) => collab['_id'] == employee['_id'],
                          );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? Colors.green : Colors.black,
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : '?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(username),
                            selected: isSelected,
                            onTap: () {
                              Get.back(result: employee); // Using GetX navigation
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
                      Text(
                        taskName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
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
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _selectedCollaborators.map((collaborator) {
                      final username = collaborator['username'] ?? 'Unknown';
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            style: TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        ),
                        label: Text(username),
                        deleteIcon: Icon(Icons.close, size: 16.sp),
                        onDeleted: () {
                          setState(() {
                            _selectedCollaborators.removeWhere(
                              (collab) => collab['_id'] == collaborator['_id'],
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
          
                SizedBox(height: 32.h),
          
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
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Update', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
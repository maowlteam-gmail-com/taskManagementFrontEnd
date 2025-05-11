import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

class RequirementModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String message;
  final String pdfFile;
  final String status;
  final Map<String, dynamic>? assignedTo;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  RequirementModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.message,
    required this.pdfFile,
    required this.status,
    this.assignedTo,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RequirementModel.fromJson(Map<String, dynamic> json) {
    return RequirementModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      pdfFile: json['pdfFile'] ?? '',
      status: json['status'] ?? '',
      assignedTo: json['assignedTo'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class EmployeeModel {
  final String id;
  final String username;
  final String role;
  final bool isActive;
  final bool deleteStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeModel({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    required this.deleteStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
      deleteStatus: json['delete_status'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class HomeController extends GetxController {
  final box = GetStorage();
  final dio = Dio();
  
  var isLoading = true.obs;
  var requirements = <RequirementModel>[].obs;
  var employees = <EmployeeModel>[].obs;
  var error = ''.obs;
  var downloadProgress = 0.0.obs;
  var isDownloading = false.obs;
  var isAssigning = false.obs;
  var isLoadingEmployees = false.obs;
  
  @override
  void onInit() {
    super.onInit();
 
      fetchRequirements();

  }

  Future<void> fetchRequirements() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final token = box.read('token');
      final response = await dio.get(
        '${dotenv.env['BASE_URL']}/requirement/filtered',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> requirementsData = data['data'];
          requirements.value = requirementsData
              .map((item) => RequirementModel.fromJson(item))
              .toList();
        } else {
          error.value = 'Failed to load requirements';
        }
      } else {
        error.value = 'Failed to load requirements';
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> fetchEmployees() async {
  isLoadingEmployees.value = true;
  
  try {
    final token = box.read('token');
    final response = await dio.get(
      '${dotenv.env['BASE_URL']}/api/getEmployees',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
    
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == true) {
        final List<dynamic> employeesData = data['data'];
        employees.value = employeesData
            .map((item) => EmployeeModel.fromJson(item))
            .toList();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load employees',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Failed to load employees',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'Error loading employees: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
  } finally {
    isLoadingEmployees.value = false;
  }
}
  
  Future<void> downloadPdf(String requirementId, String fileName) async {
    isDownloading.value = true;
    downloadProgress.value = 0.0;
    
    try {
      final token = box.read('token');
      final response = await dio.get(
        '${dotenv.env['BASE_URL']}/requirement/$requirementId/download',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );
      
      if (response.statusCode == 200) {
        // Create a blob from the PDF data
        final blob = html.Blob([response.data]);
        // Create a URL for the blob
        final url = html.Url.createObjectUrlFromBlob(blob);
        // Create an anchor element
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = fileName;
          
        // Trigger download
        anchor.click();
        
        // Clean up
        html.Url.revokeObjectUrl(url);
        
        Get.snackbar(
          'Success',
          'PDF downloaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to download PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error downloading PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }
  
  Future<void> assignRequirement(String requirementId, String employeeId) async {
    isAssigning.value = true;
    
    try {
      final token = box.read('token');
      final response = await dio.patch(
        '${dotenv.env['BASE_URL']}/requirement/$requirementId/assign',
        data: {
          "employeeId": employeeId
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      
      if (response.statusCode == 200) {
        // Refresh the requirements list
        await fetchRequirements();
        
        Get.snackbar(
          'Success',
          'Requirement assigned successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to assign requirement',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error assigning requirement: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isAssigning.value = false;
    }
  }
}
class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            _buildRequirementsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Shared Requirements',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              Text(
                controller.requirements.length.toString(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Total', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRequirementsTable() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }
        
        if (controller.requirements.isEmpty) {
          return Center(child: Text('No requirements found'));
        }

        // Use LayoutBuilder to determine screen size
        return LayoutBuilder(
          builder: (context, constraints) {
            // Check if we're on a small screen (mobile view)
            bool isMobileView = constraints.maxWidth < 600;
            
            return Column(
              children: [
                // Table Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      if (!isMobileView) ...[
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Phone',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        flex: isMobileView ? 3 : 3,
                        child: Text(
                          'Message',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      if (!isMobileView)
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ), 
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Table Body
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.requirements.length,
                    itemBuilder: (context, index) {
                      final requirement = controller.requirements[index];
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                requirement.name,
                                style: TextStyle(fontSize: isMobileView ? 16.sp : 14.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isMobileView) ...[
                              Expanded(
                                flex: 2,
                                child: Text(
                                  requirement.email,
                                  style: TextStyle(fontSize: 14.sp),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  requirement.phone,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ],
                            Expanded(
                              flex: isMobileView ? 3 : 3,
                              child: Text(
                                requirement.message,
                                style: TextStyle(fontSize: isMobileView ? 16.sp : 14.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isMobileView)
                              Expanded(
                                flex: 2,
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(requirement.createdAt),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: requirement.status == 'pending' 
                                      ? Colors.orange.shade100 
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  requirement.status.capitalizeFirst!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: requirement.status == 'pending' 
                                        ? Colors.orange.shade800 
                                        : Colors.green.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showRequirementDetails(requirement);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                    minimumSize: Size(40.w, 30.h),
                                  ),
                                  child: Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        );
      }),
    );
  }

  void _showRequirementDetails(RequirementModel requirement) {
    final controller = Get.find<HomeController>();
    
    // Fetch employees when opening the dialog
    controller.fetchEmployees();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 500.w,
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    'Requirement Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: 400.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Name', requirement.name),
                    _detailRow('Email', requirement.email),
                    _detailRow('Phone', requirement.phone),
                    _detailRow('Status', requirement.status.capitalizeFirst!),
                    _detailRow('Date', DateFormat('dd/MM/yyyy HH:mm').format(requirement.createdAt)),
                    _detailRow('Message', requirement.message),
                    
                    // Show assigned employee if any
                    if (requirement.assignedTo != null && requirement.assignedTo!.containsKey('username'))
                      _detailRow('Assigned To', requirement.assignedTo!['username']),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              
              // Action buttons in a centered row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (requirement.pdfFile.isNotEmpty)
                    Obx(() => controller.isDownloading.value 
                      ? SizedBox(
                          width: 200.w,
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: controller.downloadProgress.value,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Downloading: ${(controller.downloadProgress.value * 100).toStringAsFixed(0)}%',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            controller.downloadPdf(
                              requirement.id, 
                              requirement.pdfFile,
                            );
                          },
                          icon: Icon(Icons.file_download),
                          label: Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ),
                  SizedBox(width: 12.w),
                  if (requirement.status == 'pending')
                    Obx(() => controller.isAssigning.value
                      ? ElevatedButton.icon(
                          onPressed: null,
                          icon: SizedBox(
                            height: 12.h,
                            width: 12.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          label: Text('Processing...'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            _showAssignDialog(requirement.id);
                          },
                          icon: Icon(Icons.assignment_ind),
                          label: Text('Assign'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignDialog(String requirementId) {
    final controller = Get.find<HomeController>();
    String? selectedEmployeeId;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 400.w,
          padding: EdgeInsets.all(20.r),
          child: Obx(() {
            if (controller.isLoadingEmployees.value) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text('Loading employees...'),
                ],
              );
            }
            
            if (controller.employees.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No employees found'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Close'),
                  ),
                ],
              );
            }
            
            return StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Employee to Assign',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // Employee dropdown - uses username instead of name and email
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text('Select an employee'),
                          value: selectedEmployeeId,
                          isExpanded: true,
                          items: controller.employees.map((employee) {
                            return DropdownMenuItem<String>(
                              value: employee.id,
                              child: Text(employee.username),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedEmployeeId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel', style: TextStyle(color: Colors.black),),
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton(
                          onPressed: selectedEmployeeId == null 
                              ? null 
                              : () {
                                  Get.back(); // Close assign dialog
                                  controller.assignRequirement(
                                    requirementId, 
                                    selectedEmployeeId!,
                                  );
                                  Get.back(); // Close requirement details dialog
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Assign'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
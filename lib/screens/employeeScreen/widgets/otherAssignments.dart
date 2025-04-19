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
  final String? assignedTo;
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

class MyAssignmentsController extends GetxController {
  final box = GetStorage();
  final dio = Dio();
  
  var isLoading = true.obs;
  var requirements = <RequirementModel>[].obs;
  var error = ''.obs;
  var downloadProgress = 0.0.obs;
  var isDownloading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchMyRequirements();
  }

  Future<void> fetchMyRequirements() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final token = box.read('token');
      final response = await dio.get(
        '${dotenv.env['BASE_URL']}/requirement/my-requirements',
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
}

class OtherAssignmentsScreen extends StatelessWidget {
  final MyAssignmentsController controller = Get.put(MyAssignmentsController());

  OtherAssignmentsScreen({super.key});

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
          'My Assigned Requirements',
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
          return Center(child: Text('No requirements assigned to you'));
        }
        
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
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Message',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
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
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            requirement.email,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            requirement.phone,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            requirement.message,
                            style: TextStyle(fontSize: 14.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(requirement.createdAt),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
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
                            ],
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
      }),
    );
  }

  void _showRequirementDetails(RequirementModel requirement) {
    final controller = Get.find<MyAssignmentsController>();
    
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
                    _detailRow('Date', DateFormat('dd/MM/yyyy HH:mm').format(requirement.createdAt)),
                    _detailRow('Message', requirement.message),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              
              // Download PDF button
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
                      label: Text('Download PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ),
              SizedBox(height: 10.h),
            ],
          ),
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
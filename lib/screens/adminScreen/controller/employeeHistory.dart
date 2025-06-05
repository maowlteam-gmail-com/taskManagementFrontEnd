import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class EmployeeHistoryController extends GetxController {
  // Observable list for employee history
  RxList<Map<String, dynamic>> employeeHistory = <Map<String, dynamic>>[].obs;
  
  // Loading state
  RxBool isLoading = false.obs;
  
  // Error message
  RxString errorMessage = "".obs;
  
  // Selected employee data
  Rx<Map<String, dynamic>?> selectedEmployee = Rx<Map<String, dynamic>?>(null);
  
  final Dio _dio = Dio();
  final box = GetStorage();
  
  // Set selected employee
  void setSelectedEmployee(Map<String, dynamic> employee) {
    selectedEmployee.value = employee;
  }
  
  // Fetch employee history
  Future<void> fetchEmployeeHistory(String employeeId) async {
    isLoading.value = true;
    errorMessage.value = "";
    employeeHistory.clear();
    
    try {
      final token = box.read('token');
      
      if (token == null) {
        Get.snackbar(
          "Error",
          "Authentication token not found",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        return;
      }
      
      print('Fetching history for employee ID: $employeeId');
      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/employeeHistory/$employeeId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final responseBody = response.data as Map<String, dynamic>;
        
        if (responseBody['success'] == true && responseBody.containsKey('data')) {
          final dataList = responseBody['data'] as List;
          
          // Convert to list of maps
          final historyItems = dataList
              .map((e) => e as Map<String, dynamic>)
              .toList();
          
          // Sort by date - latest first (descending order)
          historyItems.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['date'] ?? '');
              final dateB = DateTime.parse(b['date'] ?? '');
              return dateB.compareTo(dateA); // Latest first
            } catch (e) {
              print('Error parsing dates for sorting: $e');
              return 0; // Keep original order if dates can't be parsed
            }
          });
          
          employeeHistory.value = historyItems;
        } else {
          errorMessage.value = responseBody['message'] ?? "Failed to fetch employee history";
        }
      } else {
        errorMessage.value = "Failed to load employee history: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Error fetching employee history: $e";
      print('Error fetching employee history: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Format date for display with exact date and time
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      // Format for exact date and time
      final dateFormatter = DateFormat('dd MMM yyyy');
      final timeFormatter = DateFormat('hh:mm a');
      
      final formattedDate = dateFormatter.format(date);
      final formattedTime = timeFormatter.format(date);
      
      if (difference.inDays == 0) {
        // Same day - show "Today" with time
        return 'Today at $formattedTime';
      } else if (difference.inDays == 1) {
        // Yesterday - show "Yesterday" with time
        return 'Yesterday at $formattedTime';
      } else if (difference.inDays < 7) {
        // Within a week - show day name with time
        final dayFormatter = DateFormat('EEEE');
        final dayName = dayFormatter.format(date);
        return '$dayName at $formattedTime';
      } else {
        // Older than a week - show full date with time
        return '$formattedDate at $formattedTime';
      }
    } catch (e) {
      print('Error formatting date: $e');
      return dateString; // Return original string if parsing fails
    }
  }
  
  // Get exact date without relative formatting
  String getExactDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMM yyyy, hh:mm a');
      return formatter.format(date);
    } catch (e) {
      print('Error getting exact date: $e');
      return dateString;
    }
  }
  
  // Get just the date part
  String getDateOnly(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMM yyyy');
      return formatter.format(date);
    } catch (e) {
      print('Error getting date only: $e');
      return dateString;
    }
  }
  
  // Get just the time part
  String getTimeOnly(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('hh:mm a');
      return formatter.format(date);
    } catch (e) {
      print('Error getting time only: $e');
      return dateString;
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    // Get employee data from arguments if available
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args.containsKey('employee')) {
        setSelectedEmployee(args['employee']);
        final employeeId = args['employee']['_id'] ?? '';
        if (employeeId.isNotEmpty) {
          fetchEmployeeHistory(employeeId);
        }
      }
    }
  }
}
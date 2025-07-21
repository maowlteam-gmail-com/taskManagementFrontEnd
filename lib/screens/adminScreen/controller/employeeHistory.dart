import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:maowl/util/dio_config.dart'; 
class EmployeeHistoryController extends GetxController {
  final RxList<Map<String, dynamic>> employeeHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;
  final Rx<Map<String, dynamic>?> selectedEmployee = Rx<Map<String, dynamic>?>(null);

  final Dio _dio = DioConfig.getDio();
  final box = GetStorage();

  void setSelectedEmployee(Map<String, dynamic> employee) {
    selectedEmployee.value = employee;
  }

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
      );

      if (response.statusCode == 200) {
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody['success'] == true && responseBody.containsKey('data')) {
          final dataList = responseBody['data'] as List;

          final historyItems = dataList
              .map((e) => e as Map<String, dynamic>)
              .toList();

          historyItems.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['date'] ?? '');
              final dateB = DateTime.parse(b['date'] ?? '');
              return dateB.compareTo(dateA);
            } catch (e) {
              print('Error parsing dates for sorting: $e');
              return 0;
            }
          });

          employeeHistory.value = historyItems;
        } else {
          errorMessage.value = responseBody['message'] ?? "Failed to fetch employee history";
        }
      } else {
        errorMessage.value = "Failed to load employee history: ${response.statusCode}";
      }
    } on DioException catch (e) {
      errorMessage.value = e.response?.data.toString() ?? e.message ?? 'Unknown error';
      print('Dio error: ${e.message}');
    } catch (e) {
      errorMessage.value = "Error fetching employee history: $e";
      print('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      final dateFormatter = DateFormat('dd MMM yyyy');
      final timeFormatter = DateFormat('hh:mm a');

      final formattedDate = dateFormatter.format(date);
      final formattedTime = timeFormatter.format(date);

      if (difference.inDays == 0) {
        return 'Today at $formattedTime';
      } else if (difference.inDays == 1) {
        return 'Yesterday at $formattedTime';
      } else if (difference.inDays < 7) {
        final dayFormatter = DateFormat('EEEE');
        final dayName = dayFormatter.format(date);
        return '$dayName at $formattedTime';
      } else {
        return '$formattedDate at $formattedTime';
      }
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

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

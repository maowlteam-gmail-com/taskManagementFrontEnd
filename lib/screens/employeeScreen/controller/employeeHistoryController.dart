import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:maowl/util/dio_config.dart';

class EmployeeHistoryController extends GetxController with WidgetsBindingObserver {
  final RxList<Map<String, dynamic>> employeeHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;
  final RxString currentEmployeeName = "".obs;

  final Dio _dio = DioConfig.getDio();
  final box = GetStorage();
  
  // Timer for periodic refresh
  Timer? _refreshTimer;
  
  // Static method to trigger refresh from other screens
  static void triggerRefresh() {
    try {
      if (Get.isRegistered<EmployeeHistoryController>()) {
        Get.find<EmployeeHistoryController>().refreshAfterUpdate();
      }
    } catch (e) {
      print('Error triggering refresh: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Get current employee name from storage if available
    currentEmployeeName.value = box.read('username') ?? 'Employee';
    fetchOwnHistory();
    
    // Start periodic refresh (every 30 seconds)
    _startPeriodicRefresh();
    
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Refresh when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (!isLoading.value) {
          fetchOwnHistory(showLoading: false);
        }
      });
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      // Only refresh if not currently loading
      if (!isLoading.value) {
        fetchOwnHistory(showLoading: false);
      }
    });
  }

  Future<void> fetchOwnHistory({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    errorMessage.value = "";

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

      print('Fetching own task history...');

      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/tasks/ownHistory',
      );

      if (response.statusCode == 200) {
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody['success'] == true && responseBody.containsKey('history')) {
          final historyList = responseBody['history'] as List;

          final historyItems = historyList
              .map((e) => e as Map<String, dynamic>)
              .toList();

          // Sort by date - latest first
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
          errorMessage.value = responseBody['message'] ?? "Failed to fetch task history";
        }
      } else {
        errorMessage.value = "Failed to load task history: ${response.statusCode}";
      }
    } on DioException catch (e) {
      errorMessage.value = e.response?.data.toString() ?? e.message ?? 'Unknown error';
      print('Dio error: ${e.message}');
    } catch (e) {
      errorMessage.value = "Error fetching task history: $e";
      print('Unexpected error: $e');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Method to be called from other screens after task updates
  void refreshAfterUpdate() {
    fetchOwnHistory(showLoading: false);
  }

  String formatDate(String dateString) {
    try {
      // Parse UTC date and convert to local
      final utcDate = DateTime.parse(dateString);
      final localDate = utcDate.toLocal();
      final now = DateTime.now();
      final difference = now.difference(localDate);

      final dateFormatter = DateFormat('dd MMM yyyy');
      final timeFormatter = DateFormat('hh:mm a');

      final formattedDate = dateFormatter.format(localDate);
      final formattedTime = timeFormatter.format(localDate);

      if (difference.inDays == 0) {
        return 'Today at $formattedTime';
      } else if (difference.inDays == 1) {
        return 'Yesterday at $formattedTime';
      } else if (difference.inDays < 7) {
        final dayFormatter = DateFormat('EEEE');
        final dayName = dayFormatter.format(localDate);
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
      // Parse UTC date and convert to local
      final utcDate = DateTime.parse(dateString);
      final localDate = utcDate.toLocal();
      final formatter = DateFormat('dd MMM yyyy, hh:mm a');
      return formatter.format(localDate);
    } catch (e) {
      print('Error getting exact date: $e');
      return dateString;
    }
  }

  String getDateOnly(String dateString) {
    try {
      // Parse UTC date and convert to local
      final utcDate = DateTime.parse(dateString);
      final localDate = utcDate.toLocal();
      final formatter = DateFormat('dd MMM yyyy');
      return formatter.format(localDate);
    } catch (e) {
      print('Error getting date only: $e');
      return dateString;
    }
  }

  String getTimeOnly(String dateString) {
    try {
      // Parse UTC date and convert to local
      final utcDate = DateTime.parse(dateString);
      final localDate = utcDate.toLocal();
      final formatter = DateFormat('hh:mm a');
      return formatter.format(localDate);
    } catch (e) {
      print('Error getting time only: $e');
      return dateString;
    }
  }
}
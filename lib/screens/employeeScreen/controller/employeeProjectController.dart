import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class EmployeeProjectsController extends GetxController {
  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  var selectedTask = {}.obs;
  final RxString errorMessage = ''.obs;
  final Dio _dio = Dio();
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async { 
    print("Starting fetchTasks method");
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = box.read('token');

      print(
        "Token: ${token != null ? (token.length > 10 ? token.substring(0, 10) + '...' : token) : 'null'}",
      );

      if (token == null) {
        print("Authentication failure: token is null");
        errorMessage.value = 'Authentication token not found';
        isLoading.value = false;
        return;
      }

      print("Making API request to: ${dotenv.env['BASE_URL']}/api/tasks/myTasks");

      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/tasks/myTasks',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          // Add timeout to prevent infinite waiting
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      print("API Response status code: ${response.statusCode}");
      print("API Response body type: ${response.data.runtimeType}");
      if (response.data != null) {
        print(
          "API Response first few keys: ${response.data is Map ? (response.data as Map).keys.take(5).toList() : 'Not a Map'}",
        );
      }

      if (response.statusCode == 200) {
        try {
          final responseBody = response.data as Map<String, dynamic>;

          if (responseBody.containsKey('data')) {
            if (responseBody['data'] is List) {
              print(
                "Data is a List with ${(responseBody['data'] as List).length} items",
              );
              final dataList = responseBody['data'] as List;
              tasks.value =
                  dataList.map((e) => e as Map<String, dynamic>).toList();
              print("Tasks list updated with ${tasks.length} items");
            } else {
              print(
                "'data' is not a List: ${responseBody['data'].runtimeType}",
              );
              errorMessage.value =
                  "Unexpected response format: 'data' is not a list";
            }
          } else {
            print(
              "Response doesn't contain 'data' key. Keys: ${responseBody.keys.toList()}",
            );
            errorMessage.value =
                "Unexpected response format: missing 'data' array";
          }
        } catch (e) {
          print("Error parsing response: $e");
          errorMessage.value = "Error parsing response: $e";
        }
      } else {
        print("Failed response: ${response.statusCode}");
        errorMessage.value = "Failed to load tasks: ${response.statusCode}";
      }
    } catch (e) {
      print("Exception in fetchTasks: $e");
      if (e is DioException) {
        print("DioException type: ${e.type}");
        print("DioException message: ${e.message}");
        print("DioException response: ${e.response?.data}");

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage.value =
              "Connection timeout. Please check your internet connection.";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage.value =
              "Connection error. Is the server running at ${dotenv.env['BASE_URL']}?";
        } else {
          errorMessage.value = "Error fetching tasks: ${e.message}";
        }
      } else {
        errorMessage.value = "Error fetching tasks: $e";
      }
    } finally {
      print("Setting isLoading to false");
      isLoading.value = false;
      print("Current tasks: ${tasks.length}");
      print("Current error message: ${errorMessage.value}");
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String capitalizeStatus(String status) {
    return status
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
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

  Map<String, dynamic>? getLatestWorkDetail(List<dynamic>? workDetails) {
    if (workDetails == null || workDetails.isEmpty) {
      return null;
    }

    try {
      // Sort work details by date (newest first)
      final sorted = List<Map<String, dynamic>>.from(workDetails)..sort((a, b) {
        final dateA =
            a['date'] != null
                ? DateTime.parse(a['date'].toString())
                : DateTime(1900);
        final dateB =
            b['date'] != null
                ? DateTime.parse(b['date'].toString())
                : DateTime(1900);
        return dateB.compareTo(dateA);
      });

      return sorted.first;
    } catch (e) {
      // Handle any casting or parsing errors
      return null;
    }
  }

  String getLatestDescription(Map<String, dynamic> task) {
    final workDetails = task['work_details'] as List?;
    if (workDetails == null || workDetails.isEmpty) {
      return task['description'] ?? 'No description available';
    }

    final latestWorkDetail = getLatestWorkDetail(workDetails);
    return latestWorkDetail?['description'] ??
        task['description'] ??
        'No description available';
        
  }

  void openTaskDetail(Map<String, dynamic> task) {

    Get.toNamed('/taskDetails', arguments: task);
  }
}
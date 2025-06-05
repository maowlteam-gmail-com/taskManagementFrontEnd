// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class EmployeeProjectsController extends GetxController {
//   final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
//   final RxBool isLoading = true.obs;
//   final RxString errorMessage = ''.obs;
//   final Dio _dio = Dio();
//   final box = GetStorage();

//   // Task detail and history state
//   final RxBool showTaskDetail = false.obs;
//   final Rx<Map<String, dynamic>> selectedTask = Rx<Map<String, dynamic>>({});
//   final RxList<Map<String, dynamic>> taskHistory = <Map<String, dynamic>>[].obs;
//   final RxBool isLoadingHistory = false.obs;
//   final RxString historyError = ''.obs;
//   final RxList filterWorkDetails = [].obs;

//   String? employeeId;

//   void initialize(String empId) {
//     employeeId = empId;
//     fetchTasks();
//   }

//   Future<void> fetchTasks() async {
//     if (employeeId == null) return;
    
//     isLoading.value = true;
//     errorMessage.value = '';

//     try {
//       final token = box.read('token');

//       if (token == null) {
//         errorMessage.value = 'Authentication token not found';
//         return;
//       }

//       final response = await _dio.get(
//         '${dotenv.env['BASE_URL']}/api/tasks/getTaskByUserId/$employeeId',
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $token",
//           },
//         ),
//       );

//       if (response.statusCode == 200) {
//         final responseBody = response.data as Map<String, dynamic>;

//         if (responseBody.containsKey('data') && responseBody['data'] is List) {
//           final dataList = responseBody['data'] as List;
//           tasks.value = dataList.map((e) => e as Map<String, dynamic>).toList();
//         } else {
//           errorMessage.value = "Unexpected response format: missing 'data' array";
//         }
//       } else {
//         errorMessage.value = "Failed to load tasks: ${response.statusCode}";
//       }
//     } catch (e) {
//       errorMessage.value = "Error fetching tasks: $e";
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> fetchTaskHistory(String taskId) async {
//     isLoadingHistory.value = true;
//     historyError.value = '';

//     try {
//       final token = box.read('token');

//       if (token == null) {
//         historyError.value = 'Authentication token not found';
//         return;
//       }

//       final response = await _dio.get(
//         '${dotenv.env['BASE_URL']}/api/tasks/getTaskHistory/$taskId',
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $token",
//           },
//         ),
//       );

//       if (response.statusCode == 200) {
//         final responseBody = response.data as Map<String, dynamic>;

//         if (responseBody.containsKey('history') && responseBody['history'] is List) {
//           final historyList = responseBody['history'] as List;

//           taskHistory.value = historyList.map((e) => e as Map<String, dynamic>).toList();

//           filterWorkDetails.value = taskHistory.value
//               .where((item) => item['action'] == 'work_detail_added')
//               .toList();

//           print("Work detail items: ${filterWorkDetails}");
//           print("work details length : ${filterWorkDetails.length}");
//         } else {
//           taskHistory.value = [];
//           filterWorkDetails.value = [];
//           historyError.value = "No history available for this task";
//         }
//       } else {
//         historyError.value = "Failed to load task history: ${response.statusCode}";
//       }
//     } on DioException catch (e) {
//       historyError.value = "Dio error: ${e.message}";
//     } catch (e) {
//       historyError.value = "Error fetching task history: $e";
//     } finally {
//       isLoadingHistory.value = false;
//     }
//   }

//   void viewTaskDetail(Map<String, dynamic> task) {
//     selectedTask.value = task;
//     showTaskDetail.value = true;

//     if (task.containsKey('_id')) {
//       fetchTaskHistory(task['_id']);
//     } else {
//       historyError.value = "Task ID not found";
//       taskHistory.clear();
//     }
//   }

//   void closeTaskDetail() {
//     showTaskDetail.value = false;
//   }

//   Future<void> deleteTask(String taskId) async {
//     try {
//       final token = box.read('token');

//       if (token == null) {
//         Get.snackbar(
//           'Error',
//           'Authentication token not found',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return;
//       }

//       final response = await _dio.delete(
//         '${dotenv.env['BASE_URL']}/api/tasks/deleteTask/$taskId',
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $token",
//           },
//         ),
//       );

//       if (response.statusCode == 200) {
//         tasks.removeWhere((task) => task['_id'] == taskId);
//         Get.snackbar(
//           'Success',
//           'Task deleted successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.black,
//           colorText: Colors.white,
//           duration: Duration(seconds: 2),
//         );
//       } else {
//         Get.snackbar(
//           'Error',
//           'Failed to delete task: ${response.statusCode}',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.black,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       print("Error deleting task: $e");
//       Get.snackbar(
//         'Error',
//         'Unexpected error: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   void showDeleteConfirmation(String taskId, String taskName) {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Delete Task'),
//         content: Text(
//           'Are you sure you want to delete "$taskName"? This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             style: TextButton.styleFrom(foregroundColor: Colors.grey[800]),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               deleteTask(taskId);
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.black),
//             child: Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   Map<String, dynamic>? getLatestWorkDetail(List<dynamic>? workDetails) {
//     if (workDetails == null || workDetails.isEmpty) {
//       return null;
//     }

//     final sorted = List<Map<String, dynamic>>.from(workDetails)..sort((a, b) {
//       final dateA = a['date'] != null ? DateTime.parse(a['date'].toString()) : DateTime(1900);
//       final dateB = b['date'] != null ? DateTime.parse(b['date'].toString()) : DateTime(1900);
//       return dateB.compareTo(dateA);
//     });

//     return sorted.first;
//   }

//   Map<String, dynamic>? getLatestFile(List<dynamic>? files) {
//     if (files == null || files.isEmpty) return null;

//     files.sort((a, b) {
//       final DateTime dateA = DateTime.parse(a['uploaded_at']);
//       final DateTime dateB = DateTime.parse(b['uploaded_at']);
//       return dateB.compareTo(dateA);
//     });

//     return files.first as Map<String, dynamic>;
//   }
// }
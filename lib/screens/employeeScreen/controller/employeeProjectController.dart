import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:maowl/colors/app_colors.dart';
import 'package:maowl/util/dio_config.dart';

class EmployeeProjectsController extends GetxController {
  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  var selectedTask = {}.obs;
  final RxString errorMessage = ''.obs;
  final Dio _dio = DioConfig.getDio();
  final box = GetStorage();

  final RxInt selectedTabIndex = 0.obs;
  final RxList<Map<String, dynamic>> filteredTasks =
      <Map<String, dynamic>>[].obs;
  String currentUserId = '';

  @override
  void onInit() {
    super.onInit();

    // Debug: Print all stored user data
    print("🔍 === USER DATA DEBUG ===");
    print("🔍 All keys in GetStorage: ${box.getKeys()}");

    // Try different possible keys for user ID
    final possibleKeys = ['user_id', '_id', 'userId', 'id', 'currentUserId'];
    for (String key in possibleKeys) {
      final value = box.read(key);
      print("🔍 $key: $value");
    }

    // Check if there's a user object stored
    final userObj = box.read('user');
    print("🔍 user object: $userObj");

    // FIX: Read from '_id' instead of 'user_id' since LoginController stores it as '_id'
    currentUserId = box.read('_id') ?? '';
    print("🔍 Final currentUserId: '$currentUserId'");
    print("🔍 CurrentUserId type: ${currentUserId.runtimeType}");
    print("🔍 CurrentUserId isEmpty: ${currentUserId.isEmpty}");
    print("🔍 =========================");

    fetchTasks();
  }

  void filterTasks() {
    print("🔍 Starting filterTasks - Selected tab: ${selectedTabIndex.value}");
    print("🔍 Total tasks: ${tasks.length}");
    print("🔍 Current user ID: '$currentUserId'");

    // Debug: Print all available user IDs in tasks
    print("🔍 All user IDs in tasks:");
    for (var task in tasks) {
      print("🔍 Task: ${task['task_name']}");
      print(
        "🔍   Created by: ${task['created_by']?['_id']} (${task['created_by']?['username']})",
      );
      print(
        "🔍   Assigned to: ${task['assigned_to']?['_id']} (${task['assigned_to']?['username']})",
      );
      print("🔍   Collaborators: ${task['collaborators']}");
    }

    if (selectedTabIndex.value == 0) {
      // Show tasks created by current user (including completed tasks)
      print("🔍 Filtering for CREATED tasks...");
      filteredTasks.value =
          tasks.where((task) {
            final createdBy = task['created_by'];
            if (createdBy != null && createdBy['_id'] != null) {
              final createdById = createdBy['_id'].toString().trim();
              final currentUserIdTrimmed = currentUserId.toString().trim();
              final match = createdById == currentUserIdTrimmed;
              print(
                "🔍 Task '${task['task_name']}': Created by '$createdById' == '$currentUserIdTrimmed' = $match",
              );
              return match;
            }
            return false;
          }).toList();
    } else {
      // Show tasks where user is EITHER assigned OR collaborator (or both) - EXCLUDE completed tasks
      print(
        "🔍 Filtering for ASSIGNED tasks (assignee OR collaborator) - excluding completed tasks...",
      );
      filteredTasks.value =
          tasks.where((task) {
            final assignedTo = task['assigned_to'];
            final collaborators = task['collaborators'] as List?;
            final taskStatus = task['status']?.toString().toLowerCase() ?? '';
            final lastActiveUser = task['last_active_user'];
            debugPrint("Task ${task['task_name']} editable by $lastActiveUser");

            // First check if task is completed - if so, exclude it from Assigned tab
            if (taskStatus == 'completed') {
              print(
                "🔍 Task '${task['task_name']}': Status is completed - excluding from Assigned tab",
              );
              return false;
            }

            // Check if user is the main assignee
            bool isAssignee = false;
            if (assignedTo != null && assignedTo['_id'] != null) {
              final assignedToId = assignedTo['_id'].toString().trim();
              final currentUserIdTrimmed = currentUserId.toString().trim();
              isAssignee = assignedToId == currentUserIdTrimmed;
            }

            // // Check if user is a collaborator
            // bool isCollaborator = false;
            // if (collaborators != null && collaborators.isNotEmpty) {
            //   for (var collaborator in collaborators) {
            //     if (collaborator != null && collaborator['_id'] != null) {
            //       final collaboratorId = collaborator['_id'].toString().trim();
            //       final currentUserIdTrimmed = currentUserId.toString().trim();
            //       if (collaboratorId == currentUserIdTrimmed) {
            //         isCollaborator = true;
            //         break;
            //       }
            //     }
            //   }
            // }

            // Check if any collaborator exist and if the last editor is user
            bool match = false;
            bool isCollaborator = false;
            if (lastActiveUser != null) {
              isCollaborator =
                  lastActiveUser.toString().trim() ==
                  currentUserId.toString().trim();
              match = isCollaborator;
              debugPrint("Collab: $isCollaborator $match");
            } else {
              match = isAssignee;
              debugPrint("Assign: $isAssignee $match");
            }
            debugPrint("Match: $match");

            print("🔍 Task '${task['task_name']}': ");
            print("🔍   - Status: $taskStatus");
            print("🔍   - Is Assignee: $isAssignee");
            print("🔍   - Is Collaborator: $isCollaborator");
            print("🔍   - Match (either/both and not completed): $match");

            return match;
          }).toList();
    }

    print("🔍 Filtered tasks count: ${filteredTasks.length}");

    // Additional debugging - show what we found
    if (filteredTasks.isNotEmpty) {
      print("🔍 Found tasks:");
      for (var task in filteredTasks) {
        print("🔍   - ${task['task_name']} (Status: ${task['status']})");
      }
    } else {
      print("🔍 No tasks found for current filter");
      if (selectedTabIndex.value == 1) {
        print("🔍 Possible reasons for Assigned tab:");
        print("🔍   1. User is not assignee or collaborator for any task");
        print("🔍   2. All assigned tasks are completed (filtered out)");
        print(
          "🔍   3. Check if user ID matches exactly (including case sensitivity)",
        );
        print("🔍   4. Check if user ID is stored correctly in GetStorage");
        print(
          "🔍   5. Verify API response structure for assigned_to and collaborators",
        );
      }
    }
  }

  void switchTab(int index) {
    selectedTabIndex.value = index;
    filterTasks();
  }

  Future<void> fetchTasks() async {
    print("Starting fetchTasks method");
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("BASE_URL not defined in .env");
      }

      final response = await _dio.get(
        '$baseUrl/api/tasks/myTasks',
        options: Options(
          headers: {"Content-Type": "application/json"},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      print("API Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = response.data as Map<String, dynamic>;
        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          final dataList = responseBody['data'] as List;
          tasks.value = dataList.map((e) => e as Map<String, dynamic>).toList();

          // Debug: Print sample task structure
          if (tasks.isNotEmpty) {
            print("🔍 Sample task structure:");
            final sampleTask = tasks.first;
            print("🔍 Created by: ${sampleTask['created_by']}");
            print("🔍 Assigned to: ${sampleTask['assigned_to']}");
          }

          filterTasks(); // Filter tasks after fetching
          print("Tasks list updated with ${tasks.length} items");
        }
      } else {
        errorMessage.value = "Failed to load tasks: ${response.statusCode}";
        print("Error: ${errorMessage.value}");
      }
    } on DioException catch (e) {
      print("DioException: ${e.message}");
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage.value =
              "Connection timeout. Please check your internet.";
          break;
        case DioExceptionType.connectionError:
          errorMessage.value = "Connection error. Please try again.";
          break;
        default:
          errorMessage.value = "Failed to fetch tasks: ${e.message}";
      }
    } catch (e) {
      print("Other Exception: $e");
      errorMessage.value = "Unexpected error: $e";
    } finally {
      isLoading.value = false;
      print("fetchTasks done. Tasks count: ${tasks.length}");
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
        return AppColors.pendingColor;
      case 'due':
        return AppColors.dueColor;
      case 'in progress':
        return AppColors.inProgressColor;
      case 'completed':
        return AppColors.completedColor;
      case 'delayed':
        return AppColors.delayedColor;
      case 'warning':
        return AppColors.warningColor;
      default:
        return AppColors.inProgressColor;
    }
  }

  Map<String, dynamic>? getLatestWorkDetail(List<dynamic>? workDetails) {
    if (workDetails == null || workDetails.isEmpty) return null;

    try {
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

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AdminScreenController extends GetxController {
  // Observable selected option
  Rx<String> selectedOption = "".obs;

  // Add admin name as an observable
  RxString adminName = "".obs;

  // Method to set the selected option
  void setSelectedOption(String option) {
    selectedOption.value = option;
  }

  // Method to set admin name and persist it
  void setAdminName(String name) {
    adminName.value = name;
    // Store admin name in local storage for persistence
    box.write('adminName', name);
  }

  // List of teams
  RxList<Map<String, dynamic>> teamsList = <Map<String, dynamic>>[].obs;

  // List of employees
  RxList<Map<String, dynamic>> employees = <Map<String, dynamic>>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Error message
  RxString errorMessage = "".obs;

  // Selected employee
  Rx<Map<String, dynamic>?> selectedEmployee = Rx<Map<String, dynamic>?>(null);

  final Dio _dio = Dio();
  final box = GetStorage();

  // Add a new team
  void addTeam(Map<String, dynamic> teamData) {
    teamsList.add(teamData);
  }

  // Method to load admin name from storage or fetch from API
  Future<void> loadAdminName() async {
    // First try to get from local storage
    String? storedAdminName = box.read('adminName');
    
    if (storedAdminName != null && storedAdminName.isNotEmpty) {
      adminName.value = storedAdminName;
      return;
    }

    // If not in storage, try to get from arguments
    if (Get.arguments != null) {
      String nameFromArgs = Get.arguments.toString();
      setAdminName(nameFromArgs);
      return;
    }

    // If neither available, fetch from API using the current user's token
    await fetchAdminProfile();
  }

  // Fetch admin profile information
  Future<void> fetchAdminProfile() async {
    try {
      final token = box.read('token');
      
      if (token == null) {
        print('No token found for fetching admin profile');
        return;
      }

      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/profile', // Adjust endpoint as needed
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final profileData = response.data;
        if (profileData['username'] != null) {
          setAdminName(profileData['username']);
        } else if (profileData['name'] != null) {
          setAdminName(profileData['name']);
        }
      }
    } catch (e) {
      print('Error fetching admin profile: $e');
      // Fallback to a default name or leave empty
      if (adminName.value.isEmpty) {
        adminName.value = 'Admin'; // Default fallback
      }
    }
  }

  // Fetch employees
  Future<void> fetchEmployees() async {
    isLoading.value = true;
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

      print('token : $token');
      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/getEmployees',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // Extract the 'data' array from the response
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          final dataList = responseBody['data'] as List;
          employees.value =
              dataList
                  .map((e) => e as Map<String, dynamic>)
                  .where(
                    (emp) => emp['role'] != 'admin',
                  ) // Filter out admin users
                  .toList();
        } else {
          errorMessage.value =
              "Unexpected response format: missing 'data' array";
        }
      } else {
        errorMessage.value = "Failed to load employees: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Error fetching employees: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // Rename employee
  Future<bool> renameEmployee(
    String employeeId,
    String currentUsername,
    String newUsername,
  ) async {
    isLoading.value = true;
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
        return false;
      }

      print('token : $token');
      final response = await _dio.patch(
        '${dotenv.env['BASE_URL']}/api/renameEmployee',
        data: {
          'username': currentUsername,
          'newUsername': newUsername,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // Update the local list with new username
        final index = employees.indexWhere((emp) => emp['_id'] == employeeId);
        if (index != -1) {
          employees[index]['username'] = newUsername;
          employees.refresh();
        }
        
        Get.snackbar(
          "Success",
          "Employee username updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        return true;
      } else {
        Get.snackbar(
          "Failed",
          "Failed to rename employee: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        errorMessage.value =
            "Failed to rename employee: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Error renaming employee: $e";
      Get.snackbar(
        "Error",
        "Error renaming employee: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update employee password
  Future<bool> updateEmployeePassword(
    String employeeId,
    String newPassword,
  ) async {
    isLoading.value = true;
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
        return false;
      }

      print('token : $token');
      final response = await _dio.put(
        '${dotenv.env['BASE_URL']}/api/updateEmployee/$employeeId',
        data: {'password': newPassword},
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // Update the local list - using _id instead of id
        final index = employees.indexWhere((emp) => emp['_id'] == employeeId);
        if (index != -1) {
          employees[index]['password'] = newPassword;
          employees.refresh();
        }
        Get.snackbar(
          "Success",
          "Password Updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        return true;
      } else {
        Get.snackbar(
          "Failed",
          "Failed to update password: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        errorMessage.value =
            "Failed to update password: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Error updating password: $e";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete employee
  Future<bool> deleteEmployee(String employeeId) async {
    isLoading.value = true;
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
        return false;
      }

      final response = await _dio.delete(
        '${dotenv.env['BASE_URL']}/api/deleteEmployee/$employeeId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // Remove the employee from the local list
        employees.removeWhere((emp) => emp['_id'] == employeeId);
        employees.refresh();

        Get.snackbar(
          "Success",
          "Employee deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        return true;
      } else {
        Get.snackbar(
          "Failed",
          "Failed to delete employee: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        errorMessage.value =
            "Failed to delete employee: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Error deleting employee: $e";
      Get.snackbar(
        "Error",
        "Error deleting employee: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  //logout
  Future<void> logout() async {
    isLoading.value = true;
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

      final response = await _dio.post(
        '${dotenv.env['BASE_URL']}/api/logout',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        // Clear token and other user data including adminName
        box.remove('token');
        box.remove('userId');
        box.remove('userName');
        box.remove('adminName'); // Clear stored admin name
        
        // Show success message
        Get.snackbar(
          "Success",
          "Logged out successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
        
        // Navigate to login screen
        Get.offAllNamed('/mainsite');
      } else {
        errorMessage.value = "Failed to logout: ${response.statusCode}";
        Get.snackbar(
          "Error",
          "Failed to logout: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = "Error during logout: $e";
      Get.snackbar(
        "Error",
        "Error during logout: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Set selected employee
  void setSelectedEmployee(Map<String, dynamic> employee) {
    selectedEmployee.value = employee;
  }

  @override
  void onInit() async {
    super.onInit();
    
    // Load admin name from storage or fetch it
    await loadAdminName();

    // Initial fetch of employees
    fetchEmployees();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/functions/common_functions.dart';
import 'package:maowl/util/dio_config.dart';

class AdminScreenController extends GetxController {
  // Observable selected option
  Rx<String> selectedOption = "".obs;

  // Add admin name as an observable
  RxString adminName = "".obs;

  // Method to set the selected option
  void setSelectedOption(String option) => selectedOption.value = option;

  // Method to set admin name and persist it
  void setAdminName(String name) {
    adminName.value = name;
    box.write('adminName', name);
  }

  RxList<Map<String, dynamic>> teamsList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> employees = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredEmployees = <Map<String, dynamic>>[].obs;
  RxString selectedDesignation = "All".obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;
  Rx<Map<String, dynamic>?> selectedEmployee = Rx<Map<String, dynamic>?>(null);

  final Dio _dio = DioConfig.getDio(); // globally configured Dio
  final box = GetStorage();

  void addTeam(Map<String, dynamic> teamData) {
    teamsList.add(teamData);
  }

  void selectDesignation(String designation) {
    selectedDesignation.value = designation;
    filterEmployeesByDesignation();
  }

  void filterEmployeesByDesignation() {
    if (selectedDesignation.value == "All") {
      filteredEmployees.assignAll(employees);
    } else {
      filteredEmployees.assignAll(
        employees
            .where(
              (emp) =>
                  emp['designation'] == roleToApi(selectedDesignation.value),
            )
            .toList(),
      );
    }
  }

  Future<void> loadAdminName() async {
    String? storedAdminName = box.read('adminName');
    if (storedAdminName != null && storedAdminName.isNotEmpty) {
      adminName.value = storedAdminName;
      return;
    }

    if (Get.arguments != null) {
      String nameFromArgs = Get.arguments.toString();
      setAdminName(nameFromArgs);
      return;
    }

    await fetchAdminProfile();
  }

  Future<void> fetchAdminProfile() async {
    try {
      final response = await _dio.get('${dotenv.env['BASE_URL']}/api/profile');

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
      if (adminName.value.isEmpty) adminName.value = 'Admin';
    }
  }

  Future<void> fetchEmployees() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _dio.get(
        '${dotenv.env['BASE_URL']}/api/getEmployees',
      );

      if (response.statusCode == 200) {
        final responseBody = response.data as Map<String, dynamic>;
        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          final dataList = responseBody['data'] as List;
          employees.value =
              dataList
                  .map((e) => e as Map<String, dynamic>)
                  .where((emp) => emp['role'] != 'admin')
                  .toList();
          filterEmployeesByDesignation();
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

  Future<bool> renameEmployee(
    String employeeId,
    String currentUsername,
    String newUsername,
  ) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _dio.patch(
        '${dotenv.env['BASE_URL']}/api/renameEmployee',
        data: {'username': currentUsername, 'newUsername': newUsername},
      );

      if (response.statusCode == 200) {
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

  Future<bool> updateEmployee(String employeeId, String selectedRole) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      print('${dotenv.env['BASE_URL']}/api/upDesignation/$employeeId');
      final response = await _dio.patch(
        '${dotenv.env['BASE_URL']}/api/upDesignation/$employeeId',
        data: {'designation': selectedRole},
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final index = employees.indexWhere((emp) => emp['_id'] == employeeId);
        if (index != -1) {
          employees[index]['designation'] = selectedRole;
          employees.refresh();
        }

        Get.snackbar(
          "Success",
          "Employee details updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        return true;
      } else {
        Get.snackbar(
          "Failed",
          "Failed to update employee details: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        errorMessage.value =
            "Failed to update employee details: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Error updating employee details: $e";
      Get.snackbar(
        "Error",
        "Error updating employee details: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEmployeePassword(
    String employeeId,
    String newPassword,
  ) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _dio.put(
        '${dotenv.env['BASE_URL']}/api/updateEmployee/$employeeId',
        data: {'password': newPassword},
      );

      if (response.statusCode == 200) {
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

  Future<bool> deleteEmployee(String employeeId) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _dio.delete(
        '${dotenv.env['BASE_URL']}/api/deleteEmployee/$employeeId',
      );

      if (response.statusCode == 200) {
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

  Future<void> logout() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _dio.post('${dotenv.env['BASE_URL']}/api/logout');

      if (response.statusCode == 200) {
        box.remove('token');
        box.remove('userId');
        box.remove('userName');
        box.remove('adminName');

        Get.snackbar(
          "Success",
          "Logged out successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

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

  void setSelectedEmployee(Map<String, dynamic> employee) {
    selectedEmployee.value = employee;
  }

  @override
  void onInit() async {
    super.onInit();
    await loadAdminName();
    fetchEmployees();
  }
}

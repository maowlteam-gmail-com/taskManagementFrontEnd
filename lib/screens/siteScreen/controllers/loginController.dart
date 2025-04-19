import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/util/dio_config.dart';

class LoginController extends GetxController {
  final dio =
      DioConfig.getDio(); // Use getDio instead of createDio to ensure singleton
  var userController = TextEditingController();
  var passwordController = TextEditingController();

  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final storage = GetStorage();
  var obscureText = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Check for existing authentication on controller initialization
    checkAuthentication();
  }

  // Check if user is already authenticated
  void checkAuthentication() {
    final token = storage.read('token');
    final role = storage.read('role');

    if (token != null && role != null) {
      isAuthenticated.value = true;

      // Auto-redirect to appropriate screen if already logged in
      // Use Future.delayed to ensure this runs after the widget tree is built
      Future.delayed(Duration.zero, () {
        if (Get.currentRoute != '/admin' && Get.currentRoute != '/employee') {
          if (role == 'admin') {
            Get.offAllNamed('/admin', arguments: storage.read('name'));
          } else {
            Get.offAllNamed('/employee', arguments: storage.read('name'));
          }
        }
      });
    }
  }

  void togglePasswordVisbility() {
    obscureText.value = !obscureText.value;
  }

  Future<void> login() async {
    if (userController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Username and password are required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    var data = {
      "username": userController.text,
      "password": passwordController.text,
    };

    try {
      var response = await dio.post(
        '${dotenv.env['BASE_URL']}/api/login',
        data: data,
      );

      if (response.statusCode == 200) {
        var responseData = response.data;
        var id = responseData['user']['_id'];
        var token = responseData['token'];
        var name = responseData['user']['username'] ?? responseData['username'];
        var role = responseData['user']['role'];

        // Store authentication data
        await storage.write('_id', id);
        await storage.write('token', token);
        await storage.write('name', name);
        await storage.write('role', role);

        // Update authentication state
        isAuthenticated.value = true;

        Get.snackbar(
          "Success",
          "Login successful",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Navigate based on role
        if (role == 'admin') {
          Get.offAllNamed('/admin', arguments: name);
        } else {
          Get.offAllNamed('/employee', arguments: name);
        }
      } else {
        Get.snackbar(
          "Failed",
          "Failed to login: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Login error: $e");
      Get.snackbar(
        "Error",
        "Failed to connect to server. Please check your connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Handle logout
  void logout() {
    // Clear stored credentials
    storage.remove('token');
    storage.remove('role');
    storage.remove('_id');
    storage.remove('name');

    // Update authentication state
    isAuthenticated.value = false;

    // Clear form fields
    userController.clear();
    passwordController.clear();

    // Redirect to login
    Get.offAllNamed('/mainsite');
  }
}

import 'package:dio/dio.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:get/get.dart'; 
import 'package:get_storage/get_storage.dart'; 

class Employeecontroller extends GetxController {   
  // Initialize with a safe default value   
  final Rx<String> selectedOption = "Home".obs;   
  final Rx<String> employeeName = "".obs;   
  final box = GetStorage();      
  
  // Loading state   
  final RxBool isLoading = false.obs;   
  final RxString errorMessage = "".obs;      
  
  void setSelectedOption(String option) {     
    print("Setting selectedOption to: $option");
    selectedOption.value = option;   
  }      
  
  @override   
  void onInit() {     
    super.onInit();     
    print("EmployeeController onInit");
    
    // First, try to get employee name from arguments (for fresh navigation)
    if (Get.arguments != null) {       
      employeeName.value = Get.arguments.toString();
      // Store it in persistent storage for future refreshes
      box.write('employeeName', employeeName.value);
      print("Setting employeeName from arguments to: ${employeeName.value}");
    } else {
      // If no arguments (page refresh), try to get from storage
      final storedName = box.read('employeeName');
      if (storedName != null && storedName.isNotEmpty) {
        employeeName.value = storedName;
        print("Retrieved employeeName from storage: ${employeeName.value}");
      } else {
        // Fallback: try to get from the stored 'name' field
        final fallbackName = box.read('name');
        if (fallbackName != null && fallbackName.isNotEmpty) {
          employeeName.value = fallbackName;
          print("Using fallback employeeName from 'name': ${employeeName.value}");
        }
      }
    }
    
    // Set the default option to "Home" when controller initializes     
    selectedOption.value = "Home";
    print("Set default selectedOption to: ${selectedOption.value}");
    
    // Debug storage values
    debugStoredValues();
  }

  void debugStoredValues() {
    final token = box.read('token');
    final userId = box.read('_id');
    final userName = box.read('name');
    final storedEmployeeName = box.read('employeeName');
    
    print('Stored token: ${token != null ? (token.length > 10 ? token.substring(0, 10) + '...' : token) : 'null'}');
    print('Stored userId: $userId');
    print('Stored userName: $userName');
    print('Stored employeeName: $storedEmployeeName');
  }
  
  // logout   
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
        isLoading.value = false;         
        return;       
      }              
      
      final response = await Dio().post(         
        '${dotenv.env['BASE_URL']}/api/logout',         
        options: Options(           
          headers: {             
            "Content-Type": "application/json",             
            "Authorization": "Bearer $token",           
          },         
        ),       
      );              
      
      if (response.statusCode == 200) {         
        // Clear token and other user data         
        box.remove('token');         
        box.remove('_id');         
        box.remove('name');
        box.remove('employeeName'); // Also remove the stored employee name
        
        // Clear the observable values
        employeeName.value = "";
        selectedOption.value = "Home";
        
        // Show success message         
        Get.snackbar(           
          "Success",           
          "Logged out successfully",           
          snackPosition: SnackPosition.BOTTOM,           
          backgroundColor: Colors.black87,           
          colorText: Colors.white,           
          duration: Duration(seconds: 2),         
        );                  
        
        // Navigate to login screen after a brief delay         
        Future.delayed(Duration(milliseconds: 500), () {           
          Get.offAllNamed('/mainsite');         
        });       
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
}
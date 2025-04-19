import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class RequirementController extends GetxController {
  final dio.Dio _dio = dio.Dio();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isSuccess = false.obs;
  final responseData = Rx<Map<String, dynamic>>({});

  // Form input observables
  final nameController = ''.obs;
  final phoneController = ''.obs;
  final emailController = ''.obs;
  final messageController = ''.obs;
  final pdfFile = Rx<File?>(null);
  
  // For web platform
  final webPdfBytes = Rx<Uint8List?>(null);
  final webPdfName = ''.obs;

  // Validation states
  final isNameValid = true.obs;
  final isPhoneValid = true.obs;
  final isEmailValid = true.obs;
  final isMessageValid = true.obs;
  final isPdfValid = true.obs;

  void setName(String value) => nameController.value = value;
  void setPhone(String value) => phoneController.value = value;
  void setEmail(String value) => emailController.value = value;
  void setMessage(String value) => messageController.value = value;
  
  void setPdfFile(File file) {
    pdfFile.value = file;
    isPdfValid.value = true;
  }
  
  void setWebPdfFile(Uint8List bytes, String name) {
    webPdfBytes.value = bytes;
    webPdfName.value = name;
    isPdfValid.value = true;
  }
  
  void clearPdfFile() {
    pdfFile.value = null;
    webPdfBytes.value = null;
    webPdfName.value = '';
    isPdfValid.value = false;
  }
  
  String? getPdfFileName() {
    if (kIsWeb) {
      return webPdfName.value.isNotEmpty ? webPdfName.value : null;
    } else {
      return pdfFile.value?.path.split('/').last;
    }
  }

  bool validateInputs() {
    isNameValid.value = nameController.value.isNotEmpty;
    isPhoneValid.value = phoneController.value.isNotEmpty;
    isEmailValid.value = GetUtils.isEmail(emailController.value);
    isMessageValid.value = messageController.value.isNotEmpty;
    
    if (kIsWeb) {
      isPdfValid.value = webPdfBytes.value != null;
    } else {
      isPdfValid.value = pdfFile.value != null;
    }

    return isNameValid.value &&
        isPhoneValid.value &&
        isEmailValid.value &&
        isMessageValid.value &&
        isPdfValid.value;
  }

  // Helper to validate if a file is actually a PDF (for additional client-side validation)
  bool isPdfFileValid(String fileName) {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  // Helper method to extract error message from HTML response
  String extractErrorFromHtml(String html) {
    RegExp regExp = RegExp(r'Error: ([^<]+)');
    Match? match = regExp.firstMatch(html);
    return match?.group(1)?.trim() ?? "Unknown server error";
  }

  Future<bool> submitRequirement() async {
    if (!validateInputs()) {
      errorMessage.value = "Please fill all fields correctly";
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    isSuccess.value = false;

    try {
      // Create a new Dio instance with minimal configuration
      final client = dio.Dio();
      
      // Add logging to see exactly what's being sent
      client.interceptors.add(dio.LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ));
      
      // Determine correct URL based on platform
      String baseUrl;
      if (kIsWeb) {
        baseUrl = '${dotenv.env['BASE_URL']}';
      } else {
        // For Android emulators, use 10.0.2.2 instead of localhost
        baseUrl = Platform.isAndroid ? 'http://10.0.2.2:5001' : '${dotenv.env['BASE_URL']}';
        // For physical devices, use your computer's IP address
        // baseUrl = 'http://192.168.1.X:5001'; // Replace with your actual IP
      }
      
      String apiUrl = '$baseUrl/requirement/create';
      print('Sending request to: $apiUrl');
      
      // Create form data exactly as Postman does - keeping it simple
      dio.FormData formData = dio.FormData();
      
      // Add text fields first
      formData.fields.add(MapEntry('name', nameController.value));
      formData.fields.add(MapEntry('phone', phoneController.value));
      formData.fields.add(MapEntry('email', emailController.value));
      formData.fields.add(MapEntry('message', messageController.value));
      
      // Add file separately with proper MIME type
      if (kIsWeb && webPdfBytes.value != null) {
        if (!isPdfFileValid(webPdfName.value)) {
          errorMessage.value = "Please select a valid PDF file";
          isLoading.value = false;
          return false;
        }
        
        formData.files.add(MapEntry(
          'pdfFile',
          dio.MultipartFile.fromBytes(
            webPdfBytes.value!,
            filename: webPdfName.value,
            contentType: MediaType('application', 'pdf'),
          ),
        ));
      } else if (!kIsWeb && pdfFile.value != null) {
        final fileName = pdfFile.value!.path.split('/').last;
        
        if (!isPdfFileValid(fileName)) {
          errorMessage.value = "Please select a valid PDF file";
          isLoading.value = false;
          return false;
        }
        
        formData.files.add(MapEntry(
          'pdfFile',
          await dio.MultipartFile.fromFile(
            pdfFile.value!.path,
            filename: fileName,
            contentType: MediaType('application', 'pdf'),
          ),
        ));
      }
      
      print('Form data fields: ${formData.fields}');
      print('Form data files: ${formData.files}');
      
      final response = await client.post(
        apiUrl,
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': '*/*',
          },
          validateStatus: (status) {
            return status! < 500; // This will make Dio NOT throw on 500 errors
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        isSuccess.value = true;
        responseData.value = response.data;
        resetForm();
        return true;
      } else {
        // Try to extract meaningful error from response
        if (response.data is String && response.data.toString().contains('Error:')) {
          errorMessage.value = extractErrorFromHtml(response.data.toString());
        } else {
          errorMessage.value = "Server returned status: ${response.statusCode}";
        }
        return false;
      }
    } on dio.DioException catch (e) {
      print('Dio error type: ${e.type}');
      print('Error message: ${e.message}');
      
      if (e.response != null) {
        print('Error response status: ${e.response?.statusCode}');
        print('Error response data: ${e.response?.data}');
      }
      
      // Provide more detailed error message based on error type
      if (e.type == dio.DioExceptionType.connectionError || 
          e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage.value = "Connection error. Please check your server address and network connection.";
      } else if (e.response?.statusCode == 500) {
        // Try to extract the actual error message from the HTML response
        if (e.response?.data is String) {
          String errorMsg = extractErrorFromHtml(e.response!.data.toString());
          errorMessage.value = "Server error: $errorMsg";
        } else {
          errorMessage.value = "Server error (500). The server encountered an issue processing your request.";
        }
      } else {
        errorMessage.value = "Error: ${e.message}";
      }
      
      return false;
    } catch (e) {
      print('General error: $e');
      errorMessage.value = "Error: ${e.toString()}";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    nameController.value = '';
    phoneController.value = '';
    emailController.value = '';
    messageController.value = '';
    pdfFile.value = null;
    webPdfBytes.value = null;
    webPdfName.value = '';
  }
}
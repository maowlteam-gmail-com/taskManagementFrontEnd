
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DioConfig {

  static Dio? _dio;
  
  static Dio createDio() {
    if (_dio == null) {
      _dio = Dio();
      final storage = GetStorage();
      
      // Add request interceptor
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // Get token from storage and add to headers
          final token = storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle 401 errors globally
          if (e.response?.statusCode == 401) {
            // Clear stored credentials
            storage.remove('token');
            storage.remove('role');
            storage.remove('_id');
            storage.remove('name');
            
            // Show error message
            Get.snackbar(
              "Authentication Error", 
              "Your session has expired. Please login again.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
            );
            
            // Redirect to login
            Get.offAllNamed('/login');
          }
          return handler.next(e);
        }
      ));
    }
    
    return _dio!;
  }
  
  // Get the existing instance or create a new one
  static Dio getDio() {
    if (_dio == null) {
      return createDio();
    }
    return _dio!;
  }
}
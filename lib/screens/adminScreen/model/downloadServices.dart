// services/download_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService extends GetxController {
  final Dio _dio = Dio();
  final GetStorage box = GetStorage();

  // Download state
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;
  final RxMap<String, bool> isDownloading = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _configureDio();
  }

  void _configureDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<void> downloadFile(String fileId, {String? fileName}) async {
    if (fileId.isEmpty) {
      Get.snackbar('Error', 'File ID is required');
      return;
    }

    try {
      // Check and request permissions
      if (!await _checkPermissions()) {
        Get.snackbar('Error', 'Storage permission is required to download files');
        return;
      }

      isDownloading[fileId] = true;
      downloadProgress[fileId] = 0.0;

      final token = box.read('token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get download directory
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        throw Exception('Could not access download directory');
      }

      // Generate file name if not provided
      final downloadFileName = fileName ?? 'download_$fileId';
      final filePath = '${directory.path}/$downloadFileName';

      // Download file
      await _dio.download(
        '${dotenv.env['BASE_URL']}/api/files/download/$fileId',
        filePath,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress[fileId] = received / total;
          }
        },
      );

      // Success
      Get.snackbar(
        'Success', 
        'File downloaded successfully to Downloads folder',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      Get.snackbar(
        'Download Error', 
        'Failed to download file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isDownloading[fileId] = false;
      downloadProgress.remove(fileId);
    }
  }

  Future<bool> _checkPermissions() async {
    if (kIsWeb) return true; // Web doesn't need storage permissions

    if (Platform.isAndroid) {
      // For Android 11+ (API 30+), we might need different permissions
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
      
      // For Android 13+ (API 33+), check for specific permissions
      if (status.isDenied) {
        var photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          photosStatus = await Permission.photos.request();
        }
        return photosStatus.isGranted;
      }
      
      return status.isGranted;
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
      return status.isGranted;
    }

    return false;
  }

  Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Try to get external storage directory
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Create Downloads folder in external storage
          final downloadDir = Directory('${directory.path}/Downloads');
          if (!downloadDir.existsSync()) {
            downloadDir.createSync(recursive: true);
          }
          return downloadDir;
        }
        
        // Fallback to app documents directory
        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      debugPrint('Error getting download directory: $e');
    }
    return null;
  }

  // Get download progress for a specific file
  double getDownloadProgress(String fileId) {
    return downloadProgress[fileId] ?? 0.0;
  }

  // Check if a file is currently downloading
  bool isFileDownloading(String fileId) {
    return isDownloading[fileId] ?? false;
  }
}
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/util/dio_config.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Ensure this import path is correct

class DownloadService extends GetxController {
  final Dio _dio = DioConfig.getDio();

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
            "Content-Type": "application/json",
            // No need to include Authorization header manually
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
    } on DioException catch (e) {
      Get.snackbar(
        'Download Error',
        'Dio error: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } catch (e) {
      Get.snackbar(
        'Download Error',
        'Failed to download file: $e',
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
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }

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
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadDir = Directory('${directory.path}/Downloads');
          if (!downloadDir.existsSync()) {
            downloadDir.createSync(recursive: true);
          }
          return downloadDir;
        }

        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      debugPrint('Error getting download directory: $e');
    }
    return null;
  }

  double getDownloadProgress(String fileId) {
    return downloadProgress[fileId] ?? 0.0;
  }

  bool isFileDownloading(String fileId) {
    return isDownloading[fileId] ?? false;
  }
}

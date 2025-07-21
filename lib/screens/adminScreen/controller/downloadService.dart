import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

import 'package:maowl/util/dio_config.dart'; 
class DownloadService extends GetxController {
  final Dio _dio = DioConfig.getDio(); 
  final box = GetStorage();

  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxString currentFileName = ''.obs;
  final RxString downloadError = ''.obs;

  Future<void> downloadFile(String fileId, {String? fileName}) async {
    isDownloading.value = true;
    downloadProgress.value = 0.0;
    downloadError.value = '';
    currentFileName.value = fileName ?? 'file';

    try {
      final token = box.read('token');

      if (token == null) {
        downloadError.value = 'Authentication token not found';
        _showErrorSnackbar('Authentication token not found');
        return;
      }

      final String cleanFileId = fileId.startsWith('/api/tasks/download/')
          ? fileId.split('/').last
          : fileId;

      final downloadUrl = '${dotenv.env['BASE_URL'] ?? ''}/api/tasks/download/$cleanFileId';

      print('Downloading from: $downloadUrl');

      final response = await _dio.get(
        downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      if (response.statusCode == 200) {
        String downloadFileName =
            fileName ?? _getFileNameFromHeaders(response) ?? 'downloaded_file';

        if (kIsWeb) {
          await _downloadForWeb(response.data, downloadFileName);
        } else if (Platform.isAndroid || Platform.isIOS) {
          await _downloadForMobile(response.data, downloadFileName);
        } else {
          await _downloadForDesktop(response.data, downloadFileName);
        }

        _showSuccessSnackbar('File downloaded successfully');
      } else {
        downloadError.value = 'Server returned: ${response.statusCode}';
        _showErrorSnackbar('Download failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      downloadError.value = e.message ?? 'Unknown Dio error';
      _showErrorSnackbar('Download failed: ${e.response?.statusCode ?? ''} ${e.message}');
      print('Dio error: ${e.message}');
    } catch (e) {
      downloadError.value = e.toString();
      _showErrorSnackbar('Download failed: $e');
      print('General download error: $e');
    } finally {
      isDownloading.value = false;
      if (Get.isDialogOpen!) {
        Get.back();
      }
    }
  }

  Future<void> _downloadForWeb(Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..setAttribute('style', 'display: none');
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _downloadForMobile(Uint8List bytes, String fileName) async {
    if (!await _requestStoragePermission()) {
      downloadError.value = 'Permission denied';
      _showErrorSnackbar('Storage permission denied');
      return;
    }

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        downloadError.value = 'Cannot access directory';
        _showErrorSnackbar('Storage access failed');
        return;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      Get.dialog(
        AlertDialog(
          title: Text('Download Complete'),
          content: Text('File saved to $filePath'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text('Open'),
              onPressed: () {
                Get.back();
                OpenFile.open(filePath);
              },
            ),
          ],
        ),
      );
    } catch (e) {
      downloadError.value = 'File save error: $e';
      _showErrorSnackbar('Failed to save file: $e');
    }
  }

  Future<void> _downloadForDesktop(Uint8List bytes, String fileName) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        downloadError.value = 'Download directory error';
        _showErrorSnackbar('Cannot access downloads');
        return;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      _showSuccessSnackbar('File saved to $filePath');
    } catch (e) {
      downloadError.value = 'File write error: $e';
      _showErrorSnackbar('Error writing file: $e');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  String? _getFileNameFromHeaders(Response response) {
    if (response.headers.map.containsKey('content-disposition')) {
      final contentDisposition = response.headers.value('content-disposition');
      if (contentDisposition != null && contentDisposition.contains('filename=')) {
        return contentDisposition.split('filename=')[1].replaceAll('"', '').replaceAll("'", "");
      }
    }
    return null;
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
    );
  }
}

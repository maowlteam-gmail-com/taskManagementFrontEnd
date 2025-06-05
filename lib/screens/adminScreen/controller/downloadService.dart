import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;  // Hide the Response from get package
import 'package:get_storage/get_storage.dart';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class DownloadService extends GetxController {
  final Dio _dio = Dio();
  final box = GetStorage();
  
  // Download status
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxString currentFileName = ''.obs;
  
  // Error handling
  final RxString downloadError = ''.obs;

  // Download a file from the server
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
      
      // Ensure fileId is only using the ID part, not the full path
      final String cleanFileId = fileId.startsWith('/api/tasks/download/') 
          ? fileId.split('/').last 
          : fileId;
      
      final downloadUrl = '${dotenv.env['BASE_URL'] ?? ''}/api/tasks/download/$cleanFileId';

      print('Downloading from: $downloadUrl');
      
      // Show download progress dialog
      
      
      final response = await _dio.get(
        downloadUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );
      
      if (response.statusCode == 200) {
        // Get filename from headers if not provided
        String downloadFileName = fileName ?? _getFileNameFromHeaders(response) ?? 'downloaded_file';
        
        // Handle download based on platform
        if (kIsWeb) {
          await _downloadForWeb(response.data, downloadFileName);
        } else if (Platform.isAndroid || Platform.isIOS) {
          await _downloadForMobile(response.data, downloadFileName);
        } else {
          await _downloadForDesktop(response.data, downloadFileName);
        }
        
        _showSuccessSnackbar('File downloaded successfully');
      } else {
        downloadError.value = 'Server returned status code: ${response.statusCode}';
        _showErrorSnackbar('Download failed: Server error ${response.statusCode}');
      }
    } catch (e) {
      downloadError.value = e.toString();
      _showErrorSnackbar('Download failed: $e');
      print('Download error: $e');
    } finally {
      isDownloading.value = false;
      if (Get.isDialogOpen!) {
        Get.back();
      }
    }
  }
  
  // Download file for web platform
  Future<void> _downloadForWeb(Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create download link and trigger click
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..setAttribute('style', 'display: none');
    
    html.document.body?.children.add(anchor);
    anchor.click();
    
    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
  
  // Download file for mobile platforms
  Future<void> _downloadForMobile(Uint8List bytes, String fileName) async {
    // Request storage permission
    if (!await _requestStoragePermission()) {
      downloadError.value = 'Storage permission denied';
      _showErrorSnackbar('Cannot download: Storage permission denied');
      return;
    }
    
    try {
      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Create directory if it doesn't exist
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        downloadError.value = 'Could not access download directory';
        _showErrorSnackbar('Download failed: Could not access storage');
        return;
      }
      
      // Create file path
      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);
      
      // Write file
      await file.writeAsBytes(bytes);
      
      // Show success and ask to open
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
      downloadError.value = 'Error saving file: $e';
      _showErrorSnackbar('Error saving file: $e');
    }
  }
  
  // Download file for desktop platforms
  Future<void> _downloadForDesktop(Uint8List bytes, String fileName) async {
    try {
      // For desktop platforms, use similar approach to web for now
      // In a real app, you might want to use file_picker to choose save location
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        downloadError.value = 'Could not access download directory';
        _showErrorSnackbar('Download failed: Could not access downloads folder');
        return;
      }
      
      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);
      
      await file.writeAsBytes(bytes);
      
      _showSuccessSnackbar('File saved to $filePath');
    } catch (e) {
      downloadError.value = 'Error saving file: $e';
      _showErrorSnackbar('Error saving file: $e');
    }
  }
  
  // Request storage permission for mobile
  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    
    return status.isGranted;
  }
  
  // Get filename from response headers
  String? _getFileNameFromHeaders(Response response) {
    if (response.headers.map.containsKey('content-disposition')) {
      final contentDisposition = response.headers.value('content-disposition');
      if (contentDisposition != null && contentDisposition.contains('filename=')) {
        return contentDisposition
            .split('filename=')[1]
            .replaceAll('"', '')
            .replaceAll("'", "");
      }
    }
    return null;
  }
  
  // Show download progress dialog
  // void _showDownloadProgressDialog() {
  //   Get.dialog(
  //     Obx(() => AlertDialog(
  //       title: Text('Downloading File'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(currentFileName.value),
  //           SizedBox(height: 16),
  //           LinearProgressIndicator(value: downloadProgress.value > 0 ? downloadProgress.value : null),
  //           SizedBox(height: 8),
  //           Text(downloadProgress.value > 0 
  //               ? '${(downloadProgress.value * 100).toStringAsFixed(0)}%'
  //               : 'Starting download...'),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           child: Text('Cancel'),
  //           onPressed: () {
  //             // Cancel the download
  //             _dio.close(force: true);
  //             Get.back();
  //             _showErrorSnackbar('Download cancelled');
  //           },
  //         ),
  //       ],
  //     )),
  //     barrierDismissible: false,
  //   );
  // }
  
  // Show success snackbar
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
  
  // Show error snackbar
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
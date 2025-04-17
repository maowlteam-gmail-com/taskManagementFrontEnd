import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:html' as html;

class PlatformFile {
  final String name;
  final int size;
  final Uint8List? bytes;
  final String? path;

  PlatformFile({
    required this.name,
    required this.size,
    this.bytes,
    this.path,
  });
}

class FileHelper {
  static PlatformFile? _selectedFile;

  // Getter for the selected file
  static PlatformFile? get selectedFile => _selectedFile;

  // Set the selected file
  static void setSelectedFile(PlatformFile file) {
    _selectedFile = file;
  }

  // Clear the selected file
  static void clearSelectedFile() {
    _selectedFile = null;
  }

  // Get the file size in bytes
  static int getFileSize() {
    return _selectedFile?.size ?? 0;
  }

  // Get the file name
  static String getFileName() {
    return _selectedFile?.name ?? '';
  }

  // Check if file exists
  static bool hasFile() {
    return _selectedFile != null;
  }

  // Format file size to human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / 1048576).toStringAsFixed(2)} MB';
  }
}
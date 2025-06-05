// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class TaskUtils {
//   static String formatDate(String? dateString) {
//     if (dateString == null) return 'N/A';
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('MMM d, yyyy').format(date);
//     } catch (e) {
//       return 'Invalid Date';
//     }
//   }

//   static String formatDateTime(String? dateString) {
//     if (dateString == null) return 'N/A';
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('MMM d, yyyy - h:mm a').format(date);
//     } catch (e) {
//       return 'Invalid Date';
//     }
//   }

//   static String capitalizeStatus(String status) {
//     return status
//         .split('_')
//         .map(
//           (word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
//         )
//         .join(' ');
//   }

//   static Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'in_progress':
//         return Colors.blue;
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       case 'warning':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   static String getUsername(dynamic addedBy) {
//     if (addedBy is Map<String, dynamic>) {
//       return addedBy['username'] ?? 'Unknown User';
//     } else if (addedBy is String) {
//       return addedBy;
//     }
//     return 'Unknown User';
//   }

//   static IconData getFileIcon(String fileType) {
//     switch (fileType.toLowerCase()) {
//       case 'pdf':
//         return Icons.picture_as_pdf;
//       case 'jpg':
//       case 'jpeg':
//       case 'png':
//       case 'gif':
//         return Icons.image;
//       case 'doc':
//       case 'docx':
//         return Icons.description;
//       case 'xls':
//       case 'xlsx':
//         return Icons.table_chart;
//       case 'ppt':
//       case 'pptx':
//         return Icons.slideshow;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }
// }
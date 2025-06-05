// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:maowl/screens/adminScreen/controller/employeeProjectController.dart';
// import 'package:maowl/screens/adminScreen/model/taskUtils.dart';


// class TaskCardWidget extends StatelessWidget {
//   final Map<String, dynamic> task;
//   final EmployeeProjectsController controller;

//   const TaskCardWidget({
//     Key? key,
//     required this.task,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final projectName = task['project_name'] ?? 'Unknown Project';
//     final taskName = task['task_name'] ?? 'Unnamed Task';
//     final startDate = TaskUtils.formatDate(task['start_date']);
//     final endDate = TaskUtils.formatDate(task['end_date']);
//     final updatedAt = TaskUtils.formatDate(task['updatedAt']);
//     final status = task['status'] ?? 'unknown';

//     // Get latest work detail
//     final workDetails = task['work_details'] as List<dynamic>?;
//     final latestWorkDetail = controller.getLatestWorkDetail(workDetails);
//     final hasWorkDetails = latestWorkDetail != null;

//     // Get latest file associated with the task
//     final files = task['files'] as List<dynamic>?;
//     final latestFile = controller.getLatestFile(files);
//     final hasFile = latestFile != null;

//     // Check if the latest work detail and latest file are from the same update
//     final bool isFileRelatedToLatestWorkDetail = hasWorkDetails &&
//         hasFile &&
//         latestWorkDetail['added_by']['_id'] == latestFile['uploaded_by'] &&
//         (latestWorkDetail['date'].toString().substring(0, 19) ==
//             latestFile['uploaded_at'].toString().substring(0, 19));

//     return InkWell(
//       onTap: () => controller.viewTaskDetail(task),
//       borderRadius: BorderRadius.circular(8),
//       child: Card(
//         color: Color(0xff333333),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(color: Colors.grey.shade200),
//         ),
//         child: Stack(
//           children: [
//             // Status vertical line on the right side
//             Positioned(
//               top: 0,
//               bottom: 0,
//               right: 50,
//               width: Get.width < 600 ? 100 : 150,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: TaskUtils.getStatusColor(status),
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(8),
//                     bottomRight: Radius.circular(8),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: TaskUtils.getStatusColor(status).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(3),
//                         border: Border.all(color: Colors.white, width: 1.5),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 2,
//                             spreadRadius: 0.5,
//                           ),
//                         ],
//                       ),
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           TaskUtils.capitalizeStatus(status),
//                           style: TextStyle(
//                             fontSize: Get.width < 600 ? 12 : 14,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             shadows: [
//                               Shadow(
//                                 offset: Offset(0.5, 0.5),
//                                 blurRadius: 1.0,
//                                 color: Colors.black.withOpacity(0.5),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Main content with padding to accommodate the status line
//             Padding(
//               padding: EdgeInsets.fromLTRB(12, 12, 20, 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           projectName,
//                           style: TextStyle(
//                             fontSize: Get.width < 600 ? 20 : 24,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       SizedBox(width: 4),
//                       InkWell(
//                         onTap: () {
//                           controller.showDeleteConfirmation(task['_id'], taskName);
//                         },
//                         borderRadius: BorderRadius.circular(4),
//                         child: Padding(
//                           padding: EdgeInsets.all(4),
//                           child: Icon(
//                             Icons.delete_outline,
//                             size: 18,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     taskName,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 8),

//                   // Latest Work Detail Section
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(4),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: hasWorkDetails
//                           ? Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Latest Update',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                     Text(
//                                       '${latestWorkDetail['hours_spent']} hrs',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.blue[700],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 4),
//                                 Expanded(
//                                   child: SingleChildScrollView(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           '${latestWorkDetail['description']}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black,
//                                           ),
//                                           overflow: TextOverflow.fade,
//                                         ),
//                                         if (isFileRelatedToLatestWorkDetail && hasFile) ...[
//                                           SizedBox(height: 4),
//                                           Row(
//                                             children: [
//                                               Icon(
//                                                 TaskUtils.getFileIcon(latestFile['type']),
//                                                 size: 14,
//                                                 color: Colors.blue[700],
//                                               ),
//                                               SizedBox(width: 4),
//                                               Expanded(
//                                                 child: Text(
//                                                   '${latestFile['filename']}',
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: Colors.blue[700],
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                   maxLines: 1,
//                                                   overflow: TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'By: ${latestWorkDetail['added_by']['username']}',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontStyle: FontStyle.italic,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     Text(
//                                       TaskUtils.formatDateTime(latestWorkDetail['date']),
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             )
//                           : Center(
//                               child: Text(
//                                 'No work updates yet',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[500],
//                                   fontStyle: FontStyle.italic,
//                                 ),
//                               ),
//                             ),
//                     ),
//                   ),

//                   SizedBox(height: 8),
//                   _buildInfoRow(Icons.calendar_today, 'Start: $startDate'),
//                   SizedBox(height: 4),
//                   _buildInfoRow(Icons.event, 'Due: $endDate'),
//                   SizedBox(height: 4),
//                   _buildInfoRow(Icons.update, 'Updated: $updatedAt'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 14.sp, color: Colors.white),
//         SizedBox(width: 4.w),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(fontSize: 12.sp, color: Colors.white),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
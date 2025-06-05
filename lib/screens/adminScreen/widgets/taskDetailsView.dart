// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:maowl/screens/adminScreen/controller/downloadService.dart';
// import 'package:maowl/screens/adminScreen/controller/employeeProjectController.dart';
// import 'package:maowl/screens/adminScreen/model/taskUtils.dart';
// import 'package:maowl/screens/adminScreen/widgets/collaboratorAvatar.dart';

// class TaskDetailView extends StatelessWidget {
//   final EmployeeProjectsController controller;

//   const TaskDetailView({
//     Key? key,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final task = controller.selectedTask.value;
//       final projectName = task['project_name'] ?? 'Unknown Project';
//       final taskName = task['task_name'] ?? 'Unnamed Task';
//       final description = task['description'] ?? 'No description available';
//       final startDate = TaskUtils.formatDate(task['start_date']);
//       final endDate = TaskUtils.formatDate(task['end_date']);
//       final status = task['status'] ?? 'unknown';
//       final createdAt = TaskUtils.formatDateTime(task['createdAt']);
//       final updatedAt = TaskUtils.formatDateTime(task['updatedAt']);

//       bool isMobileView = Get.width < 800;

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with back button
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: controller.closeTaskDetail,
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         taskName,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         projectName,
//                         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: TaskUtils.getStatusColor(status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(color: TaskUtils.getStatusColor(status), width: 1),
//                   ),
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       TaskUtils.capitalizeStatus(status),
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: TaskUtils.getStatusColor(status),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(height: 1),

//           // Task details and history - Responsive layout
//           Expanded(
//             child: isMobileView
//                 // Mobile layout (vertical)
//                 ? SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Task info card
//                         Padding(
//                           padding: EdgeInsets.all(16),
//                           child: _buildTaskInfoCard(
//                             status,
//                             description,
//                             startDate,
//                             endDate,
//                             createdAt,
//                             updatedAt,
//                           ),
//                         ),

//                         // Work Details Card
//                         Padding(
//                           padding: EdgeInsets.all(16),
//                           child: _buildWorkDetailsCard(),
//                         ),
//                       ],
//                     ),
//                   )
//                 // Desktop layout (horizontal)
//                 : Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Left panel - Task details
//                       Expanded(
//                         flex: 3,
//                         child: SingleChildScrollView(
//                           padding: EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Task info card
//                               _buildTaskInfoCard(
//                                 status,
//                                 description,
//                                 startDate,
//                                 endDate,
//                                 createdAt,
//                                 updatedAt,
//                               ),
//                               SizedBox(height: 16),
//                               // Work Details Card
//                               _buildWorkDetailsCard(),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _buildTaskInfoCard(
//     String status,
//     String description,
//     String startDate,
//     String endDate,
//     String createdAt,
//     String updatedAt,
//   ) {
//     return Card(
//       color: Color(0xff333333),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             bottom: 0,
//             right: 50,
//             width: Get.width < 600 ? 100 : 150,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: TaskUtils.getStatusColor(status),
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(8),
//                   bottomRight: Radius.circular(8),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Align(
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: TaskUtils.getStatusColor(status).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(3),
//                       border: Border.all(color: Colors.white, width: 1.5),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 2,
//                           spreadRadius: 0.5,
//                         ),
//                       ],
//                     ),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         TaskUtils.capitalizeStatus(status),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(
//                               offset: Offset(0.5, 0.5),
//                               blurRadius: 1.0,
//                               color: Colors.black.withOpacity(0.5),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Task Information',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 16),

//                 // Description
//                 Text(
//                   'Description',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Text(
//                     description,
//                     style: TextStyle(fontSize: 14, color: Colors.black),
//                   ),
//                 ),
//                 SizedBox(height: 16),

//                 // Dates - Responsive layout
//                 Get.width < 500
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildDateField(
//                             'Start Date',
//                             Icons.calendar_today,
//                             startDate,
//                           ),
//                           SizedBox(height: 12),
//                           _buildDateField('Due Date', Icons.event, endDate),
//                         ],
//                       )
//                     : Row(
//                         children: [
//                           Expanded(
//                             child: _buildDateField(
//                               'Start Date',
//                               Icons.calendar_today,
//                               startDate,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: _buildDateField(
//                               'Due Date',
//                               Icons.event,
//                               endDate,
//                             ),
//                           ),
//                         ],
//                       ),
//                 SizedBox(height: 16),

//                 // Timestamps - Responsive layout
//                 Get.width < 500
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildTimestampField('Created At', createdAt),
//                           SizedBox(height: 12),
//                           _buildTimestampField('Last Updated', updatedAt),
//                         ],
//                       )
//                     : Row(
//                         children: [
//                           Expanded(
//                             child: _buildTimestampField('Created At', createdAt),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: _buildTimestampField(
//                               'Last Updated',
//                               updatedAt,
//                             ),
//                           ),
//                         ],
//                       ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateField(String label, IconData icon, String date) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: 4),
//         Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: BorderRadius.circular(4),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, size: 16, color: Colors.black87),
//               SizedBox(width: 8),
//               Text(date, style: TextStyle(fontSize: 14, color: Colors.black)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTimestampField(String label, String timestamp) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(timestamp, style: TextStyle(fontSize: 14, color: Colors.white)),
//       ],
//     );
//   }

//   Widget _buildWorkDetailsCard() {
//     final DownloadService downloadService = Get.put(DownloadService());

//     return Obx(() {
//       return Card(
//         color: Color(0xff333333),
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Work Details',
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     '${controller.filterWorkDetails.value.length} ${controller.filterWorkDetails.value.length == 1 ? 'Entry' : 'Entries'}',
//                     style: TextStyle(fontSize: 14.sp, color: Colors.white),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16.h),

//               if (controller.filterWorkDetails.value.isEmpty)
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(vertical: 24.h),
//                     child: Column(
//                       children: [
//                         Icon(
//                           Icons.work_outline,
//                           size: 48.sp,
//                           color: Colors.white,
//                         ),
//                         SizedBox(height: 16.h),
//                         Text(
//                           'No work details available',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             color: Colors.white,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               else
//                 ListView.separated(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: controller.filterWorkDetails.value.length,
//                   separatorBuilder: (context, index) => Divider(height: 24.h),
//                   itemBuilder: (context, index) {
//                     final item = controller.filterWorkDetails.value[index];

//                     final description =
//                         item['details']?['description'] ??
//                         item['description'] ??
//                         'No description';

//                     final date = TaskUtils.formatDateTime(
//                       item['timestamp'] ?? item['date'],
//                     );

//                     final hoursSpentRaw = item['details']?['hours_spent'] ?? 
//                                         item['hours_spent'] ?? 
//                                         0;
//                     final hoursSpent = hoursSpentRaw is String 
//                         ? double.tryParse(hoursSpentRaw) ?? 0 
//                         : (hoursSpentRaw is num ? hoursSpentRaw : 0);

//                     final addedBy = item['performed_by'] ?? item['added_by'];
//                     String addedByName = '';

//                     if (addedBy is Map<String, dynamic>) {
//                       addedByName = addedBy['username'] ?? 'Unknown User';
//                     } else if (addedBy is String) {
//                       addedByName = addedBy;
//                     } else {
//                       addedByName = 'Unknown User';
//                     }

//                     List<Map<String, dynamic>> files = [];

//                     if (item['files'] != null && item['files'] is List) {
//                       files = (item['files'] as List).map<Map<String, dynamic>>((file) {
//                         if (file is Map<String, dynamic>) {
//                           return {
//                             'id': file['_id'] ?? '',
//                             'filename': file['filename'] ?? 'Unknown File',
//                             'caption': file['caption'] ?? '',
//                             'type': file['type'] ?? '',
//                           };
//                         } else {
//                           return {
//                             'id': '',
//                             'filename': 'Unknown File',
//                             'caption': '',
//                             'type': '',
//                           };
//                         }
//                       }).toList();
//                     }

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             CollaboratorAvatar(name: addedByName, size: 32.sp),
//                             SizedBox(width: 12.w),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     addedByName,
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     date,
//                                     style: TextStyle(
//                                       fontSize: 12.sp,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if (hoursSpent > 0)
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 8.w,
//                                   vertical: 4.h,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue[50],
//                                   borderRadius: BorderRadius.circular(4.r),
//                                   border: Border.all(
//                                     color: Colors.blue[300]!,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   '$hoursSpent hrs',
//                                   style: TextStyle(
//                                     fontSize: 12.sp,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue[700],
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         SizedBox(height: 12.h),
//                         if (description.isNotEmpty)
//                           Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.all(12.w),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[800],
//                               borderRadius: BorderRadius.circular(4.r),
//                               border: Border.all(color: Colors.grey[600]!),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 if (description.isNotEmpty)
//                                   Text(
//                                     description,
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 if (files.isNotEmpty) ...[
//                                   if (description.isNotEmpty)
//                                     SizedBox(height: 12.h),
//                                   Text(
//                                     'Attached Files',
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8.h),
//                                   ...files
//                                       .map(
//                                         (file) => _buildFileItem(
//                                           file,
//                                           downloadService,
//                                         ),
//                                       )
//                                       .toList(),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         SizedBox(height: 8.h),
//                       ],
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildFileItem(Map<String, dynamic> file, DownloadService downloadService) {
//     final String fileName = file['filename'] ?? 'Unknown File';
//     final String fileType = file['type'] ?? '';
//     final String fileId = file['id'] ?? '';
    
//     IconData fileIcon;
//     Color iconColor;
    
//     switch (fileType.toLowerCase()) {
//       case 'pdf':
//         fileIcon = Icons.picture_as_pdf;
//         iconColor = Colors.red[400]!;
//         break;
//       case 'image':
//         fileIcon = Icons.image;
//         iconColor = Colors.blue[400]!;
//         break;
//       case 'doc':
//       case 'docx':
//         fileIcon = Icons.description;
//         iconColor = Colors.blue[700]!;
//         break;
//       case 'xls':
//       case 'xlsx':
//         fileIcon = Icons.table_chart;
//         iconColor = Colors.green[600]!;
//         break;
//       default:
//         fileIcon = Icons.insert_drive_file;
//         iconColor = Colors.grey[400]!;
//     }

//     return Padding(
//       padding: EdgeInsets.only(bottom: 8.h),
//       child: InkWell(
//         onTap: () {
//           if (fileId.isNotEmpty) {
//             downloadService.downloadFile(fileId, fileName: fileName);
//           }
//         },
//         borderRadius: BorderRadius.circular(4.r),
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
//           decoration: BoxDecoration(
//             color: Colors.grey[700],
//             borderRadius: BorderRadius.circular(4.r),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 fileIcon,
//                 size: 20.sp,
//                 color: iconColor,
//               ),
//               SizedBox(width: 8.w),
//               Expanded(
//                 child: Text(
//                   fileName,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.white,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Icon(
//                 Icons.download,
//                 size: 18.sp,
//                 color: Colors.blue[300],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
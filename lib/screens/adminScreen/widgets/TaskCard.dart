// // widgets/task_card.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:maowl/screens/adminScreen/model/ProjectTaskDetailsModel.dart%2015-27-56-707.dart';

// class TaskCard extends StatelessWidget {
//   final ProjectTaskDetailsModel task;
//   final VoidCallback onTap;

//   const TaskCard({
//     Key? key,
//     required this.task,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _getStatusColor(task.status);

//     return Card(
//       elevation: 8,
//       color: Colors.grey[900],
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12.r),
//         child: Stack(
//           children: [
//             // Main content
//             _buildMainContent(),
            
//             // Status container spanning full height on the right side
//             _buildStatusContainer(statusColor),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.r),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.grey[900]!,
//             Colors.grey[800]!,
//           ],
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with task name
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   task.taskName,
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               SizedBox(width: 80.w), // Space for status container
//             ],
//           ),
          
//           SizedBox(height: 16.h),
          
//           // User information
//           Row(
//             children: [
//               Expanded(
//                 child: _buildUserColumn(
//                   'CREATED BY',
//                   task.createdBy.username,
//                   Icons.person_add,
//                   Colors.blue,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: _buildUserColumn(
//                   'ASSIGNED TO',
//                   task.assignedTo.username,
//                   Icons.assignment_ind,
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusContainer(Color statusColor) {
//     return Positioned(
//       top: 0,
//       right: 0,
//       bottom: 0,
//       child: Container(
//         width: 60.w,
//         decoration: BoxDecoration(
//           color: statusColor,
//           borderRadius: BorderRadius.only(
//             topRight: Radius.circular(12.r),
//             bottomRight: Radius.circular(12.r),
//           ),
//         ),
//         child: RotatedBox(
//           quarterTurns: 3,
//           child: Center(
//             child: Text(
//               task.status.toUpperCase().replaceAll('_', ' '),
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 1.2,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserColumn(String label, String username, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(8.w),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(color: color.withOpacity(0.5)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 14.sp, color: color),
//               SizedBox(width: 4.w),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     fontWeight: FontWeight.w600,
//                     color: color,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             username,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'in_progress':
//       case 'in progress':
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
// }
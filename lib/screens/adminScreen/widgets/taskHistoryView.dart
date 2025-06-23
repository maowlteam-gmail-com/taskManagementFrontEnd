import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:maowl/screens/adminScreen/widgets/collaboratorAvatar.dart';


class TaskHistoryItem extends StatelessWidget {
  final Map<String, dynamic> historyItem;

  const TaskHistoryItem({
    super.key,
    required this.historyItem,
  });

  // String formatDateTime(String? dateString) {
  //   if (dateString == null) return 'N/A';
  //   try {
  //     final date = DateTime.parse(dateString);
  //     return DateFormat('MMM d, yyyy - h:mm a').format(date);
  //   } catch (e) {
  //     return 'Invalid Date';
  //   }
  // }
  String formatDateTime(String? dateString) {
  if (dateString == null) return 'N/A';
  try {
    final date = DateTime.parse(dateString);
    // Convert UTC to local time
    final localDate = date.toLocal();
    return DateFormat('MMM d, yyyy - h:mm a').format(localDate);
  } catch (e) {
    return 'Invalid Date';
  }
}

  String getActionTitle(String action) {
    switch (action) {
      case 'created':
        return 'Task Created';
      case 'work_detail_added':
        return 'Work Update';
      case 'status_changed':
        return 'Status Changed';
      case 'assigned':
        return 'Task Assigned';
      default:
        return action.split('_').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }

  IconData getActionIcon(String action) {
    switch (action) {
      case 'created':
        return Icons.add_circle_outline;
      case 'work_detail_added':
        return Icons.update;
      case 'status_changed':
        return Icons.sync;
      case 'assigned':
        return Icons.person_add_alt;
      default:
        return Icons.info_outline;
    }
  }

  Color getActionColor(String action) {
    switch (action) {
      case 'created':
        return Colors.green;
      case 'work_detail_added':
        return Colors.blue;
      case 'status_changed':
        return Colors.orange;
      case 'assigned':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = historyItem['action'] ?? 'unknown';
    final performedBy = historyItem['performed_by'] ?? 'Unknown';
    final timestamp = formatDateTime(historyItem['timestamp']);
    final details = historyItem['details'] as Map<String, dynamic>?;
    final comment = historyItem['comment'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
              decoration: BoxDecoration(
                color: getActionColor(action).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.sp),
                border: Border.all(color: getActionColor(action), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    getActionIcon(action),
                    size: 14.sp,
                    color: getActionColor(action),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    getActionTitle(action),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: getActionColor(action),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                timestamp,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CollaboratorAvatar(name: performedBy),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performedBy,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (action == 'work_detail_added' && details != null) ...[
                    _buildWorkDetailContent(details),
                  ]
                   else if (details != null) ...[
                    _buildGenericDetailContent(details),
                  ] 
                  else ...[
                    Text(
                      comment,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkDetailContent(Map<String, dynamic> details) {
    final description = details['description'] ?? 'No description provided';
    final caption = details['caption'];
    final hoursSpent = details['hours_spent'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
              if (caption != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Caption: $caption',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 8.h),
        if (hoursSpent != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4.sp),
              border: Border.all(color: Colors.blue[300]!, width: 1),
            ),
            child: Text(
              'Hours spent: $hoursSpent',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenericDetailContent(Map<String, dynamic> details) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...details.entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.key.split('_').map((word) => 
                      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
                    ).join(' ')}: ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: '${entry.value}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
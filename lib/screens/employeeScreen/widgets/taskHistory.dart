import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TaskHistoryItemWidget extends StatelessWidget {
  final Map<String, dynamic> workDetail;
  final bool isLast;

  const TaskHistoryItemWidget({
    Key? key,
    required this.workDetail,
    this.isLast = false,
  }) : super(key: key);

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy h:mm a').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      String updatedBy = 'Unknown';
if (workDetail.containsKey('updated_by') && workDetail['updated_by'] is Map) {
  final Map<String, dynamic> updatedByMap = workDetail['updated_by'] as Map<String, dynamic>;
  updatedBy = updatedByMap['username']?.toString() ?? 'Unknown';
} 
else if (workDetail.containsKey('added_by') && workDetail['added_by'] is Map) {
  final Map<String, dynamic> addedByMap = workDetail['added_by'] as Map<String, dynamic>;
  updatedBy = addedByMap['username']?.toString() ?? 'Unknown';
}

print('Work detail: $workDetail');
print('Updated by: $updatedBy');
      
      final description = workDetail['description']?.toString() ?? 'No details provided';
      final date = formatDate(workDetail['date']?.toString());
      
      // Handle different field names for hours
     String hours = '0';
if (workDetail.containsKey('hours') && workDetail['hours'] != null) {
  hours = workDetail['hours'].toString();
} else if (workDetail.containsKey('hours_spent') && workDetail['hours_spent'] != null) {
  hours = workDetail['hours_spent'].toString();
}
      
      // Get collaborators if available
      final List collaborators = workDetail['collaborators'] is List ? workDetail['collaborators'] as List : [];
      
      // Calculate approximate content height for timeline
      final double descriptionLines = (description.length / 30).ceil().toDouble();
      final double approximateContentHeight = (descriptionLines * 20 + 80).h;
      
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 16.sp,
                height: 16.sp,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: approximateContentHeight, // Dynamic height based on content
                  color: Colors.grey[300],
                ),
            ],
          ),
          SizedBox(width: 16.w),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        updatedBy,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                
                // Work details card
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
                      // Hours logged
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$hours hours logged',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      
                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      // Fallback widget if any exception
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Text('Error displaying work detail: ${e.toString()}'),
          ),
        ),
      );
    }
  }
}
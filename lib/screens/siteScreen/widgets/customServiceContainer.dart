import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/screens/siteScreen/widgets/customText.dart';

class CustomServiceContainer extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String text;

  const  CustomServiceContainer({
    super.key,
    required this.items,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.w,
      height: 500.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r), // Optional rounded corners
      ),
      child: Padding(
        padding: EdgeInsets.all(27.r), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Centered Title
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.h), // Space below the title
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 15.h), // Space between items
                  child: CustomText(
                    text1: item['text1'],
                    imagePath: item['imagePath'], // Use imagePath instead of icon
                  ),
                );
              }),
              
                ],
              ),
            )
    
            // CustomText items
            // ...items.map((item) {
            //   return Padding(
            //     padding: EdgeInsets.only(bottom: 15.h), // Space between items
            //     child: CustomText(
            //       text1: item['text1'],
            //       imagePath: item['imagePath'], // Use imagePath instead of icon
            //     ),
            //   );
            // }).toList(),
          ],
        ),
      ),
    );
  }
}

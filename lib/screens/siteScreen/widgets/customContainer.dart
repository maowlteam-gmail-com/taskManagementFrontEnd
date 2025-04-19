import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainer extends StatelessWidget {
  final String imagePath;
  final String text;

  const CustomContainer({super.key, required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 247.w,
      height: 77.h,
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Row(
          
           crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 50.w,
                height: 50.h,
                //fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),  
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


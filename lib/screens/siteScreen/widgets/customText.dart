import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomText extends StatelessWidget {
  final String text1;
  final String imagePath;

   const CustomText({super.key, required this.text1, required this.imagePath, });

  @override
  Widget build(BuildContext context) {
    return Row(
     
      
      
      children: [
    
        Image.asset(
            imagePath,
            width: 50.w,
            height: 50.h,
            //fit: BoxFit.contain,
          ),
        SizedBox(width: 23.sp,),
        Text(text1, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700,color: Colors.white),)
    
      ],
    );
  }
}
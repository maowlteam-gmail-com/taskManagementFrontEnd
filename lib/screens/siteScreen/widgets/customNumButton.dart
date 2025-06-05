import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomNumButtom extends StatelessWidget {
  final String text1;
  final String text2;

  const CustomNumButtom({super.key, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217.w,
      height: 219.h,
      decoration: BoxDecoration(  
        color: Colors.black,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            topRight: Radius.circular(0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: Offset(0, 4),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text1,
           style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white
           ),
          ),
          SizedBox(height: 7.sp,),
          Text(
            text2,
           style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
             color: Colors.white
           ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {

  final String text;
  final VoidCallback? onPressed;


  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed

    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 192.w,
        height: 63.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.r),
          // borderRadius: BorderRadius.only(
          //   bottomLeft: Radius.circular(20),
          //   bottomRight: Radius.circular(20),
          //   topLeft: Radius.circular(20),
          //   topRight: Radius.circular(0)
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: Offset(0, 4), 
              blurRadius: 8,
            )
          ]
        ),        
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize:  20.sp,
              fontWeight: FontWeight.normal
            ),
          ),
        ),
      ),
    );
  }
}
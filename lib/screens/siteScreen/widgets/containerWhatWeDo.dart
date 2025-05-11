import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainerWidget extends StatelessWidget {
  const CustomContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size to calculate constraints
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: min(800.w, screenWidth * 0.95), // 90% of screen width or 686.w, whichever is smaller
          maxHeight: min(1200.h, screenHeight * 0.85), // 70% of screen height or 486.h, whichever is smaller
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(min(20.w, 20)), // Prevent padding from becoming too large
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading
                Text(
                  'What are we',
                  style: TextStyle(
                    fontSize: min(36.sp, 36), // Prevent font from becoming too large
                    fontWeight: FontWeight.w600,
                    // shadows: const [
                    //   Shadow(
                    //     color: Colors.black38,
                    //     offset: Offset(2, 2),
                    //     blurRadius: 4,
                    //   ),
                    // ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: min(20.h, 20)), // Prevent spacing from becoming too large
                // Content
                Text(
                  'MAOWL constitutes a bunch of technocrats who accelerate towards an emerging future. Our team is a group of striving talents with an indomitable passion to connect technology with Mankind. Our expertise in the field of Manufacturing opens doors to young minds out there to explore their share of Opportunities & nurturing their talents.',
                  style: TextStyle(
                    fontSize: min(24.sp, 36.sp), // Prevent font from becoming too large
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to find minimum of two numbers
double min(double a, double b) => a < b ? a : b;
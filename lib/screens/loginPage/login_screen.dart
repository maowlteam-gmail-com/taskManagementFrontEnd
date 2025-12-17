import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/screens/siteScreen/widgets/loginFormContainer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // bool isMobile = MediaQuery.of(context).size.width < 600;
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
      width: double.infinity,
      height: screenHeight,
      color: Color(0xFFD9D9D9),
      child: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: LoginFormContainer()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(),
          ),
        ),
      ),
    ),
    );
  }
}
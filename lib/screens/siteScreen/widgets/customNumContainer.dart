import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/siteScreen/widgets/customNumButton.dart';

class CustomNumContainer extends StatelessWidget {
  const CustomNumContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // Using GetX to check if we're on mobile
    bool isMobile = Get.width < 600;

    return Container(
      width: double.infinity,
      // Increased height for mobile view
      height: isMobile ? 800.h : 555.h,
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
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
        child: Column(
          children: [
            SizedBox(height: 30.h),
            Text(
              'We Take Pride in Our Numbers',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 28.sp : 36.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 44.h),
            // Make content scrollable for mobile
            Expanded(
              child: SingleChildScrollView(
                child: isMobile
                    ? _buildMobileLayout()
                    : _buildDesktopLayout(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomNumButtom(text1: '7+', text2: 'Years of\nExperience'),
        SizedBox(height: 20.h),
        CustomNumButtom(text1: '30+', text2: 'Business\nPartners'),
        SizedBox(height: 20.h),
        CustomNumButtom(text1: '50+', text2: 'Products\nDeveloped'),
        SizedBox(height: 20.h),
        CustomNumButtom(text1: '1000+', text2: 'Clients\nServed'),
        SizedBox(height: 20.h),
       CustomNumButtom(text1: '7+', text2: 'Field’s of\nExpertise'),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: [
        CustomNumButtom(text1: '7+', text2: 'Years of\nExperience'),
        CustomNumButtom(text1: '30+', text2: 'Business\nPartners'),
        CustomNumButtom(text1: '50+', text2: 'Products\nDeveloped'),
        CustomNumButtom(text1: '1000+', text2: 'Clients\nServed'),
       CustomNumButtom(text1: '7+', text2: 'Field’s of\nExpertise'),
      ],
    );
  }
}
// CreateTeamWidget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/adminScreen/controller/createTeamConroller.dart';
import 'package:maowl/screens/siteScreen/widgets/customButtom.dart';

class CreateTeamWidget extends StatelessWidget {
  final CreateTeamController controller = Get.put(CreateTeamController());

  CreateTeamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600.w,
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Create Team Member',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30.h),
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Team Member Name',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.black54),
                // helperText: 'Enter the username for the new team member',
                // helperStyle: TextStyle(color: Colors.black45),
              ),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => TextField(
                controller: controller.passwordController,

                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureText.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: () => controller.togglePasswordVisbility(),
                  ),
                ),
                obscureText: controller.obscureText.value,
              ),
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: 300.w,
              child: CustomButton(
                text: 'Submit',
                onPressed: () {
                  FocusScope.of(context).unfocus(); // Hide keyboard
                  controller.submitTeam();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

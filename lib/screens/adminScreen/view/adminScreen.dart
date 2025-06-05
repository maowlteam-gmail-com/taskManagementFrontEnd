import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/screens/adminScreen/controller/adminScreenController.dart';
import 'package:maowl/screens/adminScreen/view/homeScreen.dart';
import 'package:maowl/screens/adminScreen/widgets/addTask.dart';
import 'package:maowl/screens/adminScreen/widgets/createProject.dart';
import 'package:maowl/screens/adminScreen/widgets/createTeam.dart';
import 'package:maowl/screens/adminScreen/widgets/projects.dart';
import 'package:maowl/screens/adminScreen/widgets/sideMenu.dart';
import 'package:maowl/screens/adminScreen/widgets/employeeList.dart';

class AdminScreen extends StatelessWidget {
  AdminScreen({super.key});

  final AdminScreenController controller = Get.put(AdminScreenController());

  @override
  Widget build(BuildContext context) {
    bool isMobile = Get.width < 600;
    bool isTablet = Get.width >= 600 && Get.width < 1200;

    // Adjusting widths for each device type
    final double mobileMenuWidth = 200.w; // Slightly larger for mobile
    final double tabletMenuWidth = 80.w; // Keep tablet size the same
    final double desktopMenuWidth = 200.w; // Desktop size unchanged

    return Scaffold(
      key: const Key('admin_scaffold'),
      // Mobile drawer with adjusted width
      drawer:
          isMobile
              ? Drawer(
                key: const Key('mobile_drawer'),
                width: mobileMenuWidth,
                 shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              ),
                child: SideMenu(
                  isIconOnly: false, // Show text on mobile
                  isMobileView: true, // Flag as mobile
                  menuLayout: MenuLayout.vertical, // Text below icon for mobile
                  fixedWidth: mobileMenuWidth,
                ),
              )
              : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              SideMenu(
                isIconOnly: isTablet,
                fixedWidth: isTablet ? tabletMenuWidth : desktopMenuWidth,
                isMobileView: false,
                menuLayout:
                    MenuLayout.horizontal, // Text beside icon for desktop
              ),
            Expanded(
              child: Column(
                children: [
                  if (isMobile)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Builder(
                        builder: (context) {
                          return IconButton(
                            icon: Icon(Icons.menu, size: 20.sp),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Obx(() {
                        switch (controller.selectedOption.value) {
                          case "Home":
                            return HomeScreen();
                          case "Show Team":
                            return EmployeeList();
                          case "Add Team":
                            return CreateTeamWidget();
                          case "Create Task":
                            return CreateTaskContent();
                          case "Projects":
                             return Projects();
                          case "Create Project":
                            return CreateProject();
                          default:
                            return Center(child: HomeScreen());
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/screens/employeeScreen/controller/employeeController.dart';
import 'package:maowl/screens/employeeScreen/widgets/addTask.dart';
import 'package:maowl/screens/employeeScreen/widgets/employeeProjects.dart';
import 'package:maowl/screens/employeeScreen/widgets/otherAssignments.dart';
import 'package:maowl/screens/employeeScreen/widgets/sideMenu.dart';

class EmployeeScreen extends StatelessWidget {
  EmployeeScreen({super.key});
  
  final Employeecontroller controller = Get.put(Employeecontroller());
  
  @override
  Widget build(BuildContext context) {
    print("Building EmployeeScreen");
    bool isMobile = Get.width < 600;
    bool isTablet = Get.width >= 600 && Get.width < 1200;
    
    // Adjusting widths for each device type
    final double mobileMenuWidth = 80.w; // Slightly larger for mobile
    final double tabletMenuWidth = 70.w; // Keep tablet size the same
    final double desktopMenuWidth = 200.w; // Desktop size unchanged
    
    return Scaffold(
      key: const Key('employee_scaffold'),
      // Mobile drawer with adjusted width
      drawer: isMobile
        ? Drawer(
          key: const Key('employee_mobile_drawer'),
            width: mobileMenuWidth,
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
                menuLayout: MenuLayout.horizontal, // Text beside icon for desktop
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
                        print("Building Obx in EmployeeScreen");
                        final selectedOption = controller.selectedOption.value;
                        print("Selected option: $selectedOption");
                        
                        Widget contentWidget;
                        
                        if (selectedOption == "Home") {
                          contentWidget = EmployeeProjects();
                        } else if (selectedOption == "Create Task") {
                          contentWidget = CreateTaskContent();
                        } else if (selectedOption == "Other Assignments"){
                          contentWidget = OtherAssignmentsScreen();
                        }
                         else {
                          contentWidget = Center(
                            child: Text(
                              'Select an option from the menu',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }
                        
                        // Using a key here forces widget to rebuild correctly when switching options
                        return KeyedSubtree(
                          key: ValueKey<String>(selectedOption),
                          child: contentWidget,
                        );
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

class TeamList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 48),
          SizedBox(height: 16),
          Text('Team List View', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
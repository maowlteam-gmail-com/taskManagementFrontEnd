import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/adminScreen/controller/adminScreenController.dart';

// Enum to define menu layout options
enum MenuLayout {
  horizontal, // Text beside icon (for desktop)
  vertical, // Text below icon (for mobile)
}

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    this.isIconOnly = false,
    this.fixedWidth,
    this.isMobileView = false,
    this.menuLayout = MenuLayout.horizontal,
  });

  final bool isIconOnly;
  final double? fixedWidth;
  final bool isMobileView;
  final MenuLayout menuLayout;

  @override
  Widget build(BuildContext context) {
    final AdminScreenController controller = Get.find<AdminScreenController>();
    final double menuWidth =
        fixedWidth ?? (isMobileView ? 250.w : (isIconOnly ? 70.w : 200.w));
    final double iconSize = isMobileView ? 24.sp : (isIconOnly ? 22.sp : 20.sp);
    final double headerIconSize =
        isMobileView ? 30.sp : (isIconOnly ? 26.sp : 22.sp);
    final double headerHeight = isMobileView ? 80.h : 70.h;
    final double fontSize = isMobileView ? 14.sp : 12.sp;

    return Container(
      width: menuWidth,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Admin avatar and name section
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              height: headerHeight,
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 10.sp),
              child:
                  isMobileView
                      ? CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: headerIconSize / 2,
                        child: Text(
                          controller.adminName.value.isNotEmpty
                              ? controller.adminName.value[0].toUpperCase()
                              : 'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: headerIconSize * 0.6,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: headerIconSize / 2,
                            child: Text(
                              controller.adminName.value.isNotEmpty
                                  ? controller.adminName.value[0].toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: headerIconSize * 0.6,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Obx(
                              () => Text(
                                controller.adminName.value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          Divider(height: 1, color: Colors.white24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.home,
                    text: 'Home',
                    isIconOnly: isIconOnly,
                    isMobile: isMobileView,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    layout: menuLayout,
                    onTap: () {
                      controller.setSelectedOption("Home");
                      if (Get.width < 600)Get.back();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.add,
                    text: 'Add Team',
                    isIconOnly: isIconOnly,
                    isMobile: isMobileView,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    layout: menuLayout,
                    onTap: () {
                      controller.setSelectedOption("Add Team");
                      if (Get.width < 600) Get.back();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.task,
                    text: 'Create Task',
                    isIconOnly: isIconOnly,
                    isMobile: isMobileView,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    layout: menuLayout,
                    onTap: () {
                      controller.setSelectedOption("Create Task");
                      if (Get.width < 600) Get.back();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.group,
                    text: 'Show Team',
                    isIconOnly: isIconOnly,
                    isMobile: isMobileView,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    layout: menuLayout,
                    onTap: () {
                      controller.setSelectedOption("Show Team");

                      // Refresh employee data
                      controller.fetchEmployees();

                      if (Get.width < 600) Get.back();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    text: 'LogOut',
                    isIconOnly: isIconOnly,
                    isMobile: isMobileView,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    layout: menuLayout,
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text(
                            'LogOut',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to log out?',
                            style: TextStyle(color: Colors.black87),
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.sp),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black54),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                            ),
                            ElevatedButton(

                              onPressed: () async {
                                controller.logout();
                                Get.back();
                              },
                              child: Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.sp),
                                ),
                              ),
                            ),
                          ],
                          actionsPadding: EdgeInsets.symmetric(
                            horizontal: 16.sp,
                            vertical: 8.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required bool isIconOnly,
    required bool isMobile,
    required double iconSize,
    required double fontSize,
    required MenuLayout layout,
    required VoidCallback onTap,
  }) {
    if (isIconOnly) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8.0 : 6.0,
          vertical: 4.0,
        ),
        leading: Icon(icon, color: Colors.white, size: iconSize),
        title: null,
        onTap: onTap,
        dense: true,
        minLeadingWidth: 0,
      );
    }

    if (layout == MenuLayout.vertical) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: fontSize),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: isMobile ? 6.0 : 4.0,
      ),
      leading: Icon(icon, color: Colors.white, size: iconSize),
      title: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      onTap: onTap,
      dense: !isMobile,
      minLeadingWidth: 0,
    );
  }
}

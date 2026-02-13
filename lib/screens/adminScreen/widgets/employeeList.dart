import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/colors/app_colors.dart';
import 'package:maowl/functions/common_functions.dart';
import 'package:maowl/screens/adminScreen/controller/adminScreenController.dart';
import 'package:maowl/screens/adminScreen/widgets/employeeProjects.dart';

class EmployeeList extends StatelessWidget {
  EmployeeList({super.key});

  final AdminScreenController controller = Get.find<AdminScreenController>();
  final RxBool isEditingPassword = false.obs;
  final RxString newPassword = "".obs;
  final RxBool isViewingProjects = false.obs;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Get.width < 600;
    return Obx(
      () =>
          isViewingProjects.value
              ? EmployeeProjects(
                employee: controller.selectedEmployee.value!,
                onBack: () => isViewingProjects.value = false,
              )
              : _buildEmployeeListScreen(),
    );
  }

  void _showEditEmployeeDialog(Map<String, dynamic> employee) {
    final id = employee['_id'] ?? '';
    final currentName = employee['username'] ?? '';
    String? currentRole = employee['designation'];

    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    final List<String> roles = ['Staff', 'Intern', 'Team Lead'];
    String? selectedRole = currentRole;

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Edit Employee',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Rename
            Text(
              'Username',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'New Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            /// Role Dropdown
            Text(
              'Designation / Role',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value:
                  selectedRole == null
                      ? null
                      : roleToDisplay(selectedRole), // null → shows hint
              hint: const Text('Select role'),
              items:
                  roles
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
              onChanged: (value) {
                selectedRole = roleToApi(value!);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.sp),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = nameController.text.trim();

              if (newUsername.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Username cannot be empty",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (newUsername == currentName && selectedRole == currentRole) {
                Get.snackbar(
                  "No Changes",
                  "Please update username or role",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              debugPrint("Role now:" + (selectedRole ?? "null"));

              Get.back();

              await controller.updateEmployee(id, selectedRole!);
              if (newUsername != currentName) {
                await controller.renameEmployee(id, currentName, newUsername);
              }

              controller.selectDesignation("All");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.sp),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      ),
      barrierDismissible: false,
    );
  }

  // Show rename confirmation dialog
  void _showRenameDialog(Map<String, dynamic> employee) {
    final id = employee['_id'] ?? '';
    final currentName = employee['username'] ?? '';
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    Get.dialog(
      AlertDialog(
        title: Text(
          'Rename Employee',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter new username for $currentName:',
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'New Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.sp),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = nameController.text.trim();
              if (newUsername.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Username cannot be empty",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              if (newUsername == currentName) {
                Get.snackbar(
                  "Error",
                  "New username must be different from current username",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              await controller.renameEmployee(id, currentName, newUsername);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.sp),
              ),
            ),
            child: Text('Rename'),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      ),
      barrierDismissible: false,
    );
  }

  // Show delete confirmation dialog with GetX
  void _showDeleteConfirmation(Map<String, dynamic> employee) {
    final id = employee['_id'] ?? '';
    final name = employee['username'] ?? 'Unknown';

    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Employee',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Text(
          'Are you sure you want to delete $name?',
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
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.deleteEmployee(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.sp),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildEmployeeListScreen() {
    final chipList = ['All', 'Staff', 'Intern', 'Team Lead'];

    return Container(
      color: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.black, size: 48),
                SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () => controller.fetchEmployees(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.employees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 48),
                SizedBox(height: 16),
                Text('No employees found'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchEmployees(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Employees List',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children:
                        chipList
                            .map(
                              (chip) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(chip),
                                  onSelected:
                                      (value) =>
                                          controller.selectDesignation(chip),
                                  selectedColor: Colors.black,
                                  checkmarkColor: Colors.white,
                                  selected:
                                      chip ==
                                      controller.selectedDesignation.value,
                                  labelStyle: TextStyle(
                                    color:
                                        chip ==
                                                controller
                                                    .selectedDesignation
                                                    .value
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchEmployees(),
                child: ListView.separated(
                  itemCount: controller.filteredEmployees.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final employee = controller.filteredEmployees[index];
                    // Use username instead of name since that's what the API returns
                    final name = employee['username'] ?? 'Unknown';
                    final firstLetter =
                        name.isNotEmpty ? name[0].toUpperCase() : 'U';
                    final id = employee['_id'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Text(
                          firstLetter,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(name),
                      subtitle: Row(
                        children: [
                          Text('Password: '),
                          Obx(() {
                            final isEditing =
                                isEditingPassword.value &&
                                controller.selectedEmployee.value?['_id'] == id;

                            if (isEditing) {
                              return Expanded(
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Enter new password',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.sp,
                                      horizontal: 8.sp,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.sp),
                                    ),
                                  ),
                                  onChanged:
                                      (value) => newPassword.value = value,
                                ),
                              );
                            } else {
                              return Text(
                                '********',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              );
                            }
                          }),
                          SizedBox(width: 8.w),
                          Obx(() {
                            // Fixed here - using _id instead of id
                            final isEditing =
                                isEditingPassword.value &&
                                controller.selectedEmployee.value?['_id'] == id;

                            if (isEditing) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async {
                                      if (newPassword.value.isNotEmpty) {
                                        final success = await controller
                                            .updateEmployeePassword(
                                              id,
                                              newPassword.value,
                                            );
                                        if (success) {
                                          isEditingPassword.value = false;
                                          newPassword.value = "";
                                        }
                                      } else {
                                        Get.snackbar(
                                          "Error",
                                          "Password cannot be empty",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    tooltip: 'Save',
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    iconSize: 20.sp,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      isEditingPassword.value = false;
                                      newPassword.value = "";
                                    },
                                    tooltip: 'Cancel',
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    iconSize: 20.sp,
                                  ),
                                ],
                              );
                            } else {
                              return IconButton(
                                icon: Icon(Icons.edit, size: 20.sp),
                                onPressed: () {
                                  controller.setSelectedEmployee(employee);
                                  isEditingPassword.value = true;
                                },
                                tooltip: 'Edit Password',
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              );
                            }
                          }),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Rename Button
                          IconButton(
                            icon: Icon(
                              Icons.edit_note_rounded,
                              color: Colors.black,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              controller.setSelectedEmployee(employee);
                              _showEditEmployeeDialog(employee);
                            },
                            tooltip: 'Edit Employee',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              controller.setSelectedEmployee(employee);
                              _showDeleteConfirmation(employee);
                            },
                            tooltip: 'Delete Employee',
                          ),
                          SizedBox(width: 4.w),
                          // History Button
                          ElevatedButton(
                            onPressed: () {
                              controller.setSelectedEmployee(employee);
                              Get.toNamed(
                                '/employee-history',
                                arguments: {'employee': employee},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 12.sp),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.sp),
                              ),
                            ),
                            child: Text(
                              'History',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          ElevatedButton(
                            onPressed: () {
                              controller.setSelectedEmployee(employee);
                              isViewingProjects.value = true;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16.sp),
                            ),
                            child: Text('View'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

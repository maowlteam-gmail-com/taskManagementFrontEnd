import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maowl/screens/adminScreen/controller/adminScreenController.dart';
import 'package:maowl/screens/adminScreen/view/adminScreen.dart';
import 'package:maowl/screens/adminScreen/widgets/employeeHistoryScreen.dart';
import 'package:maowl/screens/adminScreen/widgets/taskHistoryWidget.dart';
import 'package:maowl/screens/employeeScreen/controller/employeeController.dart';
import 'package:maowl/screens/employeeScreen/view/employeeScreen.dart';
import 'package:maowl/screens/employeeScreen/widgets/taskDetails.dart';
import 'package:maowl/screens/employeeScreen/widgets/taskUpdateScreen.dart';
import 'package:maowl/screens/siteScreen/views/siteScreen.dart';
import 'package:maowl/util/dio_config.dart';


class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final token = storage.read('token');
    final role = storage.read('role');
    
    // If no token or token is empty, redirect to login
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: '/mainsite');
    }
    
    // Check if user is trying to access a route they shouldn't
    if (route == '/admin' && role != 'admin') {
      return const RouteSettings(name: '/mainsite');
    }
    
    if (route == '/employee' && role != 'employee') {
      return const RouteSettings(name: '/mainsite');
    }
    
    return null;
  }
}

// Create utility function to check if user is logged in
void checkAuthOnAppStart() {
  final storage = GetStorage();
  final token = storage.read('token');
  final role = storage.read('role');
  
  if (token != null && token.isNotEmpty) {
    // Direct to appropriate screen based on role
    if (role == 'admin') {
      Get.offAllNamed('/admin');
    } else if (role == 'employee') {
      Get.offAllNamed('/employee');
    }
  }
}

void main() async {
  await dotenv.load(fileName: "assets/.env");  
  await GetStorage.init();
  DioConfig.createDio();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 1024),
      builder: (context, child) {
        return GetMaterialApp(
          key: const Key('app_material_key'),
          debugShowCheckedModeBanner: false,
          initialRoute: _determineInitialRoute(), // Use function to determine initial route
          getPages: [
            GetPage(
              name: '/mainsite',
              page: () => SiteScreen(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: '/admin',
              page: () => AdminScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<AdminScreenController>(() => AdminScreenController(), fenix: true);
              }),
              middlewares: [AuthMiddleware()],
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: '/employee',
              page: () => EmployeeScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<Employeecontroller>(() => Employeecontroller(), fenix: true);
              }),
              middlewares: [AuthMiddleware()],
              transition: Transition.fadeIn,
            ),
              GetPage(
              name: '/taskDetails',
              page: () => TaskDetailScreen(task: Get.arguments,),             
              middlewares: [AuthMiddleware()],
              transition: Transition.fadeIn,
            ),
             GetPage(
              name: '/taskUpdate',
              page: () => TaskUpdateScreen(task: Get.arguments,),             
              middlewares: [AuthMiddleware()],
              transition: Transition.fadeIn,
            ),  
             GetPage(
              name: '/taskHistory',
              page: () => TaskHistoryWidget(),             
              middlewares: [AuthMiddleware()],
              transition: Transition.fadeIn,
            ),    
            GetPage(
  name: '/employee-history',
  page: () => EmployeeHistoryScreen(),
),                
          ],
        );
      },
    );
  }
  
  // Function to determine initial route based on stored credentials
  String _determineInitialRoute() {
    final storage = GetStorage();
    final token = storage.read('token');
    final role = storage.read('role');
    
    if (token != null && token.isNotEmpty) {
      if (role == 'admin') {
        return '/admin';
      } else if (role == 'employee') {
        return '/employee';
      }
    }
    return '/mainsite';
  }
}
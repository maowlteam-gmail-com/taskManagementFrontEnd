import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:maowl/screens/siteScreen/controllers/siteScreenController.dart';
import 'package:maowl/screens/siteScreen/widgets/containerWhatWeDo.dart';
import 'package:maowl/screens/siteScreen/widgets/customButtom.dart';
import 'package:maowl/screens/siteScreen/widgets/customContainer.dart';
import 'package:maowl/screens/siteScreen/widgets/customForm.dart';
import 'package:maowl/screens/siteScreen/widgets/customNumContainer.dart';
import 'package:maowl/screens/siteScreen/widgets/customServiceContainer.dart';
import 'package:maowl/screens/siteScreen/widgets/loginFormContainer.dart';

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  final PageController _pageController = PageController();
  final SiteScreenController _siteController = Get.put(SiteScreenController());

  @override
  Widget build(BuildContext context) {
    // Improved responsive breakpoint detection
    bool isMobile = MediaQuery.of(context).size.width < 600;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ScreenUtilInit(
      // Set design size based on device type
      designSize:
          isMobile
              ? const Size(375, 812) // Standard mobile design size
              : const Size(1440, 900), // Desktop design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            children: [
              // First Section - Make the entire section scrollable on mobile
              isMobile
                  ? SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,       
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 150.h,
                                    width: 150.w,
                                    child: Image.asset(
                                      'assets/images/M02_01.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 10.w,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            return IconButton(
                                              onPressed: () {
                                                Get.dialog(
                                                  Dialog(
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        vertical: 20.h,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(height: 20.h),
                                                          TextButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                child: Text(
                                                                  'Gallery',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors.black,
                                                                  ),
                                                                ),
                                                              )
                                                              .animate()
                                                              .fadeIn(
                                                                duration: 500.ms,
                                                              )
                                                              .slideX(),
                                                          SizedBox(height: 15.h),
                                                          TextButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                  _pageController
                                                                      .animateToPage(
                                                                        3,
                                                                        duration:
                                                                            Duration(
                                                                              milliseconds:
                                                                                  500,
                                                                            ),
                                                                        curve:
                                                                            Curves
                                                                                .easeInOut,
                                                                      );
                                                                },
                                                                child: Text(
                                                                  'Contact Us',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors.black,
                                                                  ),
                                                                ),
                                                              )
                                                              .animate()
                                                              .fadeIn(
                                                                duration: 500.ms,
                                                              )
                                                              .slideX(),
                                                          SizedBox(height: 15.h),
                                                          TextButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                  _pageController
                                                                      .animateToPage(
                                                                        6,
                                                                        duration:
                                                                            Duration(
                                                                              milliseconds:
                                                                                  500,
                                                                            ),
                                                                        curve:
                                                                            Curves
                                                                                .easeInOut,
                                                                      );
                                                                },
                                                                child: Text(
                                                                  'Login',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors.black,
                                                                  ),
                                                                ),
                                                              )
                                                              .animate()
                                                              .fadeIn(
                                                                duration: 500.ms,
                                                              )
                                                              .slideX(),
                                                          SizedBox(height: 20.h),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  barrierDismissible: true,
                                                );
                                              },
                                              icon: Icon(Icons.menu),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'MAOWL - The Abode of Manufacturing Tech',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 15.h),

                            // Auto-scrolling image carousel
                            SizedBox(
                              height: screenHeight * 0.4, // Set a reasonable height
                              child: AbsorbPointer(
                                // This prevents user interaction with the scroll view
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _siteController.scrollController,
                                  physics:
                                      NeverScrollableScrollPhysics(), // Disable manual scrolling
                                  child: Row(
                                    children:
                                        [
                                          'assets/images/pexels-cottonbro-4709364.jpg',
                                          'assets/images/pexels-jamalyahyayev-12863114.jpg',
                                          'assets/images/pexels-mikhail-nilov-9242925.jpg',
                                          'assets/images/pexels-pixabay-163125.jpg',
                                          'assets/images/pexels-thisisengineering-19895784.jpg',
                                          'assets/images/pexels-vanessa-loring-7869034.jpg',
                                        ].map((imagePath) {
                                          return Container(
                                            width: screenWidth * 0.9,
                                            height: screenHeight * 0.3,
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                            ),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                  imagePath,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.4),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                          ).animate().fadeIn(duration: 500.ms).slideX();
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            // Add bottom padding for better scrolling experience
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: screenHeight,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(40.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 300.h,
                                  width: 300.w,
                                  child: Image.asset(
                                    'assets/images/M02_01.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 20.w,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomButton(
                                        text: 'Gallery',
                                        onPressed: () {},
                                      ).animate().fadeIn(duration: 500.ms).slideX(),
                                      SizedBox(width: 30.w),
                                      CustomButton(
                                        text: 'Contact Us',
                                        onPressed: () {
                                          _pageController.animateToPage(
                                            3,
                                            duration: Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ).animate().fadeIn(duration: 500.ms).slideX(),
                                      SizedBox(width: 30.w),
                                      CustomButton(
                                        text: 'Login',
                                        onPressed: () {
                                          _pageController.animateToPage(
                                            6,
                                            duration: Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ).animate().fadeIn(duration: 500.ms).slideX(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'MAOWL - The Abode of Manufacturing Tech',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 30.h),

                          // Auto-scrolling image carousel
                          Expanded(
                            child: AbsorbPointer(
                              // This prevents user interaction with the scroll view
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _siteController.scrollController,
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable manual scrolling
                                child: Row(
                                  children:
                                      [
                                        'assets/images/pexels-cottonbro-4709364.jpg',
                                        'assets/images/pexels-jamalyahyayev-12863114.jpg',
                                        'assets/images/pexels-mikhail-nilov-9242925.jpg',
                                        'assets/images/pexels-pixabay-163125.jpg',
                                        'assets/images/pexels-thisisengineering-19895784.jpg',
                                        'assets/images/pexels-vanessa-loring-7869034.jpg',
                                      ].map((imagePath) {
                                        return Container(
                                          width: 889.w,
                                          height: 511.h,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                          ),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                imagePath,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.4),
                                                offset: Offset(0, 4),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ).animate().fadeIn(duration: 500.ms).slideX();
                                      }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

              // Second Section - Already has SingleChildScrollView for mobile
              SizedBox(
                width: double.infinity,
                height: isMobile ? null : screenHeight, // Remove fixed height for mobile
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(height: isMobile ? 15.h : 30.h),
                              Container(
                                width: double.infinity,
                                height: isMobile ? null : 800.h, // Remove fixed height for mobile
                                color: Colors.white,
                                child: buildServicesSection(),
                              ),
                              // Add bottom padding for mobile scrolling
                                      // if (isMobile) SizedBox(height: 20.h),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Third Section - Already has SingleChildScrollView for mobile
              isMobile
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            CustomServiceContainer(
                              items: [
                                {
                                  'text1': 'PCB Designing',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Fabrication',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Manufacturing',
                                  'imagePath': 'assets/images/Done.png',
                                },
                              ],
                              text: 'PCB',
                            ).animate().fadeIn(duration: 500.ms).slideY(),
                            SizedBox(height: 20.h),
                            CustomServiceContainer(
                              items: [
                                {
                                  'text1': 'Ideation',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Designing',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Prototyping',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Testing',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Manufacturing',
                                  'imagePath': 'assets/images/Done.png',
                                },
                              ],
                              text: 'R&D',
                            ).animate().fadeIn(duration: 500.ms).slideY(),
                            SizedBox(height: 20.h),
                            CustomServiceContainer(
                              items: [
                                {
                                  'text1': 'Product Engineering \nServices',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Designing',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'Software Services',
                                  'imagePath': 'assets/images/Done.png',
                                },
                                {
                                  'text1': 'PoC Development',
                                  'imagePath': 'assets/images/Done.png',
                                },
                              ],
                              text: 'IOT',
                            ).animate().fadeIn(duration: 500.ms).slideY(),
                            SizedBox(
                              height: 20.h,
                            ), // Bottom padding for scrolling
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: screenHeight,
                      child: Column(
                        children: [
                          SizedBox(height: 100.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomServiceContainer(
                                  items: [
                                    {
                                      'text1': 'PCB Designing',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Fabrication',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Manufacturing',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                  ],
                                  text: 'PCB',
                                ).animate().fadeIn(duration: 500.ms).slideX(),
                                SizedBox(width: 47.w),
                                CustomServiceContainer(
                                  items: [
                                    {
                                      'text1': 'Ideation',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Designing',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Prototyping',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Testing',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Manufacturing',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                  ],
                                  text: 'R&D',
                                ).animate().fadeIn(duration: 500.ms).slideX(),
                                SizedBox(width: 47.w),
                                CustomServiceContainer(
                                  items: [
                                    {
                                      'text1':
                                          'Product Engineering \nServices',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Designing',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'Software Services',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                    {
                                      'text1': 'PoC Development',
                                      'imagePath': 'assets/images/Done.png',
                                    },
                                  ],
                                  text: 'IOT',
                                ).animate().fadeIn(duration: 500.ms).slideX(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

              // Fourth Section (Contact Us) - Already has SingleChildScrollView for mobile
              isMobile
                  ? SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: screenHeight * 0.25,
                              child: Image.asset(
                                'assets/images/Frame 52.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 20.h,
                              ),
                              child:
                                  CustomFormWidget()
                                      .animate()
                                      .fadeIn(duration: 500.ms)
                                      .slideY(),
                            ),
                            SizedBox(height: 20.h),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 20.h,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                          'MAOWL LABS PRIVATE LIMITED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.sp,
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(duration: 500.ms)
                                        .slideY(),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'XV-44B,GROUND FLOOR, VELLAKKAL\n'
                                      'BUILDING,VKC PO, Vadacode,\n'
                                      'Ernakulam, Ernakulam- 682021, Kerala.\n'
                                      'PH: +91-7356487222.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                      textAlign: TextAlign.left,
                                    ).animate().fadeIn(duration: 500.ms).slideY(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ), // Bottom padding for scrolling
                          ],
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: screenHeight,
                      color: Colors.black,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Image.asset(
                              'assets/images/Frame 52.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            left: 100.w,
                            top: 40.h,
                            child:
                                CustomFormWidget()
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideX(),
                          ),
                          Positioned(
                            right: 150.w,
                            top: MediaQuery.of(context).size.height * 0.4,
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                          'MAOWL LABS PRIVATE LIMITED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24.sp,
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(duration: 500.ms)
                                        .slideY(),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'XV-44B,GROUND FLOOR, VELLAKKAL\n'
                                      'BUILDING,VKC PO, Vadacode,\n'
                                      'Ernakulam, Ernakulam- 682021, Kerala.\n'
                                      'PH: +91-7356487222.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24.sp,
                                      ),
                                      textAlign: TextAlign.left,
                                    ).animate().fadeIn(duration: 500.ms).slideY(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

              // Fifth Section
              isMobile
                  ? SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: Column(
                          children: [
                            // Black section at top
                            Container(
                              width: double.infinity,
                              height: screenHeight * 0.3,
                              color: Colors.black,
                            ),
                            // White section at bottom
                            Container(
                              width: double.infinity,
                              color: Colors.white,
                              padding: EdgeInsets.only(top: 50.h, bottom: 20.h),
                              child: CustomContainerWidget()
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slideY(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: screenHeight,
                      color: Colors.black,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: screenHeight * 0.5,
                            bottom: 0,
                            child: Container(color: Colors.black),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: screenHeight * 0.5,
                            bottom: 0,
                            child: Container(color: Colors.white),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: screenHeight * 0.5 - 100.h,
                            child:
                                CustomContainerWidget()
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideY(),
                          ),
                        ],
                      ),
                    ),

              // Sixth Section
              isMobile
                  ? SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        color: Color(0xFFD9D9D9),
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: SizedBox(
                            width: screenWidth * 0.9,
                            child:
                                SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  controller: _siteController.scrollController,
                                physics:
                                    NeverScrollableScrollPhysics(), 
                                  child: CustomNumContainer()
                                      .animate()
                                      .fadeIn(duration: 500.ms)
                                      .slideY(),
                                ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: screenHeight,
                      color: Color(0xFFD9D9D9),
                      child: Center(
                        child: SizedBox(
                          height: 555.h,
                          child:
                              CustomNumContainer()
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slideY(),
                        ),
                      ),
                    ),

              // Seventh Section (Login)
              Container(
                width: double.infinity,
                height: isMobile ? null : screenHeight, // Remove fixed height for mobile
                color: Color(0xFFD9D9D9),
                child: Center(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: isMobile ? null : 864.h, // Remove fixed height for mobile
                      width: isMobile ? screenWidth * 0.9 : null,
                      child:
                          LoginFormContainer()
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget buildServicesSection() {
  final SiteScreenController siteController = Get.put(SiteScreenController());
  return LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      if (isMobile) {
        // Make this section scrollable to avoid overflow
        return Container(
          width: double.infinity,
          color: Color(0xFFD9D9D9),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(),
                SizedBox(height: 20.h),

                // Image container on top for mobile
                Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.25,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/pexels-tanfeez-10699355.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(),

                SizedBox(height: 20.h),

                // Container widgets in a row layout with horizontal scrolling
                Column(
                  // Changed from Stack to Column to avoid positioning issues
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      color: Colors.black,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: siteController.scrollController,
                                  physics:
                                      NeverScrollableScrollPhysics(),
                        child: Row(
                          children: [
                            SizedBox(width: 10.w),
                            _buildMobileContainer(
                              'assets/images/Electronics.png',
                              'Electronics',
                            ),
                            SizedBox(width: 10.w),
                            _buildMobileContainer(
                              'assets/images/Electrical.png',
                              'Electrical',
                            ),
                            SizedBox(width: 10.w),
                            _buildMobileContainer(
                              'assets/images/Services.png',
                              'Mechanical',
                            ),
                            SizedBox(width: 10.w),
                            _buildMobileContainer(
                              'assets/images/Laptop Coding.png',
                              'Software',
                            ),
                            SizedBox(width: 10.w),
                            _buildMobileContainer(
                              'assets/images/embedded-system-3758538-3134263 1.png',
                              'Embedded',
                            ),
                            SizedBox(width: 10.w),
                          ]..animate().fadeIn(duration: 500.ms).slideX(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      } else {
        // Desktop layout (with adjusted height)
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height:
                  screenHeight * 0.7, // Use relative height instead of fixed
              color: Color(0xFFD9D9D9),
              child: Column(
                children: [
                  SizedBox(height: 39.h),
                  Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(),
                  // Make this section scrollable if needed
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.4, // Use relative width
                          0,
                          20.w, // Add some padding on the right
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomContainer(
                              imagePath: 'assets/images/Electronics.png',
                              text: 'Electronics',
                            ).animate().fadeIn(duration: 500.ms).slideX(),
                            SizedBox(height: 11.h),
                            CustomContainer(
                              imagePath: 'assets/images/Electrical.png',
                              text: 'Electrical',
                            ).animate().fadeIn(duration: 500.ms).slideX(),
                            SizedBox(height: 11.h),
                            CustomContainer(
                              imagePath: 'assets/images/Services.png',
                              text: 'Mechanical',
                            ).animate().fadeIn(duration: 500.ms).slideX(),
                            SizedBox(height: 11.h),
                            CustomContainer(
                              imagePath: 'assets/images/Laptop Coding.png',
                              text: 'Software',
                            ).animate().fadeIn(duration: 500.ms).slideX(),
                            SizedBox(height: 11.h),
                            CustomContainer(
                              imagePath:
                                  'assets/images/embedded-system-3758538-3134263 1.png',
                              text: 'Embedded',
                            ).animate().fadeIn(duration: 500.ms).slideX(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: screenWidth * 0.3, // Use relative width
                height: screenHeight * 0.7, // Match parent container height
                color: Colors.black,
              ),
            ),
            Positioned(
              left: screenWidth * 0.1, // Use relative positioning
              top: screenHeight * 0.15, // Use relative positioning
              child:
                  Container(
                    width: screenWidth * 0.35, // Use relative width
                    height: screenHeight * 0.5, // Use relative height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/pexels-tanfeez-10699355.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(),
            ),
          ],
        );
      }
    },
  );
}

// Helper method for mobile container items that are smaller and designed for a row layout
Widget _buildMobileContainer(String imagePath, String text) {
  return Container(
    width: 120.w,
    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(imagePath, height: 50.h, width: 50.w),
        SizedBox(height: 5.h),
        Text(
          text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ).animate().fadeIn(duration: 400.ms).slideX();
}

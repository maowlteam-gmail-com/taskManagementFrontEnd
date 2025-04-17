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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          // First Section
        // First Section with continuous auto-scrolling images
Container(
  width: double.infinity,
  height: MediaQuery.of(context).size.height,
  child: Column(
    children: [
      Padding(
        padding: EdgeInsets.all(40.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 300.h,
              width: 300.w,
              child: Image.asset(
                'assets/images/M02_01_ PNG.png',
                fit: BoxFit.contain,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20.w),
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
      ),
      
      SizedBox(height: 30.h),
      
      // Auto-scrolling image carousel
      Expanded(
        child: AbsorbPointer( // This prevents user interaction with the scroll view
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _siteController.scrollController,
            physics: NeverScrollableScrollPhysics(), // Disable manual scrolling
            child: Row(
              children: [
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
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
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
          // Second Section
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 800.h,
                          color: Colors.white,
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 615.h,
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
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.4,
                                                ),
                                                offset: Offset(4, 4),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(duration: 500.ms)
                                        .slideY(),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        600.w,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          CustomContainer(
                                                imagePath:
                                                    'assets/images/Electronics.png',
                                                text: 'Electronics',
                                              )
                                              .animate()
                                              .fadeIn(duration: 500.ms)
                                              .slideX(),
                                          SizedBox(height: 11.h),
                                          CustomContainer(
                                                imagePath:
                                                    'assets/images/Electrical.png',
                                                text: 'Electrical',
                                              )
                                              .animate()
                                              .fadeIn(duration: 500.ms)
                                              .slideX(),
                                          SizedBox(height: 11.h),
                                          CustomContainer(
                                                imagePath:
                                                    'assets/images/Services.png',
                                                text: 'Mechanical',
                                              )
                                              .animate()
                                              .fadeIn(duration: 500.ms)
                                              .slideX(),
                                          SizedBox(height: 11.h),
                                          CustomContainer(
                                                imagePath:
                                                    'assets/images/Laptop Coding.png',
                                                text: 'Software',
                                              )
                                              .animate()
                                              .fadeIn(duration: 500.ms)
                                              .slideX(),
                                          SizedBox(height: 11.h),
                                          CustomContainer(
                                                imagePath:
                                                    'assets/images/embedded-system-3758538-3134263 1.png',
                                                text: 'Embedded',
                                              )
                                              .animate()
                                              .fadeIn(duration: 500.ms)
                                              .slideX(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 471.w,
                                  height: 617.h,
                                  color: Colors.black,
                                ),
                              ),
                              Positioned(
                                left: 146.w,
                                top: 142.h,
                                child:
                                    Container(
                                      width: 523.w,
                                      height: 560.h,
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Third Section
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(height: 100.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      ).animate().fadeIn(duration: 500.ms).slideX(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fourth Section (Contact Us)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Stack(
              children: [
                Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAOWL LABS PRIVATE LIMITED',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.sp,
                            ),
                          ).animate().fadeIn(duration: 500.ms).slideY(),
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
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.5,
                  bottom: 0,
                  child: Container(color: Colors.black),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.5,
                  bottom: 0,
                  child: Container(color: Colors.white),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.5 - 100.h,
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
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
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
            height: MediaQuery.of(context).size.height,
            color: Color(0xFFD9D9D9),
            child: Center(
              child: SizedBox(
                height: 864.h,
                child:
                    LoginFormContainer()
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

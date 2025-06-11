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

class _SiteScreenState extends State<SiteScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final SiteScreenController _siteController = Get.put(SiteScreenController());
  late AnimationController _animationController;
  
  // Separate scroll controllers for auto-scrolling sections
  late ScrollController _heroScrollController;
  late ScrollController _servicesScrollController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _heroScrollController = ScrollController();
    _servicesScrollController = ScrollController();
    
    // Start auto-scrolling animations
    _startAutoScroll();
  }

  void _startAutoScroll() {
    // Auto-scroll for hero section
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _autoScrollHero();
      }
    });
    
    // Auto-scroll for services section
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        _autoScrollServices();
      }
    });
  }

  void _autoScrollHero() {
    if (!mounted || !_heroScrollController.hasClients) return;
    
    const double scrollDistance = 300.0;
    const duration = Duration(seconds: 3);
    
    _heroScrollController.animateTo(
      _heroScrollController.offset + scrollDistance,
      duration: duration,
      curve: Curves.linear,
    ).then((_) {
      if (mounted) {
        Future.delayed(Duration(milliseconds: 1000), () {
          if (mounted && _heroScrollController.hasClients) {
            // Reset to beginning or continue scrolling
            if (_heroScrollController.offset >= _heroScrollController.position.maxScrollExtent) {
              _heroScrollController.jumpTo(0);
            }
            _autoScrollHero();
          }
        });
      }
    });
  }

  void _autoScrollServices() {
    if (!mounted || !_servicesScrollController.hasClients) return;
    
    const double scrollDistance = 150.0;
    const duration = Duration(seconds: 2);
    
    _servicesScrollController.animateTo(
      _servicesScrollController.offset + scrollDistance,
      duration: duration,
      curve: Curves.linear,
    ).then((_) {
      if (mounted) {
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted && _servicesScrollController.hasClients) {
            if (_servicesScrollController.offset >= _servicesScrollController.position.maxScrollExtent) {
              _servicesScrollController.jumpTo(0);
            }
            _autoScrollServices();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heroScrollController.dispose();
    _servicesScrollController.dispose();
    super.dispose();
  }

  void _navigateToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ScreenUtilInit(
      designSize: isMobile ? const Size(375, 812) : const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(), // Better scroll physics
            children: [
              // Section 1: Hero Section
              _buildHeroSection(isMobile, screenHeight, screenWidth),
              
              // Section 2: Services Section
              _buildServicesSection(isMobile, screenHeight, screenWidth),
              
              // Section 3: Service Details Section
              _buildServiceDetailsSection(isMobile, screenHeight, screenWidth),
              
              // Section 4: Contact Section
              _buildContactSection(isMobile, screenHeight, screenWidth),
              
              // Section 5: About Section
              _buildAboutSection(isMobile, screenHeight, screenWidth),
              
              // Section 6: Stats Section
              _buildStatsSection(isMobile, screenHeight, screenWidth),
              
              // Section 7: Login Section
              _buildLoginSection(isMobile, screenHeight, screenWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(bool isMobile, double screenHeight, double screenWidth) {
    return Container(
      width: double.infinity,
      height: screenHeight,
      child: Column(
        children: [
          // Header
          _buildHeader(isMobile, screenWidth),
          
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Text(
              'MAOWL - The Abode of Manufacturing Tech',
              style: TextStyle(
                fontSize: isMobile ? 24.sp : 32.sp,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Image Carousel
          Expanded(
            child: Container(
              height: isMobile ? screenHeight * 0.4 : screenHeight * 0.6,
              child: ListView.builder(
                controller: _heroScrollController,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(), // Allow user interaction but smooth
                itemCount: 1000, // Large count for infinite scroll effect
                itemBuilder: (context, index) {
                  final images = [
                    'assets/images/pexels-cottonbro-4709364.jpg',
                    'assets/images/pexels-jamalyahyayev-12863114.jpg',
                    'assets/images/pexels-mikhail-nilov-9242925.jpg',
                    'assets/images/pexels-pixabay-163125.jpg',
                    'assets/images/pexels-thisisengineering-19895784.jpg',
                    'assets/images/pexels-vanessa-loring-7869034.jpg',
                  ];
                  
                  final imagePath = images[index % images.length];
                  
                  return Container(
                    width: isMobile ? screenWidth * 0.85 : 800.w,
                    height: isMobile ? screenHeight * 0.3 : 500.h,
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX();
                },
              ),
            ),
          ),
          
          // Navigation hint
          if (!isMobile)
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 32.sp,
                color: Colors.grey[600],
              ).animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1000.ms)
                .then()
                .slideY(duration: 1000.ms, begin: 0, end: 0.3)
                .then()
                .fadeOut(duration: 1000.ms),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.w : 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          SizedBox(
            height: isMobile ? 180.h : 200.h,
            width: isMobile ? 180.w : 200.w,
            child: Image.asset(
              'assets/images/M02_01.png',
              fit: BoxFit.contain,
            ),
          ),
          
          // Navigation
          if (isMobile)
            _buildMobileMenu()
          else
            _buildDesktopMenu(),
        ],
      ),
    );
  }

  Widget _buildMobileMenu() {
    return IconButton(
      onPressed: () {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuButton('Gallery', () {
                    Get.back();
                    // Add gallery navigation
                  }),
                  SizedBox(height: 20.h),
                  _buildMenuButton('Contact Us', () {
                    Get.back();
                    _navigateToPage(3);
                  }),
                  SizedBox(height: 20.h),
                  _buildMenuButton('Login', () {
                    Get.back();
                    _navigateToPage(6);
                  }),
                ],
              ),
            ),
          ),
          barrierDismissible: true,
        );
      },
      icon: Icon(Icons.menu, size: 28.sp),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX();
  }

  Widget _buildDesktopMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          text: 'Gallery',
          onPressed: () {},
        ).animate().fadeIn(duration: 500.ms).slideX(),
        SizedBox(width: 30.w),
        CustomButton(
          text: 'Contact Us',
          onPressed: () => _navigateToPage(3),
        ).animate().fadeIn(duration: 500.ms).slideX(),
        SizedBox(width: 30.w),
        CustomButton(
          text: 'Login',
          onPressed: () => _navigateToPage(6),
        ).animate().fadeIn(duration: 500.ms).slideX(),
      ],
    );
  }

  Widget _buildServicesSection(bool isMobile, double screenHeight, double screenWidth) {
    return Container(
      width: double.infinity,
      height: screenHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isMobile) {
            return Container(
              color: Color(0xFFD9D9D9),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(),
                  
                  SizedBox(height: 30.h),
                  
                  // Main image
                  Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage('assets/images/pexels-tanfeez-10699355.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  
                  SizedBox(height: 30.h),
                  
                  // Services scroll
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: SizedBox(
                          height: 120.h,
                          child: ListView.builder(
                            controller: _servicesScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            itemCount: 1000,
                            itemBuilder: (context, index) {
                              final services = [
                                {'icon': 'assets/images/Electronics.png', 'title': 'Electronics'},
                                {'icon': 'assets/images/Electrical.png', 'title': 'Electrical'},
                                {'icon': 'assets/images/Services.png', 'title': 'Mechanical'},
                                {'icon': 'assets/images/Laptop Coding.png', 'title': 'Software'},
                                {'icon': 'assets/images/embedded-system-3758538-3134263 1.png', 'title': 'Embedded'},
                              ];
                              
                              final service = services[index % services.length];
                              
                              return Container(
                                width: 120.w,
                                margin: EdgeInsets.symmetric(horizontal: 8.w),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      service['icon']!,
                                      height: 40.h,
                                      width: 40.w,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      service['title']!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 400.ms).slideX();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Desktop layout
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight,
                  color: Color(0xFFD9D9D9),
                ),
                
                // Black section
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenHeight,
                    color: Colors.black,
                  ),
                ),
                
                // Main image
                Positioned(
                  left: screenWidth * 0.05,
                  top: screenHeight * 0.2,
                  child: Container(
                    width: screenWidth * 0.35,
                    height: screenHeight * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage('assets/images/pexels-tanfeez-10699355.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(),
                ),
                
                // Services list
                Positioned(
                  right: 50.w,
                  top: 100.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Our Services',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(),
                      
                      SizedBox(height: 40.h),
                      
                      ...['Electronics', 'Electrical', 'Mechanical', 'Software', 'Embedded']
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final service = entry.value;
                        final icons = [
                          'assets/images/Electronics.png',
                          'assets/images/Electrical.png',
                          'assets/images/Services.png',
                          'assets/images/Laptop Coding.png',
                          'assets/images/embedded-system-3758538-3134263 1.png',
                        ];
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: CustomContainer(
                            imagePath: icons[index],
                            text: service,
                          ).animate(delay: Duration(milliseconds: 200 * index))
                            .fadeIn(duration: 500.ms)
                            .slideX(),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildServiceDetailsSection(bool isMobile, double screenHeight, double screenWidth) {
    return Container(
      width: double.infinity,
      height: screenHeight,
      color: Colors.white,
      child: isMobile
          ? SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    _buildServiceCard('PCB', [
                      'PCB Designing',
                      'Fabrication',
                      'Manufacturing',
                    ]),
                    SizedBox(height: 30.h),
                    _buildServiceCard('R&D', [
                      'Ideation',
                      'Designing',
                      'Prototyping',
                      'Testing',
                      'Manufacturing',
                    ]),
                    SizedBox(height: 30.h),
                    _buildServiceCard('IOT', [
                      '''Product Engineering 
                         Services''',
                      'Designing',
                      'Software Services',
                      'PoC Development',
                    ]),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildServiceCard('PCB', [
                    'PCB Designing',
                    'Fabrication',
                    'Manufacturing',
                  ]),
                  _buildServiceCard('R&D', [
                    'Ideation',
                    'Designing',
                    'Prototyping',
                    'Testing',
                    'Manufacturing',
                  ]),
                  _buildServiceCard('IOT', [
                    'Product Engineering Services',
                    'Designing',
                    'Software Services',
                    'PoC Development',
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceCard(String title, List<String> items) {
    return CustomServiceContainer(
      items: items.map((item) => {
        'text1': item,
        'imagePath': 'assets/images/Done.png',
      }).toList(),
      text: title,
    ).animate().fadeIn(duration: 600.ms).slideY();
  }

  Widget _buildContactSection(bool isMobile, double screenHeight, double screenWidth) {
    return Container(
      width: double.infinity,
      height: screenHeight,
      color: Colors.black,
      child: isMobile
          ? SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Frame 52.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        CustomFormWidget()
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(),
                        SizedBox(height: 40.h),
                        _buildContactInfo(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Frame 52.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 100.w,
                  top: 80.h,
                  child: CustomFormWidget()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(),
                ),
                Positioned(
                  right: 100.w,
                  bottom: 100.h,
                  child: _buildContactInfo(),
                ),
              ],
            ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MAOWL LABS PRIVATE LIMITED',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
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
              fontSize: 14.sp,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isMobile, double screenHeight, double screenWidth) {
    return Container(
      width: double.infinity,
      height: screenHeight,
      child: isMobile
          ? SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.4,
                    color: Colors.black,
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.all(20.w),
                    child: CustomContainerWidget()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.5,
                  color: Colors.black,
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
                  top: screenHeight * 0.3,
                  child: Center(
                    child: CustomContainerWidget()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsSection(bool isMobile, double screenHeight, double screenWidth) {
    return Container(
      width: double.infinity,
      height: screenHeight,
      color: Color(0xFFD9D9D9),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: CustomNumContainer()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(),
        ),
      ),
    );
  }

  Widget _buildLoginSection(bool isMobile, double screenHeight, double screenWidth) {
    return Container(
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
    );
  }
}
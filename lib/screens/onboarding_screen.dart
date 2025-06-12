import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/screens/login_screen.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // For auto-sliding carousel in first screen
  late PageController _imageCarouselController;
  late Timer _autoScrollTimer;
  int _currentImageIndex = 0;

  final List<String> _homeOnboardingImages = [
    'assets/images/home_onboarding1.jpg',
    'assets/images/home_onboardind2.jpg',
    'assets/images/home_onboarding3.jpg',
  ];

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Make Informed Decisions",
      description:
          "Smart home monitoring helps you make informed decisions about your home's environment and energy usage.",
      imageType: ImageType.carousel,
      imagePath: null, // Will use carousel
      color: const Color(0xFF6D4C41),
    ),
    OnboardingData(
      title: "Accurate Predictions at Your Fingertips",
      description:
          "Get accurate predictions and real-time data about temperature, humidity, and air quality in your home.",
      imageType: ImageType.gif,
      imagePath: 'assets/images/person.gif',
      color: const Color(0xFF8D6E63),
    ),
    OnboardingData(
      title: "Simple & Easy to Use",
      description:
          "Everything you need in one simple app. No complicated setup, just download and start using GaugeHaus.",
      imageType: ImageType.gif,
      imagePath: 'assets/images/home.gif',
      color: const Color(0xFFA1887F),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _imageCarouselController = PageController();
    // Start auto-scroll timer for first screen carousel
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage == 0 && mounted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _homeOnboardingImages.length;
        });
        _imageCarouselController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildImageWidget(OnboardingData data, int index) {
    if (index == 0) {
      // First screen - automatic sliding carousel
      return Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.r),
          child: PageView.builder(
            controller: _imageCarouselController,
            onPageChanged: (int pageIndex) {
              setState(() {
                _currentImageIndex = pageIndex;
              });
            },
            itemCount: _homeOnboardingImages.length,
            itemBuilder: (context, imageIndex) {
              return AnimatedBuilder(
                animation: _imageCarouselController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_imageCarouselController.position.haveDimensions) {
                    value = _imageCarouselController.page! - imageIndex;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }

                  return Transform.scale(
                    scale: Curves.easeOut.transform(value),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Image.asset(
                        _homeOnboardingImages[imageIndex],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.withOpacity(0.3),
                                  Colors.grey.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                      milliseconds: 1000 + (imageIndex * 200)),
                                  curve: Curves.elasticOut,
                                  builder: (context, animValue, child) {
                                    return Transform.scale(
                                      scale: animValue,
                                      child: Icon(
                                        Icons.home_rounded,
                                        size: 60.sp,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Home ${imageIndex + 1}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    } else {
      // Second and third screens - GIF images with transparent background
      return Container(
        width: 280.w,
        height: 280.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
              spreadRadius: 0.r,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.r),
          child: Container(
            color: Colors.transparent,
            child: Image.asset(
              data.imagePath!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        index == 1
                            ? Icons.analytics_rounded
                            : Icons.touch_app_rounded,
                        size: 70.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        index == 1 ? 'Analytics' : 'Touch',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  // Helper method to get current color safely
  Color get currentColor {
    if (_currentPage >= 0 && _currentPage < _onboardingData.length) {
      return _onboardingData[_currentPage].color;
    }
    return const Color(0xFF6D4C41); // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
            colors: [
              currentColor,
              currentColor.withOpacity(0.8),
              currentColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Skip button
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.w,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () => _navigateToLogin(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Enhanced PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    if (page >= 0 && page < _onboardingData.length) {
                      setState(() {
                        _currentPage = page;
                      });
                    }
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    if (index >= 0 && index < _onboardingData.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Image widget (carousel for first screen, GIF for others)
                                    _buildImageWidget(
                                        _onboardingData[index], index),

                                    // Add carousel indicators for first screen
                                    if (index == 0) ...[
                                      SizedBox(height: 20.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          _homeOnboardingImages.length,
                                          (imageIndex) => AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            width:
                                                _currentImageIndex == imageIndex
                                                    ? 20.w
                                                    : 8.w,
                                            height: 8.h,
                                            decoration: BoxDecoration(
                                              color: _currentImageIndex ==
                                                      imageIndex
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],

                                    SizedBox(height: 30.h),

                                    // Enhanced Title with flexible font size
                                    Text(
                                      _onboardingData[index].title,
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth < 350
                                            ? 24.sp
                                            : 28.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 20.h),

                                    // Enhanced Description with flexible font size
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Text(
                                        _onboardingData[index].description,
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth < 350
                                              ? 15.sp
                                              : 16.sp,
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),

              // Enhanced bottom section
              Container(
                padding: EdgeInsets.all(30.w),
                child: Column(
                  children: [
                    // Enhanced page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          width: _currentPage == index ? 35.w : 12.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: _currentPage == index
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 8.r,
                                      offset: Offset(0, 2.h),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Enhanced button with better styling
                    Container(
                      width: double.infinity,
                      height: 56.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _navigateToLogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: currentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Enhanced Back button
                    if (_currentPage > 0) ...[
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    _imageCarouselController.dispose();
    super.dispose();
  }
}

enum ImageType { carousel, gif }

class OnboardingData {
  final String title;
  final String description;
  final ImageType imageType;
  final String? imagePath;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imageType,
    this.imagePath,
    required this.color,
  });
}

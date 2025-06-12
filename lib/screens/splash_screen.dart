import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/app_cubit/app_states.dart';
import 'package:gauge_haus/main.dart';

import '../app_cubit/app_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to onboarding screen after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => startScreen!),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppCubitState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // House icon with shadow and gradient
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2.r,
                        blurRadius: 10.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 60.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30.h),
                // GaugeHaus text with better typography
                Text(
                  'GaugeHaus',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                // Subtitle
                Text(
                  'Smart Home Monitoring',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 40.h),
                // Loading indicator
                SizedBox(
                  width: 30.w,
                  height: 30.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

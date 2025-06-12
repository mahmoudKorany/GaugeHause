import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/app_cubit/app_cubit.dart';
import 'package:gauge_haus/screens/home_screen.dart';
import 'package:gauge_haus/screens/login_screen.dart';
import 'package:gauge_haus/screens/onboarding_screen.dart';
import 'package:gauge_haus/screens/splash_screen.dart';
import 'package:gauge_haus/shared/cache_helper.dart';
import 'package:gauge_haus/shared/dio_helper.dart';

Widget? startScreen;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await DioHelper.init();
  bool isOnboarding = CacheHelper.getData(key: 'onBoarding') ?? false;
  String? token = CacheHelper.getData(key: 'token');
  String userId = CacheHelper.getData(key: 'userId') ?? '';
  if (isOnboarding) {
    if (token != null) {
      startScreen =
          const HomeScreen();
    } else {
      startScreen =
          const LoginPage();
    }
  } else {
    startScreen =
        const OnboardingScreen();
  }
  runApp(MyApp(userId: userId));
}

class MyApp extends StatelessWidget {
  final String userId;
  const MyApp({super.key, required this.userId});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocProvider(
        create: (context) => AppCubit()..getUserData(userId),
        child: ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'GaugeHaus',
              theme: ThemeData(
                primarySwatch: Colors.brown,
              ),
              home: const SplashScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}

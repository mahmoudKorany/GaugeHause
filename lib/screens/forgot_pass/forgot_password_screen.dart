import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/screens/forgot_pass/verification_screen.dart';
import 'package:gauge_haus/shared/dio_helper.dart';
import 'package:gauge_haus/shared/url_constants.dart';
import 'package:dio/dio.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_emailController.text.isEmpty) {
      _showMessage('Please enter your email address', isError: true);
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showMessage('Please enter a valid email address', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Make actual API call to forgot password endpoint
      final response = await DioHelper.postData(
        url: UrlConstants.forgetPassword,
        data: {
          "email": _emailController.text.trim(),
        },
      );

      setState(() {
        isLoading = false;
      });

      // Check if the request was successful
      if (response.statusCode == 200) {
        _showMessage('Verification code sent to your email!');

        // Navigate to verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerificationScreen(email: _emailController.text),
          ),
        );
      } else {
        // Handle error response
        String errorMessage =
            'Failed to send verification code. Please try again.';
        if (response.data != null && response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
        _showMessage(errorMessage, isError: true);
      }
    } on DioException catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = 'An error occurred. Please try again.';

      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          errorMessage = 'Email address not found. Please check your email.';
        } else if (e.response!.statusCode == 400) {
          errorMessage = 'Invalid email address format.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      _showMessage(errorMessage, isError: true);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage('An unexpected error occurred. Please try again.',
          isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF583B2D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE1CFC3),
              Color(0xFFA37B61),
              Color(0xFF583B2D),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 0.6, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10.r,
                                offset: Offset(0, 5.h),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon
                                Container(
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF583B2D)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lock_reset_rounded,
                                    size: 50.sp,
                                    color: const Color(0xFF583B2D),
                                  ),
                                ),
                                SizedBox(height: 24.h),

                                // Title
                                Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),

                                // Subtitle
                                Text(
                                  'Enter your email address and we\'ll send you a verification code to reset your password.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 32.h),

                                // Email Field
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF583B2D)),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),

                                // Send Code Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading ? null : _handleSendCode,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF583B2D),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : Text(
                                            'Send Verification Code',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // Back to Login
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: const Color(0xFF583B2D),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

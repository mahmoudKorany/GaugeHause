import 'package:flutter/material.dart';
import 'package:gauge_haus/screens/forgot_pass/reset_password_screen.dart';
import 'package:gauge_haus/shared/dio_helper.dart';
import 'package:gauge_haus/shared/url_constants.dart';
import 'package:dio/dio.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool isLoading = false;
  bool isResending = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    String code = _controllers.map((controller) => controller.text).join();

    if (code.length != 6) {
      _showMessage('Please enter the complete verification code',
          isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Make actual API call to verify OTP
      final response = await DioHelper.postData(
        url: UrlConstants.verifyOTP,
        data: {
          "email": widget.email,
          "otp": code,
        },
      );

      setState(() {
        isLoading = false;
      });

      // Check if the request was successful
      if (response.statusCode == 200) {
        _showMessage('Code verified successfully!');

        // Navigate to reset password screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: widget.email),
          ),
        );
      } else {
        // Handle error response
        String errorMessage = 'Invalid verification code. Please try again.';
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
        if (e.response!.statusCode == 400) {
          errorMessage =
              'Invalid verification code. Please check and try again.';
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'Verification code not found or expired.';
        } else if (e.response!.statusCode == 410) {
          errorMessage =
              'Verification code has expired. Please request a new one.';
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

  Future<void> _handleResendCode() async {
    setState(() {
      isResending = true;
    });

    try {
      // Make actual API call to forgot password endpoint to resend code
      final response = await DioHelper.postData(
        url: UrlConstants.forgetPassword,
        data: {
          "email": widget.email,
        },
      );

      setState(() {
        isResending = false;
      });

      // Check if the request was successful
      if (response.statusCode == 200) {
        _showMessage('Verification code sent again to your email!');

        // Clear the current input fields
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on the first input field
        _focusNodes[0].requestFocus();
      } else {
        // Handle error response
        String errorMessage =
            'Failed to resend verification code. Please try again.';
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
        isResending = false;
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
        isResending = false;
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
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF583B2D).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified_user_rounded,
                                  size: 50,
                                  color: Color(0xFF583B2D),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              const Text(
                                'Verify Your Email',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                'We sent a 6-digit verification code to\n${widget.email}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Code Input Fields
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: 45,
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF583B2D)),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 5) {
                                          _focusNodes[index + 1].requestFocus();
                                        } else if (value.isEmpty && index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                        }
                                      },
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 24),

                              // Verify Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      isLoading ? null : _handleVerifyCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF583B2D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text(
                                          'Verify Code',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Resend Code
                              TextButton(
                                onPressed:
                                    isResending ? null : _handleResendCode,
                                child: isResending
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF583B2D),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Sending...',
                                            style: TextStyle(
                                              color: Color(0xFF583B2D),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Didn\'t receive code? Resend',
                                        style: TextStyle(
                                          color: Color(0xFF583B2D),
                                          fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }
}

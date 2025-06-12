import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/shared/shared_widgets.dart';

class WhyPredictionScreen extends StatefulWidget {
  const WhyPredictionScreen({super.key});

  @override
  State<WhyPredictionScreen> createState() => _WhyPredictionScreenState();
}

class _WhyPredictionScreenState extends State<WhyPredictionScreen>
    with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1000),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: (MediaQuery.of(context).size.height / 3).h,
      color: const Color(0xFFF5F1EC),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 15.h),
        child: Column(
          children: [
            // Back button row
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF86755B).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: pop(context),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 10.h),
            // Expanded images row
            Expanded(
              child: Row(
                children: [
                  _buildEnhancedImage('assets/images/Frame 91.png', 0),
                  SizedBox(width: 4.w),
                  _buildEnhancedImage('assets/images/Frame 92.png', 1),
                  SizedBox(width: 4.w),
                  _buildEnhancedImage('assets/images/Frame 93.png', 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedImage(String assetPath, int index) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * _animationController.value),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main title section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8D6E63), Color(0xFFA1887F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8D6E63).withOpacity(0.3),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 32.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Let us explain why',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Understanding the power of AI-driven property predictions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Long explanation section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How Our Prediction System Works',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8D6E63),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  '''Our advanced artificial intelligence system analyzes thousands of real estate data points to provide you with the most accurate property price predictions available in the market.

Using machine learning algorithms, we consider multiple factors that influence property values:

• Location and neighborhood characteristics
• Property size, type, and condition
• Market trends and historical data
• Economic indicators and demographics
• Nearby amenities and infrastructure
• Comparable sales in the area

Our AI model has been trained on extensive datasets from the Egyptian real estate market, ensuring that predictions are tailored specifically to local conditions and market dynamics.

The system continuously learns and improves its accuracy by analyzing new market data, recent transactions, and changing economic conditions. This means that every prediction becomes more precise over time.

Whether you're buying your first home, investing in real estate, or simply curious about property values in your area, our prediction tool provides you with reliable, data-driven insights that can help you make informed decisions.

The technology behind our predictions combines traditional statistical methods with cutting-edge deep learning techniques, resulting in predictions that are not only accurate but also take into account the unique characteristics of the Egyptian property market.

Trust in our AI-powered predictions to guide your real estate journey with confidence and precision.''',
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),

                // Feature highlights
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1EC),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Benefits:',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8D6E63),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildBenefitItem('🎯', 'High Accuracy',
                          'Up to 95% prediction accuracy'),
                      _buildBenefitItem(
                          '⚡', 'Instant Results', 'Get predictions in seconds'),
                      _buildBenefitItem('📊', 'Market Insights',
                          'Detailed analysis and trends'),
                      _buildBenefitItem(
                          '🔄', 'Always Updated', 'Real-time data integration'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

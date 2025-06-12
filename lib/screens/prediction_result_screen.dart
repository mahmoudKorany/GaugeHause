import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/screens/why_prediction_screen.dart';
import 'package:gauge_haus/shared/shared_widgets.dart';

class PredictionResultScreen extends StatefulWidget {
  final String? predictedPrice;
  final Map<String, dynamic>? propertyData;

  const PredictionResultScreen({
    Key? key,
    this.predictedPrice,
    this.propertyData,
  }) : super(key: key);

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSaved = false;

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
      begin: const Offset(0, 0.5),
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

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isSaved ? 'Property saved!' : 'Property removed from saved'),
        backgroundColor: const Color(0xFF8D6E63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildExplanationRow(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Image (without status bar)
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // House Image Background
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/home.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Back Button
                  Positioned(
                    top: 60.h,
                    left: 20.w,
                    child: pop(context),
                  ),
                ],
              ),
            ),

            // Bottom Card
            Expanded(
              flex: 6,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Your Home',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFF8D6E63),
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'giza, fisal, cairo, Egypt',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Property Info
                        _buildPropertyInfo(),

                        SizedBox(height: 24.h),

                        // Price Section
                        _buildPriceSection(),

                        const Spacer(),

                        // Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyInfo() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.home_outlined,
                color: const Color(0xFF8D6E63), size: 20.sp),
            SizedBox(width: 8.w),
            Text('Area: ', style: TextStyle(fontSize: 16.sp)),
            GestureDetector(
              onTap: () {
                // Handle area tap
              },
              child: Text(
                '280 M',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(Icons.chair_outlined,
                color: const Color(0xFF8D6E63), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Receptions: 2-Reception',
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(Icons.bed_outlined,
                color: const Color(0xFF8D6E63), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Rooms: 7-Rooms',
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(Icons.list_alt, color: const Color(0xFF8D6E63), size: 20.sp),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                // Handle show more
              },
              child: Text(
                'Show 3-MORE',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF8D6E63).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '💰',
              style: TextStyle(fontSize: 24.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predicted Price',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.predictedPrice ?? '750,000 L.E',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Save Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleSave,
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
              size: 20.sp,
            ),
            label: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6E63),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
          ),
        ),
        SizedBox(width: 16.w),

        // Why Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhyPredictionScreen(),
                  ));
            },
            icon: Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 20.sp,
            ),
            label: Text(
              'Why',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}

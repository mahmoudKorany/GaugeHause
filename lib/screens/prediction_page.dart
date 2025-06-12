import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/screens/prediction_result_screen.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({Key? key}) : super(key: key);

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedType = 'Villa';
  String _selectedLocation = 'Cairo';
  String _selectedCondition = 'Excellent';
  bool _hasGarden = false;
  bool _hasParking = false;
  bool _isLoading = false;
  String? _predictedPrice;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _propertyTypes = [
    'Villa',
    'Apartment',
    'House',
    'Studio',
    'Penthouse'
  ];
  final List<String> _locations = [
    'Cairo',
    'Giza',
    'Alexandria',
    'New Cairo',
    'Sheikh Zayed',
    'Maadi',
    'Zamalek'
  ];
  final List<String> _conditions = [
    'Excellent',
    'Very Good',
    'Good',
    'Fair',
    'Needs Renovation'
  ];

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
    _areaController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _predictPrice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _predictedPrice = null;
    });

    // Simulate AI prediction process
    await Future.delayed(const Duration(seconds: 3));

    // Simulate price calculation based on inputs
    double basePrice = 1000000; // Base price
    double area = double.tryParse(_areaController.text) ?? 100;
    int bedrooms = int.tryParse(_bedroomsController.text) ?? 2;
    int bathrooms = int.tryParse(_bathroomsController.text) ?? 1;
    int age = int.tryParse(_ageController.text) ?? 5;

    // Simple calculation simulation
    double calculatedPrice =
        basePrice + (area * 8000) + (bedrooms * 150000) + (bathrooms * 100000);

    // Adjust based on location
    switch (_selectedLocation) {
      case 'New Cairo':
      case 'Sheikh Zayed':
        calculatedPrice *= 1.5;
        break;
      case 'Zamalek':
      case 'Maadi':
        calculatedPrice *= 1.3;
        break;
      case 'Alexandria':
        calculatedPrice *= 0.7;
        break;
    }

    // Adjust based on condition
    switch (_selectedCondition) {
      case 'Excellent':
        calculatedPrice *= 1.2;
        break;
      case 'Very Good':
        calculatedPrice *= 1.1;
        break;
      case 'Fair':
        calculatedPrice *= 0.9;
        break;
      case 'Needs Renovation':
        calculatedPrice *= 0.7;
        break;
    }

    // Adjust based on age
    calculatedPrice -= (age * 20000);

    // Add extras
    if (_hasGarden) calculatedPrice += 200000;
    if (_hasParking) calculatedPrice += 150000;

    final String formattedPrice =
        '${(calculatedPrice / 1000).toStringAsFixed(0)},000 L.E';

    setState(() {
      _isLoading = false;
      _predictedPrice = formattedPrice;
    });

    _showSuccessMessage();

    // Navigate to result screen after short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResultScreen(
            predictedPrice: formattedPrice,
            propertyData: {
              'type': _selectedType,
              'location': _selectedLocation,
              'area': _areaController.text,
              'bedrooms': _bedroomsController.text,
              'bathrooms': _bathroomsController.text,
              'condition': _selectedCondition,
              'age': _ageController.text,
              'hasGarden': _hasGarden,
              'hasParking': _hasParking,
            },
          ),
        ),
      );
    });
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Price prediction completed successfully!'),
        backgroundColor: const Color(0xFF8D6E63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Property Details'),
                          SizedBox(height: 16.h),
                          _buildPropertyTypeDropdown(),
                          SizedBox(height: 16.h),
                          _buildLocationDropdown(),
                          SizedBox(height: 16.h),
                          _buildAreaField(),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(child: _buildBedroomsField()),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildBathroomsField()),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('Property Condition'),
                          SizedBox(height: 16.h),
                          _buildConditionDropdown(),
                          SizedBox(height: 16.h),
                          _buildAgeField(),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('Additional Features'),
                          SizedBox(height: 16.h),
                          _buildCheckboxes(),
                          SizedBox(height: 32.h),
                          _buildPredictButton(),
                          if (_predictedPrice != null) ...[
                            SizedBox(height: 24.h),
                            _buildResultCard(),
                          ],
                        ],
                      ),
                    ),
                  ),
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
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF86755B), Color(0xFFC2BAA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Prediction',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Enter your property details for accurate pricing',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.analytics_rounded, color: Colors.white, size: 30.sp),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF8D6E63),
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Property Type',
        prefixIcon: const Icon(Icons.home_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      items: _propertyTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) => setState(() => _selectedType = value!),
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLocation,
      decoration: InputDecoration(
        labelText: 'Location',
        prefixIcon: const Icon(Icons.location_on_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      items: _locations.map((location) {
        return DropdownMenuItem(value: location, child: Text(location));
      }).toList(),
      onChanged: (value) => setState(() => _selectedLocation = value!),
    );
  }

  Widget _buildAreaField() {
    return TextFormField(
      controller: _areaController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Area (Square Meters)',
        prefixIcon: const Icon(Icons.square_foot),
        suffixText: 'm²',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the area';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return 'Please enter a valid area';
        }
        return null;
      },
    );
  }

  Widget _buildBedroomsField() {
    return TextFormField(
      controller: _bedroomsController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Bedrooms',
        prefixIcon: const Icon(Icons.bed_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildBathroomsField() {
    return TextFormField(
      controller: _bathroomsController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Bathrooms',
        prefixIcon: const Icon(Icons.bathroom_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCondition,
      decoration: InputDecoration(
        labelText: 'Property Condition',
        prefixIcon: const Icon(Icons.star_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      items: _conditions.map((condition) {
        return DropdownMenuItem(value: condition, child: Text(condition));
      }).toList(),
      onChanged: (value) => setState(() => _selectedCondition = value!),
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Property Age (Years)',
        prefixIcon: const Icon(Icons.calendar_today_rounded),
        suffixText: 'years',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the property age';
        }
        return null;
      },
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text('Has Garden', style: TextStyle(fontSize: 16.sp)),
          subtitle:
              Text('Private garden or yard', style: TextStyle(fontSize: 14.sp)),
          value: _hasGarden,
          onChanged: (value) => setState(() => _hasGarden = value!),
          activeColor: const Color(0xFF8D6E63),
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Has Parking', style: TextStyle(fontSize: 16.sp)),
          subtitle:
              Text('Private parking space', style: TextStyle(fontSize: 14.sp)),
          value: _hasParking,
          onChanged: (value) => setState(() => _hasParking = value!),
          activeColor: const Color(0xFF8D6E63),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPredictButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _predictPrice,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8D6E63),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Analyzing...',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_rounded,
                      color: Colors.white, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Predict Price',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
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
        children: [
          Icon(
            Icons.monetization_on_rounded,
            color: Colors.white,
            size: 40.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'Predicted Price',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _predictedPrice!,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Based on current market trends and property details',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

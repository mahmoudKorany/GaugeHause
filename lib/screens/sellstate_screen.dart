import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/widgets/map_location_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

class SellStateScreen extends StatefulWidget {
  const SellStateScreen({super.key});

  @override
  State<SellStateScreen> createState() => _SellStateScreenState();
}

class _SellStateScreenState extends State<SellStateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _livingroomsController = TextEditingController();
  final _kitchenController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _compoundNameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _deliveryDateController = TextEditingController();

  // Dropdown selections
  String _selectedPropertyType = 'Apartment';
  String _selectedCity = 'Cairo';
  bool _isFurnished = false;
  bool _isLoading = false;
  List<String> _selectedImages = [];

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Property types
  final List<String> _propertyTypes = [
    'Apartment',
    'Villa',
    'House',
    'Studio',
    'Penthouse',
    'Duplex',
    'Townhouse'
  ];

  // Cities
  final List<String> _cities = [
    'Cairo',
    'Giza',
    'Alexandria',
    'New Cairo',
    'Sheikh Zayed',
    'Maadi',
    'Zamalek',
    'Nasr City',
    'Heliopolis',
    'October City'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDefaultValues();
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

  void _initializeDefaultValues() {
    // Set default coordinates for Cairo
    _latitudeController.text = '30.0444';
    _longitudeController.text = '31.2357';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _livingroomsController.dispose();
    _kitchenController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _compoundNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8D6E63),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _deliveryDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? pickedFiles = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((file) => file.path).toList());
        });
      }
    } catch (e) {
      // Handle the error gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting images: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create and use the estate data object
    final estateData = {
      "title": _titleController.text,
      "propertyType": _selectedPropertyType,
      "location": {
        "type": "Point",
        "coordinates": [
          double.tryParse(_longitudeController.text) ?? 31.2357,
          double.tryParse(_latitudeController.text) ?? 30.0444
        ],
        "address": _addressController.text,
        "city": _selectedCity
      },
      "price": int.tryParse(_priceController.text) ?? 0,
      "description": _descriptionController.text,
      "bedrooms": int.tryParse(_bedroomsController.text) ?? 0,
      "bathrooms": int.tryParse(_bathroomsController.text) ?? 0,
      "livingrooms": int.tryParse(_livingroomsController.text) ?? 0,
      "kitchen": int.tryParse(_kitchenController.text) ?? 0,
      "area": int.tryParse(_areaController.text) ?? 0,
      "compoundName": _compoundNameController.text,
      "furnished": _isFurnished,
      "deliveryDate": _deliveryDateController.text,
      "images": _selectedImages
    };

    // Simulate API call - here you would typically send estateData to your backend
    print('Estate Data: $estateData'); // For debugging
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success message
    _showSuccessMessage();
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Property listed successfully!'),
        backgroundColor: const Color(0xFF8D6E63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to property details or listings
          },
        ),
      ),
    );
  }

  void _openMapPicker() async {
    final currentLat = double.tryParse(_latitudeController.text) ?? 30.0444;
    final currentLng = double.tryParse(_longitudeController.text) ?? 31.2357;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          initialLatitude: currentLat,
          initialLongitude: currentLng,
          onLocationSelected: (latitude, longitude, address) {
            setState(() {
              _latitudeController.text = latitude.toStringAsFixed(6);
              _longitudeController.text = longitude.toStringAsFixed(6);
              // Auto-update address field if address is available
              if (address != null && address.isNotEmpty) {
                _addressController.text = address;
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateAddressFromCoordinates() async {
    final lat = double.tryParse(_latitudeController.text);
    final lng = double.tryParse(_longitudeController.text);

    if (lat != null && lng != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}"
                  .replaceAll(RegExp(r'^,\s*|,\s*$|,\s*,'), '')
                  .trim();

          if (address.isNotEmpty) {
            setState(() {
              _addressController.text = address;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Address updated automatically'),
                backgroundColor: const Color(0xFF8D6E63),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        // Silently handle errors - don't show error messages for this automatic feature
        print('Error getting address from coordinates: $e');
      }
    }
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
                          _buildSectionTitle('Property Information'),
                          SizedBox(height: 16.h),
                          _buildTitleField(),
                          SizedBox(height: 16.h),
                          _buildPropertyTypeDropdown(),
                          SizedBox(height: 16.h),
                          _buildPriceField(),
                          SizedBox(height: 16.h),
                          _buildDescriptionField(),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('Property Details'),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(child: _buildBedroomsField()),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildBathroomsField()),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(child: _buildLivingroomsField()),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildKitchenField()),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildAreaField(),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('Location Details'),
                          SizedBox(height: 16.h),
                          _buildCityDropdown(),
                          SizedBox(height: 16.h),
                          _buildAddressField(),
                          SizedBox(height: 16.h),
                          _buildCompoundNameField(),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(child: _buildLatitudeField()),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildLongitudeField()),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('Additional Information'),
                          SizedBox(height: 16.h),
                          _buildFurnishedCheckbox(),
                          SizedBox(height: 16.h),
                          _buildDeliveryDateField(),
                          SizedBox(height: 16.h),
                          _buildImageSelector(),
                          SizedBox(height: 32.h),
                          _buildSubmitButton(),
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
                  'Sell Your Property',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'List your property for sale',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.home_work_rounded, color: Colors.white, size: 30.sp),
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

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Property Title *',
        prefixIcon: const Icon(Icons.title_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter property title';
        }
        return null;
      },
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPropertyType,
      decoration: InputDecoration(
        labelText: 'Property Type *',
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
      onChanged: (value) => setState(() => _selectedPropertyType = value!),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Price (EGP) *',
        prefixIcon: const Icon(Icons.monetization_on_rounded),
        suffixText: 'EGP',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the price';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return 'Please enter a valid price';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Property Description *',
        prefixIcon: const Icon(Icons.description_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter property description';
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
        labelText: 'Bedrooms *',
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
        labelText: 'Bathrooms *',
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

  Widget _buildLivingroomsField() {
    return TextFormField(
      controller: _livingroomsController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Living Rooms *',
        prefixIcon: const Icon(Icons.weekend_rounded),
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

  Widget _buildKitchenField() {
    return TextFormField(
      controller: _kitchenController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Kitchens *',
        prefixIcon: const Icon(Icons.kitchen_rounded),
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

  Widget _buildAreaField() {
    return TextFormField(
      controller: _areaController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Area (Square Meters) *',
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

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: 'City *',
        prefixIcon: const Icon(Icons.location_city_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      items: _cities.map((city) {
        return DropdownMenuItem(value: city, child: Text(city));
      }).toList(),
      onChanged: (value) => setState(() => _selectedCity = value!),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Address *',
        prefixIcon: const Icon(Icons.location_on_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the address';
        }
        return null;
      },
    );
  }

  Widget _buildCompoundNameField() {
    return TextFormField(
      controller: _compoundNameController,
      decoration: InputDecoration(
        labelText: 'Compound Name',
        prefixIcon: const Icon(Icons.business_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
    );
  }

  Widget _buildLatitudeField() {
    return TextFormField(
      controller: _latitudeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Latitude',
        prefixIcon: const Icon(Icons.my_location_rounded),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _updateAddressFromCoordinates,
              tooltip: 'Update address from coordinates',
            ),
            IconButton(
              icon: const Icon(Icons.map_rounded),
              onPressed: _openMapPicker,
              tooltip: 'Select on map',
            ),
          ],
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
        helperText: 'Tap refresh to auto-update address',
      ),
      onChanged: (value) {
        // Auto-update address after a short delay when both lat and lng are valid
        final lat = double.tryParse(value);
        final lng = double.tryParse(_longitudeController.text);
        if (lat != null && lng != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _updateAddressFromCoordinates();
          });
        }
      },
    );
  }

  Widget _buildLongitudeField() {
    return TextFormField(
      controller: _longitudeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Longitude',
        prefixIcon: const Icon(Icons.place_rounded),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _updateAddressFromCoordinates,
              tooltip: 'Update address from coordinates',
            ),
            IconButton(
              icon: const Icon(Icons.map_rounded),
              onPressed: _openMapPicker,
              tooltip: 'Select on map',
            ),
          ],
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
        helperText: 'Tap refresh to auto-update address',
      ),
      onChanged: (value) {
        // Auto-update address after a short delay when both lat and lng are valid
        final lat = double.tryParse(_latitudeController.text);
        final lng = double.tryParse(value);
        if (lat != null && lng != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _updateAddressFromCoordinates();
          });
        }
      },
    );
  }

  Widget _buildFurnishedCheckbox() {
    return CheckboxListTile(
      title: Text('Furnished Property', style: TextStyle(fontSize: 16.sp)),
      subtitle: Text('Check if the property is furnished',
          style: TextStyle(fontSize: 14.sp)),
      value: _isFurnished,
      onChanged: (value) => setState(() => _isFurnished = value!),
      activeColor: const Color(0xFF8D6E63),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDeliveryDateField() {
    return TextFormField(
      controller: _deliveryDateController,
      readOnly: true,
      onTap: _selectDeliveryDate,
      decoration: InputDecoration(
        labelText: 'Delivery Date',
        prefixIcon: const Icon(Icons.calendar_today_rounded),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF8D6E63)),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _selectImages,
          child: Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded,
                    size: 40.sp, color: const Color(0xFF8D6E63)),
                SizedBox(height: 8.h),
                Text(
                  _selectedImages.isEmpty
                      ? 'Add Property Images'
                      : 'Add More Images (${_selectedImages.length} selected)',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF8D6E63),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Text(
            'Selected Images:',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 12.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(_selectedImages[index]),
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitListing,
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
                    'Listing Property...',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.publish_rounded, color: Colors.white, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'List Property',
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
}

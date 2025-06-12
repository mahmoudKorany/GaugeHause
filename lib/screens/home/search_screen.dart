import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gauge_haus/models/estate_model.dart';
import 'package:gauge_haus/models/user_model.dart';
import 'package:gauge_haus/shared/dio_helper.dart';
import 'package:gauge_haus/shared/cache_helper.dart';
import 'package:gauge_haus/screens/estate_details_screen.dart';
import 'package:gauge_haus/app_cubit/app_cubit.dart';
import 'package:gauge_haus/app_cubit/app_states.dart';
import 'package:gauge_haus/screens/home_screen.dart';
import 'package:gauge_haus/screens/home/menu_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _distanceController =
      TextEditingController(text: '5');

  List<Estate> _searchResults = [];
  bool _isLoading = false;
  String _selectedPropertyType = 'All';
  String _selectedUnit = 'km';
  double? _selectedLat;
  double? _selectedLng;
  bool _locationPermissionGranted = false;
  String _selectedLocationName = 'Tap on map to select location';
  bool _showMap = false;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(30.0444, 31.2357), // Cairo, Egypt
    zoom: 10,
  );

  final List<String> _propertyTypes = [
    'All',
    'House',
    'Apartment',
    'Villa',
    'Duplex',
    'Studio',
    'Penthouse'
  ];

  final List<String> _distanceUnits = ['km', 'mi'];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() {
          _locationPermissionGranted = true;
        });
        await _getCurrentLocation();
      }
    } catch (e) {
      _showMessage('Error accessing location: $e', isError: true);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12,
        );
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        );
      }
    } catch (e) {
      _showMessage('Error getting current location: $e', isError: true);
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    setState(() {
      _selectedLat = position.latitude;
      _selectedLng = position.longitude;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(
            title: 'Selected Location',
            snippet: 'Search area',
          ),
        ),
      };
    });

    // Get location name from coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _selectedLocationName =
              '${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}'
                  .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
          if (_selectedLocationName.isEmpty) {
            _selectedLocationName = 'Selected Location';
          }
        });
      }
    } catch (e) {
      setState(() {
        _selectedLocationName = 'Selected Location';
      });
    }
  }

  Future<void> _searchEstatesByDistance() async {
    if (_selectedLat == null || _selectedLng == null) {
      _showMessage('Please select a location on the map first', isError: true);
      return;
    }

    final distance = double.tryParse(_distanceController.text);
    if (distance == null || distance <= 0) {
      _showMessage('Please enter a valid distance', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Using the new endpoint format: /estates/nearest/{lat},{lng}/unit/{unit}
      final response = await DioHelper.getData(
        url: '/estates/nearest/$_selectedLat,$_selectedLng/unit/$_selectedUnit',
        token: CacheHelper.getData(key: 'token'),
        query: {
          'distance': distance.toString(),
        },
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        final estatesData = response.data['data']['estates'] as List;
        List<Estate> estates =
            estatesData.map((estate) => Estate.fromJson(estate)).toList();

        // Filter by property type if not "All"
        if (_selectedPropertyType != 'All') {
          estates = estates
              .where((estate) =>
                  estate.propertyType.toLowerCase() ==
                  _selectedPropertyType.toLowerCase())
              .toList();
        }

        // Filter by search query if provided
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          estates = estates
              .where((estate) =>
                  estate.title.toLowerCase().contains(query) ||
                  estate.description.toLowerCase().contains(query) ||
                  estate.compoundName.toLowerCase().contains(query))
              .toList();
        }

        setState(() {
          _searchResults = estates;
          _isLoading = false;
        });

        _showMessage(
            'Found ${estates.length} estates within $distance $_selectedUnit');
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        _showMessage('No estates found in the specified area', isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error searching estates: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF86755B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        title:
            const Text('Search Estates', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map, color: Colors.white),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Color(0xFF86755B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Location Selection
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showMap = !_showMap;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: const Color(0xFF86755B)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search Location',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _selectedLocationName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _showMap
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF86755B),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title, description, or compound...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        if (_selectedLat != null && _selectedLng != null) {
                          _searchEstatesByDistance();
                        }
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (_selectedLat != null && _selectedLng != null) {
                      _searchEstatesByDistance();
                    }
                  },
                ),

                SizedBox(height: 16.h),

                // Filters Row
                Row(
                  children: [
                    // Property Type Filter
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPropertyType,
                            isExpanded: true,
                            items: _propertyTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type,
                                    style: TextStyle(fontSize: 14.sp)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPropertyType = newValue!;
                              });
                              if (_selectedLat != null &&
                                  _selectedLng != null) {
                                _searchEstatesByDistance();
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Distance Input
                    Expanded(
                      child: TextField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Distance',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                        ),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Unit Selector
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          items: _distanceUnits.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child:
                                  Text(unit, style: TextStyle(fontSize: 14.sp)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedUnit = newValue!;
                            });
                            if (_selectedLat != null && _selectedLng != null) {
                              _searchEstatesByDistance();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Search Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _searchEstatesByDistance,
                    icon: _isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search_outlined),
                    label: Text(_isLoading ? 'Searching...' : 'Search Nearby'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6E63),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Map or Results
          Expanded(
            child: _showMap ? _buildMapView() : _buildResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: _initialCameraPosition,
          onTap: _onMapTap,
          markers: _markers,
          myLocationEnabled: _locationPermissionGranted,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              _selectedLat == null
                  ? 'Select a location on map to search'
                  : 'No estates found',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _selectedLat == null
                  ? 'Tap the map icon to open map view'
                  : 'Try adjusting your search criteria',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final estate = _searchResults[index];
        return EstateSearchCard(estate: estate);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _distanceController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}

class EstateSearchCard extends StatelessWidget {
  final Estate estate;

  const EstateSearchCard({Key? key, required this.estate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EstateDetailsScreen(estate: estate),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: estate.images.isNotEmpty
                  ? Image.network(
                      estate.images.first,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200.h,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.home,
                            size: 50.sp,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 200.h,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.home,
                        size: 50.sp,
                        color: Colors.grey[400],
                      ),
                    ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          estate.title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E2E2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        estate.formattedPrice,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF86755B),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Property Type and Compound
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF86755B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          estate.propertyType,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86755B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (estate.compoundName.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            estate.compoundName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Room Details
                  Row(
                    children: [
                      _buildRoomInfo(Icons.bed, '${estate.bedrooms}', 'Bed'),
                      SizedBox(width: 16.w),
                      _buildRoomInfo(
                          Icons.bathtub, '${estate.bathrooms}', 'Bath'),
                      SizedBox(width: 16.w),
                      _buildRoomInfo(
                          Icons.square_foot, estate.formattedArea, ''),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Description
                  if (estate.description.isNotEmpty)
                    Text(
                      estate.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfo(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          '$value${label.isNotEmpty ? ' $label' : ''}',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppCubitState>(
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final user = cubit.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F1EC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF86755B),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildProfileHeader(user, context),
                SizedBox(height: 24.h),
                _buildProfileStats(cubit, context),
                SizedBox(height: 24.h),
                _buildProfileInfo(user, context),
                SizedBox(height: 24.h),
                _buildQuickActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User? user, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF86755B), Color(0xFFC2BAA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF8D6E63),
              child: user?.image != null && user!.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user.image,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => Text(
                        user.initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      user?.initials ?? 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user?.name ?? 'Guest User',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            user?.email ?? 'No email available',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Member since ${user?.formattedJoinDate ?? 'Unknown'}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats(AppCubit cubit, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Listed',
              '${cubit.myEstates.length}',
              Icons.home,
              const Color(0xFF4CAF50),
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'Liked',
              '${cubit.likedEstates.length}',
              Icons.favorite,
              const Color(0xFFF44336),
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'Days',
              '${cubit.currentUser?.membershipDays ?? 0}',
              Icons.calendar_today,
              const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(User? user, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
              Icons.person, 'Full Name', user?.name ?? 'Not available'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.email, 'Email', user?.email ?? 'Not available'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.calendar_today, 'Joined',
              user?.formattedJoinDate ?? 'Unknown'),
          SizedBox(height: 12.h),
          _buildInfoRow(
              Icons.verified_user, 'Account ID', user?.id ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8D6E63), size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.edit,
                  'Edit Profile',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  Icons.home_outlined,
                  'My Properties',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyEstatesPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.favorite_outline,
                  'Liked Properties',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LikedEstatePage(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  Icons.settings,
                  'Settings',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF8D6E63).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF8D6E63).withOpacity(0.2),
            width: 1.w,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF8D6E63), size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF8D6E63),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Edit Profile Page
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AppCubit.get(context).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showMessage('Failed to select image. Please try again.', isError: true);
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      _showMessage('Please fill all required fields', isError: true);
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showMessage('Please enter a valid email address', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await AppCubit.get(context).updateUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      image: _selectedImage,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF8D6E63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppCubitState>(
      listener: (context, state) {
        if (state is UserDataLoadingState) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is UserDataSuccessState) {
          setState(() {
            _isLoading = false;
          });
          _showMessage('Profile updated successfully!');
          Navigator.pop(context);
        } else if (state is UserDataErrorState) {
          setState(() {
            _isLoading = false;
          });
          _showMessage(state.error, isError: true);
        }
      },
      builder: (context, state) {
        final user = AppCubit.get(context).currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F1EC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF86755B),
            title: const Text('Edit Profile',
                style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildImageSection(user),
                SizedBox(height: 32.h),
                _buildFormSection(),
                SizedBox(height: 32.h),
                _buildUpdateButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(User? user) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: _selectImage,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF8D6E63), width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF8D6E63).withOpacity(0.1),
                child: _selectedImage != null
                    ? ClipOval(
                        child: Image.file(
                          _selectedImage!,
                          width: 120.w,
                          height: 120.h,
                          fit: BoxFit.cover,
                        ),
                      )
                    : user?.image != null && user!.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.image,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(
                              color: Color(0xFF8D6E63),
                              strokeWidth: 2,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.camera_alt,
                              color: const Color(0xFF8D6E63),
                              size: 40.sp,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            color: const Color(0xFF8D6E63),
                            size: 40.sp,
                          ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 20.h),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              prefixIcon:
                  const Icon(Icons.person_outline, color: Color(0xFF8D6E63)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFF8D6E63)),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F1EC),
            ),
          ),
          SizedBox(height: 16.h),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address *',
              prefixIcon:
                  const Icon(Icons.email_outlined, color: Color(0xFF8D6E63)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFF8D6E63)),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F1EC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8D6E63),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Updating...',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ],
              )
            : Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

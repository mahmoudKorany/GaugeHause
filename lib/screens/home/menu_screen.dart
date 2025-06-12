import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gauge_haus/app_cubit/app_cubit.dart';
import 'package:gauge_haus/app_cubit/app_states.dart';
import 'package:gauge_haus/models/prediction_model.dart';
import 'package:gauge_haus/screens/home/search_screen.dart';
import 'package:gauge_haus/screens/sellstate_screen.dart';
import 'package:gauge_haus/screens/home_screen.dart';
import 'package:gauge_haus/shared/cache_helper.dart';
import 'package:gauge_haus/screens/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Profile Section
              _buildProfileSection(context),
              SizedBox(height: 30.h),

              // Menu Items
              _buildMenuSection(context),

              SizedBox(height: 30.h),

              // Logout Button
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<AppCubit, AppCubitState>(
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final user = cubit.currentUser;

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF86755B), Color(0xFFC2BAA5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
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
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Text(
                          user?.initials ?? 'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Guest User',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user?.email ?? 'No email available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToPage(context, const ProfilePage()),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      MenuItem(
        icon: Icons.person_outline,
        title: 'Profile',
        subtitle: 'Manage your profile information',
        onTap: () => _navigateToPage(context, const ProfilePage()),
      ),
      MenuItem(
        icon: Icons.add_circle_outline,
        title: 'Sell State',
        subtitle: 'List your property for sale',
        onTap: () => _navigateToPage(context, const SellStateScreen()),
      ),
      MenuItem(
        icon: Icons.analytics_outlined,
        title: 'Saved Predictions',
        subtitle: 'View your saved price predictions',
        onTap: () => _navigateToPage(context, const SavedPredictionsPage()),
      ),
      MenuItem(
        icon: Icons.favorite_outline,
        title: 'Liked States',
        subtitle: 'Properties you have liked',
        onTap: () => _navigateToPage(context, const LikedEstatePage()),
      ),
      MenuItem(
        icon: Icons.home_outlined,
        title: 'Your States',
        subtitle: 'Properties you have listed',
        onTap: () => _navigateToPage(context, const YourStatesPage()),
      ),
      MenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'App preferences and settings',
        onTap: () => _navigateToPage(context, const SettingsPage()),
      ),
      MenuItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: () => _navigateToPage(context, const HelpSupportPage()),
      ),
      MenuItem(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'App version and information',
        onTap: () => _navigateToPage(context, const AboutPage()),
      ),
    ];

    return Column(
      children: menuItems.map((item) => _buildMenuItem(context, item)).toList(),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            item.onTap();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D6E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    item.icon,
                    color: const Color(0xFF8D6E63),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Material(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red[200]!, width: 1.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red[600],
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _handleLogout(context);
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handles the logout process by clearing stored data and navigating to login
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Remove token and user ID from cache
      await CacheHelper.removeData(key: 'token');
      await CacheHelper.removeData(key: 'userId');

      // Navigate to login screen and clear the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out successfully'),
          backgroundColor: const Color(0xFF8D6E63),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      // Handle any errors during logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error during logout. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// MenuItem Model
class MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

// Additional Page Classes
class SavedPredictionsPage extends StatefulWidget {
  const SavedPredictionsPage({Key? key}) : super(key: key);

  @override
  State<SavedPredictionsPage> createState() => _SavedPredictionsPageState();
}

class _SavedPredictionsPageState extends State<SavedPredictionsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Prediction> _savedPredictions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPredictions();
  }

  void _loadSavedPredictions() {
    // Simulate loading saved predictions
    // In a real app, this would fetch from API
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _savedPredictions = [
          // Sample data - replace with actual API call
          Prediction(
            id: '1',
            title: 'Villa in New Cairo',
            city: 'New Cairo',
            propertyType: 'Villa',
            furnished: 'Yes',
            deliveryTerm: 'Finished',
            bedrooms: 4,
            bathrooms: 3,
            area: 350.0,
            level: 2,
            price: 2500000.0,
            pricePerSqm: 7142.86,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            updatedAt: DateTime.now().subtract(const Duration(days: 5)),
            version: 0,
          ),
          Prediction(
            id: '2',
            title: 'Apartment in Maadi',
            city: 'Maadi',
            propertyType: 'Apartment',
            furnished: 'No',
            deliveryTerm: 'Semi-finished',
            bedrooms: 3,
            bathrooms: 2,
            area: 180.0,
            level: 5,
            price: 1800000.0,
            pricePerSqm: 10000.0,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            updatedAt: DateTime.now().subtract(const Duration(days: 10)),
            version: 0,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  List<Prediction> get filteredPredictions {
    if (_searchQuery.isEmpty) return _savedPredictions;

    return _savedPredictions.where((prediction) {
      return prediction.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          prediction.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prediction.propertyType
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        title: const Text('Saved Predictions',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search predictions...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8D6E63)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F1EC),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),

          // Predictions List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8D6E63)),
                  )
                : filteredPredictions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: filteredPredictions.length,
                        itemBuilder: (context, index) {
                          final prediction = filteredPredictions[index];
                          return _buildPredictionCard(prediction);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isEmpty
                ? 'No saved predictions yet'
                : 'No results found',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isEmpty
                ? 'Start making predictions to see them here'
                : 'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(Prediction prediction) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and delete action
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${prediction.city} • ${prediction.propertyType}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePrediction(prediction);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Property details
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _buildDetailItem(Icons.square_foot, prediction.formattedArea),
                SizedBox(width: 16.w),
                _buildDetailItem(Icons.bed, '${prediction.bedrooms} bed'),
                SizedBox(width: 16.w),
                _buildDetailItem(
                    Icons.bathroom, '${prediction.bathrooms} bath'),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Price section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predicted Price',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      prediction.formattedPrice,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Per Sqm',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      prediction.formattedPricePerSqm,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _deletePrediction(Prediction prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prediction'),
        content: const Text('Are you sure you want to delete this prediction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _savedPredictions.removeWhere((p) => p.id == prediction.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prediction deleted'),
                  backgroundColor: Color(0xFF8D6E63),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class YourStatesPage extends StatelessWidget {
  const YourStatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Reuse the MyEstatesPage from home_screen.dart
    return const MyEstatesPage();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  bool _pushNotifications = true;
  bool _locationServices = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'EGP';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Notifications'),
            _buildNotificationSettings(),
            SizedBox(height: 24.h),
            _buildSectionTitle('Preferences'),
            _buildPreferencesSettings(),
            SizedBox(height: 24.h),
            _buildSectionTitle('Privacy & Security'),
            _buildPrivacySettings(),
            SizedBox(height: 24.h),
            _buildSectionTitle('App Information'),
            _buildAppInfoSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF8D6E63),
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          _buildSwitchTile(
            'Enable Notifications',
            'Receive notifications about property updates',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
            Icons.notifications,
          ),
          if (_notificationsEnabled) ...[
            const Divider(),
            _buildSwitchTile(
              'Email Notifications',
              'Receive updates via email',
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
              Icons.email,
            ),
            const Divider(),
            _buildSwitchTile(
              'Push Notifications',
              'Receive push notifications on your device',
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
              Icons.phone_android,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesSettings() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          _buildDropdownTile(
            'Language',
            'Select your preferred language',
            _selectedLanguage,
            ['English', 'Arabic', 'French'],
            (value) => setState(() => _selectedLanguage = value!),
            Icons.language,
          ),
          const Divider(),
          _buildDropdownTile(
            'Currency',
            'Select your preferred currency',
            _selectedCurrency,
            ['EGP', 'USD', 'EUR'],
            (value) => setState(() => _selectedCurrency = value!),
            Icons.monetization_on,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          _buildSwitchTile(
            'Location Services',
            'Allow app to access your location for better recommendations',
            _locationServices,
            (value) => setState(() => _locationServices = value),
            Icons.location_on,
          ),
          const Divider(),
          _buildActionTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(),
          ),
          const Divider(),
          _buildActionTile(
            'Terms of Service',
            'Read our terms of service',
            Icons.article,
            () => _showTermsOfService(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSettings() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          _buildActionTile(
            'App Version',
            'Version 1.0.0',
            Icons.info,
            null,
          ),
          const Divider(),
          _buildActionTile(
            'Check for Updates',
            'Check if a new version is available',
            Icons.update,
            () => _checkForUpdates(),
          ),
          const Divider(),
          _buildActionTile(
            'Clear Cache',
            'Clear app cache to free up space',
            Icons.clear_all,
            () => _clearCache(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value,
      Function(bool) onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8D6E63)),
      title: Text(title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF8D6E63),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value,
      List<String> options, Function(String?) onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8D6E63)),
      title: Text(title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        underline: Container(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile(
      String title, String subtitle, IconData icon, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8D6E63)),
      title: Text(title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      trailing:
          onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('This would open the privacy policy document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('This would open the terms of service document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are using the latest version'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'Are you sure you want to clear the app cache? This will remove temporary files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Color(0xFF8D6E63),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        title:
            const Text('Help & Support', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSection(context),
            SizedBox(height: 24.h),
            _buildFAQSection(context),
            SizedBox(height: 24.h),
            _buildResourcesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
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
            'Contact Us',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          _buildContactItem(
            Icons.email,
            'Email Support',
            'support@gaugehaus.com',
            () => _sendEmail(context),
          ),
          SizedBox(height: 12.h),
          _buildContactItem(
            Icons.phone,
            'Phone Support',
            '+20 123 456 789',
            () => _makePhoneCall(context),
          ),
          SizedBox(height: 12.h),
          _buildContactItem(
            Icons.chat,
            'Live Chat',
            'Chat with our support team',
            () => _openLiveChat(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I list my property?',
        'answer':
            'Go to "Sell State" from the menu and fill in your property details.'
      },
      {
        'question': 'How accurate are price predictions?',
        'answer':
            'Our AI model provides up to 95% accuracy based on current market data.'
      },
      {
        'question': 'Can I edit my property listing?',
        'answer':
            'Yes, you can edit your listings from "Your States" in the menu.'
      },
      {
        'question': 'How do I save properties I like?',
        'answer':
            'Tap the heart icon on any property to add it to your liked properties.'
      },
    ];

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
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          ...faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),
        ],
      ),
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
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
            'Resources',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          _buildResourceItem(
            Icons.video_library,
            'Video Tutorials',
            'Learn how to use the app',
            () => _openVideoTutorials(context),
          ),
          SizedBox(height: 12.h),
          _buildResourceItem(
            Icons.article,
            'User Guide',
            'Complete app documentation',
            () => _openUserGuide(context),
          ),
          SizedBox(height: 12.h),
          _buildResourceItem(
            Icons.bug_report,
            'Report a Bug',
            'Help us improve the app',
            () => _reportBug(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFF8D6E63), size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            answer,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
        ],
      ),
    );
  }

  void _sendEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email app...'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }

  void _makePhoneCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening phone app...'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }

  void _openLiveChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live chat feature coming soon!'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }

  void _openVideoTutorials(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video tutorials coming soon!'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }

  void _openUserGuide(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User guide coming soon!'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }

  void _reportBug(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug report feature coming soon!'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        title: const Text('About', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildAppInfoSection(),
            SizedBox(height: 24.h),
            _buildFeatureSection(),
            SizedBox(height: 24.h),
            _buildTeamSection(),
            SizedBox(height: 24.h),
            _buildLegalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.home,
              size: 40.sp,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Gauge Haus',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your trusted real estate companion powered by AI',
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

  Widget _buildFeatureSection() {
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
            'Key Features',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(Icons.analytics, 'AI Price Predictions',
              'Get accurate property price estimates using advanced AI'),
          _buildFeatureItem(Icons.home, 'Property Listings',
              'Browse and list properties with detailed information'),
          _buildFeatureItem(Icons.favorite, 'Wishlist',
              'Save and organize your favorite properties'),
          _buildFeatureItem(Icons.location_on, 'Location-based Search',
              'Find properties near you with map integration'),
          _buildFeatureItem(Icons.trending_up, 'Market Insights',
              'Stay updated with real estate market trends'),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
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
            'Development Team',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Gauge Haus is developed by a dedicated team of engineers and designers passionate about revolutionizing the real estate experience in Egypt.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made with ❤️ in Egypt',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
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
            'Legal',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16.h),
          _buildLegalItem('Privacy Policy', 'How we protect your data'),
          SizedBox(height: 12.h),
          _buildLegalItem('Terms of Service', 'App usage terms and conditions'),
          SizedBox(height: 12.h),
          _buildLegalItem('Licenses', 'Third-party licenses and attributions'),
          SizedBox(height: 20.h),
          Text(
            '© 2024 Gauge Haus. All rights reserved.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: const Color(0xFF8D6E63), size: 20.sp),
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
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        // Handle legal document tap
      },
      child: Row(
        children: [
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
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

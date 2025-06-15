import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gauge_haus/app_cubit/app_cubit.dart';
import 'package:gauge_haus/app_cubit/app_states.dart';
import 'package:gauge_haus/screens/explore_screen.dart';
import 'package:gauge_haus/screens/prediction_page.dart';
import 'package:gauge_haus/screens/sellstate_screen.dart';
import 'package:gauge_haus/screens/home/menu_screen.dart';
import 'package:gauge_haus/screens/estate_details_screen.dart';
import 'package:gauge_haus/widgets/estate_card.dart';

import '../models/estate_model.dart';
import 'home/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Initialize combined state and fetch both estates when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = AppCubit.get(context);
      cubit.initializeCombinedEstatesState();
      cubit.getMyEstates();
      cubit.getLikedEstates();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-enable combined state when returning to home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = AppCubit.get(context);
     cubit.enableCombinedState();
    });
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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    HapticFeedback.lightImpact();

    switch (index) {
      case 0:
        // Home - just update the index, don't navigate
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 1:
        setState(() {
          _selectedIndex = index;
        });
        _navigateToPage(const SellStateScreen());
        break;
      case 2:
        setState(() {
          _selectedIndex = index;
        });
        _navigateToPage(const ExplorePage());
        break;
      case 3:
        setState(() {
          _selectedIndex = index;
        });
        _navigateToPage(const MenuPage());
        break;
    }
  }

  void _navigateToPage(Widget page) {
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
    ).then((_) {
      // Reset to home when returning from any page
      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppCubitState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F1EC),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  _buildPredictPriceCard(),
                  _buildFeatureShortcuts(),
                  SizedBox(height: 10.h),
                  _buildLikedEstates(),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildHeader() {
    var cubit = AppCubit.get(context);
    return Container(
      height: 240.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF86755B), Color(0xFFC2BAA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.7],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 40.h,
          bottom: 20.h,
        ),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Row(
              children: [
                // Profile Picture
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF8D6E63),
                    child: cubit.currentUser?.image != null &&
                            cubit.currentUser!.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: cubit.currentUser!.image,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            memCacheWidth: 120,
                            // Double the display size for quality
                            memCacheHeight: 120,
                          )
                        : Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                  ),
                ),
                SizedBox(width: 16.w),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        cubit.currentUser?.name ?? 'Guest',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // search icon
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // تحسين جملة Your Feature
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Text(
                'Your Feature',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildPredictPriceCard() {
    return Transform.translate(
      offset: Offset(0, -20.h),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PredictionPage(),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          padding: EdgeInsets.all(15.w),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureShortcuts() {
    final features = [
      FeatureItem(
        icon: Icons.favorite_border,
        label: 'Liked Estates',
        onTap: () => _navigateToPage(const LikedEstatePage()),
      ),
      FeatureItem(
        icon: Icons.analytics_outlined,
        label: 'Prediction',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PredictionPage(),
            ),
          );
        },
      ),
      FeatureItem(
        icon: Icons.add_circle_outline,
        label: 'Sell',
        onTap: () => _navigateToPage(const SellStateScreen()),
      ),
      FeatureItem(
        icon: Icons.public_outlined,
        label: 'Explore',
        onTap: () => _navigateToPage(const ExplorePage()),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: features.map((feature) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            feature.onTap();
          },
          child: Column(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(
                  feature.icon,
                  color: const Color(0xFF8D6E63),
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                feature.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLikedEstates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Estates',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToPage(const MyEstatesPage()),
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: const Color(0xFF8D6E63),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 220.h,
          child: BlocBuilder<AppCubit, AppCubitState>(
            builder: (context, state) {
              if (AppCubit.get(context).myEstates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 48.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No estates found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Start by adding your first property',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }else if (state is MyEstatesLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8D6E63),
                  ),
                );
              }else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: AppCubit.get(context).myEstates.length,
                  itemBuilder: (context, index) {
                    final estate = AppCubit.get(context).myEstates[index];
                    return Container(
                      width: 180.w,
                      margin: EdgeInsets.only(right: 16.w),
                      child: EstateCard(estate: estate),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8D6E63),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}

// Feature Item Model
class FeatureItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  FeatureItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

// // Enhanced Estate Card Widget
// class BuildEstateCard extends StatelessWidget {
//   const BuildEstateCard({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 10.r,
//             offset: Offset(0, 2.h),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 110.h,
//             decoration: BoxDecoration(
//               color: const Color(0xFF8D6E63).withOpacity(0.3),
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(16.r),
//               ),
//             ),
//             child: Stack(
//               children: [
//                 Center(
//                   child: Icon(
//                     Icons.home_rounded,
//                     size: 35.sp,
//                     color: const Color(0xFF8D6E63).withOpacity(0.7),
//                   ),
//                 ),
//                 Positioned(
//                   top: 8.h,
//                   right: 8.w,
//                   child: Container(
//                     padding: EdgeInsets.all(4.w),
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.favorite,
//                       color: Colors.red,
//                       size: 14.sp,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.all(10.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Industrial House',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 2.h),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         size: 12.sp,
//                         color: Colors.grey,
//                       ),
//                       SizedBox(width: 2.w),
//                       Expanded(
//                         child: Text(
//                           'Cairo, Giza',
//                           style: TextStyle(
//                             fontSize: 11.sp,
//                             color: Colors.grey,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     '280.9 M',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF8D6E63),
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     'Yahyai Rabie',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: Colors.black54,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Placeholder classes for pages

class LikedEstatePage extends StatefulWidget {
  const LikedEstatePage({super.key});

  @override
  State<LikedEstatePage> createState() => _LikedEstatePageState();
}

class _LikedEstatePageState extends State<LikedEstatePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'House',
    'Apartment',
    'Villa',
    'Duplex'
  ];

  @override
  void initState() {
    super.initState();
    // Disable combined state for individual page and ensure liked estates are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = AppCubit.get(context);
      cubit.disableCombinedState();
      cubit.getLikedEstates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Estate> _filterEstates(List<Estate> estates) {
    List<Estate> filtered = estates;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((estate) {
        return estate.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            estate.compoundName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            estate.propertyType
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by property type
    if (_selectedFilter != 'All') {
      filtered = filtered.where((estate) {
        return estate.propertyType.toLowerCase() ==
            _selectedFilter.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        title:
            const Text('Liked Estates', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              AppCubit.get(context).getLikedEstates();
            },
          ),
        ],
      ),
      body: BlocConsumer<AppCubit, AppCubitState>(
        listener: (context, state) {
          if (state is LikeEstateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.isLiked ? Colors.green : Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is LikeEstateErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: EdgeInsets.all(16.w),
                color: Colors.white,
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1EC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search liked estates...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 20.sp,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Filter Chips
                    SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;
                          return Container(
                            margin: EdgeInsets.only(right: 8.w),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF8D6E63),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF8D6E63),
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF8D6E63)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Liked Estates Grid
              Expanded(
                child: _buildLikedEstatesContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLikedEstatesContent(AppCubitState state) {
    if (state is LikedEstatesLoadingState) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6E63),
        ),
      );
    } else if (state is LikedEstatesSuccessState) {
      final filteredEstates = _filterEstates(state.estates);

      if (state.estates.isEmpty) {
        return _buildEmptyState(
          icon: Icons.favorite_border,
          title: 'No liked estates yet',
          subtitle: 'Start exploring and like estates you\'re interested in',
          showExploreButton: true,
        );
      } else if (filteredEstates.isEmpty) {
        return _buildEmptyState(
          icon: Icons.search_off,
          title: 'No results found',
          subtitle: 'Try adjusting your search or filters',
          showExploreButton: false,
        );
      }

      return Column(
        children: [
          // Results count
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: Colors.white,
            child: Text(
              '${filteredEstates.length} liked estate${filteredEstates.length != 1 ? 's' : ''} found',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Estates Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredEstates.length,
              itemBuilder: (context, index) {
                final estate = filteredEstates[index];
                return LikedEstateCard(estate: estate);
              },
            ),
          ),
        ],
      );
    } else if (state is LikedEstatesErrorState) {
      return _buildErrorState(state.error);
    } else {
      // Initial state - trigger loading
      AppCubit.get(context).getLikedEstates();
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6E63),
        ),
      );
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showExploreButton,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (showExploreButton) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExplorePage(),
                    ),
                  );
                },
                icon: Icon(Icons.explore, size: 18.sp),
                label: Text(
                  'Explore Estates',
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load liked estates',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    AppCubit.get(context).getLikedEstates();
                  },
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text(
                    'Retry',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExplorePage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.explore, size: 18.sp),
                  label: Text(
                    'Explore',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8D6E63),
                    side: const BorderSide(color: Color(0xFF8D6E63)),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// My Estates Page - Full page view for user's estates
class MyEstatesPage extends StatefulWidget {
  const MyEstatesPage({super.key});

  @override
  State<MyEstatesPage> createState() => _MyEstatesPageState();
}

class _MyEstatesPageState extends State<MyEstatesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'House',
    'Apartment',
    'Villa',
    'Duplex'
  ];

  @override
  void initState() {
    super.initState();
    // Disable combined state for individual page and ensure my estates are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = AppCubit.get(context);
      cubit.disableCombinedState();
      cubit.getMyEstates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Estate> _filterEstates(List<Estate> estates) {
    List<Estate> filtered = estates;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((estate) {
        return estate.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            estate.compoundName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            estate.propertyType
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by property type
    if (_selectedFilter != 'All') {
      filtered = filtered.where((estate) {
        return estate.propertyType.toLowerCase() ==
            _selectedFilter.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF86755B),
        title: const Text('My Estates', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              AppCubit.get(context).getMyEstates();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellStateScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AppCubit, AppCubitState>(
        listener: (context, state) {
          // Handle any specific state changes if needed
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: EdgeInsets.all(16.w),
                color: Colors.white,
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1EC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search my estates...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 20.sp,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Filter Chips
                    SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;
                          return Container(
                            margin: EdgeInsets.only(right: 8.w),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF8D6E63),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF8D6E63),
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF8D6E63)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // My Estates Grid
              Expanded(
                child: _buildMyEstatesContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyEstatesContent(AppCubitState state) {
    if (state is MyEstatesLoadingState) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6E63),
        ),
      );
    } else if (state is MyEstatesSuccessState) {
      final filteredEstates = _filterEstates(state.estates);

      if (state.estates.isEmpty) {
        return _buildEmptyState(
          icon: Icons.home_outlined,
          title: 'No estates listed yet',
          subtitle: 'Start by adding your first property for sale',
          showAddButton: true,
        );
      } else if (filteredEstates.isEmpty) {
        return _buildEmptyState(
          icon: Icons.search_off,
          title: 'No results found',
          subtitle: 'Try adjusting your search or filters',
          showAddButton: false,
        );
      }

      return Column(
        children: [
          // Results count
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: Colors.white,
            child: Text(
              '${filteredEstates.length} estate${filteredEstates.length != 1 ? 's' : ''} listed',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Estates Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredEstates.length,
              itemBuilder: (context, index) {
                final estate = filteredEstates[index];
                return MyEstateCard(estate: estate);
              },
            ),
          ),
        ],
      );
    } else if (state is MyEstatesErrorState) {
      return _buildErrorState(state.error);
    } else {
      // Initial state - trigger loading
      AppCubit.get(context).getMyEstates();
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8D6E63),
        ),
      );
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showAddButton,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (showAddButton) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellStateScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: Text(
                  'Add Property',
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load your estates',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    AppCubit.get(context).getMyEstates();
                  },
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text(
                    'Retry',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellStateScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, size: 18.sp),
                  label: Text(
                    'Add Estate',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8D6E63),
                    side: const BorderSide(color: Color(0xFF8D6E63)),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// My Estate Card - for user's own estates with edit/delete options
class MyEstateCard extends StatelessWidget {
  final Estate estate;

  const MyEstateCard({Key? key, required this.estate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Navigate to estate details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstateDetailsScreen(estate: estate),
            ),
          );
        },
        child: Container(
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
              // Image with status indicator
              Stack(
                children: [
                  Container(
                    height: 110.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: estate.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: estate.images.first,
                              width: double.infinity,
                              height: 110.h,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF8D6E63).withOpacity(0.3),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFF8D6E63),
                                    strokeWidth: 2.w,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF8D6E63).withOpacity(0.3),
                                child: Center(
                                  child: Icon(
                                    Icons.home_rounded,
                                    size: 35.sp,
                                    color: const Color(0xFF8D6E63)
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF8D6E63).withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  Icons.home_rounded,
                                  size: 35.sp,
                                  color:
                                      const Color(0xFF8D6E63).withOpacity(0.7),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Status indicator
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Listed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // More options button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () => _showOptionsMenu(context),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.grey[700],
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Estate info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        estate.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              estate.compoundName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${estate.price} EGP',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D6E63),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Yahyai Rabie',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF8D6E63)),
              title: const Text('Edit Estate'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen
                // TODO: Implement edit functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Color(0xFF8D6E63)),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EstateDetailsScreen(estate: estate),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF8D6E63)),
              title: const Text('Share Estate'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Estate'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Estate'),
        content: const Text(
            'Are you sure you want to delete this estate? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estate deletion not implemented yet'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Enhanced Estate Card for Liked Estates with unlike functionality
class LikedEstateCard extends StatelessWidget {
  final Estate estate;

  const LikedEstateCard({Key? key, required this.estate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Navigate to estate details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstateDetailsScreen(estate: estate),
            ),
          );
        },
        child: Container(
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
              // Image with like button
              Stack(
                children: [
                  Container(
                    height: 110.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: estate.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: estate.images.first,
                              width: double.infinity,
                              height: 110.h,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF8D6E63).withOpacity(0.3),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFF8D6E63),
                                    strokeWidth: 2.w,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF8D6E63).withOpacity(0.3),
                                child: Center(
                                  child: Icon(
                                    Icons.home_rounded,
                                    size: 35.sp,
                                    color: const Color(0xFF8D6E63)
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF8D6E63).withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  Icons.home_rounded,
                                  size: 35.sp,
                                  color:
                                      const Color(0xFF8D6E63).withOpacity(0.7),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Like button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: BlocBuilder<AppCubit, AppCubitState>(
                      builder: (context, state) {
                        final cubit = AppCubit.get(context);
                        final isLiked = cubit.isEstateLiked(estate.id);
                        final isLoading = state is LikeEstateLoadingState;

                        return GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  cubit.toggleEstateLike(estate.id);
                                },
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 14.sp,
                                    height: 14.sp,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      color: const Color(0xFF8D6E63),
                                    ),
                                  )
                                : Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                    size: 14.sp,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Estate info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        estate.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              estate.compoundName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${estate.price} EGP',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D6E63),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        estate.propertyType,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

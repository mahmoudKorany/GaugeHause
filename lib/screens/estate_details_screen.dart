import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gauge_haus/app_cubit/app_cubit.dart';
import 'package:gauge_haus/app_cubit/app_states.dart';
import 'package:gauge_haus/models/estate_model.dart';

class EstateDetailsScreen extends StatefulWidget {
  final Estate estate;

  const EstateDetailsScreen({Key? key, required this.estate}) : super(key: key);

  @override
  State<EstateDetailsScreen> createState() => _EstateDetailsScreenState();
}

class _EstateDetailsScreenState extends State<EstateDetailsScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEstateTitle(),
                  SizedBox(height: 16.h),
                  _buildPriceAndDetails(),
                  SizedBox(height: 24.h),
                  _buildDescription(),
                  SizedBox(height: 24.h),
                  _buildRoomDetails(),
                  SizedBox(height: 24.h),
                  _buildLocationDetails(),
                  SizedBox(height: 24.h),
                  _buildOwnerInfo(),
                  SizedBox(height: 32.h),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: const Color(0xFF86755B),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
      ),
      actions: [
        BlocBuilder<AppCubit, AppCubitState>(
          builder: (context, state) {
            final cubit = AppCubit.get(context);
            final isLiked = cubit.isEstateLiked(widget.estate.id);
            final isLoading = state is LikeEstateLoadingState;

            return IconButton(
              onPressed: isLoading
                  ? null
                  : () {
                      cubit.toggleEstateLike(widget.estate.id);
                    },
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 18.sp,
                      ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.estate.images.isNotEmpty
            ? Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: widget.estate.images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.estate.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFF8D6E63).withOpacity(0.3),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFF8D6E63),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFF8D6E63).withOpacity(0.3),
                          child: Center(
                            child: Icon(
                              Icons.home_rounded,
                              size: 50.sp,
                              color: const Color(0xFF8D6E63),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (widget.estate.images.length > 1)
                    Positioned(
                      bottom: 20.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.estate.images.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: _currentImageIndex == index ? 12.w : 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Container(
                color: const Color(0xFF8D6E63).withOpacity(0.3),
                child: Center(
                  child: Icon(
                    Icons.home_rounded,
                    size: 80.sp,
                    color: const Color(0xFF8D6E63),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEstateTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.estate.title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16.sp,
              color: Colors.grey,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                widget.estate.compoundName.isNotEmpty
                    ? widget.estate.compoundName
                    : 'Location not specified',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndDetails() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                widget.estate.price > 0
                    ? '${widget.estate.price.toStringAsFixed(0)} EGP'
                    : 'Price not specified',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildDetailItem(
                icon: Icons.square_foot,
                label: 'Area',
                value: '${widget.estate.area.toStringAsFixed(0)} m²',
              ),
              SizedBox(width: 20.w),
              _buildDetailItem(
                icon: Icons.category,
                label: 'Type',
                value: widget.estate.propertyType.isNotEmpty
                    ? widget.estate.propertyType
                    : 'Not specified',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: const Color(0xFF8D6E63),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.estate.description.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            widget.estate.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetails() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Room Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildRoomItem(
                icon: Icons.bed_rounded,
                label: 'Bedrooms',
                count: widget.estate.bedrooms,
              ),
              _buildRoomItem(
                icon: Icons.bathroom_rounded,
                label: 'Bathrooms',
                count: widget.estate.bathrooms,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildRoomItem(
                icon: Icons.weekend_rounded,
                label: 'Living Rooms',
                count: widget.estate.livingrooms,
              ),
              _buildRoomItem(
                icon: Icons.kitchen_rounded,
                label: 'Kitchens',
                count: widget.estate.kitchen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: const Color(0xFF8D6E63),
          ),
          SizedBox(width: 8.w),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Location',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20.sp,
                color: const Color(0xFF8D6E63),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.estate.compoundName.isNotEmpty
                      ? widget.estate.compoundName
                      : 'Location details not available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          if (widget.estate.furnished)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.chair,
                    size: 20.sp,
                    color: const Color(0xFF8D6E63),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Furnished',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo() {
    if (widget.estate.ownerName.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: const Color(0xFF8D6E63),
            backgroundImage: widget.estate.ownerImage.isNotEmpty
                ? CachedNetworkImageProvider(widget.estate.ownerImage)
                : null,
            child: widget.estate.ownerImage.isEmpty
                ? Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 25.sp,
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Property Owner',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.estate.ownerName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement contact functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact feature coming soon!'),
                  backgroundColor: Color(0xFF8D6E63),
                ),
              );
            },
            icon: Icon(Icons.phone, size: 18.sp),
            label: Text(
              'Contact',
              style: TextStyle(fontSize: 16.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6E63),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  backgroundColor: Color(0xFF8D6E63),
                ),
              );
            },
            icon: Icon(Icons.share, size: 18.sp),
            label: Text(
              'Share',
              style: TextStyle(fontSize: 16.sp),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8D6E63),
              side: const BorderSide(color: Color(0xFF8D6E63)),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

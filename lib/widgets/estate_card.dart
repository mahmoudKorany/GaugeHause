import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gauge_haus/models/estate_model.dart';
import 'package:gauge_haus/screens/estate_details_screen.dart';

class EstateCard extends StatelessWidget {
  final Estate estate;

  const EstateCard({
    Key? key,
    required this.estate,
  }) : super(key: key);

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
            // Image Section
            Container(
              height: 110.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
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
                                child: Icon(
                                  Icons.home_rounded,
                                  size: 35.sp,
                                  color:
                                      const Color(0xFF8D6E63).withOpacity(0.7),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
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
                          )
                        : Container(
                            color: const Color(0xFF8D6E63).withOpacity(0.3),
                            child: Center(
                              child: Icon(
                                Icons.home_rounded,
                                size: 35.sp,
                                color: const Color(0xFF8D6E63).withOpacity(0.7),
                              ),
                            ),
                          ),
                  ),
                  // Property type badge
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8D6E63),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        estate.propertyType,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      estate.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            estate.compoundName.isNotEmpty
                                ? estate.compoundName
                                : 'Cairo, Egypt',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // Price
                    Text(
                      '${(estate.price / 1000000).toStringAsFixed(1)} M EGP',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8D6E63),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Room details
                    Text(
                      '${estate.bedrooms} bed • ${estate.bathrooms} bath • ${estate.area.toInt()} m²',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Owner name
                    Text(
                      estate.ownerName,
                      style: TextStyle(
                        fontSize: 10.sp,
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
      ),
    );
  }
}

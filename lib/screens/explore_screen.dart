import 'package:flutter/material.dart';
import 'package:gauge_haus/shared/dio_helper.dart';
import 'package:gauge_haus/shared/url_constants.dart';
import 'package:gauge_haus/shared/cache_helper.dart';
import 'package:gauge_haus/app_cubit/app_cubit.dart';
import 'package:gauge_haus/models/estate_model.dart';
import 'package:gauge_haus/screens/estate_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Inbox Page')));
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Map<String, dynamic>> estates = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEstates();
  }

  Future<void> _fetchEstates() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await DioHelper.getData(
        url: UrlConstants.getAllEstates,
        token: CacheHelper.getData(key: 'token'),
        query: {
          // 'page': '2',
          // 'limit': '1',
          // 'sort': '-likes',
          // 'fields': 'name,likes'
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          if (data != null && data['estates'] != null) {
            final estatesData = data['estates'] as List;
            setState(() {
              estates = estatesData.cast<Map<String, dynamic>>();
              isLoading = false;
            });
          } else {
            setState(() {
              estates = [];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = 'Failed to fetch estates';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch estates';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Estates'),
        backgroundColor: const Color(0xFF583B2D),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF583B2D),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchEstates,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF583B2D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (estates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No estates found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEstates,
      color: const Color(0xFF583B2D),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: estates.length,
        itemBuilder: (context, index) {
          final estate = estates[index];
          return _buildEstateCard(estate);
        },
      ),
    );
  }

  Widget _buildEstateCard(Map<String, dynamic> estate) {
    final name = estate['name'] ?? estate['title'] ?? 'Unnamed Estate';
    final likes = estate['likes'] ?? 0;
    final estateId = estate['_id'] ?? estate['id'] ?? '';

    return GestureDetector(
      onTap: () => _navigateToEstateDetails(estateId),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.home,
                    color: const Color(0xFF583B2D),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF583B2D),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$likes ${likes == 1 ? 'like' : 'likes'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF583B2D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Page 2 • Sorted by likes • Tap to view details',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF583B2D).withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEstateDetails(String estateId) async {
    if (estateId.isEmpty) {
      _showMessage('Estate ID not available', isError: true);
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF583B2D),
        ),
      ),
    );

    try {
      final cubit = AppCubit.get(context);
      final estate = await cubit.getEstateById(estateId);

      // Close loading dialog
      Navigator.pop(context);

      if (estate != null) {
        // Navigate to estate details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EstateDetailsScreen(estate: estate),
          ),
        );
      } else {
        _showMessage('Failed to load estate details', isError: true);
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showMessage('Error loading estate details: ${e.toString()}',
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
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gauge_haus/app_cubit/app_states.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:gauge_haus/shared/url_constants.dart';
import 'package:gauge_haus/shared/cache_helper.dart';
import 'package:gauge_haus/shared/dio_helper.dart';
import 'package:gauge_haus/models/user_model.dart';
import 'package:gauge_haus/models/estate_model.dart';
import 'dart:io';
import 'dart:convert';

class AppCubit extends Cubit<AppCubitState> {
  AppCubit() : super(AppCubitInitial());
  static AppCubit get(context) => BlocProvider.of(context);

  User? currentUser;
  List<Estate> myEstates = [];
  List<Estate> likedEstates = [];

  // Combined state for home screen to prevent state conflicts
  CombinedEstatesState? _combinedState;

  Future<void> login({required String email, required String password}) async {
    try {
      emit(LoginLoadingState());
      final response = await DioHelper.postData(
        url: UrlConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Add proper type checking
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        // Parse the response using the LoginResponse model
        final loginResponse = LoginResponse.fromJson(response.data);
        currentUser = loginResponse.data.user;
        await CacheHelper.saveData(
          key: 'userId',
          value: currentUser!.id,
        );

        // Save token and user data using CacheHelper
        await CacheHelper.saveData(key: 'token', value: loginResponse.token);

        emit(LoginSuccessState(token: loginResponse.token, user: currentUser!));
        return;
      } else {
        emit(LoginErrorState('Login failed. Please try again.'));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Invalid email or password.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage =
            'Network error. Please check your connection and try again.';
        print('Unknown error details: ${e.error}');
      } else if (e.type == DioExceptionType.badCertificate) {
        errorMessage = 'Security certificate error. Please try again.';
      }

      emit(LoginErrorState(errorMessage));
    } catch (e) {
      emit(LoginErrorState('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> getUserData(String userId) async {
    try {
      emit(UserDataLoadingState());
      final response = await DioHelper.getData(
        url: UrlConstants.getUserById(userId),
        token: CacheHelper.getData(key: 'token'),
        query: {}, // Add empty query parameters as required
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        final userData = response.data['data']['user'];
        currentUser = User.fromJson(userData);
        emit(UserDataSuccessState(user: currentUser!));
      } else {
        emit(UserDataErrorState('Failed to fetch user data'));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while fetching user data';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'User not found.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      emit(UserDataErrorState(errorMessage));
    } catch (e) {
      emit(UserDataErrorState('An unexpected error occurred'));
    }
  }

  // Update user profile
  Future<void> updateUser({
    required String name,
    required String email,
    File? image,
  }) async {
    try {
      emit(UserDataLoadingState());

      // Create FormData for multipart request
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
      });

      // Add image file if provided
      if (image != null) {
        String fileName = image.path.split('/').last;
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await DioHelper.patchFormData(
        url: UrlConstants.updateUser,
        data: formData,
        token: CacheHelper.getData(key: 'token'),
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        final userData = response.data['data']['user'];
        currentUser = User.fromJson(userData);
        emit(UserDataSuccessState(user: currentUser!));
      } else {
        emit(UserDataErrorState('Failed to update profile'));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while updating profile';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response!.statusCode == 400) {
          errorMessage = 'Invalid data. Please check your inputs.';
        } else if (e.response!.statusCode == 409) {
          errorMessage = 'Email already exists. Please use a different email.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      emit(UserDataErrorState(errorMessage));
    } catch (e) {
      emit(UserDataErrorState('An unexpected error occurred'));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmedPassword,
    File? image,
  }) async {
    try {
      emit(RegisterLoadingState());

      // Create FormData for multipart request
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'confirmedPassword': confirmedPassword,
      });

      // Add image file if provided
      if (image != null) {
        String fileName = image.path.split('/').last;
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await DioHelper.postFormData(
        url: UrlConstants.registerEndpoint,
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['status'] == 'success') {
          // Parse the response similar to login response
          final responseData = response.data as Map<String, dynamic>;
          final token = responseData['token'] as String;
          final userData = responseData['data']['user'];
          currentUser = User.fromJson(userData);
          await CacheHelper.saveData(
            key: 'userId',
            value: currentUser!.id,
          );

          // Save token using CacheHelper
          await CacheHelper.saveData(key: 'token', value: token);

          // Emit success state with user data and token for navigation
          emit(RegisterSuccessState(
              message:
                  'Registration successful! Welcome ${currentUser!.name}!'));
        } else {
          emit(RegisterErrorState('Registration failed. Please try again.'));
        }
      } else {
        String errorMessage = 'Registration failed. Please try again.';
        if (response.data != null && response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
        emit(RegisterErrorState(errorMessage));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          errorMessage = 'Invalid registration data. Please check your inputs.';
        } else if (e.response!.statusCode == 409) {
          errorMessage = 'Email already exists. Please use a different email.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (e.type == DioExceptionType.badCertificate) {
        errorMessage = 'Security certificate error. Please try again.';
      }

      emit(RegisterErrorState(errorMessage));
    } catch (e) {
      emit(RegisterErrorState(
          'An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> getMyEstates() async {
    try {
      // Update combined state if it exists, otherwise emit individual state
      if (_combinedState != null) {
        emit(_combinedState!
            .copyWith(myEstatesLoading: true, clearMyEstatesError: true));
      } else {
        emit(MyEstatesLoadingState());
      }

      final response = await DioHelper.getData(
        url: UrlConstants.myEstates,
        token: CacheHelper.getData(key: 'token'),
        query: {},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        final estatesData = response.data['data']['estates'] as List;
        myEstates =
            estatesData.map((estate) => Estate.fromJson(estate)).toList();

        // Update combined state if it exists, otherwise emit individual state
        if (_combinedState != null) {
          _combinedState = _combinedState!.copyWith(
            myEstates: myEstates,
            myEstatesLoading: false,
            clearMyEstatesError: true,
          );
          emit(_combinedState!);
        } else {
          emit(MyEstatesSuccessState(estates: myEstates));
        }
      } else {
        final error = 'Failed to fetch your estates';
        if (_combinedState != null) {
          emit(_combinedState!
              .copyWith(myEstatesLoading: false, myEstatesError: error));
        } else {
          emit(MyEstatesErrorState(error));
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while fetching your estates';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'No estates found.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      if (_combinedState != null) {
        emit(_combinedState!
            .copyWith(myEstatesLoading: false, myEstatesError: errorMessage));
      } else {
        emit(MyEstatesErrorState(errorMessage));
      }
    } catch (e) {
      final error = 'An unexpected error occurred';
      if (_combinedState != null) {
        emit(_combinedState!
            .copyWith(myEstatesLoading: false, myEstatesError: error));
      } else {
        emit(MyEstatesErrorState(error));
      }
    }
  }

  Future<void> getLikedEstates() async {
    try {
      if (currentUser == null) {
        final error = 'User not authenticated';
        if (_combinedState != null) {
          emit(_combinedState!
              .copyWith(likedEstatesLoading: false, likedEstatesError: error));
        } else {
          emit(LikedEstatesErrorState(error));
        }
        return;
      }

      // Update combined state if it exists, otherwise emit individual state
      if (_combinedState != null) {
        emit(_combinedState!
            .copyWith(likedEstatesLoading: true, clearLikedEstatesError: true));
      } else {
        emit(LikedEstatesLoadingState());
      }

      final response = await DioHelper.getData(
        url: UrlConstants.getLikedEstates(currentUser!.id),
        token: CacheHelper.getData(key: 'token'),
        query: {},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        // Fix: Access the correct key "liked estates" from API response
        final estatesData = response.data['data']['liked estates'] as List;
        likedEstates =
            estatesData.map((estate) => Estate.fromJson(estate)).toList();

        // Update combined state if it exists, otherwise emit individual state
        if (_combinedState != null) {
          _combinedState = _combinedState!.copyWith(
            likedEstates: likedEstates,
            likedEstatesLoading: false,
            clearLikedEstatesError: true,
          );
          emit(_combinedState!);
        } else {
          emit(LikedEstatesSuccessState(estates: likedEstates));
        }
      } else {
        final error = 'Failed to fetch liked estates';
        if (_combinedState != null) {
          emit(_combinedState!
              .copyWith(likedEstatesLoading: false, likedEstatesError: error));
        } else {
          emit(LikedEstatesErrorState(error));
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while fetching liked estates';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'No liked estates found.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      if (_combinedState != null) {
        emit(_combinedState!.copyWith(
            likedEstatesLoading: false, likedEstatesError: errorMessage));
      } else {
        emit(LikedEstatesErrorState(errorMessage));
      }
    } catch (e) {
      final error = 'An unexpected error occurred';
      if (_combinedState != null) {
        emit(_combinedState!
            .copyWith(likedEstatesLoading: false, likedEstatesError: error));
      } else {
        emit(LikedEstatesErrorState(error));
      }
    }
  }

  Future<void> likeEstate(String estateId) async {
    try {
      emit(LikeEstateLoadingState());
      final response = await DioHelper.postData(
        url: UrlConstants.likeEstate(estateId),
        token: CacheHelper.getData(key: 'token'),
        data: {},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        emit(LikeEstateSuccessState(
          message: 'Estate liked successfully',
          isLiked: true,
        ));
        // Refresh liked estates silently without overriding current state
        _refreshLikedEstatesSilently();
      } else {
        emit(LikeEstateErrorState('Failed to like estate'));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while liking estate';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'Estate not found.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      emit(LikeEstateErrorState(errorMessage));
    } catch (e) {
      emit(LikeEstateErrorState('An unexpected error occurred'));
    }
  }

  Future<void> unlikeEstate(String estateId) async {
    try {
      emit(LikeEstateLoadingState());
      final response = await DioHelper.postData(
        url: UrlConstants.deslikeEstate(estateId),
        token: CacheHelper.getData(key: 'token'),
        data: {},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        emit(LikeEstateSuccessState(
          message: 'Estate unliked successfully',
          isLiked: false,
        ));
        // Refresh liked estates silently without overriding current state
        _refreshLikedEstatesSilently();
      } else {
        emit(LikeEstateErrorState('Failed to unlike estate'));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while unliking estate';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'Estate not found.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      emit(LikeEstateErrorState(errorMessage));
    } catch (e) {
      emit(LikeEstateErrorState('An unexpected error occurred'));
    }
  }

  // Silent method to refresh liked estates without emitting state changes
  Future<void> _refreshLikedEstatesSilently() async {
    try {
      if (currentUser == null) return;

      final response = await DioHelper.getData(
        url: UrlConstants.getLikedEstates(currentUser!.id),
        token: CacheHelper.getData(key: 'token'),
        query: {},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        // Update the liked estates list silently without emitting state
        final estatesData = response.data['data']['liked estates'] as List;
        likedEstates =
            estatesData.map((estate) => Estate.fromJson(estate)).toList();

        // Update combined state silently if it exists
        if (_combinedState != null) {
          _combinedState = _combinedState!.copyWith(likedEstates: likedEstates);
        }
      }
    } catch (e) {
      // Silently handle errors - don't emit error states
      print('Error refreshing liked estates silently: $e');
    }
  }

  // Helper method to check if an estate is liked
  bool isEstateLiked(String estateId) {
    return likedEstates.any((estate) => estate.id == estateId);
  }

  // Helper method to toggle like/unlike
  Future<void> toggleEstateLike(String estateId) async {
    if (isEstateLiked(estateId)) {
      await unlikeEstate(estateId);
    } else {
      await likeEstate(estateId);
    }
  }

  // Initialize combined state for home screen
  void initializeCombinedEstatesState() {
    _combinedState = CombinedEstatesState(
      myEstates: myEstates,
      likedEstates: likedEstates,
    );
    emit(_combinedState!);
  }

  // Disable combined state (for individual pages) but preserve data
  void disableCombinedState() {
    // Store the current state data before disabling
    if (_combinedState != null) {
      myEstates = _combinedState!.myEstates;
      likedEstates = _combinedState!.likedEstates;
    }
    _combinedState = null;
  }

  // Re-enable combined state when returning to home
  void enableCombinedState() {
    if (_combinedState == null) {
      _combinedState = CombinedEstatesState(
        myEstates: myEstates,
        likedEstates: likedEstates,
      );
      emit(_combinedState!);
    }
  }

  // Sell Estate functionality
  Future<void> sellEstate({
    required String title,
    required String propertyType,
    required Map<String, dynamic> location,
    required int price,
    required String description,
    required int bedrooms,
    required int bathrooms,
    required int livingrooms,
    required int kitchen,
    required int area,
    String? compoundName,
    required bool furnished,
    String? deliveryDate,
    List<String>? imagePaths,
  }) async {
    try {
      emit(SellEstateLoadingState());

      // Create FormData for multipart request
      FormData formData = FormData.fromMap({
        'title': title,
        'propertyType': propertyType,
        // Send location as JSON string to avoid nested object issues
        'location': jsonEncode(location),
        'price': price,
        'description': description,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'livingrooms': livingrooms,
        'kitchen': kitchen,
        'area': area,
        'compoundName': compoundName ?? '',
        'furnished': furnished,
        'deliveryDate': deliveryDate ?? '',
      });

      // Add image files if provided with proper MIME type detection
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (int i = 0; i < imagePaths.length; i++) {
          String fileName = imagePaths[i].split('/').last;
          String fileExtension = fileName.split('.').last.toLowerCase();

          // Determine MIME type based on file extension
          String mimeType;
          switch (fileExtension) {
            case 'jpg':
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'png':
              mimeType = 'image/png';
              break;
            case 'gif':
              mimeType = 'image/gif';
              break;
            case 'webp':
              mimeType = 'image/webp';
              break;
            default:
              mimeType = 'image/jpeg'; // Default fallback
          }

          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                imagePaths[i],
                filename: fileName,
                contentType: MediaType.parse(mimeType),
              ),
            ),
          );
        }
      }

      final response = await DioHelper.postFormData(
        url: UrlConstants.sellEsate,
        data: formData,
        token: CacheHelper.getData(key: 'token'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['status'] == 'success') {
          final estateData = response.data['data']['estate'];
          final newEstate = Estate.fromJson(estateData);

          // Add the new estate to myEstates list
          myEstates.insert(0, newEstate);

          // Update combined state if it exists
          if (_combinedState != null) {
            _combinedState = _combinedState!.copyWith(myEstates: myEstates);
          }

          emit(SellEstateSuccessState(
            message: 'Property listed successfully!',
            estate: newEstate,
          ));
        } else {
          emit(SellEstateErrorState(
              'Failed to list property. Please try again.'));
        }
      } else {
        String errorMessage = 'Failed to list property. Please try again.';
        if (response.data != null && response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
        emit(SellEstateErrorState(errorMessage));
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while listing property';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response!.statusCode == 400) {
          // Handle specific 400 errors
          if (e.response!.data != null &&
              e.response!.data is Map<String, dynamic>) {
            final errorData = e.response!.data as Map<String, dynamic>;
            if (errorData['message'] != null) {
              errorMessage = errorData['message'].toString();
            }
          } else {
            errorMessage = 'Invalid property data. Please check your inputs.';
          }
        } else if (e.response!.statusCode == 422) {
          errorMessage = 'Validation error. Please check all required fields.';
        } else if (e.response!.data != null &&
            e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      emit(SellEstateErrorState(errorMessage));
    } catch (e) {
      emit(SellEstateErrorState(
          'An unexpected error occurred. Please try again.'));
    }
  }

  // Get single estate by ID
  Future<Estate?> getEstateById(String estateId) async {
    try {
      final response = await DioHelper.getData(
        url: UrlConstants.getOneEstate(estateId),
        token: CacheHelper.getData(key: 'token'),
        query: {},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['status'] == 'success') {
        final estateData = response.data['data']['estate'];
        return Estate.fromJson(estateData);
      } else {
        return null;
      }
    } on DioException catch (e) {
      print('Error fetching estate by ID: $e');
      return null;
    } catch (e) {
      print('Unexpected error fetching estate by ID: $e');
      return null;
    }
  }
}

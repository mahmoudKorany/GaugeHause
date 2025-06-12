import 'package:gauge_haus/models/user_model.dart';
import 'package:gauge_haus/models/estate_model.dart';

abstract class AppCubitState {}

class AppCubitInitial extends AppCubitState {}

// Login States
class LoginLoadingState extends AppCubitState {}

class LoginSuccessState extends AppCubitState {
  final String token;
  final User user;

  LoginSuccessState({required this.token, required this.user});
}

class LoginErrorState extends AppCubitState {
  final String error;

  LoginErrorState(this.error);
}

// Register States
class RegisterLoadingState extends AppCubitState {}

class RegisterSuccessState extends AppCubitState {
  final String message;

  RegisterSuccessState({required this.message});
}

class RegisterErrorState extends AppCubitState {
  final String error;

  RegisterErrorState(this.error);
}

// User Data States
class UserDataLoadingState extends AppCubitState {}

class UserDataSuccessState extends AppCubitState {
  final User user;

  UserDataSuccessState({required this.user});
}

class UserDataErrorState extends AppCubitState {
  final String error;

  UserDataErrorState(this.error);
}

// My Estates States
class MyEstatesLoadingState extends AppCubitState {}

class MyEstatesSuccessState extends AppCubitState {
  final List<Estate> estates;

  MyEstatesSuccessState({required this.estates});
}

class MyEstatesErrorState extends AppCubitState {
  final String error;

  MyEstatesErrorState(this.error);
}

// Liked Estates States
class LikedEstatesLoadingState extends AppCubitState {}

class LikedEstatesSuccessState extends AppCubitState {
  final List<Estate> estates;

  LikedEstatesSuccessState({required this.estates});
}

class LikedEstatesErrorState extends AppCubitState {
  final String error;

  LikedEstatesErrorState(this.error);
}

// Combined Estates State - to hold both my estates and liked estates data
class CombinedEstatesState extends AppCubitState {
  final List<Estate> myEstates;
  final List<Estate> likedEstates;
  final bool myEstatesLoading;
  final bool likedEstatesLoading;
  final String? myEstatesError;
  final String? likedEstatesError;

  CombinedEstatesState({
    required this.myEstates,
    required this.likedEstates,
    this.myEstatesLoading = false,
    this.likedEstatesLoading = false,
    this.myEstatesError,
    this.likedEstatesError,
  });

  CombinedEstatesState copyWith({
    List<Estate>? myEstates,
    List<Estate>? likedEstates,
    bool? myEstatesLoading,
    bool? likedEstatesLoading,
    String? myEstatesError,
    String? likedEstatesError,
    bool clearMyEstatesError = false,
    bool clearLikedEstatesError = false,
  }) {
    return CombinedEstatesState(
      myEstates: myEstates ?? this.myEstates,
      likedEstates: likedEstates ?? this.likedEstates,
      myEstatesLoading: myEstatesLoading ?? this.myEstatesLoading,
      likedEstatesLoading: likedEstatesLoading ?? this.likedEstatesLoading,
      myEstatesError:
          clearMyEstatesError ? null : (myEstatesError ?? this.myEstatesError),
      likedEstatesError: clearLikedEstatesError
          ? null
          : (likedEstatesError ?? this.likedEstatesError),
    );
  }
}

// Like/Unlike Estate States
class LikeEstateLoadingState extends AppCubitState {}

class LikeEstateSuccessState extends AppCubitState {
  final String message;
  final bool isLiked;

  LikeEstateSuccessState({required this.message, required this.isLiked});
}

class LikeEstateErrorState extends AppCubitState {
  final String error;

  LikeEstateErrorState(this.error);
}

// Sell Estate States
class SellEstateLoadingState extends AppCubitState {}

class SellEstateSuccessState extends AppCubitState {
  final String message;
  final Estate estate;

  SellEstateSuccessState({required this.message, required this.estate});
}

class SellEstateErrorState extends AppCubitState {
  final String error;

  SellEstateErrorState(this.error);
}

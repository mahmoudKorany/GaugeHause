class UrlConstants {
  static const String baseUrl = 'https://gaugehaus.vercel.app/api';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/signin';
  static const String verifyOTP = '/auth/verifyOTP';
  static const String forgetPassword = '/auth/forgetPassword';
  static const String resetPassword = '/auth/resetPassword';
  static const String updatePassword = '/auth/updatePassword';

  // Add Estates endpoints
  static const String getAllEstates = '/estates';
  static getOneEstate(String estateId) => '/estates/$estateId';
  static const String sellEsate = '/estates';

  /// post request
  static const String updateEstate = '/estates'; // patch request
  static const String deleteEstate = '/estates'; // delete request
  static String getEstateByUser(estateId) => '/estates/user/$estateId';
  static String deslikeEstate(estateId) => '/estates/dislike-estate/$estateId';
  static String likeEstate(estateId) => '/estates/like-estate/$estateId';
  static String getNearstEstate(double lat, double long) =>
      'estates/nearest-estates/$lat,$long';
  static String getEstatesByDistance(
          double distance, double lat, double lng, String unit) =>
      '/estates/distance/$distance/latlng/$lat,$lng/unit/$unit';

  static const String myEstates = '/estates/my-estates';
  static String getLikedEstates(String userId) =>
      '/estates/liked-estates/$userId';

  // user
  static const String updateUser = '/users/updateMe';
  static const String deleteMe = '/users/deleteMe';
  static String getUserById(String userId) => '/users/$userId';

  // prediction
  static const String makePredictionOfPrice =
      '/predictions/predict'; // post request
  static const String makePredictModel = '/predict'; // post request
  static const String savePrediction = '/predictions/save'; // post request
  static const String getAllPredictions = '/predictions/';
  static String getPredictionById(String predictionId) =>
      '/predictions/$predictionId';

  //delete prediction
  static String deletePrediction(String predictionId) =>
      '/predictions/delete/$predictionId';
  // update prediction
  static String updatePrediction(String predictionId) =>
      '/predictions/update/$predictionId';
}

class Endpoints {
  static const String appName = "Movie App";

  // TODO: replace with the real API. While baseUrl is this placeholder the
  // app runs on dummy data from lib/network/mock_backend.dart.
  static const String baseUrl = "https://api.example.com/api/";
  static const String imageBaseUrl = "https://api.example.com/storage/";
  static bool get useMockData => baseUrl.contains("api.example.com");
  static const int appVersion = 1;

  //Auth
  static const String login = "login";
  static const String signup = "create-user";
  static const String getstarted = 'get-started';
  static const String verifyOtp = "verify-otp";
  static const String forgotPassword = "forgot_password";
  static const String favourite = "favorite";
  static const String getFavourites = "get_favorites";
  static const String movieCategories = "movie_categories";
  static const String deleteFavourite = "delete_favorite";
  static const String resetPassword = "reset_password";
  static const String resendOtp = "resend-otp";
  // Profile
  static const String profileSetup = "create_profile";
  static const String profileSelection = "get_profiles";
  static const String profileDelete = "delete_profile";
  static const String profileUpdate = "update_profile";

  // Movies
  static const String getMovies = "get_movies";
  static const String getSimilarMovies = "get_similar_movies";
  static const String searchMovies = "search_movies_advanced";
  static const String saveWatchProgess = "save_watch_progress";
  static const String continueWatching = "continue_watching";
}

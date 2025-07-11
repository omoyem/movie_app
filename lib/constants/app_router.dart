import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:godly_seed_app/view/favourites/screen/favourites_screen.dart';
import 'package:godly_seed_app/view/home/binding/home_binding.dart';
import 'package:godly_seed_app/view/home/screens/home_screen.dart';
import 'package:godly_seed_app/view/login/binding/login_binding.dart';
import 'package:godly_seed_app/view/login/screens/forgot_password_screen.dart';
import 'package:godly_seed_app/view/login/screens/login_screen.dart';
import 'package:godly_seed_app/view/movie/bindings/movie_binding.dart';
import 'package:godly_seed_app/view/movie/screens/movie_details_screen.dart';
import 'package:godly_seed_app/view/onboarding/screens/onboarding_screen.dart';
import 'package:godly_seed_app/view/profile_setup/bindings/profile_binding.dart';
import 'package:godly_seed_app/view/profile_setup/screens/profile_selection.dart';
import 'package:godly_seed_app/view/profile_setup/screens/profile_selection_screen.dart';
import 'package:godly_seed_app/view/profile_setup/screens/profile_setup_screen.dart';
import 'package:godly_seed_app/view/search/bindings/search_binding.dart';
import 'package:godly_seed_app/view/search/screen/search_movies_screen.dart';
import 'package:godly_seed_app/view/sign_up/binding/signup_binding.dart';
import 'package:godly_seed_app/view/sign_up/screens/get_started_screen.dart';
import 'package:godly_seed_app/view/sign_up/screens/otp_verification_screen.dart';
import 'package:godly_seed_app/view/sign_up/screens/signup_screen.dart';

import 'package:godly_seed_app/view/splash/splash_screen.dart';

import '../view/movie/bindings/favourite_binding.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String getStarted = '/getStarted';
  static const String otpVerification = '/otpVerification';
  static const String signup = '/signup';
  static const String signin = '/login';
  static const String favourite = '/favourites';
  static const String home = '/home';
  static const String profileSelection = '/profileSelection';
  
  static const String profileSetup = '/profileSetup';
  static const String forgot = '/forgot';
  static const String movie = '/movie';
  static const String movieDetails = '/movieDetails';
  static const String searchMovies = '/search';


  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: onboarding,
      page: () => OnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),
        GetPage(
      name: getStarted,
      page: () => GetStartedScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      binding: SignUpBinding(),

    ),
        GetPage(
      name: otpVerification,
      page: () => OtpVerificationScreen(email: '',),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      binding: SignUpBinding(),

    ),
    
    GetPage(
      name: signup,
      page: () => SignupScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      binding: SignUpBinding(),
    ),

    GetPage(
      name: signin,
      page: () => SignInScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      binding: LoginBinding(),
    ),

    GetPage(
      name: favourite,
      page: () => FavouritesScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      binding: FavouriteBinding(),
    ),

      GetPage(
      name: forgot,
      page: () => ForgotPasswordScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
    ),

      GetPage(
      name: profileSelection,
      page: () => ProfileSetupIntroScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      binding: ProfileBinding(),
    ),

      GetPage(
      name: profileSetup,
      page: () => ProfileSetupScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      binding: ProfileBinding(),
    ),

      GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      binding: HomeBinding(),
    ),

     GetPage(
      name: movie,
      page: () => MovieDetailsScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      binding: MovieBinding(),
    ),

    GetPage(
      name: searchMovies,
      page: () => SearchMoviesScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      binding: SearchBinding(),
    ),
    
  ];

  static void toOnboarding() => Get.offNamed(onboarding);
  static void toSignup() => Get.toNamed(signup);
  static void toLogin() => Get.toNamed(signin);
  static void toProfile() => Get.offAllNamed(profileSelection);
  static void toProfileSetup() => Get.toNamed(profileSetup);
  static void goBack() => Get.back();
  static void toForgotPassword() => Get.toNamed(forgot);
  static void toHome() => Get.toNamed(home);
  static void toSearch() => Get.toNamed(searchMovies);
  static void toGetStarted() => Get.toNamed(getStarted);
  static void toOtpAuth() => Get.toNamed(otpVerification);



}
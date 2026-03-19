import 'package:flutter/material.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/onboarding_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/hospitals/views/ambulance_hospitals_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String ambulance = '/ambulance';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    auth: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    ambulance: (context) => const AmbulanceHospitalsScreen(),
  };
}
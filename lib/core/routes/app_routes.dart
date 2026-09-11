import 'package:flutter/material.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/onboarding_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/home/views/profile_screen.dart';
import '../../features/home/views/bookings_screen.dart';
import '../../features/doctors/views/doctor_list_screen.dart';
import '../../features/hospitals/views/ambulance_hospitals_screen.dart';
import '../../features/platform/views/care_assistant_screen.dart';
import '../../features/platform/views/access_control_screen.dart';
import '../../features/platform/views/workspaces_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String ambulance = '/ambulance';
  static const String careHub = '/care-hub';
  static const String workspaces = '/workspaces';
  static const String doctorWorkspace = '/doctor-workspace';
  static const String hospitalOps = '/hospital-ops';
  static const String platformAdmin = '/platform-admin';
  static const String emergencyCommand = '/emergency-command';
  static const String careAssistant = '/care-assistant';
  static const String organizationAccess = '/organization-access';
  static const String profile = '/profile';
  static const String bookings = '/bookings';
  static const String doctors = '/doctors';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    auth: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    ambulance: (context) => const AmbulanceHospitalsScreen(),
    careHub: (context) => const CareHubScreen(),
    workspaces: (context) => const WorkspacePickerScreen(),
    doctorWorkspace: (context) => const DoctorWorkspaceScreen(),
    hospitalOps: (context) => const HospitalOperationsScreen(),
    platformAdmin: (context) => const PlatformAdminScreen(),
    emergencyCommand: (context) => const EmergencyCommandScreen(),
    careAssistant: (context) => const CareAssistantScreen(),
    organizationAccess: (context) => const OrganizationAccessScreen(),
    profile: (context) => const ProfileScreen(),
    bookings: (context) => const BookingsScreen(),
    doctors: (context) => const DoctorListScreen(categoryId: 'all', categoryName: 'All doctors'),
  };
}

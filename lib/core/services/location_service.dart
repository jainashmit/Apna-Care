import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationPermissionState {
  initial,
  granted,
  denied,
  permanentlyDenied,
}

class LocationPermissionNotifier extends StateNotifier<LocationPermissionState> {
  LocationPermissionNotifier() : super(LocationPermissionState.initial) {
    _checkInitialPermission();
  }

  Future<void> _checkInitialPermission() async {
    final status = await Permission.location.status;
    _updateState(status);
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    _updateState(status);
  }
  
  void _updateState(PermissionStatus status) {
    if (status.isGranted) {
      state = LocationPermissionState.granted;
    } else if (status.isPermanentlyDenied) {
      state = LocationPermissionState.permanentlyDenied;
    } else {
      state = LocationPermissionState.denied;
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}

final locationPermissionProvider = StateNotifierProvider<LocationPermissionNotifier, LocationPermissionState>((ref) {
  return LocationPermissionNotifier();
});

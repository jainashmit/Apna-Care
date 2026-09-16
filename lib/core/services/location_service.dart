import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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

  /// Returns the device position when the user has granted location access.
  /// A null result is expected in the demo: the UI can use its city fallback.
  Future<Position?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {
      return null;
    }
  }
}

final locationPermissionProvider = StateNotifierProvider<LocationPermissionNotifier, LocationPermissionState>((ref) {
  return LocationPermissionNotifier();
});

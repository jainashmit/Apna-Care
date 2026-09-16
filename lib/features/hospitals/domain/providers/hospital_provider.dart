import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/hospital_model.dart';
import '../../data/repositories/hospital_repository_impl.dart';
import 'package:apna_ghar/features/hospitals/domain/repositories/hospital_repository.dart';

// ── Repository Provider ────────────────────────────────────────
final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepositoryImpl();
});

// ── All Nearby Hospitals ───────────────────────────────────────
final hospitalsProvider = FutureProvider<List<HospitalModel>>((ref) async {
  final repo = ref.watch(hospitalRepositoryProvider);
  final permission = ref.watch(locationPermissionProvider);
  if (permission == LocationPermissionState.granted) {
    final position = await ref
        .read(locationPermissionProvider.notifier)
        .currentPosition();
    if (position != null) {
      return repo.getNearbyHospitals(
        lat: position.latitude,
        lng: position.longitude,
      );
    }
  }
  // New Delhi is the deterministic demo location until the user grants GPS.
  return repo.getNearbyHospitals(lat: 28.6139, lng: 77.2090);
});

// ── Ambulance-capable hospitals (derived) ─────────────────────
final ambulanceHospitalsProvider = FutureProvider<List<HospitalModel>>((ref) async {
  final repo = ref.watch(hospitalRepositoryProvider);
  return repo.getAmbulanceHospitals();
});

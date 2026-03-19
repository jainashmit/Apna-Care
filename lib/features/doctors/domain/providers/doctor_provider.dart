import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/doctor_model.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import 'package:apna_ghar/features/doctors/domain/repositories/doctor_repository.dart';

// ── Repository Provider ────────────────────────────────────────
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl();
});

// ── Top Doctors ────────────────────────────────────────────────
final topDoctorsProvider = FutureProvider<List<DoctorModel>>((ref) async {
  final repo = ref.watch(doctorRepositoryProvider);
  return repo.getTopDoctors(lat: 28.6139, lng: 77.2090);
});

// ── Doctors By Category ──────────────────────────────────────────────
final doctorsByCategoryProvider = FutureProvider.family<List<DoctorModel>, String?>((ref, categoryId) async {
  final repo = ref.watch(doctorRepositoryProvider);
  if (categoryId == null) return [];
  // Map category ID to specialty keyword
  String? specialty;
  if (categoryId == 'general_physician') specialty = 'Physician';
  else if (categoryId == 'orthopedics') specialty = 'Orthopaedic';
  else if (categoryId == 'pediatrics') specialty = 'Pediatric';
  else if (categoryId == 'dermatology') specialty = 'Derma';
  else if (categoryId == 'dentist') specialty = 'Dentist';
  else if (categoryId == 'cardiology') specialty = 'Cardiology';
  else if (categoryId == 'neurology') specialty = 'Neurology';
  else if (categoryId == 'ent') specialty = 'ENT';
  else if (categoryId == 'ophthalmology') specialty = 'Eye';
  
  return repo.getTopDoctors(lat: 28.6139, lng: 77.2090, specialty: specialty);
});

import '../../data/models/doctor_model.dart';

/// Abstract contract for doctor data operations.
/// Implement this with a real HTTP client when API docs arrive.
abstract class DoctorRepository {
  /// Get top-rated doctors near [lat]/[lng], filtered by [specialty].
  Future<List<DoctorModel>> getTopDoctors({
    required double lat,
    required double lng,
    String? specialty,
    int radiusKm = 10,
  });

  /// Get full doctor profile by [id].
  Future<DoctorModel> getDoctorById(String id);
}

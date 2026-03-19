import '../../data/models/hospital_model.dart';

/// Abstract contract for hospital data operations.
abstract class HospitalRepository {
  /// Get nearby hospitals for given coordinates + optional service filter.
  Future<List<HospitalModel>> getNearbyHospitals({
    required double lat,
    required double lng,
    String? serviceFilter, // e.g. 'surgery', 'opd'
    int radiusKm = 15,
  });

  /// Get full hospital detail by [id].
  Future<HospitalModel> getHospitalById(String id);

  /// Returns only hospitals that provide ambulance service.
  Future<List<HospitalModel>> getAmbulanceHospitals();
}

import '../../data/models/hospital_model.dart';
import 'package:apna_ghar/features/hospitals/domain/repositories/hospital_repository.dart';

/// Concrete implementation of [HospitalRepository] returning mock data.
/// Swap [_fetchFromApi] for real HTTP calls when the backend is ready.
class HospitalRepositoryImpl implements HospitalRepository {
  static final List<HospitalModel> _mockData = [
    HospitalModel(
      id: 'h1',
      name: 'Apollo Clinic',
      rating: 4.8,
      reviewCount: 312,
      distanceKm: 1.2,
      specialties: const ['Multi-specialty', 'OPD', 'Surgery'],
      address: 'Saket, New Delhi – 110017',
      hasEmergency: true,
      hasAmbulance: true,
    ),
    HospitalModel(
      id: 'h2',
      name: 'Fortis Hospital',
      rating: 4.6,
      reviewCount: 287,
      distanceKm: 2.7,
      specialties: const ['Cardiology', 'Surgery'],
      address: 'Vasant Kunj, New Delhi – 110070',
      hasEmergency: true,
      hasAmbulance: true,
    ),
    HospitalModel(
      id: 'h3',
      name: 'Medanta',
      rating: 4.9,
      reviewCount: 501,
      distanceKm: 4.0,
      specialties: const ['Neurology', 'Orthopaedics', 'ENT'],
      address: 'Gurugram, Haryana – 122001',
      hasEmergency: true,
      hasAmbulance: true,
    ),
    HospitalModel(
      id: 'h4',
      name: 'Max Super Speciality',
      rating: 4.5,
      reviewCount: 198,
      distanceKm: 3.5,
      specialties: const ['OPD', 'Paediatrics'],
      address: 'Patparganj, New Delhi – 110092',
      hasEmergency: false,
      hasAmbulance: false,
    ),
    HospitalModel(
      id: 'h5',
      name: 'AIIMS Delhi',
      rating: 4.9,
      reviewCount: 1024,
      distanceKm: 6.1,
      specialties: const ['Multi-specialty', 'Research', 'Surgery'],
      address: 'Ansari Nagar, New Delhi – 110029',
      hasEmergency: true,
      hasAmbulance: true,
    ),
  ];

  @override
  Future<List<HospitalModel>> getNearbyHospitals({
    required double lat,
    required double lng,
    String? serviceFilter,
    int radiusKm = 15,
  }) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    if (serviceFilter == null) return _mockData;
    return _mockData
        .where((h) => h.specialties.any(
              (s) => s.toLowerCase().contains(serviceFilter.toLowerCase()),
            ))
        .toList();
  }

  @override
  Future<HospitalModel> getHospitalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockData.firstWhere((h) => h.id == id);
  }

  /// Returns only hospitals that provide ambulance service.
  Future<List<HospitalModel>> getAmbulanceHospitals() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockData.where((h) => h.hasAmbulance).toList();
  }
}

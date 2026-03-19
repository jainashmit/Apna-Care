import '../../data/models/doctor_model.dart';
import 'package:apna_ghar/features/doctors/domain/repositories/doctor_repository.dart';

/// Concrete implementation of [DoctorRepository] returning mock data.
/// Replace [_fetchFromApi] with real HTTP calls when backend is ready.
class DoctorRepositoryImpl implements DoctorRepository {
  static final List<DoctorModel> _mockData = [
    DoctorModel(
      id: 'd1',
      name: 'Dr. R. Mehta',
      specialty: 'Cardiologist',
      rating: 4.9,
      reviewCount: 248,
      opdFee: 800,
      experience: '12 yrs',
      hospitalName: 'Apollo Clinic',
      distanceKm: 1.2,
      isAvailable: true,
    ),
    DoctorModel(
      id: 'd2',
      name: 'Dr. S. Sharma',
      specialty: 'Neurologist',
      rating: 4.7,
      reviewCount: 183,
      opdFee: 700,
      experience: '8 yrs',
      hospitalName: 'Medanta',
      distanceKm: 4.0,
      isAvailable: true,
    ),
    DoctorModel(
      id: 'd3',
      name: 'Dr. A. Gupta',
      specialty: 'ENT Specialist',
      rating: 4.8,
      reviewCount: 316,
      opdFee: 500,
      experience: '10 yrs',
      hospitalName: 'Fortis Hospital',
      distanceKm: 2.7,
      isAvailable: false,
    ),
    DoctorModel(
      id: 'd4',
      name: 'Dr. P. Singh',
      specialty: 'Orthopaedic',
      rating: 4.6,
      reviewCount: 142,
      opdFee: 600,
      experience: '15 yrs',
      hospitalName: 'Max Super Speciality',
      distanceKm: 3.5,
      isAvailable: true,
    ),
  ];

  @override
  Future<List<DoctorModel>> getTopDoctors({
    double lat = 28.6,
    double lng = 77.2,
    String? specialty,
    int radiusKm = 10,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var results = _mockData.take(limit).toList();
    if (specialty != null) {
      results = results
          .where((d) => d.specialty.toLowerCase().contains(specialty.toLowerCase()))
          .toList();
    }
    return results;
  }

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockData.firstWhere((d) => d.id == id);
  }
}

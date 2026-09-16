import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../data/models/hospital_model.dart';
import 'package:apna_ghar/features/hospitals/domain/repositories/hospital_repository.dart';

/// Concrete implementation of [HospitalRepository] returning mock data.
/// Swap for real HTTP calls when the backend is ready.
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
    HospitalModel(
      id: 'h6',
      name: 'BLK Super Speciality',
      rating: 4.7,
      reviewCount: 435,
      distanceKm: 3.2,
      specialties: const ['Oncology', 'Transplant', 'Cardiology'],
      address: 'Pusa Road, New Delhi – 110005',
      hasEmergency: true,
      hasAmbulance: true,
    ),
    HospitalModel(
      id: 'h7',
      name: 'Safdarjung Hospital',
      rating: 4.3,
      reviewCount: 756,
      distanceKm: 5.4,
      specialties: const ['General Medicine', 'Surgery', 'OPD'],
      address: 'Safdarjung, New Delhi – 110029',
      hasEmergency: true,
      hasAmbulance: true,
    ),
    HospitalModel(
      id: 'h8',
      name: 'Rockland Hospital',
      rating: 4.4,
      reviewCount: 163,
      distanceKm: 2.1,
      specialties: const ['Gynaecology', 'Orthopaedics', 'Dermatology'],
      address: 'Qutab Institutional Area, New Delhi – 110016',
      hasEmergency: false,
      hasAmbulance: true,
    ),
    HospitalModel(
      id: 'h9',
      name: 'Sir Ganga Ram Hospital',
      rating: 4.8,
      reviewCount: 612,
      distanceKm: 4.8,
      specialties: const ['Nephrology', 'Urology', 'Gastroenterology'],
      address: 'Rajinder Nagar, New Delhi – 110060',
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
    final liveResults = await _fetchFromPlaces(lat: lat, lng: lng, radiusKm: radiusKm);
    if (liveResults.isNotEmpty) {
      return _filter(liveResults, serviceFilter);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    return _filter(_mockData, serviceFilter);
  }

  List<HospitalModel> _filter(List<HospitalModel> hospitals, String? serviceFilter) {
    if (serviceFilter == null || serviceFilter.trim().isEmpty) return hospitals;
    return hospitals
        .where((hospital) => hospital.specialties.any(
              (specialty) => specialty.toLowerCase().contains(serviceFilter.toLowerCase()),
            ))
        .toList();
  }

  Future<List<HospitalModel>> _fetchFromPlaces({
    required double lat,
    required double lng,
    required int radiusKm,
  }) async {
    if (AppConfig.googlePlacesApiKey.isEmpty) return const [];
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/nearbysearch/json', {
        'location': '$lat,$lng',
        'radius': '${radiusKm * 1000}',
        'type': 'hospital',
        'key': AppConfig.googlePlacesApiKey,
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return const [];
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      if (payload['status'] != 'OK') return const [];
      final results = payload['results'] as List<dynamic>? ?? const [];
      return results.map((raw) {
        final item = raw as Map<String, dynamic>;
        final name = item['name'] as String? ?? 'Nearby hospital';
        return HospitalModel(
          id: item['place_id'] as String? ?? name,
          name: name,
          rating: (item['rating'] as num?)?.toDouble() ?? 0,
          reviewCount: (item['user_ratings_total'] as num?)?.toInt() ?? 0,
          distanceKm: 0,
          specialties: const ['Hospital', 'OPD'],
          address: item['vicinity'] as String? ?? 'Address unavailable',
          hasEmergency: name.toLowerCase().contains('emergency'),
          hasAmbulance: false,
          isLive: true,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<HospitalModel> getHospitalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockData.firstWhere((h) => h.id == id);
  }

  @override
  Future<List<HospitalModel>> getAmbulanceHospitals() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockData.where((h) => h.hasAmbulance).toList();
  }
}

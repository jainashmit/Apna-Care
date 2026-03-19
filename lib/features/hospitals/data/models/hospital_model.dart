/// Hospital model — maps to API response
class HospitalModel {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final List<String> specialties;
  final String address;
  final bool hasEmergency;
  final bool hasAmbulance;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.specialties,
    required this.address,
    this.hasEmergency = false,
    this.hasAmbulance = false,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      distanceKm: (json['distance_km'] as num).toDouble(),
      specialties: List<String>.from(json['specialties'] as List),
      address: json['address'] as String,
      hasEmergency: json['has_emergency'] as bool? ?? false,
      hasAmbulance: json['has_ambulance'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rating': rating,
        'review_count': reviewCount,
        'distance_km': distanceKm,
        'specialties': specialties,
        'address': address,
        'has_emergency': hasEmergency,
        'has_ambulance': hasAmbulance,
      };
}

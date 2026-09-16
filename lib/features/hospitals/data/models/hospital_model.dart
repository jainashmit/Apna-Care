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
  final String phone;
  final String openHours;
  final List<String> services;
  final int availableDoctors;
  final String emergencyWait;
  final bool acceptsInsurance;
  final bool verified;
  final bool isLive;

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
    this.phone = '+91 1800 123 4567',
    this.openHours = 'Open today · 24 hours',
    this.services = const ['OPD', 'Diagnostics', 'Pharmacy'],
    this.availableDoctors = 12,
    this.emergencyWait = '8–12 min',
    this.acceptsInsurance = true,
    this.verified = true,
    this.isLive = false,
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
      phone: json['phone'] as String? ?? '+91 1800 123 4567',
      openHours: json['open_hours'] as String? ?? 'Open today · 24 hours',
      services: List<String>.from(json['services'] as List? ?? const ['OPD', 'Diagnostics', 'Pharmacy']),
      availableDoctors: (json['available_doctors'] as num?)?.toInt() ?? 12,
      emergencyWait: json['emergency_wait'] as String? ?? '8–12 min',
      acceptsInsurance: json['accepts_insurance'] as bool? ?? true,
      verified: json['verified'] as bool? ?? true,
      isLive: json['is_live'] as bool? ?? false,
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
        'phone': phone,
        'open_hours': openHours,
        'services': services,
        'available_doctors': availableDoctors,
        'emergency_wait': emergencyWait,
        'accepts_insurance': acceptsInsurance,
        'verified': verified,
        'is_live': isLive,
      };
}

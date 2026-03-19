/// Doctor model — maps to API response
class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final int opdFee;
  final String experience; // e.g. "12 yrs"
  final String? imageUrl;
  final String? hospitalName;
  final double? distanceKm;
  final bool isAvailable;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.opdFee,
    required this.experience,
    this.imageUrl,
    this.hospitalName,
    this.distanceKm,
    this.isAvailable = true,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      opdFee: json['opd_fee'] as int,
      experience: json['experience'] as String,
      imageUrl: json['image_url'] as String?,
      hospitalName: json['hospital_name'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'rating': rating,
        'review_count': reviewCount,
        'opd_fee': opdFee,
        'experience': experience,
        'image_url': imageUrl,
        'hospital_name': hospitalName,
        'distance_km': distanceKm,
        'is_available': isAvailable,
      };
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// HD Unsplash doctor portraits — 8 unique medical headshots.
const List<String> _kDoctorPhotoUrls = [
  'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1643297654416-05795d62e39c?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1651008376811-b90baee60c1e?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1638202993928-7267aad84c31?w=400&q=85&fm=webp&fit=crop',
];

/// HD Unsplash hospital building exteriors — 5 unique locations.
const List<String> _kHospitalPhotoUrls = [
  'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1587351021759-3772687fe598?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1516549655669-df64a3a17016?w=400&q=85&fm=webp&fit=crop',
  'https://images.unsplash.com/photo-1618498082410-b4aa22193b38?w=400&q=85&fm=webp&fit=crop',
];

/// Returns a deterministic HD doctor portrait URL based on any seed string.
String hdDoctorUrl(String? seed) {
  if (seed == null) return _kDoctorPhotoUrls[0];
  final index = seed.hashCode.abs() % _kDoctorPhotoUrls.length;
  return _kDoctorPhotoUrls[index];
}

/// Returns a deterministic HD hospital exterior photo URL.
String hdHospitalUrl(String? seed) {
  if (seed == null) return _kHospitalPhotoUrls[0];
  final index = seed.hashCode.abs() % _kHospitalPhotoUrls.length;
  return _kHospitalPhotoUrls[index];
}

/// Returns a Premium Icons8 3D Fluency icon URL (512px, transparent bg).
/// Use for service icons, category icons, and any UI iconography.
/// Source: https://icons8.com/icons/set/3d-fluency -- free for web/app use.
String icons83d(String name) =>
    'https://img.icons8.com/3d-fluency/94/$name.png';


/// A premium circular avatar that:
///  - Loads from [imageUrl] using CachedNetworkImage (FilterQuality.high)
///  - Shows a pulsing shimmer skeleton while loading
///  - Falls back to a local 3D doctor asset on error — never shows a broken icon
///
/// Usage:
///   HdAvatar(imageUrl: hdDoctorUrl(doc.id), radius: 29)
class HdAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const HdAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (_, __) => _ShimmerCircle(size: size),
          errorWidget: (_, __, ___) => _FallbackAvatar(size: size),
        ),
      ),
    );
  }
}

// ── Shimmer skeleton
class _ShimmerCircle extends StatelessWidget {
  final double size;
  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0EDD8),
      highlightColor: const Color(0xFFF5FAF0),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── 3D Local Asset Fallback
class _FallbackAvatar extends StatelessWidget {
  final double size;
  const _FallbackAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFCEE9C3),
      child: Image.asset(
        'assets/images/doctors/3d/doctor_1.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// A rounded-rectangle version for hospital / banner images.
class HdImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const HdImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: const Color(0xFFE0EDD8),
          highlightColor: const Color(0xFFF5FAF0),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: const Color(0xFFCEE9C3),
          child: Image.asset(
            'assets/images/hospitals/3d/hospital_1.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

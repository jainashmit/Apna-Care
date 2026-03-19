/// Banner model — managed by Super Admin CMS
class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? deepLink; // e.g. route to navigate on tap
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.deepLink,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String?,
      deepLink: json['deep_link'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image_url': imageUrl,
        'deep_link': deepLink,
        'is_active': isActive,
      };
}

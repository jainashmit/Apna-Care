/// User model — authenticated user profile
class UserModel {
  final String id;
  final String mobile;
  final String? name;
  final String? email;
  final String? profileImageUrl;
  final String role; // 'user' | 'provider' | 'admin'

  const UserModel({
    required this.id,
    required this.mobile,
    this.name,
    this.email,
    this.profileImageUrl,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      mobile: json['mobile'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mobile': mobile,
        'name': name,
        'email': email,
        'profile_image_url': profileImageUrl,
        'role': role,
      };
}

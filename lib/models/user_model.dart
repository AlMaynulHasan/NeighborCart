/// Represents the signed-in household member.
class UserModel {
  final String id;
  final String name;
  final String emailOrPhone;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    this.avatarUrl,
  });
}

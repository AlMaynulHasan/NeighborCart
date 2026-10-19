import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/auth_mode.dart';

/// Mirrors the `users/{uid}` Firestore document.
class UserModel {
  final String id;
  final String name; // customer full name
  final String emailOrPhone;
  final String? avatarUrl;
  final AuthMode role;
  final String? businessName; // wholesaler
  final String? contactName; // wholesaler
  final String? activePoolId;
  final List<String> joinedPoolIds;

  const UserModel({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    this.avatarUrl,
    this.role = AuthMode.customer,
    this.businessName,
    this.contactName,
    this.activePoolId,
    this.joinedPoolIds = const [],
  });

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return UserModel(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      emailOrPhone: (d['email'] as String?) ?? '',
      avatarUrl: d['avatarUrl'] as String?,
      role: d['role'] == 'wholesaler' ? AuthMode.wholesaler : AuthMode.customer,
      businessName: d['businessName'] as String?,
      contactName: d['contactName'] as String?,
      activePoolId: d['activePoolId'] as String?,
      joinedPoolIds: List<String>.from((d['joinedPoolIds'] as List<dynamic>?) ?? const []),
    );
  }

  String get firstName {
    final n = name.trim();
    return n.isEmpty ? 'there' : n.split(' ').first;
  }

  /// Name to show on a profile header.
  String get displayName {
    if (role == AuthMode.wholesaler) {
      return businessName ?? contactName ?? emailOrPhone;
    }
    return name.isNotEmpty ? name : emailOrPhone;
  }
}

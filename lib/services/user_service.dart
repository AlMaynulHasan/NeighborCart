import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<UserModel> watchCurrentUser() {
    final uid = AuthService.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots().map(UserModel.fromDoc);
  }

  Future<void> setHouseholdSize(int size) {
    final uid = AuthService.instance.currentUser!.uid;
    final clamped = size < 1 ? 1 : (size > 12 ? 12 : size);
    return _db
        .collection('users')
        .doc(uid)
        .set({'householdSize': clamped}, SetOptions(merge: true));
  }
}

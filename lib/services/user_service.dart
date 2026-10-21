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

  /// Changes a customer's name everywhere it is copied: their profile, their
  /// member entries in joined pools, and the coordinator name on pools they run.
  Future<void> updateCustomerName(String name) async {
    final uid = AuthService.instance.currentUser!.uid;
    final userRef = _db.collection('users').doc(uid);
    final userSnap = await userRef.get();
    final poolIds = List<String>.from((userSnap.data()?['joinedPoolIds'] as List<dynamic>?) ?? const []);

    final batch = _db.batch();
    batch.set(userRef, {'name': name}, SetOptions(merge: true));
    for (final poolId in poolIds) {
      final poolRef = _db.collection('pools').doc(poolId);
      final memberRef = poolRef.collection('pool_members').doc(uid);
      if ((await memberRef.get()).exists) {
        batch.update(memberRef, {'name': name});
      }
      final poolSnap = await poolRef.get();
      if (poolSnap.data()?['coordinatorUid'] == uid) {
        batch.update(poolRef, {'coordinatorName': name});
      }
    }
    await batch.commit();
  }

  Future<void> updateWholesalerProfile({
    required String businessName,
    required String contactName,
  }) {
    final uid = AuthService.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).set(
      {'businessName': businessName, 'contactName': contactName},
      SetOptions(merge: true),
    );
  }
}

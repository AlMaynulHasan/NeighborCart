import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// "Report a problem" (consumer protection): stored in `reports/` for the
/// project team to review in the Firebase console.
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the report reference id.
  Future<String> submit({
    required String category,
    required String message,
    String? poolId,
    String? poolName,
  }) async {
    final uid = AuthService.instance.currentUser!.uid;
    final ref = _db.collection('reports').doc();
    await ref.set({
      'uid': uid,
      'category': category,
      'message': message.trim(),
      if (poolId != null) 'poolId': poolId,
      if (poolName != null) 'poolName': poolName,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/stream_utils.dart';
import '../models/reliability_model.dart';

class _CacheEntry {
  final DateTime at;
  final Future<ReliabilityScore> future;
  _CacheEntry(this.at, this.future);
}

/// Reads a member's reliability record: `users/{uid}/reliability/summary`
/// (counters written when a pool cycle is completed) plus the shared
/// weights in `config/reliability`.
class ReliabilityService {
  ReliabilityService._();
  static final ReliabilityService instance = ReliabilityService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, _CacheEntry> _cache = {};

  DocumentReference<Map<String, dynamic>> _summaryRef(String uid) =>
      _db.collection('users').doc(uid).collection('reliability').doc('summary');

  DocumentReference<Map<String, dynamic>> get _configRef =>
      _db.collection('config').doc('reliability');

  ReliabilityScore _build(Map<String, dynamic>? summary, Map<String, dynamic>? config) {
    return ReliabilityScore(
      cycles: (summary?['cycles'] as num?)?.toInt() ?? 0,
      paid: (summary?['paid'] as num?)?.toInt() ?? 0,
      pickedUp: (summary?['pickedUp'] as num?)?.toInt() ?? 0,
      weights: ReliabilityWeights.fromMap(config),
    );
  }

  /// Live score for the profile screen.
  Stream<ReliabilityScore> watchScore(String uid) {
    return combineLatest2<DocumentSnapshot<Map<String, dynamic>>,
        DocumentSnapshot<Map<String, dynamic>>, ReliabilityScore>(
      _summaryRef(uid).snapshots(),
      _configRef.snapshots(),
      (summary, config) => _build(summary.data(), config.data()),
    );
  }

  /// One-off read (cached for a minute) for lists of members.
  Future<ReliabilityScore> getScore(String uid) {
    final cached = _cache[uid];
    if (cached != null && DateTime.now().difference(cached.at) < const Duration(seconds: 60)) {
      return cached.future;
    }
    final future = () async {
      final summary = await _summaryRef(uid).get();
      final config = await _configRef.get();
      return _build(summary.data(), config.data());
    }();
    _cache[uid] = _CacheEntry(DateTime.now(), future);
    return future;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pricing_tier_model.dart';
import 'auth_service.dart';

/// Wholesale price-break tiers live in one shared doc (`config/pricing`)
/// that the wholesaler edits and every pool/cart reads. Falls back to
/// [defaultTiers] until the wholesaler saves their own.
class PricingService {
  PricingService._();
  static final PricingService instance = PricingService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<PricingTierModel> defaultTiers = [
    PricingTierModel(id: 't1', label: 'Tier 1', minimumThreshold: 5000, discountPercent: 10, isActive: true),
    PricingTierModel(id: 't2', label: 'Tier 2', minimumThreshold: 10000, discountPercent: 15, isActive: true),
    PricingTierModel(id: 't3', label: 'Tier 3', minimumThreshold: 15000, discountPercent: 20, isActive: true),
  ];

  DocumentReference<Map<String, dynamic>> get _ref => _db.collection('config').doc('pricing');

  Stream<List<PricingTierModel>> watchTiers() {
    return _ref.snapshots().map((snap) {
      final raw = snap.data()?['tiers'] as List<dynamic>?;
      if (raw == null || raw.isEmpty) return defaultTiers;
      final tiers = raw
          .map((e) => PricingTierModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      tiers.sort((a, b) => a.minimumThreshold.compareTo(b.minimumThreshold));
      return tiers;
    });
  }

  Future<void> saveTiers(List<PricingTierModel> tiers) {
    final sorted = List<PricingTierModel>.of(tiers)
      ..sort((a, b) => a.minimumThreshold.compareTo(b.minimumThreshold));
    return _ref.set({
      'tiers': sorted.map((t) => t.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': AuthService.instance.currentUser?.uid,
    });
  }
}

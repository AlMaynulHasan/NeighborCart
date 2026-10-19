import 'package:cloud_firestore/cloud_firestore.dart';
import 'pricing_service.dart';

class _SeedProduct {
  final String id, name, description, category, shelfLife;
  final double price;
  final int moq, stock;
  final bool active;
  const _SeedProduct(this.id, this.name, this.description, this.category, this.price,
      this.moq, this.stock, this.shelfLife,
      {this.active = true});
}

/// DEV ONLY — loads demo data so a fresh Firestore isn't empty.
/// Wired to "Load demo ..." tiles on the Profile screens. Safe to run
/// repeatedly (skips anything that already exists).
class SeedService {
  SeedService._();
  static final SeedService instance = SeedService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _catalog = [
    _SeedProduct('seed_rice', 'Miniket Rice 5kg', 'Premium polished grains', 'Grains', 380, 5, 220, '12 months'),
    _SeedProduct('seed_lentils', 'Red Lentils 2kg', 'Deshi moshur dal', 'Pulses', 260, 4, 180, '9 months'),
    _SeedProduct('seed_oil', 'Soybean Oil 5L', 'Rupchanda premium oil', 'Cooking Oil', 820, 3, 30, '18 months'),
    _SeedProduct('seed_onion', 'Onion 3kg', 'Local organic red onions', 'Vegetables', 220, 5, 210, '2 months'),
    _SeedProduct('seed_sugar', 'Sugar 2kg', 'Refined white sugar', 'Grocery', 170, 4, 3, '24 months'),
    _SeedProduct('seed_turmeric', 'Turmeric Powder 500g', 'Ground turmeric', 'Spices', 130, 3, 120, '12 months', active: false),
  ];

  _SeedProduct _p(String id) => _catalog.firstWhere((p) => p.id == id);

  DateTime _nextWeekday(int weekday, int hour) {
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day, hour);
    while (d.weekday != weekday || !d.isAfter(now)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  Map<String, dynamic> _demand(Map<String, int> qtyById) => {
        for (final e in qtyById.entries) e.key: {'name': _p(e.key).name, 'qty': e.value},
      };

  /// Wholesaler: this wholesaler's demo products + default pricing tiers.
  /// Returns how many products were created.
  Future<int> seedWholesalerCatalog(String uid) async {
    var created = 0;
    for (final p in _catalog) {
      final ref = _db.collection('products').doc(p.id);
      if ((await ref.get()).exists) continue;
      await ref.set({
        'name': p.name,
        'description': p.description,
        'category': p.category,
        'wholesalePrice': p.price,
        'moq': p.moq,
        'availableQuantity': p.stock,
        'shelfLife': p.shelfLife,
        'isActive': p.active,
        'wholesalerUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      created++;
    }
    final pricingRef = _db.collection('config').doc('pricing');
    if (!(await pricingRef.get()).exists) {
      await PricingService.instance.saveTiers(PricingService.defaultTiers);
    }
    return created;
  }

  /// Customer: demo pools (with a few seeded neighbors in the Block-C pool).
  /// Returns how many pools were created.
  Future<int> seedPools() async {
    var created = 0;

    Future<bool> createPool(String id, Map<String, dynamic> data) async {
      final ref = _db.collection('pools').doc(id);
      if ((await ref.get()).exists) return false;
      await ref.set({...data, 'createdAt': FieldValue.serverTimestamp()});
      return true;
    }

    // Seeded neighbors for the Block-C pool: uid -> (name, paid, qty by product)
    final neighbors = <String, (String, bool, Map<String, int>)>{
      'seed_tanvir': ('Tanvir Ahmed', false, {'seed_rice': 2, 'seed_oil': 2, 'seed_lentils': 2, 'seed_onion': 3}),
      'seed_sadia': ('Sadia Rahman', true, {'seed_rice': 1, 'seed_lentils': 2, 'seed_sugar': 3}),
      'seed_jubayer': ('Jubayer Al-Mahmud', true, {'seed_rice': 3, 'seed_oil': 1, 'seed_onion': 2, 'seed_sugar': 2, 'seed_lentils': 1}),
    };
    final blockCDemand = <String, int>{};
    var blockCValue = 0.0;
    final cartDocs = <String, Map<String, dynamic>>{};
    neighbors.forEach((uid, n) {
      var subtotal = 0.0;
      final items = <Map<String, dynamic>>[];
      n.$3.forEach((pid, qty) {
        final p = _p(pid);
        subtotal += p.price * qty;
        blockCDemand[pid] = (blockCDemand[pid] ?? 0) + qty;
        items.add({
          'productId': pid,
          'name': p.name,
          'description': p.description,
          'price': p.price,
          'quantity': qty,
        });
      });
      blockCValue += subtotal;
      cartDocs[uid] = {'items': items, 'subtotal': subtotal, 'updatedAt': FieldValue.serverTimestamp()};
    });

    if (await createPool('pool_saidpur_c', {
      'name': 'Saidpur Block-C Pool',
      'pickupLocation': 'Saidpur Community Center, Gate 2',
      'deadline': Timestamp.fromDate(_nextWeekday(DateTime.thursday, 20)),
      'coordinatorName': 'Zahid Hasan',
      'coordinatorUid': 'seed_zahid',
      'orderNumber': 204,
      'memberCount': 12,
      'collectiveValue': blockCValue,
      'demand': _demand(blockCDemand),
      'updatedAt': FieldValue.serverTimestamp(),
    })) {
      created++;
      final poolRef = _db.collection('pools').doc('pool_saidpur_c');
      for (final e in neighbors.entries) {
        await poolRef.collection('pool_members').doc(e.key).set({
          'name': e.value.$1,
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
        });
        await poolRef.collection('carts').doc(e.key).set(cartDocs[e.key]!);
        if (e.value.$2) {
          await poolRef.collection('payments').doc(e.key).set({
            'uid': e.key,
            'amount': (cartDocs[e.key]!['subtotal'] as double) * 0.9,
            'paidAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    if (await createPool('pool_nilphamari', {
      'name': 'Nilphamari Road Pool',
      'pickupLocation': 'Saidpur Govt College Gate',
      'deadline': Timestamp.fromDate(_nextWeekday(DateTime.thursday, 20)),
      'coordinatorName': 'Rafiq Hossain',
      'coordinatorUid': 'seed_rafiq',
      'orderNumber': 187,
      'memberCount': 8,
      'collectiveValue': 6200,
      'demand': _demand({'seed_lentils': 12, 'seed_oil': 6}),
      'updatedAt': FieldValue.serverTimestamp(),
    })) {
      created++;
    }

    if (await createPool('pool_university', {
      'name': 'University Quarter Pool',
      'pickupLocation': 'Unicourt Community Gate 1',
      'deadline': Timestamp.fromDate(_nextWeekday(DateTime.wednesday, 18)),
      'coordinatorName': 'Nusrat Jahan',
      'coordinatorUid': 'seed_nusrat',
      'orderNumber': 211,
      'memberCount': 15,
      'collectiveValue': 11200,
      'demand': _demand({'seed_rice': 14, 'seed_onion': 20, 'seed_sugar': 9}),
      'updatedAt': FieldValue.serverTimestamp(),
    })) {
      created++;
    }

    if (await createPool('pool_east_saidpur', {
      'name': 'East Saidpur Block-A Pool',
      'pickupLocation': 'Al-Falah Jame Mosque Complex',
      'deadline': Timestamp.fromDate(_nextWeekday(DateTime.friday, 16)),
      'coordinatorName': 'Imran Khan',
      'coordinatorUid': 'seed_imran',
      'orderNumber': 176,
      'memberCount': 6,
      'collectiveValue': 3100,
      'demand': _demand({'seed_rice': 3, 'seed_turmeric': 2}),
      'updatedAt': FieldValue.serverTimestamp(),
    })) {
      created++;
    }

    return created;
  }
}

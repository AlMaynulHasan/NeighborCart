import '../core/utils/stream_utils.dart';
import '../models/bid_model.dart';
import '../models/pool_model.dart';
import 'auth_service.dart';
import 'bid_service.dart';
import 'pool_service.dart';

/// Aggregated demand of the open pools in one neighbourhood. Only totals are
/// shown — never individual members' baskets.
class AreaDemand {
  final String area;
  final List<PoolModel> pools;

  const AreaDemand({required this.area, required this.pools});

  int get poolCount => pools.length;
  int get memberCount => pools.fold<int>(0, (s, p) => s + p.memberCount);
  double get totalValue => pools.fold<double>(0, (s, p) => s + p.collectiveValue);

  List<MapEntry<String, int>> topProducts([int n = 4]) {
    final totals = <String, int>{};
    for (final p in pools) {
      for (final d in p.demand.values) {
        totals[d.name] = (totals[d.name] ?? 0) + d.quantity;
      }
    }
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(n).toList();
  }
}

class CommunityDemandData {
  final List<AreaDemand> areas;
  final Map<String, BidModel> myBids; // poolId -> my bid
  final String myUid;

  const CommunityDemandData({required this.areas, required this.myBids, required this.myUid});
}

class CommunityDemandService {
  CommunityDemandService._();
  static final CommunityDemandService instance = CommunityDemandService._();

  Stream<CommunityDemandData> watch() {
    final uid = AuthService.instance.currentUser!.uid;
    return combineLatest2<List<PoolModel>, Map<String, BidModel>, CommunityDemandData>(
      PoolService.instance.watchPools(),
      BidService.instance.watchMyBids(),
      (pools, myBids) {
        final byArea = <String, List<PoolModel>>{};
        for (final p in pools.where((p) => p.status == 'open')) {
          byArea.putIfAbsent(p.areaLabel, () => []).add(p);
        }
        final areas = [
          for (final e in byArea.entries) AreaDemand(area: e.key, pools: e.value),
        ]..sort((a, b) => b.totalValue.compareTo(a.totalValue));
        return CommunityDemandData(areas: areas, myBids: myBids, myUid: uid);
      },
    );
  }
}

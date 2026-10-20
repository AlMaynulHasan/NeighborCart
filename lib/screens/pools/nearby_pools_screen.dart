import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/stream_utils.dart';
import '../../models/user_model.dart';
import '../../services/pool_service.dart';
import '../../services/user_service.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/stream_view.dart';
import 'create_pool_screen.dart';
import 'pool_details_screen.dart';

/// Matches Figma screen 3 ("Nearby Pools").
class NearbyPoolsScreen extends StatefulWidget {
  const NearbyPoolsScreen({super.key});

  @override
  State<NearbyPoolsScreen> createState() => _NearbyPoolsScreenState();
}

class _NearbyPoolsScreenState extends State<NearbyPoolsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<(List<PoolView>, UserModel)> _createStream() {
    return combineLatest2<List<PoolView>, UserModel, (List<PoolView>, UserModel)>(
      PoolService.instance.watchPoolViews(),
      UserService.instance.watchCurrentUser(),
      (pools, user) => (pools, user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Nearby Pools', style: AppTextStyles.heading2.copyWith(fontSize: 24))),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreatePoolScreen()),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Search by street or area...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: Icon(Icons.tune_rounded, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamView<(List<PoolView>, UserModel)>(
              create: _createStream,
              builder: (context, data) {
                final q = _query.toLowerCase();
                final pools = data.$1
                    .where((v) =>
                        v.pool.name.toLowerCase().contains(q) ||
                        v.pool.pickupLocation.toLowerCase().contains(q))
                    .toList();
                final user = data.$2;

                if (pools.isEmpty) {
                  return Center(
                    child: Text(
                      data.$1.isEmpty
                          ? 'No pools yet. Load demo pools from Profile.'
                          : 'No pools found',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: pools.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final view = pools[index];
                    return PoolCard(
                      poolView: view,
                      isMember: user.joinedPoolIds.contains(view.pool.id),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PoolDetailsScreen(poolId: view.pool.id)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

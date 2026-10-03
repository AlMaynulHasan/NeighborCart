import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/pool_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final pools = MockDataService.nearbyPools
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nearby Pools', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
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
            child: pools.isEmpty
                ? const Center(child: const Text('No pools found', style: AppTextStyles.bodySecondary))
                : ListView.separated(
                    itemCount: pools.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final pool = pools[index];
                      return PoolCard(
                        pool: pool,
                        onJoin: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PoolDetailsScreen()),
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

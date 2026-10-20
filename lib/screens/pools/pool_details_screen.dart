import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/utils/stream_utils.dart';
import '../../models/user_model.dart';
import '../../services/pool_service.dart';
import '../../services/user_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/stream_view.dart';
import '../../widgets/tier_card.dart';
import '../home/home_screen.dart';
import 'pool_pickup_screen.dart';

/// Matches Figma screen 4 ("Pool Details").
class PoolDetailsScreen extends StatefulWidget {
  final String poolId;
  const PoolDetailsScreen({super.key, required this.poolId});

  @override
  State<PoolDetailsScreen> createState() => _PoolDetailsScreenState();
}

class _PoolDetailsScreenState extends State<PoolDetailsScreen> {
  bool _isJoining = false;

  Stream<(PoolView?, UserModel)> _createStream() {
    return combineLatest2<PoolView?, UserModel, (PoolView?, UserModel)>(
      PoolService.instance.watchPoolView(widget.poolId),
      UserService.instance.watchCurrentUser(),
      (pv, user) => (pv, user),
    );
  }

  Future<void> _joinAndShop() async {
    setState(() => _isJoining = true);
    try {
      await PoolService.instance.joinPool(widget.poolId);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialTab: AppTab.cart)),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not join the pool. Please try again.')),
      );
      setState(() => _isJoining = false);
    }
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Pool Details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_rounded)),
        ],
      ),
      body: SafeArea(
        child: StreamView<(PoolView?, UserModel)>(
          create: _createStream,
          builder: (context, data) {
            final poolView = data.$1;
            final user = data.$2;
            if (poolView == null) {
              return Center(child: Text('This pool no longer exists.', style: AppTextStyles.bodySecondary));
            }
            final pool = poolView.pool;
            final pb = poolView.priceBreak;
            final isMember = user.joinedPoolIds.contains(pool.id);
            final next = pb.nextTier;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pool.name, style: AppTextStyles.heading2.copyWith(fontSize: 24)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: _cardDecoration,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('COLLECTIVE VALUE', style: AppTextStyles.caption),
                              const SizedBox(height: 6),
                              Text(formatTaka(pool.collectiveValue),
                                  style: AppTextStyles.body.copyWith(
                                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppColors.divider),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ACTIVE NEIGHBORS', style: AppTextStyles.caption),
                              const SizedBox(height: 6),
                              Text('${pool.memberCount} Joined',
                                  style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _cardDecoration,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(Icons.person_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pool Coordinator', style: AppTextStyles.caption),
                              const SizedBox(height: 2),
                              Text(pool.coordinatorUid == user.id ? '${pool.coordinatorName} (You)' : pool.coordinatorName,
                                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primarySoft,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: _cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tier Unlocks', style: AppTextStyles.title),
                        const SizedBox(height: 8),
                        for (final tier in pb.tiers)
                          TierRow(
                            tier: tier,
                            amountNeeded: tier.unlocked ? null : pb.amountNeeded(tier),
                          ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                        Text(
                          next == null
                              ? 'All tiers unlocked! 🎉'
                              : 'Add ${formatTaka(pb.amountToNext)} more to unlock ${next.label}!',
                          style: AppTextStyles.body.copyWith(
                            color: next == null ? AppColors.primary : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pickup Location', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                            Text(pool.pickupLocation, style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order Deadline',
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w700, color: AppColors.warning)),
                            Text(pool.deadlineLabel, style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isMember) ...[
                    const SizedBox(height: 20),
                    _PickupEntryCard(
                      isCoordinator: pool.coordinatorUid == user.id,
                      statusLabel: pool.statusLabel,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PoolPickupScreen(poolId: pool.id)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isJoining ? null : _joinAndShop,
                    child: _isJoining
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(isMember ? 'Continue Shopping' : 'Join Pool & Start Shopping'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PickupEntryCard extends StatelessWidget {
  final bool isCoordinator;
  final String statusLabel;
  final VoidCallback onTap;

  const _PickupEntryCard({
    required this.isCoordinator,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isCoordinator ? 'Coordinator tools' : 'Pickup status',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                  Text(statusLabel, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format.dart';
import '../../../models/bid_model.dart';
import '../../../models/pool_model.dart';
import '../../../services/bid_service.dart';
import '../../../services/community_demand_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/stream_view.dart';

String _pct(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

/// Demand of open pools grouped by neighbourhood, with bidding on each pool.
/// Only totals are shown — never individual members' baskets.
class CommunityDemandView extends StatelessWidget {
  const CommunityDemandView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamView<CommunityDemandData>(
      create: () => CommunityDemandService.instance.watch(),
      builder: (context, data) {
        if (data.areas.isEmpty) {
          return const Center(
            child: const Text('No open pools right now.', style: AppTextStyles.bodySecondary),
          );
        }
        return ListView(
          children: [
            const Text(
              'Open pools grouped by area. Bid on a pool to become its supplier: your extra discount '
              'stacks on top of the pool\'s tier discount.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
            for (final area in data.areas) _AreaCard(area: area, data: data),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _AreaCard extends StatelessWidget {
  final AreaDemand area;
  final CommunityDemandData data;
  const _AreaCard({required this.area, required this.data});

  @override
  Widget build(BuildContext context) {
    final top = area.topProducts();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(area.area, style: AppTextStyles.title)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Stat(label: 'Pools', value: '${area.poolCount}'),
              _Stat(label: 'Households', value: '${area.memberCount}'),
              _Stat(label: 'Weekly value', value: formatTaka(area.totalValue)),
            ],
          ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in top)
                  Chip(
                    label: Text('${e.key} ×${e.value}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    backgroundColor: AppColors.primarySoft,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          for (final pool in area.pools) _PoolBidRow(pool: pool, myBid: data.myBids[pool.id], myUid: data.myUid),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PoolBidRow extends StatelessWidget {
  final PoolModel pool;
  final BidModel? myBid;
  final String myUid;
  const _PoolBidRow({required this.pool, required this.myBid, required this.myUid});

  Future<void> _withdraw(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await BidService.instance.withdrawBid(pool.id);
      messenger.showSnackBar(const SnackBar(content: Text('Bid withdrawn.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not withdraw the bid.')));
    }
  }

  void _openBidSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BidSheet(pool: pool),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget trailing;
    if (pool.supplierUid == myUid) {
      trailing = _chip('You won ✓ +${_pct(pool.supplierExtraPercent)}%', AppColors.primary, AppColors.primarySoft);
    } else if (pool.hasSupplier) {
      trailing = _chip('Supplier: ${pool.supplierName}', AppColors.textSecondary, AppColors.border);
    } else if (myBid != null) {
      trailing = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Your bid +${_pct(myBid!.extraPercent)}%',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          InkWell(
            onTap: () => _withdraw(context),
            child: Text('Withdraw',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
          ),
        ],
      );
    } else {
      trailing = OutlinedButton(
        onPressed: () => _openBidSheet(context),
        style: OutlinedButton.styleFrom(minimumSize: const Size(90, 38), padding: const EdgeInsets.symmetric(horizontal: 14)),
        child: const Text('Place bid'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pool.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                Text('${pool.pickupLocation} • ${formatTaka(pool.collectiveValue)} • ${pool.closesLabel}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _chip(String text, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: AppTextStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w700)),
      );
}

class _BidSheet extends StatefulWidget {
  final PoolModel pool;
  const _BidSheet({required this.pool});

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  final _noteController = TextEditingController();
  double _percent = 2;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await BidService.instance.placeBid(pool: widget.pool, extraPercent: _percent, note: _noteController.text);
      messenger.showSnackBar(const SnackBar(content: Text('Bid placed. The coordinator will see it.')));
      navigator.pop();
    } on LicenceRequiredException {
      setState(() {
        _saving = false;
        _error = 'Add your trade/food licence number in Profile > Business Information first.';
      });
    } catch (_) {
      setState(() {
        _saving = false;
        _error = 'Could not place the bid. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pool = widget.pool;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bid on ${pool.name}', style: AppTextStyles.title),
            const SizedBox(height: 4),
            Text('${pool.memberCount} households • ${formatTaka(pool.collectiveValue)} this week • pickup ${pool.pickupLocation}',
                style: AppTextStyles.caption),
            const SizedBox(height: 18),
            Text('Extra discount: ${_pct(_percent)}%', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            Slider(
              value: _percent,
              min: 0,
              max: 15,
              divisions: 30,
              label: '${_pct(_percent)}%',
              activeColor: AppColors.primary,
              onChanged: _saving ? null : (v) => setState(() => _percent = v),
            ),
            const Text('Added on top of the pool\'s tier discount for every member if the coordinator picks your bid.',
                style: AppTextStyles.caption),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 2,
              enabled: !_saving,
              decoration: const InputDecoration(hintText: 'Note (delivery day, conditions...)'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
            ],
            const SizedBox(height: 16),
            CustomButton(label: 'Place Bid', isLoading: _saving, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

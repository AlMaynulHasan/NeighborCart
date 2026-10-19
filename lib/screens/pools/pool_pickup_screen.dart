import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/pickup_service.dart';
import '../../widgets/stream_view.dart';

/// ASSUMPTION: pickup tracking wasn't designed in Figma — a simple screen in
/// the same style. Shows where the pool is in its weekly cycle; the
/// coordinator gets the action buttons and can mark members as picked up.
class PoolPickupScreen extends StatefulWidget {
  final String poolId;
  const PoolPickupScreen({super.key, required this.poolId});

  @override
  State<PoolPickupScreen> createState() => _PoolPickupScreenState();
}

class _PoolPickupScreenState extends State<PoolPickupScreen> {
  bool _busy = false;

  Future<bool> _confirm(String title, String message, String confirmLabel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(confirmLabel)),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } on NotCoordinatorException {
      messenger.showSnackBar(const SnackBar(content: Text('Only the pool coordinator can do this.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Something went wrong. Please try again.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _placeOrder(PickupData data) async {
    final early = !data.pool!.isClosed;
    final ok = await _confirm(
      'Place the order?',
      early
          ? 'The deadline has not passed yet. Placing the order now closes ordering for everyone.'
          : 'This closes ordering and sends the pool order to the wholesaler.',
      'Place order',
    );
    if (!ok || !mounted) return;
    await _run(() => PickupService.instance.placeOrder(widget.poolId), 'Order placed.');
  }

  Future<void> _markReady() async {
    await _run(() => PickupService.instance.markReadyForPickup(widget.poolId), 'Marked as ready for pickup.');
  }

  Future<void> _complete(PickupData data) async {
    final next = data.nextCoordinator;
    final nextText = (next == null || next.uid == data.myUid)
        ? 'You stay the coordinator (no other members yet).'
        : '${next.name} becomes the coordinator.';
    final ok = await _confirm(
      'Complete this cycle?',
      '${data.pickedUpCount} of ${data.members.length} members picked up. $nextText '
          "This week's carts and payments are cleared and the pool re-opens for next week.",
      'Complete cycle',
    );
    if (!ok || !mounted) return;
    await _run(() => PickupService.instance.completeCycle(widget.poolId), 'Cycle completed. Pool re-opened.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Pickup & Coordinator')),
      body: SafeArea(
        child: StreamView<PickupData>(
          create: () => PickupService.instance.watch(widget.poolId),
          builder: (context, data) {
            final pool = data.pool;
            if (pool == null) {
              return Center(child: Text('This pool no longer exists.', style: AppTextStyles.bodySecondary));
            }
            final me = data.members.where((m) => m.isMe).toList();
            final next = data.nextCoordinator;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(pool.name, style: AppTextStyles.heading2.copyWith(fontSize: 22)),
                const SizedBox(height: 14),
                _StatusSteps(status: pool.status),
                const SizedBox(height: 16),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoLine(icon: Icons.location_on_outlined, label: 'Pickup', value: pool.pickupLocation),
                      const SizedBox(height: 10),
                      _InfoLine(icon: Icons.access_time_rounded, label: 'Deadline', value: pool.deadlineLabel),
                      const SizedBox(height: 10),
                      _InfoLine(
                        icon: Icons.person_rounded,
                        label: 'Coordinator',
                        value: data.iAmCoordinator ? '${pool.coordinatorName} (You)' : pool.coordinatorName,
                      ),
                      if (next != null && data.members.length > 1) ...[
                        const SizedBox(height: 10),
                        _InfoLine(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Next coordinator',
                          value: next.isMe ? '${next.name} (You)' : next.name,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (data.iAmCoordinator) _coordinatorCard(data) else _memberNote(data, me.isEmpty ? null : me.first),
                const SizedBox(height: 22),
                Text('Members', style: AppTextStyles.title),
                const SizedBox(height: 10),
                if (data.members.isEmpty)
                  Text('No members yet.', style: AppTextStyles.bodySecondary)
                else
                  for (final m in data.members)
                    _MemberRow(
                      member: m,
                      showToggle: data.iAmCoordinator && pool.status == 'ready',
                      busy: _busy,
                      onToggle: (v) => _run(
                        () => PickupService.instance.setPickedUp(widget.poolId, m.uid, v),
                        v ? '${m.name} marked as picked up.' : 'Pickup mark removed.',
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _coordinatorCard(PickupData data) {
    final pool = data.pool!;
    final String title;
    final String body;
    final String buttonLabel;
    final VoidCallback onPressed;

    if (pool.status == 'open') {
      title = 'Next step: place the order';
      body = pool.isClosed
          ? 'The deadline has passed. Place the order so the wholesaler can prepare it.'
          : 'You can wait for the deadline, or close ordering early and place the order now.';
      buttonLabel = 'Place Order';
      onPressed = () => _placeOrder(data);
    } else if (pool.status == 'ordered') {
      title = 'Next step: receive the goods';
      body = 'When the wholesaler has delivered everything to the pickup point, mark it ready.';
      buttonLabel = 'Mark Goods Received';
      onPressed = _markReady;
    } else {
      title = 'Hand over the goods';
      body = '${data.pickedUpCount} of ${data.members.length} members picked up. '
          'Tick each member below as they collect their items (paid members first).';
      buttonLabel = 'Complete Cycle & Rotate Coordinator';
      onPressed = () => _complete(data);
    }

    return _Card(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coordinator tools', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(body, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _busy ? null : onPressed,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                  )
                : Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  Widget _memberNote(PickupData data, PickupMember? me) {
    final pool = data.pool!;
    String text;
    if (pool.status == 'open') {
      text = 'Ordering is open until ${pool.deadlineLabel}. After that, ${pool.coordinatorName} places the order.';
    } else if (pool.status == 'ordered') {
      text = 'The order has been placed. ${pool.coordinatorName} will mark it ready once the goods arrive.';
    } else if (me != null && me.pickedUp) {
      text = 'You have picked up your items. Thank you!';
    } else {
      text = 'Your goods are ready. Collect them from ${pool.pickupLocation}.';
    }
    return _Card(child: Text(text, style: AppTextStyles.body));
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool highlighted;
  const _Card({required this.child, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: highlighted ? Border.all(color: AppColors.primary, width: 1.4) : null,
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: child,
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusSteps extends StatelessWidget {
  final String status;
  const _StatusSteps({required this.status});

  @override
  Widget build(BuildContext context) {
    const labels = ['Ordering open', 'Order placed', 'Ready for pickup'];
    final current = status == 'ordered' ? 1 : (status == 'ready' ? 2 : 0);
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= current ? AppColors.primary : AppColors.border,
                  ),
                  child: i < current
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : Text('${i + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: i == current ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          )),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: i == current ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: i == current ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  final PickupMember member;
  final bool showToggle;
  final bool busy;
  final ValueChanged<bool> onToggle;

  const _MemberRow({
    required this.member,
    required this.showToggle,
    required this.busy,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final name = member.isMe ? '${member.name} (You)' : member.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySoft,
            child: Text(member.name.isEmpty ? '?' : member.name[0],
                style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (member.isCoordinator) ...[
                      Text('Coordinator', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                      Text('  •  ', style: AppTextStyles.caption),
                    ],
                    Text(
                      member.paid ? 'Paid' : 'Not paid',
                      style: AppTextStyles.caption.copyWith(
                        color: member.paid ? AppColors.primary : AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showToggle)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Picked up', style: AppTextStyles.caption),
                Checkbox(
                  value: member.pickedUp,
                  activeColor: AppColors.primary,
                  onChanged: busy ? null : (v) => onToggle(v ?? false),
                ),
              ],
            )
          else if (member.pickedUp)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
              child: Text('Picked up',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

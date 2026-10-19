import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../services/settlement_service.dart';
import '../../widgets/member_payment_card.dart';
import '../../widgets/stream_view.dart';

/// Matches Figma screen 6 ("Settlement").
class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  bool _isPaying = false;

  Future<void> _pay(SettlementData data) async {
    setState(() => _isPaying = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await SettlementService.instance.payShare(data);
      messenger.showSnackBar(const SnackBar(content: Text('Payment recorded. Thank you!')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Payment failed. Please try again.')));
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Settlement')),
      body: SafeArea(
        child: StreamView<SettlementData>(
          create: () => SettlementService.instance.watch(),
          builder: (context, data) {
            final poolView = data.poolView;
            if (poolView == null) {
              return Center(
                child: Text('Join a pool to see its settlement.', style: AppTextStyles.bodySecondary),
              );
            }
            final pool = poolView.pool;

            final String payLabel;
            final bool canPay;
            if (data.iHavePaid) {
              payLabel = 'Paid ✓';
              canPay = false;
            } else if (data.myShare <= 0) {
              payLabel = 'Nothing to pay yet';
              canPay = false;
            } else {
              payLabel = 'Pay Now — ${formatTaka(data.myShare)}';
              canPay = true;
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pool.name} Weekly Order #${pool.orderNumber}', style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL POOL ORDER', style: AppTextStyles.caption),
                                  const SizedBox(height: 6),
                                  Text(formatTaka(data.totalAmount),
                                      style: AppTextStyles.body.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('YOUR SHARE', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                                  const SizedBox(height: 6),
                                  Text(formatTaka(data.myShare),
                                      style: AppTextStyles.body.copyWith(
                                          fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Neighbor payment progress', style: AppTextStyles.bodySecondary),
                            Text('${data.paidCount} of ${data.members.length} paid',
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: data.paidProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('Member Breakdown', style: AppTextStyles.title),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final member in data.members) MemberPaymentCard(member: member),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: (canPay && !_isPaying) ? () => _pay(data) : null,
                          child: _isPaying
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                )
                              : Text(payLabel),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../models/order_summary_model.dart';
import '../../widgets/custom_button.dart';

class ReceiptData {
  final String poolName;
  final String orderLabel; // "#204"
  final double amount;
  final double? retail;
  final String method;
  final String? phoneLast4;
  final String txnId;
  final DateTime paidAt;

  const ReceiptData({
    required this.poolName,
    required this.orderLabel,
    required this.amount,
    this.retail,
    required this.method,
    this.phoneLast4,
    required this.txnId,
    required this.paidAt,
  });

  factory ReceiptData.fromOrder(OrderSummary o) => ReceiptData(
        poolName: o.poolName,
        orderLabel: o.id,
        amount: o.memberShare,
        retail: o.retailAmount,
        method: o.paymentMethod ?? 'Demo',
        phoneLast4: o.phoneLast4,
        txnId: o.txnId ?? '-',
        paidAt: o.date,
      );

  double get saved {
    final r = retail;
    return (r == null || r <= amount) ? 0 : r - amount;
  }
}

/// ASSUMPTION: no Figma design for receipts — a simple summary in the same style.
class ReceiptScreen extends StatelessWidget {
  final ReceiptData data;
  const ReceiptScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Receipt')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 64),
            const SizedBox(height: 10),
            Text('Payment successful', textAlign: TextAlign.center, style: AppTextStyles.heading2.copyWith(fontSize: 22)),
            const SizedBox(height: 4),
            Text(formatTaka(d.amount),
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 32)),
            if (d.saved > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                  child: Text('You saved ${formatTaka(d.saved)} vs retail',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
              ),
              child: Column(
                children: [
                  _Line('Pool', d.poolName),
                  _Line('Order', d.orderLabel),
                  _Line('Date', '${formatShortDate(d.paidAt)}, ${formatTime(d.paidAt, alwaysMinutes: true)}'),
                  _Line('Method', d.phoneLast4 == null ? d.method : '${d.method} •••• ${d.phoneLast4}'),
                  _Line('Transaction ID', d.txnId),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Demo payment — no real money was charged.',
                textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
            const SizedBox(height: 20),
            CustomButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

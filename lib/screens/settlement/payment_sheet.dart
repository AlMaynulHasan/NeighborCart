import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../models/payment_model.dart';
import '../../widgets/custom_button.dart';

/// ASSUMPTION: no Figma design for checkout. A simulated mobile-wallet style
/// payment sheet — no real money moves and no real account is contacted.
Future<PaymentDetails?> showPaymentSheet(BuildContext context, double amount) {
  return showModalBottomSheet<PaymentDetails>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.scaffoldBackground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _PaymentSheet(amount: amount),
  );
}

class _PaymentSheet extends StatefulWidget {
  final double amount;
  const _PaymentSheet({required this.amount});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  static const _methods = ['bKash', 'Nagad', 'Card (demo)'];
  final _phoneController = TextEditingController();
  String _method = 'bKash';
  String? _error;
  bool _processing = false;

  bool get _needsPhone => _method != 'Card (demo)';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final phone = _phoneController.text.trim();
    if (_needsPhone && !RegExp(r'^01[3-9]\d{8}$').hasMatch(phone)) {
      setState(() => _error = 'Enter a valid 11-digit mobile number, e.g. 01712345678');
      return;
    }
    setState(() {
      _error = null;
      _processing = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200)); // simulated processing
    if (!mounted) return;
    final txn = 'NC${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}${100 + Random().nextInt(900)}';
    Navigator.of(context).pop(PaymentDetails(
      method: _method,
      phoneLast4: _needsPhone ? phone.substring(phone.length - 4) : null,
      txnId: txn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pay ${formatTaka(widget.amount)}', style: AppTextStyles.heading2.copyWith(fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Demo payment — no real money is charged.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Payment method', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final m in _methods)
                  ChoiceChip(
                    label: Text(m),
                    selected: _method == m,
                    onSelected: _processing ? null : (_) => setState(() => _method = m),
                    selectedColor: AppColors.primarySoft,
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: _method == m ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide.none,
                    backgroundColor: AppColors.cardBackground,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_needsPhone)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_processing,
                decoration: InputDecoration(
                  hintText: '$_method number (01XXXXXXXXX)',
                  errorText: _error,
                ),
              )
            else
              const Text('Card details are not collected in this demo.', style: AppTextStyles.caption),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Confirm & Pay ${formatTaka(widget.amount)}',
              isLoading: _processing,
              onPressed: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

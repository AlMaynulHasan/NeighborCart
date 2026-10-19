import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/pricing_tier_model.dart';
import '../../../services/pricing_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/stream_view.dart';
import '../../../widgets/wholesaler/pricing_tier_editor_card.dart';

/// MOQ & Pricing Management — the wholesale price-break tiers saved here
/// (config/pricing) are the ones every customer pool and cart uses.
class PricingManagementScreen extends StatelessWidget {
  const PricingManagementScreen({super.key});

  Future<void> _openSheet(
    BuildContext context,
    List<PricingTierModel> tiers,
    PricingTierModel tier, {
    required bool isNew,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showModalBottomSheet<PricingTierModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditTierSheet(tier: tier),
    );
    if (result == null) return;

    final updated = isNew
        ? [...tiers, result]
        : [for (final t in tiers) t.id == result.id ? result : t];
    try {
      await PricingService.instance.saveTiers(updated);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not save pricing tiers.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamView<List<PricingTierModel>>(
      create: () => PricingService.instance.watchTiers(),
      builder: (context, tiers) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MOQ & Pricing', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
                  ElevatedButton.icon(
                    onPressed: () => _openSheet(
                      context,
                      tiers,
                      PricingTierModel(
                        id: 't${DateTime.now().millisecondsSinceEpoch}',
                        label: 'Tier ${tiers.length + 1}',
                        minimumThreshold: 0,
                        discountPercent: 0,
                        isActive: true,
                      ),
                      isNew: true,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Tier'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Wholesale pricing tiers used across all active pools.', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    for (final tier in tiers)
                      PricingTierEditorCard(
                        tier: tier,
                        onEdit: () => _openSheet(context, tiers, tier, isNew: false),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditTierSheet extends StatefulWidget {
  final PricingTierModel tier;
  const _EditTierSheet({required this.tier});

  @override
  State<_EditTierSheet> createState() => _EditTierSheetState();
}

class _EditTierSheetState extends State<_EditTierSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _thresholdController;
  late final TextEditingController _discountController;
  late bool _isActive;
  String? _error;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.tier.label);
    _thresholdController = TextEditingController(text: widget.tier.minimumThreshold.toStringAsFixed(0));
    _discountController = TextEditingController(text: widget.tier.discountPercent.toStringAsFixed(0));
    _isActive = widget.tier.isActive;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _thresholdController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _save() {
    final threshold = double.tryParse(_thresholdController.text);
    final discount = double.tryParse(_discountController.text);
    if (_labelController.text.trim().isEmpty ||
        threshold == null ||
        threshold <= 0 ||
        discount == null ||
        discount < 0 ||
        discount > 100) {
      setState(() => _error = 'Enter a label, a threshold above 0 and a discount between 0 and 100.');
      return;
    }
    Navigator.of(context).pop(widget.tier.copyWith(
      label: _labelController.text.trim(),
      minimumThreshold: threshold,
      discountPercent: discount,
      isActive: _isActive,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit Tier', style: AppTextStyles.title),
          const SizedBox(height: 18),
          CustomTextField(label: 'Tier Label', controller: _labelController),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Minimum Threshold (৳)',
            controller: _thresholdController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Discount (%)',
            controller: _discountController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active', style: TextStyle(fontWeight: FontWeight.w700)),
            value: _isActive,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _isActive = v),
          ),
          if (_error != null) ...[
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          CustomButton(label: 'Save Tier', onPressed: _save),
        ],
      ),
    );
  }
}

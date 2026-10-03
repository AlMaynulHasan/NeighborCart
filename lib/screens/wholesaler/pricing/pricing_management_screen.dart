import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/pricing_tier_model.dart';
import '../../../services/wholesaler_mock_data_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/wholesaler/pricing_tier_editor_card.dart';

/// MOQ & Pricing Management — configures the wholesale price-break tiers
/// that drive the customer-side Price-Break Engine (Master Prompt
/// section 11 / section 6). Values here are mock/demo but editable, so the
/// thresholds can change without rewriting the app, per the proposal.
class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  State<PricingManagementScreen> createState() =>
      _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  late List<PricingTierModel> _tiers;

  @override
  void initState() {
    super.initState();
    _tiers = List.of(WholesalerMockDataService.pricingTiers);
  }

  Future<void> _editTier(PricingTierModel tier) async {
    final result = await showModalBottomSheet<PricingTierModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditTierSheet(tier: tier),
    );
    if (result != null) {
      setState(() {
        final index = _tiers.indexWhere((t) => t.id == result.id);
        _tiers[index] = result;
      });
    }
  }

  Future<void> _addTier() async {
    final nextNumber = _tiers.length + 1;
    final draft = PricingTierModel(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      label: 'Tier $nextNumber',
      minimumThreshold: 0,
      discountPercent: 0,
      isActive: true,
    );
    final result = await showModalBottomSheet<PricingTierModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditTierSheet(tier: draft),
    );
    if (result != null) {
      setState(() => _tiers = [..._tiers, result]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MOQ & Pricing',
                  style: AppTextStyles.heading2.copyWith(fontSize: 24)),
              ElevatedButton.icon(
                onPressed: _addTier,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Tier'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Wholesale pricing tiers used across all active pools.',
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                for (final tier in _tiers)
                  PricingTierEditorCard(
                      tier: tier, onEdit: () => _editTier(tier)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
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

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.tier.label);
    _thresholdController = TextEditingController(
        text: widget.tier.minimumThreshold.toStringAsFixed(0));
    _discountController = TextEditingController(
        text: widget.tier.discountPercent.toStringAsFixed(0));
    _isActive = widget.tier.isActive;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _thresholdController.dispose();
    _discountController.dispose();
    super.dispose();
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
          const Text('Edit Tier', style: AppTextStyles.title),
          const SizedBox(height: 18),
          CustomTextField(label: 'Tier Label', controller: _labelController),
          const SizedBox(height: 16),
          CustomTextField(
              label: 'Minimum Threshold (৳)',
              controller: _thresholdController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          CustomTextField(
              label: 'Discount (%)',
              controller: _discountController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active',
                style: TextStyle(fontWeight: FontWeight.w700)),
            value: _isActive,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _isActive = v),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Save Tier',
            onPressed: () {
              final updated = widget.tier.copyWith(
                label: _labelController.text.trim(),
                minimumThreshold: double.tryParse(_thresholdController.text) ??
                    widget.tier.minimumThreshold,
                discountPercent: double.tryParse(_discountController.text) ??
                    widget.tier.discountPercent,
                isActive: _isActive,
              );
              Navigator.of(context).pop(updated);
            },
          ),
        ],
      ),
    );
  }
}

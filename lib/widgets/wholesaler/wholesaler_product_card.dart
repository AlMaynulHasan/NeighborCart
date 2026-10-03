import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wholesaler_product_model.dart';

/// Product row on the Product Management screen — mirrors the
/// customer-side ProductCard's visual language (icon tile, name, price)
/// but adds the wholesaler-only fields and management actions.
class WholesalerProductListTile extends StatelessWidget {
  final WholesalerProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const WholesalerProductListTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(product.category, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.isActive ? AppColors.primarySoft : AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.isActive ? 'Active' : 'Inactive',
                  style: AppTextStyles.caption.copyWith(
                    color: product.isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          Row(
            children: [
              _MiniStat(label: 'Price', value: '৳${product.wholesalePrice.toStringAsFixed(0)}'),
              _MiniStat(label: 'MOQ', value: '${product.moq}'),
              _MiniStat(
                label: 'Stock',
                value: '${product.availableQuantity}',
                valueColor: product.isLowStock ? AppColors.warning : AppColors.textPrimary,
              ),
              _MiniStat(label: 'Shelf life', value: product.shelfLife),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(38), textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggleActive,
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(38), textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                  child: Text(product.isActive ? 'Deactivate' : 'Activate'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

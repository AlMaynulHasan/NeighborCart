import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/product_model.dart';

/// Product card used in "Recommended Items" on Home and later in the
/// Weekly Cart's product-picker views.
///
/// NOTE: `product.imageUrl` is currently always null in mock data, so this
/// renders a colored placeholder with a grocery icon instead of a real
/// product photo. See chat notes for the list of image assets still needed
/// (assets/images/products/*.png).
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onAdd;

  const ProductCard({super.key, required this.product, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 76,
              width: double.infinity,
              color: AppColors.primarySoft,
              alignment: Alignment.center,
              child: const Icon(Icons.shopping_basket_rounded, color: AppColors.primary, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            product.description,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('৳${product.price.toStringAsFixed(0)}', style: AppTextStyles.priceSmall),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_cart_rounded, size: 16, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

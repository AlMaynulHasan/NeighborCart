import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/cart_actions.dart';
import '../../widgets/stream_view.dart';

/// ASSUMPTION: "View All" wasn't designed in Figma — a simple list in the
/// same card style, with an add-to-cart button on each row.
class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('All Products')),
      body: SafeArea(
        child: StreamView<List<ProductModel>>(
          create: () => ProductService.instance.watchActiveProducts(),
          builder: (context, products) {
            if (products.isEmpty) {
              return Center(child: Text('No products available yet.', style: AppTextStyles.bodySecondary));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ProductRow(product: products[index]),
            );
          },
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final ProductModel product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.shopping_basket_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(product.description, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(formatTaka(product.price), style: AppTextStyles.priceSmall),
              ],
            ),
          ),
          InkWell(
            onTap: () => addProductToCart(context, product),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add_shopping_cart_rounded, size: 20, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

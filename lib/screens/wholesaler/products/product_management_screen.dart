import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wholesaler_product_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/product_service.dart';
import '../../../widgets/stream_view.dart';
import '../../../widgets/wholesaler/wholesaler_product_card.dart';
import 'add_edit_product_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _statusFilter = 'All'; // All / Active / Inactive

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WholesalerProductModel> _filter(List<WholesalerProductModel> all) {
    return all.where((p) {
      final matchesQuery = p.name.toLowerCase().contains(_query.toLowerCase());
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && p.isActive) ||
          (_statusFilter == 'Inactive' && !p.isActive);
      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _openAddProduct() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditProductScreen()));
  }

  void _openEditProduct(WholesalerProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditProductScreen(existingProduct: product)),
    );
  }

  Future<void> _toggleActive(WholesalerProductModel product) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ProductService.instance.setActive(product.id, !product.isActive);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not update the product.')));
    }
  }

  Future<void> _deleteProduct(WholesalerProductModel product) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${product.name}" will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ProductService.instance.deleteProduct(product.id);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not delete the product.')));
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
              Text('Products', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
              ElevatedButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search products',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final status in const ['All', 'Active', 'Inactive'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _statusFilter == status,
                    onSelected: (_) => setState(() => _statusFilter = status),
                    selectedColor: AppColors.primarySoft,
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: _statusFilter == status ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide.none,
                    backgroundColor: AppColors.cardBackground,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamView<List<WholesalerProductModel>>(
              create: () => ProductService.instance
                  .watchWholesalerProducts(AuthService.instance.currentUser!.uid),
              builder: (context, all) {
                final products = _filter(all);
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      all.isEmpty
                          ? 'No products yet. Tap Add, or load demo\nproducts from Profile.'
                          : 'No products found',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return WholesalerProductListTile(
                      product: product,
                      onEdit: () => _openEditProduct(product),
                      onToggleActive: () => _toggleActive(product),
                      onDelete: () => _deleteProduct(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

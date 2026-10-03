import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wholesaler_product_model.dart';
import '../../../services/wholesaler_mock_data_service.dart';
import '../../../widgets/wholesaler/wholesaler_product_card.dart';
import 'add_edit_product_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late List<WholesalerProductModel> _products;
  final _searchController = TextEditingController();
  String _query = '';
  String _statusFilter = 'All'; // All / Active / Inactive

  @override
  void initState() {
    super.initState();
    _products = List.of(WholesalerMockDataService.products);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WholesalerProductModel> get _filtered {
    return _products.where((p) {
      final matchesQuery = p.name.toLowerCase().contains(_query.toLowerCase());
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && p.isActive) ||
          (_statusFilter == 'Inactive' && !p.isActive);
      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<void> _openAddProduct() async {
    final result = await Navigator.of(context).push<WholesalerProductModel>(
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (result != null) {
      setState(() => _products = [result, ..._products]);
    }
  }

  Future<void> _openEditProduct(WholesalerProductModel product) async {
    final result = await Navigator.of(context).push<WholesalerProductModel>(
      MaterialPageRoute(builder: (_) => AddEditProductScreen(existingProduct: product)),
    );
    if (result != null) {
      setState(() {
        final index = _products.indexWhere((p) => p.id == result.id);
        if (index != -1) _products[index] = result;
      });
    }
  }

  void _toggleActive(WholesalerProductModel product) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == product.id);
      _products[index] = product.copyWith(isActive: !product.isActive);
    });
  }

  void _deleteProduct(WholesalerProductModel product) {
    setState(() => _products.removeWhere((p) => p.id == product.id));
  }

  @override
  Widget build(BuildContext context) {
    final products = _filtered;

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
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 42), padding: const EdgeInsets.symmetric(horizontal: 16)),
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
            child: products.isEmpty
                ? const Center(child: const Text('No products found', style: AppTextStyles.bodySecondary))
                : ListView.builder(
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
                  ),
          ),
        ],
      ),
    );
  }
}

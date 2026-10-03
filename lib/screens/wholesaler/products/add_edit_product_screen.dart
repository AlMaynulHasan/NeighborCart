import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wholesaler_product_model.dart';
import '../../../services/wholesaler_mock_data_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

/// Shared Add/Edit form (spec: "Edit Product... using the same form
/// structure as Add Product"). Pass `existingProduct` to edit; omit it to
/// add a new product.
class AddEditProductScreen extends StatefulWidget {
  final WholesalerProductModel? existingProduct;

  const AddEditProductScreen({super.key, this.existingProduct});

  bool get isEditing => existingProduct != null;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _moqController;
  late final TextEditingController _quantityController;
  late final TextEditingController _shelfLifeController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(
        text:
            ''); // not modeled on WholesalerProductModel yet — UI-only for now
    _categoryController = TextEditingController(text: p?.category ?? '');
    _priceController = TextEditingController(
        text: p != null ? p.wholesalePrice.toStringAsFixed(0) : '');
    _moqController = TextEditingController(text: p != null ? '${p.moq}' : '');
    _quantityController =
        TextEditingController(text: p != null ? '${p.availableQuantity}' : '');
    _shelfLifeController = TextEditingController(text: p?.shelfLife ?? '');
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _moqController.dispose();
    _quantityController.dispose();
    _shelfLifeController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  String? _numberField(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    final product = WholesalerProductModel(
      id: widget.existingProduct?.id ??
          'wp${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      wholesalePrice: double.parse(_priceController.text),
      moq: int.parse(_moqController.text),
      availableQuantity: int.parse(_quantityController.text),
      shelfLife: _shelfLifeController.text.trim(),
      isActive: _isActive,
    );
    Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Product' : 'Add Product')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product image placeholder — no image picker wired up in
                // Phase 1; would connect to Firebase Storage later
                // (Master Prompt section 10).
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.border, style: BorderStyle.solid),
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: AppColors.primary, size: 28),
                      SizedBox(height: 6),
                      Text('Add Product Image', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                    label: 'Product Name',
                    controller: _nameController,
                    validator: _requiredField),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Description', controller: _descriptionController),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Category',
                    controller: _categoryController,
                    validator: _requiredField),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Wholesale Price (৳)',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        validator: _numberField,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'MOQ',
                        controller: _moqController,
                        keyboardType: TextInputType.number,
                        validator: _numberField,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Available Quantity',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        validator: _numberField,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Shelf Life',
                        controller: _shelfLifeController,
                        hint: 'e.g. 12 months',
                        validator: _requiredField,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Visible to customer pools',
                        style: AppTextStyles.caption),
                    value: _isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Supplier: ${WholesalerMockDataService.currentWholesaler.businessName}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Cancel',
                        variant: CustomButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label:
                            widget.isEditing ? 'Save Changes' : 'Save Product',
                        onPressed: _handleSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

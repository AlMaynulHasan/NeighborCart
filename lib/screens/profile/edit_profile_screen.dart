import 'package:flutter/material.dart';
import '../../core/constants/auth_mode.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// ASSUMPTION: no Figma design for editing a profile — a simple form in the
/// same style. Customers edit their name; wholesalers edit business and
/// contact name. The email is shown but can't be changed here.
class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.user.name);
  late final TextEditingController _businessController =
      TextEditingController(text: widget.user.businessName ?? '');
  late final TextEditingController _contactController =
      TextEditingController(text: widget.user.contactName ?? '');
  bool _isSaving = false;

  bool get _isWholesaler => widget.user.role == AuthMode.wholesaler;

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);
    try {
      if (_isWholesaler) {
        await UserService.instance.updateWholesalerProfile(
          businessName: _businessController.text.trim(),
          contactName: _contactController.text.trim(),
        );
      } else {
        await UserService.instance.updateCustomerName(_nameController.text.trim());
      }
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated.')));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not save your changes. Please try again.')));
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sendReset() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService.instance.sendPasswordReset(widget.user.emailOrPhone);
      messenger.showSnackBar(
        SnackBar(content: Text('Password reset link sent to ${widget.user.emailOrPhone}.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(AuthService.friendlyError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(_isWholesaler ? 'Business Information' : 'Personal Information')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isWholesaler) ...[
                  CustomTextField(label: 'Business Name', controller: _businessController, validator: _required),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Contact Person', controller: _contactController, validator: _required),
                ] else
                  CustomTextField(label: 'Full Name', controller: _nameController, validator: _required),
                const SizedBox(height: 16),
                Text('Email', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(widget.user.emailOrPhone, style: AppTextStyles.bodySecondary),
                ),
                const SizedBox(height: 24),
                CustomButton(label: 'Save Changes', isLoading: _isSaving, onPressed: _save),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Send Password Reset Email',
                  variant: CustomButtonVariant.outline,
                  onPressed: _isSaving ? null : _sendReset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

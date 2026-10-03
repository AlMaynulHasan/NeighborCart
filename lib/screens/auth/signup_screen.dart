import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/auth_mode.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../widgets/auth_mode_toggle.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../wholesaler/dashboard/wholesaler_dashboard_screen.dart';

/// ASSUMPTION: no Figma design was provided for Sign Up — it's only
/// referenced as a link on Login (Master Prompt section 5). This mirrors
/// the Login screen's layout/branding/fields, and — per the user's
/// explicit request — shares the same Customer/Wholesaler toggle so a
/// wholesaler can create a business account from the same flow.
class SignupScreen extends StatefulWidget {
  final AuthMode initialMode;
  const SignupScreen({super.key, this.initialMode = AuthMode.customer});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // customer: full name
  final _businessNameController = TextEditingController(); // wholesaler
  final _contactNameController = TextEditingController(); // wholesaler
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  late AuthMode _mode;

  bool get _isWholesaler => _mode == AuthMode.wholesaler;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value) => (value == null || value.trim().isEmpty) ? 'Required' : null;

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    // PHASE 1: simulate a brief loading state; replace with
    // AuthService.signUp(...) once Firebase Authentication is wired up.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (_isWholesaler) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WholesalerDashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
    }
  }

  void _handleGoogleSignUp() {
    // PHASE 1 placeholder — wire to Firebase Authentication's Google
    // provider later.
    Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    height: 88,
                    width: 88,
                    decoration: BoxDecoration(
                      color: _isWholesaler ? AppColors.textPrimary : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isWholesaler ? Icons.storefront_rounded : Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _isWholesaler ? 'Create Business Account' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 26),
                ),
                const SizedBox(height: 6),
                const Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 22),
                AuthModeToggle(mode: _mode, onChanged: (m) => setState(() => _mode = m)),
                const SizedBox(height: 28),
                if (_isWholesaler) ...[
                  CustomTextField(
                    label: 'Business Name',
                    controller: _businessNameController,
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    label: 'Contact Person Name',
                    controller: _contactNameController,
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    label: 'Business Email or Phone',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.emailOrPhone,
                  ),
                ] else ...[
                  CustomTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    label: 'Email or Phone Number',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.emailOrPhone,
                  ),
                ],
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 26),
                CustomButton(
                  label: _isWholesaler ? 'Create Business Account' : 'Sign Up',
                  isLoading: _isSubmitting,
                  onPressed: _handleSignup,
                ),
                if (!_isWholesaler) ...[
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: AppTextStyles.caption),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Continue with Google',
                    variant: CustomButtonVariant.outline,
                    onPressed: _handleGoogleSignUp,
                    icon: Icons.g_mobiledata_rounded,
                  ),
                ],
                const SizedBox(height: 28),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                          recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

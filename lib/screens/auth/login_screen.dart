import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/auth_mode.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_mode_toggle.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../wholesaler/dashboard/wholesaler_dashboard_screen.dart';
import 'signup_screen.dart';

/// Matches Figma screen 1 ("Login") for the Customer mode.
///
/// ASSUMPTION: the Customer/Wholesaler toggle above the form is NOT part
/// of the original Figma design — it was added at the user's explicit
/// request to let both account types share one entry point, which means
/// intentionally deviating from the "don't modify the 6 screens" rule for
/// this one case. The Customer mode's fields/copy/branding are otherwise
/// unchanged from the Figma spec.
class LoginScreen extends StatefulWidget {
  final AuthMode initialMode;
  const LoginScreen({super.key, this.initialMode = AuthMode.customer});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        expectedRole: _mode,
      );
      if (!mounted) return;
      if (_isWholesaler) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WholesalerDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final email = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (email == null || email.isEmpty) return;
    if (!email.contains('@')) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter the email you signed up with. Phone numbers are not supported yet.')),
      );
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email);
      messenger.showSnackBar(
        SnackBar(content: Text('If an account exists for $email, a reset link has been sent.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(AuthService.friendlyError(e))));
    }
  }

  void _handleGoogleSignIn() {
    // Still a placeholder — real Google Sign-In needs an OAuth client ID
    // configured in Google Cloud + a <meta> tag in web/index.html for
    // Flutter Web specifically. Email/Password is fully wired to Firebase
    // now; Google is the next piece once that extra setup is done.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in is not available yet. Please use your email and password.')),
    );
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
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: _isWholesaler ? AppColors.textPrimary : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isWholesaler ? Icons.storefront_rounded : Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 30),
                ),
                const SizedBox(height: 6),
                Text(
                  _isWholesaler ? 'Wholesaler Portal' : AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 24),
                AuthModeToggle(mode: _mode, onChanged: (m) => setState(() => _mode = m)),
                const SizedBox(height: 28),
                CustomTextField(
                  label: _isWholesaler ? 'Business Email or Phone' : 'Email or Phone Number',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.emailOrPhone,
                ),
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 18),
                CustomButton(
                  label: _isWholesaler ? 'Login as Wholesaler' : 'Login',
                  isLoading: _isSubmitting,
                  onPressed: _handleLogin,
                ),
                if (!_isWholesaler) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: const [
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
                    onPressed: _handleGoogleSignIn,
                    icon: Icons.g_mobiledata_rounded,
                  ),
                ],
                const SizedBox(height: 32),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: _isWholesaler ? "Don't have a business account? " : "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => SignupScreen(initialMode: _mode)),
                                ),
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

class _ResetPasswordDialog extends StatefulWidget {
  final String initialEmail;
  const _ResetPasswordDialog({required this.initialEmail});

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('We will email you a link to choose a new password.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Your account email'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Send link'),
        ),
      ],
    );
  }
}

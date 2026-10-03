import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/auth_mode.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const NeighborCartApp());
}

class NeighborCartApp extends StatelessWidget {
  const NeighborCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppConstants.routeLogin,
      routes: {
        AppConstants.routeLogin: (_) => const LoginScreen(),
        AppConstants.routeSignup: (_) => const SignupScreen(),
        AppConstants.routeHome: (_) => const HomeScreen(),
        // Same Login screen, opened straight into Wholesaler mode — kept
        // as its own route so a direct link (e.g. from the Profile
        // screen's "Switch portal", or a bookmarked URL on web) can jump
        // right past the toggle.
        AppConstants.routeWholesalerLogin: (_) => const LoginScreen(initialMode: AuthMode.wholesaler),
      },
    );
  }
}

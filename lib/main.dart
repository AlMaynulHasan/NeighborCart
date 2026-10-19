import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/auth_mode.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      // Always start at AuthGate, whatever the browser URL says (e.g. after a
      // refresh on /#/home). AuthGate restores the saved Firebase session
      // first, then opens the customer app, wholesaler app, or Login.
      onGenerateInitialRoutes: (String initialRoute) => [
        MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const AuthGate(),
        ),
      ],
      routes: {
        AppConstants.routeLogin: (_) => const LoginScreen(),
        AppConstants.routeSignup: (_) => const SignupScreen(),
        AppConstants.routeHome: (_) => const HomeScreen(),
        AppConstants.routeWholesalerLogin: (_) =>
            const LoginScreen(initialMode: AuthMode.wholesaler),
      },
    );
  }
}

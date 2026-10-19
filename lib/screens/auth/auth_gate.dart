import 'package:flutter/material.dart';
import '../../core/constants/auth_mode.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../wholesaler/dashboard/wholesaler_dashboard_screen.dart';
import 'login_screen.dart';

/// First screen: restores a saved Firebase session so people stay logged
/// in, and routes to the right side of the app (or Login).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<AuthMode?> _session = AuthService.instance.restoreSession();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthMode?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) return const LoginScreen();
        switch (snapshot.data) {
          case AuthMode.customer:
            return const HomeScreen();
          case AuthMode.wholesaler:
            return const WholesalerDashboardScreen();
          case null:
            return const LoginScreen();
        }
      },
    );
  }
}

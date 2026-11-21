import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

/// Splash while Firebase restores the session, then Home or Login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (!auth.ready) return const SplashScreen();
    return auth.canEnter ? const HomeScreen() : const LoginScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.primary,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.home_work_rounded, size: 72, color: Colors.white),
        SizedBox(height: 12),
        Text('Domexa', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
        SizedBox(height: 6),
        Text('AI house planning for Pakistan', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 28),
        SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
      ]),
    ),
  );
}
// lib/screens/shared/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      if (auth.isAdmin) {
  context.go('/admin');
} else if (auth.isPhotographer) {
  context.go('/dashboard');
} else {
  context.go('/home');
}
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: kCobalt,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.camera_alt, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('Pixxgram',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                    color: Colors.white, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text("Kenya's Premier Photography Platform",
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: kSky, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
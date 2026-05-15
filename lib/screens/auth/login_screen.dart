// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass   = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      if (auth.isAdmin) {
        context.go('/admin');
      } else if (auth.isPhotographer) {
        context.go('/dashboard');
      } else {
        context.go('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login failed'),
        backgroundColor: kError,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            // ── Top brand header ─────────────────────────────────────
            Container(
              color: kPrimary,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      size: 32, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text('Pixxgram',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8)),
                const SizedBox(height: 6),
                Text('Welcome back',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14)),
              ]),
            ),

            // ── Form card ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sign in to your account',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text('Enter your credentials to continue',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.45))),
                        const SizedBox(height: 24),

                        // Error banner
                        if (auth.error != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kError.withValues(alpha: 0.08),
                              border: Border.all(
                                  color: kError.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline,
                                  color: kError, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(auth.error!,
                                  style: const TextStyle(
                                      color: kError, fontSize: 13))),
                            ]),
                          ),

                        // Email
                        const Text('Email address',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            hintStyle: TextStyle(
                                color: Colors.black.withValues(alpha: 0.3),
                                fontSize: 14),
                            prefixIcon: Icon(Icons.email_outlined,
                                size: 18,
                                color: Colors.black.withValues(alpha: 0.35)),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return 'Email required';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        const Text('Password',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: !_showPass,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(
                                color: Colors.black.withValues(alpha: 0.3),
                                fontSize: 14),
                            prefixIcon: Icon(Icons.lock_outline,
                                size: 18,
                                color: Colors.black.withValues(alpha: 0.35)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                              onPressed: () =>
                                  setState(() => _showPass = !_showPass),
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Password required' : null,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 8),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero),
                            child: const Text('Forgot password?',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: kSecondary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            child: auth.loading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        Row(children: [
                          Expanded(child: Divider(
                              color: Colors.black.withValues(alpha: 0.1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withValues(alpha: 0.35))),
                          ),
                          Expanded(child: Divider(
                              color: Colors.black.withValues(alpha: 0.1))),
                        ]),
                        const SizedBox(height: 20),

                        // Sign up link
                        Center(child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.5)),
                              ),
                              WidgetSpan(child: GestureDetector(
                                onTap: () => context.go('/signup'),
                                child: const Text('Sign up',
                                    style: TextStyle(
                                        color: kPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              )),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Back to home
            TextButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back to Home'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black.withValues(alpha: 0.45),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
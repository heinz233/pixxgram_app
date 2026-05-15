// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
//import '../../widgets/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();

  int    _roleId   = 3; // 3 = client, 2 = photographer
  String _gender   = 'Male';
  bool   _showPass = false;
  bool   _success  = false;
  int    _step     = 1; // 1 = role select, 2 = fill form

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register({
      'name':        _nameCtrl.text.trim(),
      'email':       _emailCtrl.text.trim(),
      'password':    _passCtrl.text,
      'phoneNumber': _phoneCtrl.text.trim(),
      'role_id':     _roleId,
      'gender':      _gender,
    });
    if (!mounted) return;
    if (ok) {
      setState(() => _success = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Registration failed'),
        backgroundColor: kError,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ── Success screen ────────────────────────────────────────────────────────
    if (_success) {
      return Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: kSuccess.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_outlined,
                      size: 40, color: kSuccess),
                ),
                const SizedBox(height: 24),
                const Text('Account Created!',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                const SizedBox(height: 10),
                Text(
                  'Please check your email to verify your account '
                  'before signing in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.5),
                      height: 1.6),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Go to Sign In',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              color: kPrimary,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 36),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text('Pixxgram',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5)),
                ]),
                const SizedBox(height: 16),
                const Text('Create your account',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Join Kenya\'s #1 photography platform',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13)),

                // Step indicator
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _StepDot(number: 1, active: _step >= 1, done: _step > 1),
                  Container(
                    width: 40, height: 2,
                    color: _step > 1
                        ? kSecondary
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                  _StepDot(number: 2, active: _step >= 2, done: false),
                ]),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [

                // ── Step 1: Role selector ─────────────────────────────────
                if (_step == 1) ...[
                  const Text('I want to…',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 6),
                  Text('Choose how you\'ll use Pixxgram',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.45))),
                  const SizedBox(height: 24),

                  // Client card
                  _RoleCard(
                    selected: _roleId == 3,
                    onTap: () => setState(() => _roleId = 3),
                    icon: Icons.person_search_outlined,
                    title: 'Find a Photographer',
                    subtitle: 'Book professional photographers for your events, portraits, and more.',
                    badge: null,
                  ),
                  const SizedBox(height: 14),

                  // Photographer card
                  _RoleCard(
                    selected: _roleId == 2,
                    onTap: () => setState(() => _roleId = 2),
                    icon: Icons.camera_alt_outlined,
                    title: 'List as a Photographer',
                    subtitle: 'Showcase your work, get discovered, and manage bookings.',
                    badge: 'Ksh 300 one-time fee',
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _step = 2),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Continue',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],

                // ── Step 2: Fill form ─────────────────────────────────────
                if (_step == 2) ...[
                  // Photographer fee notice
                  if (_roleId == 2)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSecondary.withValues(alpha: 0.08),
                        border: Border.all(
                            color: kSecondary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Icon(Icons.info_outline,
                            color: kSecondary, size: 18),
                        SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Photographer Registration',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: kSecondary,
                                    fontSize: 13)),
                            SizedBox(height: 3),
                            Text(
                              'One-time fee: Ksh 300  •  Monthly subscription: Ksh 250\n'
                              'Your profile activates after payment confirmation.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: kSecondary,
                                  height: 1.5),
                            ),
                          ],
                        )),
                      ]),
                    ),

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

                  Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const _FieldLabel('Full Name'),
                      TextFormField(
                        controller: _nameCtrl,
                        style: const TextStyle(fontSize: 14),
                        decoration: _dec('Your full name',
                            Icons.person_outline),
                        validator: (v) =>
                            v!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),

                      const _FieldLabel('Email Address'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 14),
                        decoration: _dec(
                            'you@example.com', Icons.email_outlined),
                        validator: (v) => v!.isEmpty
                            ? 'Email required'
                            : !v.contains('@')
                                ? 'Invalid email'
                                : null,
                      ),
                      const SizedBox(height: 14),

                      const _FieldLabel('Phone Number'),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 14),
                        decoration: _dec(
                            '+254 7XX XXX XXX', Icons.phone_outlined),
                      ),
                      const SizedBox(height: 14),

                      const _FieldLabel('Gender'),
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black),
                        decoration: _dec(null, Icons.people_outline),
                        items: ['Male', 'Female', 'Non-binary',
                          'Prefer not to say'].map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _gender = v!),
                      ),
                      const SizedBox(height: 14),

                      const _FieldLabel('Password'),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: !_showPass,
                        style: const TextStyle(fontSize: 14),
                        decoration: _dec('Min. 6 characters',
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _showPass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                              onPressed: () => setState(
                                  () => _showPass = !_showPass),
                            )),
                        validator: (v) => v!.length < 6
                            ? 'Minimum 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      const _FieldLabel('Confirm Password'),
                      TextFormField(
                        controller: _confCtrl,
                        obscureText: !_showPass,
                        style: const TextStyle(fontSize: 14),
                        decoration: _dec('Repeat your password',
                            Icons.lock_outline),
                        validator: (v) => v != _passCtrl.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 28),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _register,
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
                              : Text(_roleId == 2
                                  ? 'Create Account & Continue to Payment'
                                  : 'Create Account'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Back
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _step = 1),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                              foregroundColor:
                                  Colors.black.withValues(alpha: 0.45)),
                        ),
                      ),
                    ]),
                  ),
                ],

                const SizedBox(height: 16),

                // Sign in link
                Center(child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.5)),
                      ),
                      WidgetSpan(child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text('Sign in',
                            style: TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      )),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  InputDecoration _dec(String? hint, IconData prefix, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.3), fontSize: 14),
        prefixIcon: Icon(prefix,
            size: 18, color: Colors.black.withValues(alpha: 0.35)),
        suffixIcon: suffix,
      );
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600)),
  );
}

class _StepDot extends StatelessWidget {
  final int number;
  final bool active;
  final bool done;
  const _StepDot({required this.number, required this.active, required this.done});

  @override
  Widget build(BuildContext context) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
      color: active
          ? (done ? kSecondary : Colors.white)
          : Colors.white.withValues(alpha: 0.2),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: done
          ? const Icon(Icons.check, size: 14, color: kPrimary)
          : Text('$number',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? kPrimary : Colors.white54)),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  const _RoleCard({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected ? kPrimary : kSurface,
        border: Border.all(
          color: selected ? kPrimary : Colors.black.withValues(alpha: 0.1),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: selected
            ? [BoxShadow(color: kPrimary.withValues(alpha: 0.2),
                blurRadius: 16, offset: const Offset(0, 4))]
            : [],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icon box
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.15)
                : kPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon,
              size: 26,
              color: selected ? Colors.white : kPrimary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : Colors.black)),
              const Spacer(),
              if (selected)
                const Icon(Icons.check_circle,
                    size: 18, color: kSecondary),
            ]),
            const SizedBox(height: 5),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.72)
                        : Colors.black.withValues(alpha: 0.5))),
            if (badge != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kSecondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        fontSize: 11,
                        color: kSecondary,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        )),
      ]),
    ),
  );
}
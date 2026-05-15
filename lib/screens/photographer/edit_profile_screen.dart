// lib/screens/photographer/edit_profile_screen.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _bioCtrl      = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _rateCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  String _gender      = 'Male';
  String _speciality  = 'Portraits';
  bool   _saving      = false;
  bool   _loading     = true;

  @override
  void initState() { super.initState(); _loadExisting(); }

  @override
  void dispose() {
    _bioCtrl.dispose(); _locationCtrl.dispose();
    _rateCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    try {
      final data = await PhotographerService.getDashboard();
      final profile = data['profile'] as Map<String, dynamic>?;
      if (profile != null) {
        _bioCtrl.text      = profile['bio'] ?? '';
        _locationCtrl.text = profile['location'] ?? '';
        _rateCtrl.text     = profile['hourly_rate']?.toString() ?? '';
        if (['Male', 'Female', 'Non-binary', 'Prefer not to say']
            .contains(profile['gender'])) {
          _gender = profile['gender'];
        }
        if (['Portraits', 'Weddings', 'Events', 'Wildlife',
              'Commercial', 'Fashion']
            .contains(profile['speciality'])) {
          _speciality = profile['speciality'];
        }
      }
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      _phoneCtrl.text = auth.user?.phone ?? '';
    } catch (_) {}
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final fd = FormData.fromMap({
        'bio':         _bioCtrl.text.trim(),
        'location':    _locationCtrl.text.trim(),
        'hourly_rate': _rateCtrl.text.trim(),
        'gender':      _gender,
        'speciality':  _speciality,
      });
      await PhotographerService.updateProfile(fd);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated! ✓'),
              backgroundColor: Colors.green));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update failed'),
              backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Profile')),
    body: _loading
        ? const LoadingWidget()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Personal Information',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: kNavy)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.people_outline),
                  filled: true, fillColor: const Color(0xFFF0F6FB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Male', 'Female', 'Non-binary', 'Prefer not to say']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 14),
              PxTextField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hint: '+254 7XX XXX XXX',
              ),

              const SizedBox(height: 20),
              const Text('Photography Details',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: kNavy)),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _speciality,
                decoration: InputDecoration(
                  labelText: 'Speciality',
                  prefixIcon: const Icon(Icons.camera_alt_outlined),
                  filled: true, fillColor: const Color(0xFFF0F6FB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Portraits', 'Weddings', 'Events', 'Wildlife',
                        'Commercial', 'Fashion']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _speciality = v!),
              ),
              const SizedBox(height: 14),

              PxTextField(
                label: 'Location',
                controller: _locationCtrl,
                prefixIcon: Icons.location_on_outlined,
                hint: 'e.g. Nairobi, Westlands',
              ),
              const SizedBox(height: 14),

              PxTextField(
                label: 'Hourly Rate (Ksh)',
                controller: _rateCtrl,
                prefixIcon: Icons.monetization_on_outlined,
                keyboardType: TextInputType.number,
                hint: 'e.g. 5000',
              ),
              const SizedBox(height: 14),

              PxTextField(
                label: 'Bio / About',
                controller: _bioCtrl,
                maxLines: 5,
                hint: 'Tell clients about your photography style…',
              ),
              const SizedBox(height: 24),

              PxButton(
                label: 'Save Changes',
                loading: _saving,
                icon: Icons.save,
                onTap: _save,
              ),
              const SizedBox(height: 24),
            ]),
          ),
  );
}
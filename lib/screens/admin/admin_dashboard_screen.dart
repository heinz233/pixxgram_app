// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
//import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<dynamic> _recent = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await AdminService.getStats();
      final p = await AdminService.getPhotographers();
      if (!mounted) return;
      setState(() {
        _stats  = s;
        _recent = (p['photographers'] as List?)?.take(5).toList() ?? [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading dashboard…')
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionHeader(title: 'Overview'),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatCard(
                        label: 'Active Photographers',
                        value: '${_stats['active_photographers'] ?? 0}',
                        icon: Icons.camera_alt, color: kCobalt,
                        sub: 'subscribed',
                      ),
                      StatCard(
                        label: 'Registered Clients',
                        value: '${_stats['total_clients'] ?? 0}',
                        icon: Icons.people, color: kNavy,
                      ),
                      StatCard(
                        label: 'Monthly Revenue',
                        value: 'Ksh ${_stats['monthly_revenue_kes'] ?? 0}',
                        icon: Icons.monetization_on,
                        color: const Color(0xFF10B981),
                      ),
                      StatCard(
                        label: 'Open Reports',
                        value: '${_stats['open_reports'] ?? 0}',
                        icon: Icons.flag, color: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const SectionHeader(title: 'Manage'),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: 2,
                    children: [
                      _AdminNav(Icons.camera_alt_outlined, 'Photographers', kCobalt,
                          () => context.go('/admin/photographers')),
                      _AdminNav(Icons.flag_outlined, 'Reports',
                          const Color(0xFFEF4444), () => context.go('/admin/reports')),
                      _AdminNav(Icons.location_on_outlined, 'Locations', kNavy,
                          () => context.go('/admin/locations')),
                      _AdminNav(Icons.tag, 'Categories', kSlate, () {}),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SectionHeader(
                    title: 'Pending Approvals',
                    action: 'View all',
                    onAction: () => context.go('/admin/photographers'),
                  ),
                  const SizedBox(height: 12),
                  ..._recent
                      .where((p) => p['subscription_status'] == 'pending')
                      .map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kCobalt,
                        child: Text(
                          (p['first_name'] ?? 'P').substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text('${p['first_name']} ${p['last_name']}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(p['county'] ?? p['email'] ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await AdminService.approvePhotographer(p['id']);
                          _load();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Approve',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: kCobalt,
        unselectedItemColor: kSlate,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Photographers'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Locations'),
        ],
        onTap: (i) {
          if (i == 1) context.go('/admin/photographers');
          if (i == 2) context.go('/admin/reports');
          if (i == 3) context.go('/admin/locations');
        },
      ),
    );
  }
}

class _AdminNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AdminNav(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Card(child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ]),
    )),
  );
}
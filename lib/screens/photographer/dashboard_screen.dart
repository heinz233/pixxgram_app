// lib/screens/photographer/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
//import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await PhotographerService.getDashboard();
      if (!mounted) return;
      setState(() { _stats = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final subStatus = _stats['subscription_status'] ?? 'inactive';
    final isActive  = subStatus == 'active';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kNavy, kCobalt],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: kSky,
                          child: Text(
                            auth.user?.name.substring(0, 1).toUpperCase() ?? 'P',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold,
                                color: kNavy),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome, ${auth.user?.name ?? ''}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            StatusBadge(status: subStatus),
                            if ((_stats['days_remaining'] ?? 0) > 0)
                              Text('${_stats['days_remaining']} days remaining',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.7))),
                          ],
                        )),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Subscription warning
                    if (!isActive)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.warning_amber,
                              color: Color(0xFFF59E0B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your subscription is $subStatus. '
                              'Renew to stay visible to clients.',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.go('/dashboard/subscription'),
                            child: const Text('Renew',
                                style: TextStyle(
                                    color: kCobalt,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ),
                    const SizedBox(height: 16),

                    // Profile completion
                    const Text('Profile Completion',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: kNavy)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: (_stats['profile_completion'] ?? 0) / 100,
                          color: kCobalt,
                          backgroundColor: const Color(0xFFE2E8F0),
                          minHeight: 10,
                        ),
                      )),
                      const SizedBox(width: 10),
                      Text('${_stats['profile_completion'] ?? 0}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: kCobalt)),
                    ]),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => context.go('/dashboard/profile'),
                      child: const Text('Complete your profile →',
                          style: TextStyle(
                              fontSize: 12,
                              color: kCobalt,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    const SectionHeader(title: 'Overview'),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        StatCard(
                          label: 'Avg Rating',
                          value: '${_stats['average_rating'] ?? '—'}',
                          icon: Icons.star,
                          color: const Color(0xFFF59E0B),
                          sub: '${_stats['total_ratings'] ?? 0} reviews',
                        ),
                        StatCard(
                          label: 'Bookings',
                          value: '${_stats['upcoming_bookings'] ?? 0}',
                          icon: Icons.calendar_month,
                          color: kCobalt,
                          sub: 'upcoming',
                        ),
                        StatCard(
                          label: 'Portfolio Views',
                          value: '${_stats['total_portfolio_views'] ?? 0}',
                          icon: Icons.visibility,
                          color: kNavy,
                        ),
                        StatCard(
                          label: 'Reports',
                          value: '${_stats['pending_reports'] ?? 0}',
                          icon: Icons.flag,
                          color: const Color(0xFFEF4444),
                          sub: 'pending',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick links
                    const SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _QuickLink(Icons.image_outlined, 'Portfolio',
                            'Manage photos', kCobalt,
                            () => context.go('/dashboard/portfolio')),
                        _QuickLink(Icons.calendar_month_outlined, 'Bookings',
                            'View sessions', kNavy,
                            () => context.go('/dashboard/bookings')),
                        _QuickLink(Icons.message_outlined, 'Messages',
                            'Chat with clients', kSlate,
                            () => context.go('/dashboard/messages')),
                        _QuickLink(Icons.credit_card, 'Subscription',
                            'Manage plan', const Color(0xFF10B981),
                            () => context.go('/dashboard/subscription')),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: kCobalt,
        unselectedItemColor: kSlate,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.image_outlined), label: 'Portfolio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined), label: 'Messages'),
        ],
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.go('/dashboard/portfolio');
          if (i == 2) context.go('/dashboard/bookings');
          if (i == 3) context.go('/dashboard/messages');
        },
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final Color color;
  final VoidCallback onTap;
  const _QuickLink(this.icon, this.label, this.desc, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(desc,
              style: const TextStyle(fontSize: 11, color: kSlate)),
        ]),
      ),
    ),
  );
}
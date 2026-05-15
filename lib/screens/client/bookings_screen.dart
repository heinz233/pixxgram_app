// lib/screens/client/bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/booking_service.dart';
import '../../widgets/widgets.dart';

class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> _all = [];
  bool _loading = true;
  String _error = '';

  // Tab filter labels matching backend statuses
  final _tabs = const ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await BookingService.getAll() as Map<String, dynamic>;
      setState(() {
        _all = data['bookings'] ?? data['data'] ?? [];
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<dynamic> _filtered(String tab) {
    if (tab == 'All') return _all;
    return _all.where((b) =>
        (b['status'] as String? ?? '').toLowerCase() == tab.toLowerCase()
    ).toList();
  }

  Future<void> _cancelBooking(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to cancel this booking? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kError,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await BookingService.updateStatus(id, 'cancelled');
      await _loadBookings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled'),
          backgroundColor: kError,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: kError),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('My Bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: kPrimary,
          unselectedLabelColor: kTextMuted,
          indicatorColor: kSecondary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error.isNotEmpty
              ? _ErrorState(message: _error, onRetry: _loadBookings)
              : RefreshIndicator(
                  color: kPrimary,
                  onRefresh: _loadBookings,
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      final items = _filtered(tab);
                      if (items.isEmpty) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: EmptyState(
                              icon: Icons.calendar_today_outlined,
                              title: tab == 'All'
                                  ? 'No bookings yet'
                                  : 'No $tab bookings',
                              subtitle: tab == 'All'
                                  ? 'Browse photographers and make your first booking'
                                  : null,
                              actionLabel: tab == 'All' ? 'Find Photographers' : null,
                              onAction: tab == 'All'
                                  ? () => context.go('/photographers')
                                  : null,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _BookingCard(
                          booking: items[i],
                          onCancel: () => _cancelBooking(items[i]['id']),
                          onViewPhotographer: () => context.go(
                              '/photographers/${items[i]['photographer_id']}'),
                        ),
                      );
                    }).toList(),
                  ),
                ),
      // FAB to find photographers
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/photographers'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('New Booking',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Booking Card ──────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onCancel;
  final VoidCallback onViewPhotographer;

  const _BookingCard({
    required this.booking,
    required this.onCancel,
    required this.onViewPhotographer,
  });

  @override
  Widget build(BuildContext context) {
    final photographer = booking['photographer'] as Map<String, dynamic>?;
    final profile = photographer?['photographer_profile']
        as Map<String, dynamic>?;

    final name        = photographer?['name'] ?? 'Photographer';
    final location    = profile?['location'] ?? 'Kenya';
    final photo       = profile?['profile_photo'] as String?;
    final status      = booking['status'] as String? ?? 'pending';
    final bookingDate = booking['booking_date'] as String? ?? '—';
    final notes       = booking['notes'] as String?;
    final rate        = profile?['hourly_rate'];

    final canCancel = status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: photo + name + status ───────────────────────
            Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: photo != null
                      ? Image.network(
                          photo,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatar(name),
                        )
                      : _avatar(name),
                ),
                const SizedBox(width: 12),

                // Name + location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: kPrimary)),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: kTextMuted),
                        const SizedBox(width: 2),
                        Text(location,
                            style: const TextStyle(
                                fontSize: 12, color: kTextMuted)),
                      ]),
                    ],
                  ),
                ),

                // Status badge
                StatusBadge(status: status),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // ── Booking details ───────────────────────────────────────
            Row(
              children: [
                _Detail(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: bookingDate,
                ),
                if (rate != null) ...[
                  const SizedBox(width: 24),
                  _Detail(
                    icon: Icons.payments_outlined,
                    label: 'Rate',
                    value: 'Ksh $rate/hr',
                  ),
                ],
              ],
            ),

            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_outlined,
                        size: 15, color: kTextMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(notes,
                          style: const TextStyle(
                              fontSize: 12,
                              color: kTextMuted,
                              height: 1.5)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Action buttons ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewPhotographer,
                    icon: const Icon(Icons.person_outline, size: 16),
                    label: const Text('View Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kBorder),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (canCancel) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kError,
                        side: const BorderSide(color: kError),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String name) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20),
          ),
        ),
      );
}

// ── Detail chip ───────────────────────────────────────────────────────────────
class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Detail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: kSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: kTextMuted)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kPrimary)),
          ],
        ),
      ],
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 56, color: Colors.black.withValues(alpha: 0.15)),
            const SizedBox(height: 12),
            const Text('Could not load bookings',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(message,
                style: const TextStyle(fontSize: 12, color: kTextMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/screens/client/client_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';


class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});
  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _bookings = [];
  bool _loading = true;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await BookingService.getAll() as Map<String, dynamic>;
      setState(() { _bookings = data['bookings'] ?? data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  List<dynamic> _filtered(String status) =>
      _bookings.where((b) => b['status'] == status).toList();

  Future<void> _cancel(dynamic b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await BookingService.updateStatus(b['id'], 'cancelled');
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled'),
              backgroundColor: Colors.orange));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('My Bookings'),
      bottom: TabBar(
        controller: _tabs,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: kSky,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Confirmed'),
          Tab(text: 'Past'),
        ],
      ),
    ),
    body: _loading
        ? const LoadingWidget(message: 'Loading bookings…')
        : TabBarView(
            controller: _tabs,
            children: [
              _ClientBookingList(
                bookings: _filtered('pending'),
                emptyTitle: 'No pending bookings',
                onCancel: _cancel,
              ),
              _ClientBookingList(
                bookings: _filtered('confirmed'),
                emptyTitle: 'No confirmed bookings',
                onCancel: _cancel,
              ),
              _ClientBookingList(
                bookings: [..._filtered('cancelled'), ..._filtered('completed')],
                emptyTitle: 'No past bookings',
                onCancel: null,
              ),
            ],
          ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: kCobalt,
      icon: const Icon(Icons.search, color: Colors.white),
      label: const Text('Find Photographer', style: TextStyle(color: Colors.white)),
      onPressed: () => context.go('/photographers'),
    ),
  );
}

class _ClientBookingList extends StatelessWidget {
  final List<dynamic> bookings;
  final String emptyTitle;
  final Future<void> Function(dynamic)? onCancel;

  const _ClientBookingList({
    required this.bookings,
    required this.emptyTitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_month_outlined,
        title: emptyTitle,
        subtitle: 'Browse photographers to make a booking',
        actionLabel: 'Find Photographers',
        onAction: () => context.go('/photographers'),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (ctx, i) {
          final b = bookings[i];
          final pgName = b['photographer']?['name'] ?? 'Photographer';
          final pgPhoto = b['photographer']?['photographer_profile']?['profile_photo'];
          final date = (b['booking_date'] as String?)?.substring(0, 10) ?? '';
          final status = b['status'] ?? 'pending';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 22, backgroundColor: kCobalt,
                    backgroundImage: pgPhoto != null
                        ? NetworkImage(pgPhoto) : null,
                    child: pgPhoto == null
                        ? Text(pgName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(pgName,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text(b['photographer']?['email'] ?? '',
                        style: const TextStyle(fontSize: 11, color: kSlate)),
                  ])),
                  StatusBadge(status: status),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.calendar_today, size: 14, color: kSlate),
                  const SizedBox(width: 6),
                  Text(date,
                      style: const TextStyle(color: kSlate, fontSize: 13)),
                ]),
                if (b['notes'] != null && (b['notes'] as String).isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.notes, size: 14, color: kSlate),
                    const SizedBox(width: 6),
                    Expanded(child: Text(b['notes'],
                        style: const TextStyle(fontSize: 13, color: kSlate))),
                  ]),
                ],
                if (b['amount'] != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.monetization_on, size: 14, color: kCobalt),
                    const SizedBox(width: 6),
                    Text('Ksh ${b['amount']}',
                        style: const TextStyle(fontSize: 13,
                            color: kCobalt, fontWeight: FontWeight.w600)),
                  ]),
                ],
                if (status == 'pending' && onCancel != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel Booking'),
                      onPressed: () => onCancel!(b),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}
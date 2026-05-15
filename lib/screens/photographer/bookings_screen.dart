// lib/screens/photographer/bookings_screen.dart

import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';


class PhotographerBookingsScreen extends StatefulWidget {
  const PhotographerBookingsScreen({super.key});
  @override
  State<PhotographerBookingsScreen> createState() => _PhotographerBookingsScreenState();
}

class _PhotographerBookingsScreenState extends State<PhotographerBookingsScreen>
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
      setState(() {
        _bookings = data['bookings'] ?? data;
        _loading  = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  List<dynamic> _filtered(String status) =>
      _bookings.where((b) => b['status'] == status).toList();

  Future<void> _updateStatus(dynamic booking, String newStatus) async {
    try {
      await BookingService.updateStatus(booking['id'], newStatus);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Booking $newStatus'),
        backgroundColor: newStatus == 'confirmed' ? Colors.green : Colors.red,
      ));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bookings'),
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
              _BookingList(
                bookings: _filtered('pending'),
                onAction: (b, s) => _updateStatus(b, s),
                showActions: true,
              ),
              _BookingList(
                bookings: _filtered('confirmed'),
                onAction: (b, s) => _updateStatus(b, s),
                showActions: false,
              ),
              _BookingList(
                bookings: [
                  ..._filtered('cancelled'),
                  ..._filtered('completed'),
                ],
                onAction: null,
                showActions: false,
              ),
            ],
          ),
  );
}

class _BookingList extends StatelessWidget {
  final List<dynamic> bookings;
  final Function(dynamic, String)? onAction;
  final bool showActions;

  const _BookingList({
    required this.bookings,
    this.onAction,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'No bookings here',
        subtitle: 'Bookings will appear as clients make requests',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (ctx, i) {
          final b = bookings[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 20, backgroundColor: kCobalt,
                    child: Text(
                      (b['client']?['name'] ?? 'C').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b['client']?['name'] ?? 'Client',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(b['client']?['phoneNumber'] ?? b['client']?['email'] ?? '',
                        style: const TextStyle(fontSize: 12, color: kSlate)),
                  ])),
                  StatusBadge(status: b['status'] ?? 'pending'),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.calendar_today, size: 14, color: kSlate),
                  const SizedBox(width: 6),
                  Text(b['booking_date']?.substring(0, 10) ?? '',
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
                if (showActions && b['status'] == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => onAction?.call(b, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red)),
                      child: const Text('Decline'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(
                      onPressed: () => onAction?.call(b, 'confirmed'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Confirm'),
                    )),
                  ]),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}
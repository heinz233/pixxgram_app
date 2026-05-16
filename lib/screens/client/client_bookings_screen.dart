// lib/screens/client/client_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
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
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // getAll() returns List<dynamic> directly — no casting to Map needed
      final list = await BookingService.getAll();
      if (!mounted) return;
      setState(() {
        _bookings = list;
        _loading  = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load: $e'),
            backgroundColor: kError),
      );
    }
  }

  List<dynamic> _filtered(String status) =>
      _bookings.where((b) => b['status'] == status).toList();

  // ── Cancel ────────────────────────────────────────────────────────
  Future<void> _cancel(dynamic b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content:
            const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: kError, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await BookingService.cancel(b['id']);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking cancelled'),
          backgroundColor: kWarning));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: kError));
    }
  }

  // ── Pay via M-Pesa ────────────────────────────────────────────────
  Future<void> _pay(dynamic b) async {
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController(
        text: b['amount']?.toString() ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pay via M-Pesa',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'An STK push will be sent to your Safaricom number.',
              style: TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone (e.g. 0712345678)',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (Ksh)',
              prefixIcon: const Icon(Icons.monetization_on),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: Colors.white),
            child: const Text('Send STK Push'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final phone  = phoneCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text.trim());

    if (phone.isEmpty || amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter a valid phone number and amount'),
          backgroundColor: kError));
      return;
    }

    try {
      final result = await BookingService.initiatePayment(
        bookingId: b['id'],
        phone:     phone,
        amount:    amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ??
              'M-Pesa prompt sent. Enter your PIN.'),
          backgroundColor: kSuccess,
          duration: const Duration(seconds: 6)));

      // Poll after 12s to see if payment went through
      await Future.delayed(const Duration(seconds: 12));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: kError));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: TabBar(
            controller: _tabs,
            labelColor: kPrimary,
            unselectedLabelColor: kTextMuted,
            indicatorColor: kSecondary,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: _loading
            ? const LoadingWidget(message: 'Loading bookings…')
            : RefreshIndicator(
                onRefresh: _load,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _BookingList(
                      bookings:   _filtered('pending'),
                      emptyTitle: 'No pending bookings',
                      onCancel:   _cancel,
                    ),
                    _BookingList(
                      bookings:   _filtered('confirmed'),
                      emptyTitle: 'No confirmed bookings',
                      onCancel:   _cancel,
                      onPay:      _pay,
                    ),
                    _BookingList(
                      bookings: [
                        ..._filtered('completed'),
                        ..._filtered('cancelled'),
                      ],
                      emptyTitle: 'No past bookings',
                    ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.search),
          label: const Text('Find Photographer',
              style: TextStyle(fontWeight: FontWeight.w600)),
          onPressed: () => context.go('/photographers'),
        ),
      );
}

// ── Booking list ──────────────────────────────────────────────────────────────
class _BookingList extends StatelessWidget {
  final List<dynamic> bookings;
  final String emptyTitle;
  final Future<void> Function(dynamic)? onCancel;
  final Future<void> Function(dynamic)? onPay;

  const _BookingList({
    required this.bookings,
    required this.emptyTitle,
    this.onCancel,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: EmptyState(
            icon: Icons.calendar_month_outlined,
            title: emptyTitle,
            subtitle: 'Browse photographers to make a booking',
            actionLabel: 'Find Photographers',
            onAction: () => context.go('/photographers'),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) {
        final b         = bookings[i];
        final pgName    = b['photographer']?['name'] as String? ?? 'Photographer';
        final pgPhoto   = b['photographer']?['photographer_profile']
            ?['profile_photo'] as String?;
        final date      = (b['booking_date'] as String?)?.substring(0, 10) ?? '';
        final status    = b['status'] as String? ?? 'pending';
        final payStatus = b['payment_status'] as String? ?? 'unpaid';
        final amount    = b['amount'];
        final notes     = b['notes'] as String?;
        final receipt   = b['mpesa_receipt'] as String?;

        // Build full photo URL
        String? photoUrl;
        if (pgPhoto != null && pgPhoto.isNotEmpty) {
          photoUrl = pgPhoto.startsWith('http')
              ? pgPhoto
              : 'http://192.168.100.8:8000/storage/$pgPhoto';
        }

        final needsPayment = status == 'confirmed' && payStatus != 'paid';
        final isPaid       = payStatus == 'paid';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Photographer row ─────────────────────────────────
                Row(children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: kPrimary,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null
                        ? Text(
                            pgName.isNotEmpty
                                ? pgName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pgName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text(
                            b['photographer']?['email'] as String? ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: kTextMuted)),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ]),

                const SizedBox(height: 12),

                // ── Date ────────────────────────────────────────────
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: kTextMuted),
                  const SizedBox(width: 6),
                  Text(date,
                      style: const TextStyle(
                          color: kTextMuted, fontSize: 13)),
                ]),

                // ── Notes ───────────────────────────────────────────
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes,
                          size: 14, color: kTextMuted),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(notes,
                              style: const TextStyle(
                                  fontSize: 13, color: kTextMuted))),
                    ],
                  ),
                ],

                // ── Amount + payment badge ───────────────────────────
                if (amount != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.monetization_on,
                        size: 14, color: kSecondary),
                    const SizedBox(width: 6),
                    Text('Ksh $amount',
                        style: const TextStyle(
                            fontSize: 13,
                            color: kPrimary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    StatusBadge(status: payStatus),
                  ]),
                ],

                // ── Cancel button (pending only) ─────────────────────
                if (status == 'pending' && onCancel != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel Booking'),
                      onPressed: () => onCancel!(b),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: kError,
                          side: const BorderSide(color: kError)),
                    ),
                  ),
                ],

                // ── Pay button (confirmed + unpaid) ──────────────────
                if (needsPayment && onPay != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.phone_android, size: 16),
                      label: const Text('Pay via M-Pesa',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => onPay!(b),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A651),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],

                // ── Paid confirmation ────────────────────────────────
                if (isPaid) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kSuccess.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kSuccess.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: kSuccess),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          receipt != null
                              ? 'Paid · Receipt: $receipt'
                              : 'Payment confirmed',
                          style: const TextStyle(
                              fontSize: 12,
                              color: kSuccess,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
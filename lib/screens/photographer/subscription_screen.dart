// lib/screens/photographer/subscription_screen.dart

import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Map<String, dynamic>? _current;
  Map<String, dynamic>  _plans       = {};
  List<dynamic>         _history     = [];
  bool   _loading     = true;
  bool   _subscribing = false;
  String _selectedPlan = 'monthly';
  String _payMethod    = 'mpesa';
  final  _phoneCtrl    = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final planData = await SubscriptionService.getPlans();
      _plans = planData['plans'] ?? {};
      try {
        final cur = await SubscriptionService.getCurrent();
        _current = cur['subscription'];
      } catch (_) {}
      try {
        final hist = await SubscriptionService.getHistory() as Map<String, dynamic>;
        _history = hist['subscriptions'] ?? [];
      } catch (_) {}
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _subscribe() async {
    if (_payMethod == 'mpesa' && _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter your M-Pesa number'),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _subscribing = true);
    try {
      final data = await SubscriptionService.subscribe(
        plan: _selectedPlan,
        paymentMethod: _payMethod,
        phone: _payMethod == 'mpesa' ? _phoneCtrl.text.trim() : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message'] ?? 'Subscription initiated!'),
        backgroundColor: Colors.green,
      ));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed. Please try again.'),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _subscribing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Subscription')),
    body: _loading
        ? const LoadingWidget()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Current status
              if (_current != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        '${_current!['plan']?.toString().toUpperCase() ?? ''} — Active',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46), fontSize: 15),
                      ),
                      Text(
                        'Expires: ${_current!['ends_at']?.substring(0, 10) ?? ''}',
                        style: const TextStyle(color: Color(0xFF065F46), fontSize: 12),
                      ),
                    ])),
                  ]),
                ),
                const SizedBox(height: 20),
              ],

              // Plans
              const Text('Choose a Plan',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kNavy)),
              const SizedBox(height: 12),
              ..._plans.entries.map((e) {
                final plan     = e.value as Map<String, dynamic>;
                final selected = _selectedPlan == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPlan = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected ? kCobalt : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected ? kCobalt : Colors.grey[300]!, width: 1.5),
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(plan['label'] ?? e.key,
                            style: TextStyle(fontWeight: FontWeight.bold,
                                color: selected ? Colors.white : kNavy, fontSize: 15)),
                        Text('${plan['duration']} days',
                            style: TextStyle(fontSize: 12,
                                color: selected ? Colors.white70 : kSlate)),
                      ])),
                      Text('Ksh ${plan['amount']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,
                              color: selected ? Colors.white : kCobalt)),
                      const SizedBox(width: 8),
                      Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: selected ? Colors.white : Colors.grey),
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 20),
              const Text('Payment Method',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kNavy)),
              const SizedBox(height: 12),
              Row(children: [
                _PayOpt('mpesa', 'M-Pesa', Icons.phone_android, _payMethod,
                    (v) => setState(() => _payMethod = v)),
                const SizedBox(width: 10),
                _PayOpt('card', 'Card', Icons.credit_card, _payMethod,
                    (v) => setState(() => _payMethod = v)),
                const SizedBox(width: 10),
                _PayOpt('paypal', 'PayPal', Icons.language, _payMethod,
                    (v) => setState(() => _payMethod = v)),
              ]),

              if (_payMethod == 'mpesa') ...[
                const SizedBox(height: 16),
                PxTextField(
                  label: 'M-Pesa Number',
                  controller: _phoneCtrl,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  hint: '+254 7XX XXX XXX',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: Color(0xFF10B981), size: 16),
                    SizedBox(width: 8),
                    Flexible(child: Text(
                      'An STK push will be sent to your phone. Enter your M-Pesa PIN to confirm.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF065F46)),
                    )),
                  ]),
                ),
              ],

              const SizedBox(height: 24),
              PxButton(
                label: 'Subscribe Now',
                loading: _subscribing,
                icon: Icons.payment,
                onTap: _subscribe,
              ),

              // History
              if (_history.isNotEmpty) ...[
                const SizedBox(height: 28),
                const SectionHeader(title: 'Payment History'),
                const SizedBox(height: 12),
                ..._history.map((h) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: kCobalt,
                        child: Icon(Icons.receipt, color: Colors.white, size: 18)),
                    title: Text('${h['plan']?.toString().toUpperCase()} — Ksh ${h['amount']}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(h['starts_at']?.substring(0, 10) ?? ''),
                    trailing: StatusBadge(status: h['status'] ?? ''),
                  ),
                )),
              ],

              const SizedBox(height: 24),
            ]),
          ),
  );
}

class _PayOpt extends StatelessWidget {
  final String value, label, selected;
  final IconData icon;
  final void Function(String) onSelect;
  const _PayOpt(this.value, this.label, this.icon, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final sel = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: sel ? kCobalt : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? kCobalt : Colors.grey[300]!, width: 1.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: sel ? Colors.white : kCobalt, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : kNavy)),
          ]),
        ),
      ),
    );
  }
}
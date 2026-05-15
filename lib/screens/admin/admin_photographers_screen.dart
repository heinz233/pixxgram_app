// lib/screens/admin/admin_photographers_screen.dart

import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';


class AdminPhotographersScreen extends StatefulWidget {
  const AdminPhotographersScreen({super.key});
  @override
  State<AdminPhotographersScreen> createState() => _AdminPhotographersScreenState();
}

class _AdminPhotographersScreenState extends State<AdminPhotographersScreen> {
  List<dynamic> _list = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminService.getPhotographers(
          status: _filter == 'all' ? null : _filter);
      setState(() { _list = data['photographers'] ?? []; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _approve(dynamic p) async {
    try {
      await AdminService.approvePhotographer(p['id']);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${p['first_name']} approved ✓'),
              backgroundColor: Colors.green));
    } catch (_) {}
  }

  Future<void> _suspend(dynamic p) async {
    try {
      await AdminService.suspendPhotographer(p['id']);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${p['first_name']} suspended'),
              backgroundColor: Colors.orange));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Photographers')),
    body: Column(children: [
      // Filter chips
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['all', 'pending', 'active', 'suspended', 'expired']
                .map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s == 'all' ? 'All' : s.toUpperCase(),
                        style: const TextStyle(fontSize: 12)),
                    selected: _filter == s,
                    selectedColor: kCobalt,
                    labelStyle: TextStyle(
                        color: _filter == s ? Colors.white : kNavy),
                    onSelected: (_) {
                      setState(() => _filter = s);
                      _load();
                    },
                  ),
                )).toList(),
          ),
        ),
      ),

      Expanded(
        child: _loading
            ? const LoadingWidget()
            : _list.isEmpty
                ? const EmptyState(icon: Icons.people, title: 'No photographers found')
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _list.length,
                      itemBuilder: (ctx, i) {
                        final p = _list[i];
                        final status = p['subscription_status'] ?? 'pending';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                CircleAvatar(
                                  radius: 22, backgroundColor: kCobalt,
                                  child: Text(
                                    (p['first_name'] ?? 'P').substring(0, 1),
                                    style: const TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${p['first_name']} ${p['last_name']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text(p['email'] ?? '',
                                      style: const TextStyle(fontSize: 12, color: kSlate)),
                                ])),
                                StatusBadge(status: status),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.location_on, size: 13, color: kSlate),
                                const SizedBox(width: 4),
                                Text(p['county'] ?? 'Unknown location',
                                    style: const TextStyle(fontSize: 12, color: kSlate)),
                                const SizedBox(width: 12),
                                const Icon(Icons.phone, size: 13, color: kSlate),
                                const SizedBox(width: 4),
                                Text(p['phone'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: kSlate)),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                if (status != 'active')
                                  Expanded(child: ElevatedButton(
                                    onPressed: () => _approve(p),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(vertical: 8)),
                                    child: const Text('Approve'),
                                  )),
                                if (status == 'active') ...[
                                  Expanded(child: OutlinedButton(
                                    onPressed: () => _suspend(p),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        padding: const EdgeInsets.symmetric(vertical: 8)),
                                    child: const Text('Suspend'),
                                  )),
                                ],
                              ]),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]),
  );
}
// lib/screens/admin/admin_reports_screen.dart

import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';


class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _reports = [];
  bool _loading = true;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminService.getReports();
      setState(() { _reports = data['reports'] ?? []; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  List<dynamic> get _open   => _reports.where((r) => r['status'] == 'open').toList();
  List<dynamic> get _closed => _reports.where((r) => r['status'] != 'open').toList();

  Future<void> _resolve(dynamic r) async {
    try {
      await AdminService.resolveReport(r['id']);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report resolved ✓'),
              backgroundColor: Colors.green));
    } catch (_) {}
  }

  Future<void> _dismiss(dynamic r) async {
    try {
      await AdminService.dismissReport(r['id']);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report dismissed'),
              backgroundColor: Colors.orange));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Reports'),
      bottom: TabBar(
        controller: _tabs,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: kSky,
        tabs: [
          Tab(text: 'Open (${_open.length})'),
          Tab(text: 'Closed (${_closed.length})'),
        ],
      ),
    ),
    body: _loading
        ? const LoadingWidget(message: 'Loading reports…')
        : TabBarView(
            controller: _tabs,
            children: [
              _ReportList(reports: _open,   onResolve: _resolve, onDismiss: _dismiss),
              _ReportList(reports: _closed, onResolve: null,     onDismiss: null),
            ],
          ),
  );
}

class _ReportList extends StatelessWidget {
  final List<dynamic> reports;
  final Future<void> Function(dynamic)? onResolve;
  final Future<void> Function(dynamic)? onDismiss;

  const _ReportList({
    required this.reports,
    this.onResolve,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No reports here',
        subtitle: 'All clear!',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reports.length,
        itemBuilder: (ctx, i) {
          final r = reports[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (r['reason'] ?? 'unknown').toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                          color: Color(0xFF991B1B)),
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: r['status'] ?? 'open'),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.camera_alt, size: 14, color: kSlate),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    'Against: ${r['photographer_name'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person_outline, size: 14, color: kSlate),
                  const SizedBox(width: 6),
                  Text(
                    'By: ${r['reported_by_name'] ?? r['reported_by_email'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 12, color: kSlate),
                  ),
                ]),
                if (r['details'] != null && (r['details'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(r['details'],
                        style: const TextStyle(fontSize: 13, color: kSlate)),
                  ),
                ],
                if (r['created_at'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Reported: ${(r['created_at'] as String).substring(0, 10)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
                if (onResolve != null || onDismiss != null) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    if (onDismiss != null)
                      Expanded(child: OutlinedButton(
                        onPressed: () => onDismiss!(r),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey)),
                        child: const Text('Dismiss'),
                      )),
                    if (onDismiss != null && onResolve != null)
                      const SizedBox(width: 10),
                    if (onResolve != null)
                      Expanded(child: ElevatedButton(
                        onPressed: () => onResolve!(r),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('Resolve'),
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
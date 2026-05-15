// lib/screens/admin/admin_locations_screen.dart

import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

// Assuming color constants are configured here or imported from theme/widgets
const kNavy = Color(0xFF0A192F);
const kCobalt = Color(0xFF172A45);
const kSlate = Color(0xFF8892B0);

class AdminLocationsScreen extends StatefulWidget {
  const AdminLocationsScreen({super.key});
  @override
  State<AdminLocationsScreen> createState() => _AdminLocationsScreenState();
}

class _AdminLocationsScreenState extends State<AdminLocationsScreen> {
  List<dynamic> _locations = [];
  bool _loading = true;
  bool _saving  = false;

  // Form controllers
  final _nameCtrl   = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  List<dynamic> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _locations;
    return _locations.where((l) =>
        (l['name']   ?? '').toString().toLowerCase().contains(q) ||
        (l['region'] ?? '').toString().toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _regionCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── API calls ──────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminService.getLocations();
      setState(() {
        _locations = data is List ? data : data['locations'] ?? [];
        _loading   = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save({int? id}) async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location name is required'),
            backgroundColor: Colors.orange));
      return;
    }
    setState(() => _saving = true);
    try {
      final regionText = _regionCtrl.text.trim();
      if (id == null) {
        await AdminService.createLocation(
          name: _nameCtrl.text.trim(),
          region: regionText.isEmpty ? '' : regionText,
        );
      } else {
        await AdminService.updateLocation(
          id,
          {
            'name': _nameCtrl.text.trim(),
            'region': regionText.isEmpty ? '' : regionText,
          },
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(id == null ? 'Location added ✓' : 'Location updated ✓'),
        backgroundColor: Colors.green,
      ));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${_errorMsg(e)}'),
            backgroundColor: Colors.red));
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete(dynamic location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Location',
            style: TextStyle(fontWeight: FontWeight.bold, color: kNavy)),
        content: Text('Delete "${location['name']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await AdminService.deleteLocation(location['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location deleted'),
            backgroundColor: Colors.orange));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${_errorMsg(e)}'),
            backgroundColor: Colors.red));
    }
  }

  // ── Bottom sheets ──────────────────────────────────────────────────────────

  void _showForm({Map<String, dynamic>? location}) {
    // Pre-fill if editing
    _nameCtrl.text   = location?['name']   ?? '';
    _regionCtrl.text = location?['region'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),

              Text(
                location == null ? 'Add New Location' : 'Edit Location',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: kNavy),
              ),
              const SizedBox(height: 20),

              PxTextField(
                label: 'Location Name *',
                controller: _nameCtrl,
                prefixIcon: Icons.location_on_outlined,
                hint: 'e.g. Nairobi',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              PxTextField(
                label: 'Region (optional)',
                controller: _regionCtrl,
                prefixIcon: Icons.map_outlined,
                hint: 'e.g. Nairobi County',
              ),
              const SizedBox(height: 24),

              PxButton(
                label: location == null ? 'Add Location' : 'Save Changes',
                loading: _saving,
                icon: location == null ? Icons.add_location_alt : Icons.save,
                onTap: () => _save(id: location?['id']),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _errorMsg(dynamic e) {
    try { return e.response?.data?['message'] ?? e.toString(); }
    catch (_) { return e.toString(); }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary strip
          Container(
            color: kCobalt,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_locations.length} location${_locations.length != 1 ? 's' : ''} registered',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search locations…',
                prefixIcon: const Icon(Icons.search, color: kSlate),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Main contents
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No locations found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(item['name'] ?? ''),
                              subtitle: Text(item['region'] ?? 'No region specified'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showForm(location: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _delete(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: kCobalt,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

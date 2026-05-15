// lib/screens/photographer/photographer_profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class PhotographerProfileScreen extends StatefulWidget {
  final int id;
  const PhotographerProfileScreen({super.key, required this.id});
  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState extends State<PhotographerProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _photographer;
  List<dynamic> _portfolio = [];
  List<dynamic> _reviews   = [];
  bool _loading = true;
  late TabController _tabs;

  // Booking form
  DateTime? _selectedDate;
  final _notesCtrl = TextEditingController();
  bool _submittingBooking = false;

  // Rating form
  double _stars = 0;
  final _reviewCtrl = TextEditingController();
  bool _submittingRating = false;

  // Report form
  String _reportReason = 'unprofessional';
  final _reportCtrl = TextEditingController();
  bool _submittingReport = false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String buildImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'http://192.168.100.8:8000/storage/$path';
  }

  Widget _pxChip({
    required String label,
    required bool selected,
    Color selectedColor = kPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.05),
          border: Border.all(
            color: selected
                ? selectedColor
                : Colors.black.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? selectedColor
                : Colors.black.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _notesCtrl.dispose();
    _reviewCtrl.dispose();
    _reportCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await PhotographerService.getById(widget.id);
      if (!mounted) return;
      setState(() {
        _photographer = data['photographer'];
        _portfolio    = data['portfolio'] ?? [];
        _reviews      = data['reviews']   ?? [];
        _loading      = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ── Booking ───────────────────────────────────────────────────────────────

  void _showBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              Text('Book ${_photographer?['name'] ?? ''}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
              const SizedBox(height: 20),

              // Date picker
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(primary: kPrimary),
                      ),
                      child: child!,
                    ),
                  );
                  if (d != null) setModal(() => _selectedDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kBackground,
                    border: Border.all(
                        color: _selectedDate != null
                            ? kPrimary
                            : Colors.black.withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: kPrimary.withValues(alpha: 0.7)),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == null
                          ? 'Select session date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                          fontSize: 14,
                          color: _selectedDate == null
                              ? Colors.black.withValues(alpha: 0.4)
                              : kPrimary,
                          fontWeight: _selectedDate != null
                              ? FontWeight.w600
                              : FontWeight.normal),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, size: 18),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Notes — describe your requirements, theme, venue…',
                  hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.35), fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary),
                  ),
                  filled: true,
                  fillColor: kBackground,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submittingBooking
                      ? null
                      : () => _submitBooking(ctx),
                  icon: _submittingBooking
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Confirm Booking',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitBooking(BuildContext sheetCtx) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: kWarning));
      return;
    }

    // Capture navigator BEFORE the await gap
    final nav = Navigator.of(sheetCtx);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _submittingBooking = true);
    try {
      await BookingService.create(
        photographerId: widget.id,
        bookingDate: _selectedDate!.toIso8601String(),
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );
      if (!mounted) return;
      nav.pop();
      messenger.showSnackBar(const SnackBar(
          content: Text('✓ Booking request sent!'),
          backgroundColor: kSuccess));
      _notesCtrl.clear();
      setState(() => _selectedDate = null);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: kError));
    } finally {
      if (mounted) setState(() => _submittingBooking = false);
    }
  }

  // ── Rating ────────────────────────────────────────────────────────────────

  void _showRatingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              const Text('Leave a Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text('How was your experience with ${_photographer?['name']}?',
                  style: TextStyle(fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.45))),
              const SizedBox(height: 20),

              Center(child: RatingBar.builder(
                initialRating: _stars,
                minRating: 1, maxRating: 5,
                itemSize: 36,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: kSecondary),
                onRatingUpdate: (r) => setModal(() => _stars = r),
              )),
              const SizedBox(height: 16),

              TextFormField(
                controller: _reviewCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Share your experience…',
                  hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.35), fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.12))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.12))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimary)),
                  filled: true, fillColor: kBackground,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submittingRating
                      ? null
                      : () => _submitRating(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submittingRating
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Review',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRating(BuildContext sheetCtx) async {
    if (_stars == 0) return;

    // Capture before await gap
    final nav = Navigator.of(sheetCtx);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _submittingRating = true);
    try {
      await RatingService.submit(widget.id, _stars.toInt(),
          comment: _reviewCtrl.text.isEmpty ? null : _reviewCtrl.text);
      if (!mounted) return;
      nav.pop();
      messenger.showSnackBar(const SnackBar(
          content: Text('✓ Review submitted!'),
          backgroundColor: kSuccess));
      _reviewCtrl.clear();
      setState(() => _stars = 0);
      _load();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
          content: Text('Failed to submit review'),
          backgroundColor: kError));
    } finally {
      if (mounted) setState(() => _submittingRating = false);
    }
  }

  // ── Report ────────────────────────────────────────────────────────────────

  void _showReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              const Row(children: [
                Icon(Icons.flag_outlined, color: kError, size: 20),
                SizedBox(width: 8),
                Text('Report Photographer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                        color: kError, letterSpacing: -0.3)),
              ]),
              const SizedBox(height: 20),
              const Text('Reason',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['unprofessional', 'no_show', 'scam',
                            'inappropriate', 'other'].map((r) => _pxChip(
                  label: r.replaceAll('_', ' ').split(' ')
                      .map((w) => w[0].toUpperCase() + w.substring(1))
                      .join(' '),
                  selected: _reportReason == r,
                  selectedColor: kError,
                  onTap: () => setModal(() => _reportReason = r),
                )).toList(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _reportCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)…',
                  hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.35), fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.12))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.12))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kError)),
                  filled: true, fillColor: kBackground,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submittingReport
                      ? null
                      : () => _submitReport(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kError,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submittingReport
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Report',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext sheetCtx) async {
    // Capture before await gap
    final nav = Navigator.of(sheetCtx);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _submittingReport = true);
    try {
      await RatingService.submit(widget.id, 0);
      if (!mounted) return;
      nav.pop();
      messenger.showSnackBar(const SnackBar(
          content: Text('Report submitted. Our team will review it.'),
          backgroundColor: kSuccess));
      _reportCtrl.clear();
    } catch (_) {
      // silently ignore
    } finally {
      if (mounted) setState(() => _submittingReport = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (_loading) {
      return const Scaffold(body: LoadingWidget(message: 'Loading profile…'));
    }
    if (_photographer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Photographer not found',
          actionLabel: 'Go Back',
          onAction: () => context.go('/photographers'),
        ),
      );
    }

    final profile  = _photographer!['photographer_profile']
        as Map<String, dynamic>?;
    final name     = _photographer!['name'] as String? ?? '';
    final photoUrl = buildImageUrl(profile?['profile_photo'] as String?);
    final location = profile?['location'] as String? ?? 'Kenya';
    final total    = profile?['total_ratings'] ?? 0;
    final bio      = profile?['bio'] as String? ?? 'Professional photographer.';
    final spec     = profile?['speciality'] as String?;
    final isActive = profile?['subscription_status'] == 'active';
    final rating = double.tryParse(profile?['average_rating']?.toString() ?? '0') ?? 0.0;
    final rate   = profile?['hourly_rate'] != null
    ? double.tryParse(profile!['hourly_rate'].toString())
    : null;

    return Scaffold(
      backgroundColor: kBackground,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    size: 18, color: Colors.white),
              ),
              onPressed: () => context.go('/photographers'),
            ),
            actions: [
              if (auth.isAuthenticated)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flag_outlined,
                        size: 18, color: Colors.white),
                  ),
                  onPressed: _showReportSheet,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _gradientBox(),
                        errorWidget: (_, __, ___) => _gradientBox(
                            child: Text(initials(name),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 56,
                                    fontWeight: FontWeight.w700))),
                      )
                    : _gradientBox(
                        child: Text(initials(name),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 56,
                                fontWeight: FontWeight.w700))),

                // Bottom gradient overlay
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 120,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // Name + location overlay
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 2),
                          Text(location,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                      ],
                    )),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: kSuccess,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 11, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Active',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                  ]),
                ),
              ]),
            ),
          ),
        ],

        body: Column(children: [
          // Info strip
          Container(
            color: kSurface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.star_rounded, size: 16, color: kSecondary),
                  const SizedBox(width: 3),
                  Text(rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(width: 4),
                  Text('($total reviews)',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.4))),
                ]),
                if (spec != null)
                  Text(spec, style: const TextStyle(
                      fontSize: 12, color: kSecondary,
                      fontWeight: FontWeight.w600)),
              ]),
              const Spacer(),
              if (rate != null)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('KSh ${rate.toString()}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: kPrimary)),
                  Text('/hr',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withValues(alpha: 0.4))),
                ]),
            ]),
          ),
          Divider(height: 1,
              color: Colors.black.withValues(alpha: 0.06)),

          // Tabs
          Container(
            color: kSurface,
            child: TabBar(
              controller: _tabs,
              labelColor: kPrimary,
              unselectedLabelColor: Colors.black.withValues(alpha: 0.4),
              indicatorColor: kPrimary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Portfolio'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),

          // Tab content
          Expanded(child: TabBarView(
            controller: _tabs,
            children: [
              // About
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(bio, style: TextStyle(
                        fontSize: 14, height: 1.65,
                        color: Colors.black.withValues(alpha: 0.65))),
                    if (rate != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.04),
                          border: Border.all(
                              color: kPrimary.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Icon(Icons.monetization_on_outlined,
                              color: kSecondary, size: 20),
                          const SizedBox(width: 10),
                          Text('From KSh $rate / hr',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: kPrimary, fontSize: 16)),
                        ]),
                      ),
                    ],
                    if (_photographer!['photographer_profile']
                            ?['service_rates'] != null) ...[
                      const SizedBox(height: 20),
                      const Text('Service Rates', style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ...((_photographer!['photographer_profile']
                              ['service_rates'] as Map<String, dynamic>)
                          .entries
                          .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Expanded(child: Text(
                            e.key[0].toUpperCase() + e.key.substring(1),
                            style: TextStyle(fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.55)),
                          )),
                          Text('KSh ${e.value}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                        ]),
                      ))),
                    ],
                  ],
                ),
              ),

              // Portfolio
              _portfolio.isEmpty
                  ? const EmptyState(
                      icon: Icons.photo_library_outlined,
                      title: 'No portfolio yet',
                      subtitle: 'This photographer hasn\'t uploaded work yet.')
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _portfolio.length,
                      itemBuilder: (ctx, i) {
                        final item = _portfolio[i];
                        final url = buildImageUrl(
                            item['image_url'] as String?);
                        return GestureDetector(
                          onTap: () => _showLightbox(i),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(fit: StackFit.expand, children: [
                              url.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: url,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                          color: Colors.black
                                              .withValues(alpha: 0.07)),
                                      errorWidget: (_, __, ___) => Container(
                                        color: Colors.black
                                            .withValues(alpha: 0.07),
                                        child: const Icon(
                                            Icons.image_outlined,
                                            color: Colors.white54)),
                                    )
                                  : Container(
                                      color: Colors.black
                                          .withValues(alpha: 0.07),
                                      child: const Icon(
                                          Icons.image_outlined,
                                          color: Colors.white54)),
                              if (item['category'] != null)
                                Positioned(
                                  bottom: 6, left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.55),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(item['category'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                            ]),
                          ),
                        );
                      },
                    ),

              // Reviews
              _reviews.isEmpty
                  ? EmptyState(
                      icon: Icons.rate_review_outlined,
                      title: 'No reviews yet',
                      subtitle: 'Be the first to review!',
                      actionLabel:
                          auth.isAuthenticated ? 'Write a Review' : null,
                      onAction:
                          auth.isAuthenticated ? _showRatingSheet : null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reviews.length,
                      separatorBuilder: (_, __) => Divider(
                          height: 24,
                          color: Colors.black.withValues(alpha: 0.06)),
                      itemBuilder: (ctx, i) {
                        final r = _reviews[i];
                        final stars =
                            (r['rating'] ?? r['stars'] ?? 0) as num;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    kPrimary.withValues(alpha: 0.1),
                                child: Text(
                                  initials(r['client_name'] as String?),
                                  style: const TextStyle(
                                      color: kPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(r['client_name'] ?? 'Client',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                  Text(
                                    (r['created_at'] as String?)
                                            ?.substring(0, 10) ??
                                        '',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black
                                            .withValues(alpha: 0.4)),
                                  ),
                                ],
                              )),
                              Row(children: List.generate(5, (s) => Icon(
                                s < stars.round()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 15, color: kSecondary,
                              ))),
                            ]),
                            if (r['comment'] != null &&
                                (r['comment'] as String).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(r['comment'],
                                  style: TextStyle(
                                      fontSize: 13, height: 1.55,
                                      color: Colors.black
                                          .withValues(alpha: 0.6))),
                            ],
                          ],
                        );
                      },
                    ),
            ],
          )),
        ]),
      ),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border(top: BorderSide(
              color: Colors.black.withValues(alpha: 0.07))),
        ),
        child: Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () {
              if (!auth.isAuthenticated) {
                context.go('/login');
              } else {
                context.go('/dashboard/messages');
              }
            },
            icon: const Icon(Icons.message_outlined, size: 16),
            label: const Text('Message'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: BorderSide(color: kPrimary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            onPressed: () {
              if (!auth.isAuthenticated) {
                context.go('/login');
              } else {
                _showBookingSheet();
              }
            },
            icon: const Icon(Icons.calendar_month_outlined, size: 16),
            label: const Text('Book Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
          )),
          if (auth.isAuthenticated && auth.isClient) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showRatingSheet,
              style: IconButton.styleFrom(
                backgroundColor: kSecondary.withValues(alpha: 0.1),
                foregroundColor: kSecondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.star_outline_rounded, size: 20),
              tooltip: 'Rate',
            ),
          ],
        ]),
      ),
    );
  }

  // ── Lightbox ──────────────────────────────────────────────────────────────

  void _showLightbox(int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: _portfolio.length,
            itemBuilder: (_, i) {
              final url = buildImageUrl(
                  _portfolio[i]['image_url'] as String?);
              return InteractiveViewer(
                child: Center(
                  child: url.isNotEmpty
                      ? CachedNetworkImage(imageUrl: url)
                      : const Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 64),
                ),
              );
            },
          ),
          Positioned(
            top: 40, right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Shared gradient background ────────────────────────────────────────────

  Widget _gradientBox({Widget? child}) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimary, Color(0xFF2D1B69)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child != null ? Center(child: child) : null,
      );
}
// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _photographers = [];
  bool   _loading    = true;
  String _errorMsg   = '';
  String _location   = '';
  String _category   = '';

  final _locationItems = ['Nairobi','Mombasa','Kisumu','Nakuru','Eldoret','Thika'];
  final _categoryItems = ['Wedding','Portrait','Corporate','Fashion','Events','Nature'];
  final _trendingTags  = ['Wedding','Portrait','Events','Fashion','Corporate'];

  final _stats = const [
    {'value': '500+',   'label': 'Photographers'},
    {'value': '2,000+', 'label': 'Bookings Made'},
    {'value': '47',     'label': 'Counties Covered'},
    {'value': '4.8★',   'label': 'Average Rating'},
  ];

  final _categories = const [
    {'label':'Wedding',     'icon': Icons.favorite_border,  'color': Colors.pink},
    {'label':'Portrait',    'icon': Icons.account_circle,   'color': Colors.purple},
    {'label':'Events',      'icon': Icons.celebration,      'color': Colors.orange},
    {'label':'Fashion',     'icon': Icons.checkroom,        'color': Colors.teal},
    {'label':'Corporate',   'icon': Icons.business_center,  'color': Colors.blue},
    {'label':'Nature',      'icon': Icons.park,             'color': Colors.green},
    {'label':'Real Estate', 'icon': Icons.home_outlined,    'color': Colors.brown},
    {'label':'Sports',      'icon': Icons.directions_run,   'color': Colors.red},
  ];

  final _steps = const [
    {'step':'1','icon':Icons.search,        'title':'Browse & Filter',
     'desc':'Search photographers by location, price, rating and category.'},
    {'step':'2','icon':Icons.calendar_today,'title':'Book & Message',
     'desc':'Choose a date, send a message, and confirm your booking.'},
    {'step':'3','icon':Icons.phone_android, 'title':'Pay with M-Pesa',
     'desc':'Secure, instant payment directly from your Safaricom line.'},
  ];

  final _testimonials = const [
    {'name':'Charles Kariuki','role':'Bride, Nairobi',
     'quote':'Found our wedding photographer within an hour. The whole process was so smooth and the photos were stunning.'},
    {'name':'Brian Kamau','role':'Marketing Manager',
     'quote':'We use Pixxgram for all our corporate events. Reliable photographers, great quality every time.'},
    {'name':'Cynthia Weru','role':'Photographer, Kisumu',
     'quote':"Joined 6 months ago and I've tripled my bookings. The platform handles everything — I just focus on shooting."},
  ];

  String initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _loadPhotographers();
  }

  Future<void> _loadPhotographers() async {
    setState(() { _loading = true; _errorMsg = ''; });
    try {
      final data = await PhotographerService.getAll(filters: {'per_page': '4'});
      setState(() {
        _photographers =
            data['photographers']?['data'] ??
            data['photographers']          ??
            data['data']                   ?? [];
      });
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goSearch() {
    final q = <String, String>{};
    if (_location.isNotEmpty) q['location'] = _location;
    if (_category.isNotEmpty) q['category'] = _category;
    final queryString = q.isNotEmpty
        ? '?${q.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';
    // go() is correct here — replacing home with list screen
    context.go('/photographers$queryString');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: kBackground,
      body: RefreshIndicator(
        color: kPrimary,
        onRefresh: _loadPhotographers,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ───────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: kSurface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(height: 1,
                    color: Colors.black.withValues(alpha: 0.07)),
              ),
              title: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_camera,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text('Pixxgram',
                    style: TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.5)),
              ]),
              actions: [
                if (auth.isAuthenticated)
                  IconButton(
                    icon: const Icon(Icons.message_outlined, color: kPrimary),
                    onPressed: () => context.go('/dashboard/messages'),
                  ),
                if (!auth.isAuthenticated) ...[
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign in',
                        style: TextStyle(
                            color: kPrimary, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => context.go('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Get started'),
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (auth.isAdmin) {
                          context.go('/admin');
                        } else if (auth.isPhotographer) {
                          context.go('/dashboard');
                        } else {
                          context.go('/bookings');
                        }
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: kPrimary,
                        child: Text(
                          initials(auth.user?.name),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SliverToBoxAdapter(child: Column(children: [

              // ── Hero ────────────────────────────────────────────────
              Container(
                color: kPrimary,
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kSecondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('🇰🇪  Kenya\'s #1 Photography Platform',
                        style: TextStyle(color: Colors.white,
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w900,
                          color: Colors.white, letterSpacing: -1.5,
                          height: 1.1),
                      children: [
                        TextSpan(text: 'Find the perfect\n'),
                        TextSpan(text: 'photographer',
                            style: TextStyle(color: kSecondary)),
                        TextSpan(text: '\nfor every moment'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Browse hundreds of professional photographers across Kenya. '
                    'Book, message, and pay via M-Pesa — all in one place.',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // Search card
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 18, color: kPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _location.isEmpty ? null : _location,
                                hint: const Text('Location',
                                    style: TextStyle(fontSize: 14)),
                                isExpanded: true, isDense: true,
                                items: _locationItems.map((l) =>
                                    DropdownMenuItem(value: l,
                                        child: Text(l, style: const TextStyle(
                                            fontSize: 14)))).toList(),
                                onChanged: (v) =>
                                    setState(() => _location = v ?? ''),
                              ),
                            ),
                          ),
                          Container(width: 1, height: 28,
                              color: Colors.black.withValues(alpha: 0.1)),
                          const SizedBox(width: 8),
                          const Icon(Icons.tag, size: 18, color: kPrimary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _category.isEmpty ? null : _category,
                                hint: const Text('Category',
                                    style: TextStyle(fontSize: 14)),
                                isExpanded: true, isDense: true,
                                items: _categoryItems.map((c) =>
                                    DropdownMenuItem(value: c,
                                        child: Text(c, style: const TextStyle(
                                            fontSize: 14)))).toList(),
                                onChanged: (v) =>
                                    setState(() => _category = v ?? ''),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _goSearch,
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trending tags
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _trendingTags.map((tag) => GestureDetector(
                      onTap: () => setState(() => _category = tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tag,
                            style: TextStyle(fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7))),
                      ),
                    )).toList(),
                  ),
                ]),
              ),

              // ── Stats ────────────────────────────────────────────────
              Container(
                color: kSurface,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _stats.map((s) => Column(children: [
                    Text(s['value']!,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: kPrimary)),
                    const SizedBox(height: 2),
                    Text(s['label']!,
                        style: TextStyle(fontSize: 11,
                            color: Colors.black.withValues(alpha: 0.45))),
                  ])).toList(),
                ),
              ),
              Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),

              // ── Categories ───────────────────────────────────────────
              Container(
                color: kSurface,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Browse by Category',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final color = cat['color'] as Color;
                        return GestureDetector(
                          // go() is fine here — navigating to list screen
                          onTap: () => context.go(
                              '/photographers?category=${cat['label']}'),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: kSurface,
                              border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(cat['icon'] as IconData,
                                      color: color, size: 22),
                                ),
                                const SizedBox(height: 8),
                                Text(cat['label'] as String,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ]),
              ),

              // ── Featured Photographers ───────────────────────────────
              Container(
                color: kBackground,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SectionHeader(
                    title: 'Featured Photographers',
                    subtitle: 'Top-rated professionals across Kenya',
                    action: 'View all',
                    onAction: () => context.go('/photographers'),
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                      children: List.generate(4, (_) => const _SkeletonCard()),
                    )
                  else if (_errorMsg.isNotEmpty)
                    _ErrorState(message: _errorMsg, onRetry: _loadPhotographers)
                  else if (_photographers.isEmpty)
                    const EmptyState(
                      icon: Icons.camera_alt_outlined,
                      title: 'No photographers yet',
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: _photographers.length,
                      itemBuilder: (_, i) {
                        final id = _photographers[i]['id'];
                        return PhotographerCard(
                          photographer: _photographers[i],
                          // ← push so swipe-back returns to home
                          onTap: () => context.push('/photographers/$id'),
                        );
                      },
                    ),
                ]),
              ),

              // ── How it works ─────────────────────────────────────────
              Container(
                color: kBackground,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kSecondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Simple Process',
                        style: TextStyle(color: Colors.white,
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Book in 3 easy steps',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('From search to shoot in minutes',
                      style: TextStyle(fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.45)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  ..._steps.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                                color: kSecondary, shape: BoxShape.circle),
                            child: Center(child: Text(s['step'] as String,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13,
                                    fontWeight: FontWeight.w800))),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: kPrimary.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(s['icon'] as IconData,
                                size: 30, color: kPrimary),
                          ),
                        ]),
                        const SizedBox(width: 16),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['title'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(s['desc'] as String,
                                  style: TextStyle(fontSize: 13,
                                      color: Colors.black.withValues(
                                          alpha: 0.5),
                                      height: 1.5)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  )),
                ]),
              ),

              // ── Testimonials ─────────────────────────────────────────
              Container(
                color: kSurface,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: Column(children: [
                  const Text('What our users say',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Trusted by thousands across Kenya',
                      style: TextStyle(fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.45)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ..._testimonials.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.07)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: List.generate(5, (_) =>
                          const Icon(Icons.star, size: 14, color: kSecondary))),
                      const SizedBox(height: 10),
                      Text('"${t['quote']}"',
                          style: TextStyle(fontSize: 13,
                              color: Colors.black.withValues(alpha: 0.65),
                              height: 1.6)),
                      const SizedBox(height: 14),
                      Row(children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: kPrimary,
                          child: Text(
                            (t['name'] as String).substring(0, 1),
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(t['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(t['role'] as String,
                              style: TextStyle(fontSize: 11,
                                  color: Colors.black.withValues(alpha: 0.45))),
                        ]),
                      ]),
                    ]),
                  )),
                ]),
              ),

              // ── CTA ──────────────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimary, Color(0xFF2D1B69)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(children: [
                  const Text('Are you a photographer?',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.5),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(
                    'Join thousands of photographers earning on Pixxgram. '
                    'Set your rates, manage bookings, get paid via M-Pesa.',
                    style: TextStyle(fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: ElevatedButton.icon(
                      onPressed: () => context.go('/signup'),
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('Join as Photographer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      child: const Text('Learn More'),
                    )),
                  ]),
                ]),
              ),

              // ── Footer ───────────────────────────────────────────────
              Container(
                color: kPrimary,
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('Pixxgram',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w800, fontSize: 16)),
                  ]),
                  const SizedBox(height: 12),
                  Text(
                    "Kenya's premier photography marketplace. "
                    "Connect, book, and create.",
                    style: TextStyle(fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                        height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 12),
                  Text("© 2026 Pixxgram — Heinz Ateng'",
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.35))),
                ]),
              ),
            ])),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.07),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(height: 14, width: 120,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Container(height: 10, width: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4))),
          ]),
        ),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(Icons.wifi_off_outlined,
              size: 52, color: Colors.black.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          const Text('Could not load photographers',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(message,
              style: TextStyle(fontSize: 11,
                  color: Colors.black.withValues(alpha: 0.45)),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: Colors.white),
          ),
        ]),
      ),
    );
  }
}
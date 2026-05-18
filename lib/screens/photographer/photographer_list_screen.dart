// lib/screens/photographer/photographer_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class PhotographerListScreen extends StatefulWidget {
  final String? initialSearch;
  final String? initialCategory;
  final String? initialLocation;
  const PhotographerListScreen({
    super.key,
    this.initialSearch,
    this.initialCategory,
    this.initialLocation,
  });
  @override
  State<PhotographerListScreen> createState() => _PhotographerListScreenState();
}

class _PhotographerListScreenState extends State<PhotographerListScreen> {
  List<dynamic> _photographers = [];
  bool   _loading  = true;
  String _errorMsg = '';
  int    _total    = 0;
  int    _page     = 1;
  bool   _hasMore  = true;

  // Filters
  final _searchCtrl = TextEditingController();
  String _location   = '';
  String _category   = '';
  String _gender     = '';
  String _sortBy     = 'rating';
  RangeValues _priceRange = const RangeValues(0, 50000);
  double _minRating = 0;

  final _locations   = ['Nairobi','Mombasa','Kisumu','Nakuru','Eldoret','Thika','Machakos'];
  final _categories  = ['Wedding','Portrait','Events','Fashion','Corporate','Nature','Real Estate','Sports'];
  final _genders     = ['Male','Female','Non-binary'];
  final _sortOptions = [
    {'value':'rating',    'label':'Top Rated'},
    {'value':'newest',    'label':'Newest'},
    {'value':'price_asc', 'label':'Price: Low to High'},
    {'value':'price_desc','label':'Price: High to Low'},
  ];

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

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch   != null) _searchCtrl.text = widget.initialSearch!;
    if (widget.initialCategory != null) _category        = widget.initialCategory!;
    if (widget.initialLocation != null) _location        = widget.initialLocation!;
    _load();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Map<String, dynamic> get _filters => {
    if (_searchCtrl.text.isNotEmpty) 'search':    _searchCtrl.text,
    if (_location.isNotEmpty)        'location':  _location,
    if (_category.isNotEmpty)        'category':  _category,
    if (_gender.isNotEmpty)          'gender':    _gender,
    'min_price':  _priceRange.start.toInt(),
    'max_price':  _priceRange.end.toInt(),
    if (_minRating > 0) 'min_rating': _minRating,
    'sort_by':    _sortBy,
    'page':       _page,
    'per_page':   '12',
  };

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() { _page = 1; _loading = true; _errorMsg = ''; });
    }
    try {
      final data = await PhotographerService.getAll(filters: _filters);
      final list = data['photographers']?['data'] ??
                   data['photographers']          ??
                   data['data']                   ?? [];
      final meta = data['photographers']?['meta'] ?? data['meta'] ?? {};
      setState(() {
        if (reset) {
          _photographers = list;
        } else {
          _photographers.addAll(list);
        }
        _total   = meta['total'] ?? _photographers.length;
        _hasMore = (_photographers.length < _total);
        _loading = false;
      });
    } catch (e) {
      setState(() { _errorMsg = e.toString(); _loading = false; });
    }
  }

  void _loadMore() {
    if (!_hasMore || _loading) return;
    setState(() => _page++);
    _load(reset: false);
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _location   = '';
      _category   = '';
      _gender     = '';
      _minRating  = 0;
      _priceRange = const RangeValues(0, 50000);
      _sortBy     = 'rating';
    });
    _load();
  }

  bool get _hasActiveFilters =>
      _location.isNotEmpty || _category.isNotEmpty ||
      _gender.isNotEmpty   || _minRating > 0       ||
      _priceRange.start > 0 || _priceRange.end < 50000;

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, ctrl) => ListView(controller: ctrl, children: [
            Center(child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2)),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Filters', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  if (_hasActiveFilters)
                    TextButton(
                      onPressed: () { Navigator.pop(ctx); _clearFilters(); },
                      child: const Text('Clear all',
                          style: TextStyle(color: kAccent, fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 20),

                const Text('Location', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _locations.map((l) => _pxChip(
                    label: l, selected: _location == l,
                    onTap: () => setModal(() =>
                        _location = _location == l ? '' : l),
                  )).toList()),
                const SizedBox(height: 20),

                const Text('Category', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _categories.map((c) => _pxChip(
                    label: c, selected: _category == c,
                    onTap: () => setModal(() =>
                        _category = _category == c ? '' : c),
                  )).toList()),
                const SizedBox(height: 20),

                const Text('Gender', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _genders.map((g) => _pxChip(
                    label: g, selected: _gender == g,
                    onTap: () => setModal(() =>
                        _gender = _gender == g ? '' : g),
                  )).toList()),
                const SizedBox(height: 20),

                Text(
                  'Price: Ksh ${_priceRange.start.toInt()} '
                  '– Ksh ${_priceRange.end.toInt()} /hr',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                RangeSlider(
                  values: _priceRange,
                  min: 0, max: 50000, divisions: 100,
                  activeColor: kPrimary,
                  inactiveColor: Colors.black.withValues(alpha: 0.1),
                  onChanged: (v) => setModal(() => _priceRange = v),
                ),
                const SizedBox(height: 20),

                const Text('Minimum Rating', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(children: [0.0, 3.0, 4.0, 4.5].map((r) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _pxChip(
                    label: r == 0 ? 'Any' : '$r+★',
                    selected: _minRating == r,
                    onTap: () => setModal(() => _minRating = r),
                  ),
                )).toList()),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(ctx); _load(); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Browse Photographers'),
        // ← Use context.pop() so swipe-back and button both work
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Column(children: [
        // ── Search + filter bar ──────────────────────────────────────
        Container(
          color: kSurface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search photographers…',
                  hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.35), fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.black.withValues(alpha: 0.4), size: 18),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () { _searchCtrl.clear(); _load(); },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kPrimary),
                  ),
                  filled: true,
                  fillColor: kBackground,
                ),
                onSubmitted: (_) => _load(),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kBackground,
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _sortBy,
                  isDense: true,
                  icon: const Icon(Icons.sort, size: 16),
                  items: _sortOptions.map((o) => DropdownMenuItem(
                    value: o['value'],
                    child: Text(o['label']!,
                        style: const TextStyle(fontSize: 12)),
                  )).toList(),
                  onChanged: (v) { setState(() => _sortBy = v!); _load(); },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Badge(
              isLabelVisible: _hasActiveFilters,
              backgroundColor: kAccent,
              child: IconButton(
                icon: const Icon(Icons.tune),
                style: IconButton.styleFrom(
                  backgroundColor: _hasActiveFilters ? kPrimary : kBackground,
                  foregroundColor: _hasActiveFilters ? Colors.white : kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.12)),
                ),
                onPressed: _showFilters,
              ),
            ),
          ]),
        ),

        // Active filter chips
        if (_hasActiveFilters)
          Container(
            color: kSurface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                if (_location.isNotEmpty)
                  _FilterChip(label: _location,
                      onRemove: () { setState(() => _location = ''); _load(); }),
                if (_category.isNotEmpty)
                  _FilterChip(label: _category,
                      onRemove: () { setState(() => _category = ''); _load(); }),
                if (_gender.isNotEmpty)
                  _FilterChip(label: _gender,
                      onRemove: () { setState(() => _gender = ''); _load(); }),
                if (_minRating > 0)
                  _FilterChip(label: '$_minRating+★',
                      onRemove: () { setState(() => _minRating = 0); _load(); }),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear all',
                      style: TextStyle(fontSize: 12, color: kAccent)),
                ),
              ]),
            ),
          ),

        // Results count
        if (!_loading)
          Container(
            color: kBackground,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(children: [
              Text('$_total photographer${_total != 1 ? 's' : ''} found',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500)),
            ]),
          ),

        // ── Results ──────────────────────────────────────────────────
        Expanded(
          child: _loading && _photographers.isEmpty
              ? const LoadingWidget(message: 'Finding photographers…')
              : _errorMsg.isNotEmpty
                  ? Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_outlined,
                            size: 48, color: Colors.black.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        const Text('Something went wrong',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white),
                        ),
                      ],
                    ))
                  : _photographers.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off,
                          title: 'No photographers found',
                          subtitle: 'Try adjusting your filters',
                          actionLabel: 'Clear Filters',
                          onAction: _clearFilters,
                        )
                      : RefreshIndicator(
                          color: kPrimary,
                          onRefresh: _load,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.62,
                            ),
                            itemCount:
                                _photographers.length + (_hasMore ? 1 : 0),
                            itemBuilder: (ctx, i) {
                              if (i == _photographers.length) {
                                _loadMore();
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                      color: kPrimary, strokeWidth: 2),
                                ));
                              }
                              final id = _photographers[i]['id'];
                              return PhotographerCard(
                                photographer: _photographers[i],
                                // ← push so swipe-back returns to list
                                onTap: () => context.push(
                                    '/photographers/$id'),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: kPrimary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary)),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: onRemove,
        child: const Icon(Icons.close, size: 14, color: kPrimary),
      ),
    ]),
  );
}
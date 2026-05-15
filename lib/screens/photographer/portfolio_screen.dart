// lib/screens/photographer/portfolio_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';


class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});
  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  final _titleCtrl = TextEditingController();
  String _category = 'Portraits';

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _titleCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await PhotographerService.getDashboard();
      setState(() {
        _items = data['portfolio_analysis'] ?? [];
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _upload() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.image, allowMultiple: true);
    if (result == null || result.files.isEmpty || !mounted) return;

    showDialog(context: context, barrierDismissible: false,
        builder: (_) => const AlertDialog(content: Row(children: [
          CircularProgressIndicator(color: kCobalt),
          SizedBox(width: 16), Text('Uploading…')
        ])));

    try {
      final fd = FormData();
      fd.fields.add(MapEntry('title',
          _titleCtrl.text.isEmpty ? 'My Photo' : _titleCtrl.text));
      fd.fields.add(MapEntry('category', _category));
      for (final f in result.files) {
        if (f.path != null) {
          fd.files.add(MapEntry('images[]',
              await MultipartFile.fromFile(f.path!, filename: f.name)));
        }
      }
      await PhotographerService.uploadPortfolio(fd);
      if (mounted) {
        Navigator.pop(context);
        _load();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploaded! ✓'),
                backgroundColor: Colors.green));
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload failed'),
                backgroundColor: Colors.red));
      }
    }
  }

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Upload Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kNavy)),
          const SizedBox(height: 16),
          PxTextField(label: 'Title', controller: _titleCtrl),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(labelText: 'Category', filled: true,
                fillColor: const Color(0xFFF0F6FB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: ['Portraits','Weddings','Events','Wildlife','Commercial','Fashion','Other']
                .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 16),
          PxButton(
            label: 'Select & Upload Photos',
            icon: Icons.upload,
            onTap: () { Navigator.pop(ctx); _upload(); },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('My Portfolio'),
      actions: [
        IconButton(icon: const Icon(Icons.add_photo_alternate),
            onPressed: _showUploadSheet),
      ],
    ),
    body: _loading
        ? const LoadingWidget()
        : _items.isEmpty
            ? EmptyState(
                icon: Icons.image_not_supported,
                title: 'No photos yet',
                subtitle: 'Upload your first photo to attract clients',
                actionLabel: 'Upload Photos',
                onAction: _showUploadSheet,
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  return Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item['image_url'] != null
                          ? CachedNetworkImage(
                              imageUrl: item['image_url'],
                              fit: BoxFit.cover,
                              width: double.infinity, height: double.infinity,
                              errorWidget: (_, __, ___) => Container(
                                  color: const Color(0xFFE2E8F0),
                                  child: const Icon(Icons.image, color: kSlate)))
                          : Container(color: const Color(0xFFE2E8F0),
                              child: const Icon(Icons.image, color: kSlate, size: 40)),
                    ),
                    Positioned(bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.visibility, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('${item['views'] ?? 0}',
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                          const SizedBox(width: 10),
                          const Icon(Icons.bookmark_border, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('${item['saves'] ?? 0}',
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ]),
                      ),
                    ),
                    Positioned(top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () async {
                          if (item['id'] != null) {
                            await PhotographerService.deletePortfolioItem(item['id']);
                            _load();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.delete, size: 14, color: Colors.white),
                        ),
                      )),
                  ]);
                }),
    floatingActionButton: FloatingActionButton(
      backgroundColor: kCobalt,
      onPressed: _showUploadSheet,
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}
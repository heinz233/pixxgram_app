class Portfolio {
  final int id;
  final int photographerId;
  final String title;
  final String? description;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? category;
  final List<String> tags;
  final int views;
  final int saves;
  final int inquiries;
 
  Portfolio({
    required this.id,
    required this.photographerId,
    required this.title,
    this.description,
    required this.imageUrl,
    this.thumbnailUrl,
    this.category,
    this.tags = const [],
    this.views = 0,
    this.saves = 0,
    this.inquiries = 0,
  });
 
  factory Portfolio.fromJson(Map<String, dynamic> j) => Portfolio(
    id:             j['id'],
    photographerId: j['photographer_id'],
    title:          j['title'] ?? '',
    description:    j['description'],
    imageUrl:       j['image_url'] ?? '',
    thumbnailUrl:   j['thumbnail_url'],
    category:       j['category'],
    tags:           j['tags'] != null ? List<String>.from(j['tags']) : [],
    views:          j['views'] ?? 0,
    saves:          j['saves'] ?? 0,
    inquiries:      j['inquiries'] ?? 0,
  );
}
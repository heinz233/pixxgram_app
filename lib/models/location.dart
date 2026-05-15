// lib/models/location.dart

class Location {
  final int id;
  final String name;
  final String? region;
  final String? county;
  final int photographerCount;

  Location({
    required this.id,
    required this.name,
    this.region,
    this.county,
    this.photographerCount = 0,
  });

  factory Location.fromJson(Map<String, dynamic> j) => Location(
        id:                 j['id'] is String ? int.parse(j['id']) : j['id'],
        name:               j['name'] ?? '',
        region:             j['region'],
        county:             j['county'],
        photographerCount:  j['photographer_count'] ?? 0,
      );
}
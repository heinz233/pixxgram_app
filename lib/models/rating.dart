class Rating {
  final int id;
  final int photographerId;
  final int clientId;
  final int stars;
  final String? comment;
  final String createdAt;
  final String? clientName;
 
  Rating({
    required this.id,
    required this.photographerId,
    required this.clientId,
    required this.stars,
    this.comment,
    required this.createdAt,
    this.clientName,
  });
 
  factory Rating.fromJson(Map<String, dynamic> j) => Rating(
    id:             j['id'] ?? 0,
    photographerId: j['photographer_id'] ?? 0,
    clientId:       j['client_id'] ?? 0,
    stars:          j['stars'] ?? j['rating'] ?? 0,
    comment:        j['comment'],
    createdAt:      j['created_at'] ?? '',
    clientName:     j['client_name'] ?? j['client']?['name'],
  );
}
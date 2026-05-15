// lib/models/photographer_profile.dart

class PhotographerProfile {
  final int     id;
  final int     userId;
  final String? bio;
  final String? location;
  final String? gender;
  final int?    age;
  final String? speciality;
  final double? hourlyRate;
  final String? profilePhoto;
  final double? averageRating;
  final int?    totalRatings;
  final String? subscriptionStatus;
  final String? subscriptionEndDate;
  final bool    isVerified;
  final Map<String, dynamic>? serviceRates;
  final int?    totalViews;
  final int?    totalSaves;
  final int?    totalInquiries;
  final int?    profileCompletion;

  const PhotographerProfile({
    required this.id,
    required this.userId,
    this.bio,
    this.location,
    this.gender,
    this.age,
    this.speciality,
    this.hourlyRate,
    this.profilePhoto,
    this.averageRating,
    this.totalRatings,
    this.subscriptionStatus,
    this.subscriptionEndDate,
    this.isVerified = false,
    this.serviceRates,
    this.totalViews,
    this.totalSaves,
    this.totalInquiries,
    this.profileCompletion,
  });

  // ── Status helpers ────────────────────────────────────────────────────────
  bool get isSubscriptionActive  => subscriptionStatus == 'active';
  bool get isSubscriptionExpired => subscriptionStatus == 'expired';
  bool get isSubscriptionPending => subscriptionStatus == 'pending';

  // ── Days remaining on subscription ───────────────────────────────────────
  int get daysRemaining {
    if (subscriptionEndDate == null) return 0;
    final end = DateTime.tryParse(subscriptionEndDate!);
    if (end == null) return 0;
    final diff = end.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isSubscriptionExpiringSoon => [1, 2, 3, 4, 5].contains(daysRemaining);

  // ── Rating display ────────────────────────────────────────────────────────
  String get ratingDisplay =>
      averageRating != null ? averageRating!.toStringAsFixed(1) : '—';

  // ── Rate display ──────────────────────────────────────────────────────────
  String get rateDisplay =>
      hourlyRate != null ? 'KSh ${hourlyRate!.toStringAsFixed(0)}/hr' : '—';

  // ── Profile photo URL ─────────────────────────────────────────────────────
  String? get photoUrl {
    if (profilePhoto == null || profilePhoto!.isEmpty) return null;
    if (profilePhoto!.startsWith('http')) return profilePhoto;
    if (profilePhoto!.startsWith('/storage/')) {
      return 'http://192.168.3.107:8000$profilePhoto';
    }
    return 'http://192.168.3.107:8000/storage/$profilePhoto';
  }

  // ── Serialisation ─────────────────────────────────────────────────────────
  factory PhotographerProfile.fromJson(Map<String, dynamic> j) =>
      PhotographerProfile(
        id:                  j['id'] ?? 0,
        userId:              j['user_id'] ?? 0,
        bio:                 j['bio'],
        location:            j['location'],
        gender:              j['gender'],
        age:                 j['age'],
        speciality:          j['speciality'],
        hourlyRate:          j['hourly_rate'] != null
                                 ? double.tryParse(j['hourly_rate'].toString())
                                 : null,
        profilePhoto:        j['profile_photo'],
        averageRating:       j['average_rating'] != null
                                 ? double.tryParse(j['average_rating'].toString())
                                 : null,
        totalRatings:        j['total_ratings'],
        subscriptionStatus:  j['subscription_status'],
        subscriptionEndDate: j['subscription_end_date'],
        isVerified:          j['is_verified'] == true || j['is_verified'] == 1,
        serviceRates:        j['service_rates'] is Map
                                 ? Map<String, dynamic>.from(j['service_rates'])
                                 : null,
        totalViews:          j['total_views'],
        totalSaves:          j['total_saves'],
        totalInquiries:      j['total_inquiries'],
        profileCompletion:   j['profile_completion'],
      );

  Map<String, dynamic> toJson() => {
        'id':                   id,
        'user_id':              userId,
        'bio':                  bio,
        'location':             location,
        'gender':               gender,
        'age':                  age,
        'speciality':           speciality,
        'hourly_rate':          hourlyRate,
        'profile_photo':        profilePhoto,
        'average_rating':       averageRating,
        'total_ratings':        totalRatings,
        'subscription_status':  subscriptionStatus,
        'subscription_end_date':subscriptionEndDate,
        'is_verified':          isVerified,
        'service_rates':        serviceRates,
      };

  PhotographerProfile copyWith({
    String? bio,
    String? location,
    String? gender,
    int?    age,
    String? speciality,
    double? hourlyRate,
    String? profilePhoto,
    Map<String, dynamic>? serviceRates,
  }) =>
      PhotographerProfile(
        id:                  id,
        userId:              userId,
        bio:                 bio                ?? this.bio,
        location:            location           ?? this.location,
        gender:              gender             ?? this.gender,
        age:                 age                ?? this.age,
        speciality:          speciality         ?? this.speciality,
        hourlyRate:          hourlyRate         ?? this.hourlyRate,
        profilePhoto:        profilePhoto       ?? this.profilePhoto,
        averageRating:       averageRating,
        totalRatings:        totalRatings,
        subscriptionStatus:  subscriptionStatus,
        subscriptionEndDate: subscriptionEndDate,
        isVerified:          isVerified,
        serviceRates:        serviceRates       ?? this.serviceRates,
        totalViews:          totalViews,
        totalSaves:          totalSaves,
        totalInquiries:      totalInquiries,
        profileCompletion:   profileCompletion,
      );
}
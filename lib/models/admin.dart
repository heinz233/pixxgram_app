// lib/models/admin.dart

import 'user.dart';
import 'booking.dart';
import 'subscription.dart';

class Admin {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
  });

  factory Admin.fromJson(Map<String, dynamic> j) => Admin(
        id:       j['id'] is String ? int.parse(j['id']) : j['id'],
        name:     j['name'] ?? '',
        email:    j['email'] ?? '',
        phone:    j['phone'] ?? j['phoneNumber'],
        isActive: j['is_active'] == true || j['is_active'] == 1,
      );
}

// ── Admin: full photographer entry as seen from admin panel ──────────────────
class AdminPhotographer {
  final User user;
  final String? speciality;
  final String? location;
  final String? subscriptionStatus;
  final double? hourlyRate;
  final double? averageRating;
  final bool isVerified;
  final int totalBookings;

  AdminPhotographer({
    required this.user,
    this.speciality,
    this.location,
    this.subscriptionStatus,
    this.hourlyRate,
    this.averageRating,
    this.isVerified = false,
    this.totalBookings = 0,
  });

  factory AdminPhotographer.fromJson(Map<String, dynamic> j) {
    final profile = j['photographer_profile'] as Map<String, dynamic>? ?? {};
    return AdminPhotographer(
      user:               User.fromJson(j),
      speciality:         profile['speciality'],
      location:           profile['location'],
      subscriptionStatus: profile['subscription_status'],
      hourlyRate:         profile['hourly_rate'] != null
          ? double.tryParse(profile['hourly_rate'].toString())
          : null,
      averageRating:      profile['average_rating'] != null
          ? double.tryParse(profile['average_rating'].toString())
          : null,
      isVerified:   profile['is_verified'] == true || profile['is_verified'] == 1,
      totalBookings: j['total_bookings'] ?? 0,
    );
  }
}

// ── Admin: booking list entry ─────────────────────────────────────────────────
// Wraps Booking instead of extending it to avoid getter override conflicts.
class AdminBooking {
  final Booking booking;
  final String? clientName;
  final String? photographerName;

  AdminBooking({
    required this.booking,
    this.clientName,
    this.photographerName,
  });

  // Convenience pass-throughs
  int    get id            => booking.id;
  String get status        => booking.status;
  String get bookingDate   => booking.bookingDate;
  String get formattedDate => booking.formattedDate;
  bool   get isPending     => booking.isPending;
  bool   get isConfirmed   => booking.isConfirmed;

  // Admin-aware name getters
  String get resolvedClientName =>
      clientName ?? booking.client?.name ?? 'Client';
  String get resolvedPhotographerName =>
      photographerName ?? booking.photographer?.name ?? 'Photographer';

  factory AdminBooking.fromJson(Map<String, dynamic> j) => AdminBooking(
        booking:          Booking.fromJson(j),
        clientName:       j['client']?['name'],
        photographerName: j['photographer']?['name'],
      );
}

// ── Admin: subscription list entry ────────────────────────────────────────────
class AdminSubscription extends Subscription {
  final String? photographerName;
  final String? photographerEmail;

  AdminSubscription({
    required super.id,
    required super.photographerId,
    required super.plan,
    required super.amount,
    required super.status,
    super.paymentMethod,
    super.startsAt,
    super.endsAt,
    this.photographerName,
    this.photographerEmail,
  });

  factory AdminSubscription.fromJson(Map<String, dynamic> j) {
    final base = Subscription.fromJson(j);
    return AdminSubscription(
      id:                base.id,
      photographerId:    base.photographerId,
      plan:              base.plan,
      amount:            base.amount,
      status:            base.status,
      paymentMethod:     base.paymentMethod,
      startsAt:          base.startsAt,
      endsAt:            base.endsAt,
      photographerName:  j['photographer']?['name'],
      photographerEmail: j['photographer']?['email'],
    );
  }
}
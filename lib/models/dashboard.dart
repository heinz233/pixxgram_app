// lib/models/dashboard.dart

// ── Photographer dashboard stats ──────────────────────────────────────────────
class PhotographerDashboard {
  final int totalBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int completedBookings;
  final double totalEarnings;
  final double averageRating;
  final int totalRatings;
  final int portfolioCount;
  final String? subscriptionStatus;
  final String? subscriptionEndsAt;

  PhotographerDashboard({
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.confirmedBookings = 0,
    this.completedBookings = 0,
    this.totalEarnings = 0,
    this.averageRating = 0,
    this.totalRatings = 0,
    this.portfolioCount = 0,
    this.subscriptionStatus,
    this.subscriptionEndsAt,
  });

  factory PhotographerDashboard.fromJson(Map<String, dynamic> j) =>
      PhotographerDashboard(
        totalBookings:      j['total_bookings'] ?? 0,
        pendingBookings:    j['pending_bookings'] ?? 0,
        confirmedBookings:  j['confirmed_bookings'] ?? 0,
        completedBookings:  j['completed_bookings'] ?? 0,
        totalEarnings:      double.tryParse(
                                j['total_earnings']?.toString() ?? '0') ?? 0,
        averageRating:      double.tryParse(
                                j['average_rating']?.toString() ?? '0') ?? 0,
        totalRatings:       j['total_ratings'] ?? 0,
        portfolioCount:     j['portfolio_count'] ?? 0,
        subscriptionStatus: j['subscription_status'],
        subscriptionEndsAt: j['subscription_ends_at'],
      );
}

// ── Admin dashboard stats ─────────────────────────────────────────────────────
class AdminDashboard {
  final int totalUsers;
  final int totalPhotographers;
  final int totalClients;
  final int totalBookings;
  final int pendingBookings;
  final double totalRevenue;
  final int activeSubscriptions;
  final int openReports;
  final List<RevenuePoint> revenueChart;
  final List<BookingPoint> bookingsChart;

  AdminDashboard({
    this.totalUsers = 0,
    this.totalPhotographers = 0,
    this.totalClients = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.totalRevenue = 0,
    this.activeSubscriptions = 0,
    this.openReports = 0,
    this.revenueChart = const [],
    this.bookingsChart = const [],
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> j) => AdminDashboard(
        totalUsers:          j['total_users'] ?? 0,
        totalPhotographers:  j['total_photographers'] ?? 0,
        totalClients:        j['total_clients'] ?? 0,
        totalBookings:       j['total_bookings'] ?? 0,
        pendingBookings:     j['pending_bookings'] ?? 0,
        totalRevenue:        double.tryParse(
                                 j['total_revenue']?.toString() ?? '0') ?? 0,
        activeSubscriptions: j['active_subscriptions'] ?? 0,
        openReports:         j['open_reports'] ?? 0,
        revenueChart:        (j['revenue_chart'] as List? ?? [])
                                 .map((e) => RevenuePoint.fromJson(e))
                                 .toList(),
        bookingsChart:       (j['bookings_chart'] as List? ?? [])
                                 .map((e) => BookingPoint.fromJson(e))
                                 .toList(),
      );
}

// ── Chart data points ─────────────────────────────────────────────────────────
class RevenuePoint {
  final String label; // e.g. "Jan", "Feb"
  final double amount;

  RevenuePoint({required this.label, required this.amount});

  factory RevenuePoint.fromJson(Map<String, dynamic> j) => RevenuePoint(
        label:  j['label'] ?? j['month'] ?? '',
        amount: double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
      );
}

class BookingPoint {
  final String label;
  final int count;

  BookingPoint({required this.label, required this.count});

  factory BookingPoint.fromJson(Map<String, dynamic> j) => BookingPoint(
        label: j['label'] ?? j['month'] ?? '',
        count: j['count'] ?? 0,
      );
}
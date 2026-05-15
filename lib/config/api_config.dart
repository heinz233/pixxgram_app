// lib/config/api_config.dart

class ApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────
  static const String baseUrl = 'http://192.168.100.8:8000/api';

  // ── Auth ───────────────────────────────────────────────────────────
  static const String login    = '/login';
  static const String register = '/register';
  static const String logout   = '/logout';
  static const String user     = '/user';

  // ── Photographers (public) ─────────────────────────────────────────
  static const String photographers = '/photographers';
  // GET  /photographers           → list (filters: location, gender, min_price, max_price, min_rating)
  // GET  /photographers/{id}      → single photographer with portfolio + ratings

  // ── Photographer (authenticated) ──────────────────────────────────
  static const String dashboard = '/photographer/dashboard';
  static const String profile   = '/photographer/profile';
  static const String portfolio = '/photographer/portfolio';
  // GET  /photographer/dashboard  → stats
  // PUT|POST /photographer/profile → update profile (multipart ok)
  // POST /photographer/portfolio  → upload images
  // GET  /photographer/portfolio  → own portfolio
  // DELETE /photographer/portfolio/{id} → delete item

  // ── Bookings ───────────────────────────────────────────────────────
  static const String bookings = '/bookings';
  // POST  /bookings                     → create (photographer_id, booking_date, notes)
  // GET   /bookings                     → my bookings (role-aware: client/photographer/admin)
  // GET   /bookings/{id}                → single booking
  // PATCH /bookings/{id}/status         → update status (pending|confirmed|completed|cancelled)
  // POST  /bookings/{id}/pay            → initiate M-Pesa STK push (phone, amount)
  // GET   /bookings/{id}/payment-status → poll payment + payout status

  // ── Payments ───────────────────────────────────────────────────────
  static const String payments         = '/payments';
  static const String paymentsInitiate = '/payments/initiate';

  // ── Messages ───────────────────────────────────────────────────────
  static const String conversations = '/messages/conversations';
  static const String sendMessage   = '/messages/send';
  static const String unreadCount   = '/messages/unread';
  // GET    /messages/conversations          → all conversations
  // GET    /messages/conversations/{userId} → chat with specific user
  // POST   /messages/send                   → send (receiver_id, message)
  // GET    /messages/unread                 → unread count
  // PATCH  /messages/{id}/read              → mark as read
  // DELETE /messages/{id}                   → delete

  // ── Ratings ────────────────────────────────────────────────────────
  // POST /photographers/{id}/rate     → submit (stars, comment)
  // GET  /photographers/{id}/ratings  → list ratings

  // ── Reports ────────────────────────────────────────────────────────
  // POST /photographers/{id}/report   → submit (reason, description)
  // Valid reasons: inappropriate_behavior | scam_or_fraud | no_show |
  //                poor_quality | harassment | fake_profile | other
  static const String myReports = '/my-reports';

  // ── Subscriptions ──────────────────────────────────────────────────
  static const String subscriptions         = '/subscriptions';
  static const String subscriptionPlans     = '/subscriptions/plans';
  static const String subscriptionCurrent   = '/subscriptions/current';
  static const String subscriptionHistory   = '/subscriptions/history';
  static const String subscriptionSubscribe = '/subscriptions/subscribe';
  // POST /subscriptions/subscribe        → (plan, payment_method, phone?)
  // POST /subscriptions/{id}/cancel      → cancel
  // GET  /subscriptions/mpesa/status/{checkoutRequestId} → poll status

  // ── Categories & Locations (public) ───────────────────────────────
  static const String categories = '/categories';
  static const String locations  = '/locations';

  // ── Admin ──────────────────────────────────────────────────────────
  static const String adminDashboard     = '/admin/dashboard';
  static const String adminPhotographers = '/admin/photographers';
  static const String adminUsers         = '/admin/users';
  static const String adminReports       = '/admin/reports';
  static const String adminRatings       = '/admin/ratings';
  static const String adminSubscriptions = '/admin/subscriptions';
  static const String adminBookings      = '/admin/bookings';
  static const String adminCategories    = '/admin/categories';
  static const String adminLocations     = '/admin/locations';
}

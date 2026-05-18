// lib/config/routes.dart

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/photographer/photographer_list_screen.dart';
import '../screens/photographer/photographer_profile_screen.dart';
import '../screens/photographer/dashboard_screen.dart';
import '../screens/photographer/portfolio_screen.dart';
import '../screens/photographer/subscription_screen.dart';
import '../screens/photographer/bookings_screen.dart';
import '../screens/photographer/messages_screen.dart';
import '../screens/photographer/edit_profile_screen.dart';
import '../screens/client/client_bookings_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_photographers_screen.dart';
import '../screens/admin/admin_locations_screen.dart';
import '../screens/admin/admin_reports_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth        = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn  = auth.isAuthenticated;
      final loc         = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/signup' || loc == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && loc == '/login') {
        if (auth.isAdmin)        return '/admin';
        if (auth.isPhotographer) return '/dashboard';
        return '/home';
      }
      return null;
    },
    routes: [
      // ── Auth & shared ──────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login',  builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(path: '/home',   builder: (c, s) => const HomeScreen()),

      // ── Public photographer browsing ───────────────────────────────
      // Uses push-style page so swipe-back works from profile → list
      GoRoute(
        path: '/photographers',
        pageBuilder: (c, s) => MaterialPage(
          key: s.pageKey,
          child: PhotographerListScreen(
            initialSearch:   s.uri.queryParameters['search'],
            initialCategory: s.uri.queryParameters['category'],
            initialLocation: s.uri.queryParameters['location'],
          ),
        ),
        routes: [
          // Nested so /photographers/:id is a child — enables swipe back
          GoRoute(
            path: ':id',
            pageBuilder: (c, s) {
              final raw = s.pathParameters['id'] ?? '0';
              final id  = int.tryParse(raw) ?? 0;
              return MaterialPage(
                key: s.pageKey,
                child: PhotographerProfileScreen(id: id),
              );
            },
          ),
        ],
      ),

      // ── Photographer dashboard ─────────────────────────────────────
      // Dashboard tabs use go() so no back stack between them
      GoRoute(path: '/dashboard',
          builder: (c, s) => const DashboardScreen()),

      // Sub-pages use pageBuilder so swipe-back returns to dashboard
      GoRoute(
        path: '/dashboard/portfolio',
        pageBuilder: (c, s) => const MaterialPage(child: PortfolioScreen()),
      ),
      GoRoute(
        path: '/dashboard/subscription',
        pageBuilder: (c, s) =>
            const MaterialPage(child: SubscriptionScreen()),
      ),
      GoRoute(
        path: '/dashboard/bookings',
        pageBuilder: (c, s) =>
            const MaterialPage(child: PhotographerBookingsScreen()),
      ),
      GoRoute(
        path: '/dashboard/messages',
        pageBuilder: (c, s) =>
            const MaterialPage(child: MessagesScreen()),
      ),
      GoRoute(
        path: '/dashboard/profile',
        pageBuilder: (c, s) =>
            const MaterialPage(child: EditProfileScreen()),
      ),

      // ── Client ─────────────────────────────────────────────────────
      GoRoute(
        path: '/bookings',
        pageBuilder: (c, s) =>
            const MaterialPage(child: ClientBookingsScreen()),
      ),

      // ── Admin ──────────────────────────────────────────────────────
      GoRoute(path: '/admin',
          builder: (c, s) => const AdminDashboardScreen()),
      GoRoute(
        path: '/admin/photographers',
        pageBuilder: (c, s) =>
            const MaterialPage(child: AdminPhotographersScreen()),
      ),
      GoRoute(
        path: '/admin/reports',
        pageBuilder: (c, s) =>
            const MaterialPage(child: AdminReportsScreen()),
      ),
      GoRoute(
        path: '/admin/locations',
        pageBuilder: (c, s) =>
            const MaterialPage(child: AdminLocationsScreen()),
      ),
    ],
  );
}
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
      final auth       = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = auth.isAuthenticated;
      final loc        = state.matchedLocation;
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
      // ── Auth & shared ──────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login',  builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(path: '/home',   builder: (c, s) => const HomeScreen()),

      // ── Public photographer browsing ───────────────────────────────────
      GoRoute(
        path: '/photographers',
        builder: (c, s) => PhotographerListScreen(
          initialSearch:   s.uri.queryParameters['search'],
          initialCategory: s.uri.queryParameters['category'],
          initialLocation: s.uri.queryParameters['location'],
        ),
      ),
      GoRoute(
        path: '/photographers/:id',
        builder: (c, s) {
          // Fix: parse String path param to int safely
          final raw = s.pathParameters['id'] ?? '0';
          final id  = int.tryParse(raw) ?? 0;
          return PhotographerProfileScreen(id: id);
        },
      ),

      // ── Photographer dashboard ─────────────────────────────────────────
      GoRoute(path: '/dashboard',
          builder: (c, s) => const DashboardScreen()),
      GoRoute(path: '/dashboard/portfolio',
          builder: (c, s) => const PortfolioScreen()),
      GoRoute(path: '/dashboard/subscription',
          builder: (c, s) => const SubscriptionScreen()),
      GoRoute(path: '/dashboard/bookings',
          builder: (c, s) => const PhotographerBookingsScreen()),
      GoRoute(path: '/dashboard/messages',
          builder: (c, s) => const MessagesScreen()),
      GoRoute(path: '/dashboard/profile',
          builder: (c, s) => const EditProfileScreen()),

      // ── Client ─────────────────────────────────────────────────────────
      GoRoute(path: '/bookings',
          builder: (c, s) => const ClientBookingsScreen()),

      // ── Admin ──────────────────────────────────────────────────────────
      GoRoute(path: '/admin',
          builder: (c, s) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/photographers',
          builder: (c, s) => const AdminPhotographersScreen()),
      GoRoute(path: '/admin/reports',
          builder: (c, s) => const AdminReportsScreen()),
      GoRoute(path: '/admin/locations',
          builder: (c, s) => const AdminLocationsScreen()),
    ],
  );
}
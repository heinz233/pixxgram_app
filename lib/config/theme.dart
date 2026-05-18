// lib/config/theme.dart
// Matches the Vuetify pixxgramLight / pixxgramDark themes exactly

import 'package:flutter/material.dart';
export 'package:flutter/material.dart' show Colors;

// ── Light theme colors (pixxgramLight) ────────────────────────────────────────
const kPrimary    = Color(0xFF1A1A2E);
const kSecondary  = Color(0xFFC9A84C);
const kAccent     = Color(0xFFE8623A);
const kBackground = Color(0xFFF7F5F2);
const kSurface    = Color(0xFFFFFFFF);
const kError      = Color(0xFFD32F2F);
const kSuccess    = Color(0xFF2E7D32);
const kWarning    = Color(0xFFF57C00);

// ── Dark theme colors (pixxgramDark) ─────────────────────────────────────────
const kDarkBackground = Color(0xFF0D0D1A);
const kDarkSurface    = Color(0xFF16213E);
const kDarkPrimary    = Color(0xFFC9A84C);
const kDarkSecondary  = Color(0xFFE8623A);

// ── Utility ───────────────────────────────────────────────────────────────────
const kBorder    = Color(0x12000000);
const kTextMuted = Color(0x73000000);

ThemeData pixxgramLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: kBackground,

    // ── Enables iOS-style swipe-back on Android too ──────────────────
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
      },
    ),

    colorScheme: const ColorScheme.light(
      primary:   kPrimary,
      secondary: kSecondary,
      tertiary:  kAccent,
      surface:   kSurface,
      error:     kError,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorder),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: kPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: kPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(
            fontWeight: FontWeight.w600, letterSpacing: 0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: const BorderSide(color: kPrimary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: kBorder),
    ),
    dividerTheme: const DividerThemeData(
        color: kBorder, thickness: 1, space: 0),
  );
}

ThemeData pixxgramDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kDarkBackground,

    // ── Enables iOS-style swipe-back on Android too ──────────────────
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
      },
    ),

    colorScheme: const ColorScheme.dark(
      primary:   kDarkPrimary,
      secondary: kDarkSecondary,
      surface:   kDarkSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: kDarkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
  );
}
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/photographer_provider.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.init(); // registers token interceptor before any request
  runApp(const PixxgramApp());
}

class PixxgramApp extends StatefulWidget {
  const PixxgramApp({super.key});

  @override
  State<PixxgramApp> createState() => _PixxgramAppState();
}

class _PixxgramAppState extends State<PixxgramApp> {
  bool _isDark = false;

  void toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PhotographerProvider()),
      ],
      child: MaterialApp.router(
        title: 'Pixxgram',
        debugShowCheckedModeBanner: false,
        theme: pixxgramLight().copyWith(
          textTheme:
              GoogleFonts.interTextTheme(pixxgramLight().textTheme),
        ),
        darkTheme: pixxgramDark().copyWith(
          textTheme:
              GoogleFonts.interTextTheme(pixxgramDark().textTheme),
        ),
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
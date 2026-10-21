import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primary = Color(0xFF4169F8);
  static const ink = Color(0xFF102A43);
  static const muted = Color(0xFF718096);
  static const surface = Color(0xFFF7F9FC);
  static const paleBlue = Color(0xFFEAF2FF);
  static const success = Color(0xFF39B979);
  static const danger = Color(0xFFFF6675);
  static const radiusLarge = 18.0;
  static const radiusMedium = 14.0;

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: ink, elevation: 0, surfaceTintColor: Colors.transparent),
    navigationBarTheme: const NavigationBarThemeData(height: 72, backgroundColor: Colors.white, indicatorColor: paleBlue, labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: ink),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
      bodyMedium: TextStyle(color: muted, height: 1.35),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primary, width: 1.5)),
    ),
    cardTheme: CardThemeData(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
  );
}

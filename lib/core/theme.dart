import 'package:flutter/material.dart';

/// Foodie brand colours (from 00_Brand_Design_System).
class C {
  static const orange = Color(0xFFFF653D);
  static const ink = Color(0xFF211F1E);
  static const cream = Color(0xFFFFF8F3);
  static const peach = Color(0xFFFFB69D);
  static const green = Color(0xFF20A66A);
  static const navy = Color(0xFF222B3A);
  static const muted = Color(0xFF8B8581);
  static const faint = Color(0xFFAAA29D);
  static const line = Color(0xFFF0E8E2);
  static const tint = Color(0xFFFFE5D8);
  static const tint2 = Color(0xFFFFD3C1);
  static const red = Color(0xFFE5484D);
  static const amber = Color(0xFFF5A524);

  static const hero = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF9A70), Color(0xFFF34F2F)]);
  static const dark = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF303A4A), Color(0xFF18202D)]);
  static const green2 = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3CCB8A), Color(0xFF16915B)]);
}

const softShadow = [BoxShadow(color: Color(0x1433231B), blurRadius: 24, offset: Offset(0, 8))];

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: C.orange, primary: C.orange, surface: C.cream, brightness: Brightness.light);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.cream,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: ThemeData.light().textTheme.apply(bodyColor: C.ink, displayColor: C.ink),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.orange : const Color(0xFFD9D2CC)),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}

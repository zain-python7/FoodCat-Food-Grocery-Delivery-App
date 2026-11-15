import 'package:flutter/material.dart';

/// Single source of truth for FoodCat's visual palette.
class FoodCatColors {
  FoodCatColors._();
  static const primary = Color(0xFFE21B70);
  static const dark = Color(0xFF29232D);
  static const muted = Color(0xFF817783);
  static const background = Color(0xFFFFF8FB);
  static const palePink = Color(0xFFFFE5F0);
}

/// Backwards-compatible alias for older files that still use FoodieColors.
/// New code should use FoodCatColors.
class FoodieColors {
  FoodieColors._();
  static const primary = FoodCatColors.primary;
  static const dark = FoodCatColors.dark;
  static const muted = FoodCatColors.muted;
  static const background = FoodCatColors.background;
}

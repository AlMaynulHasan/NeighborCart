import 'package:flutter/material.dart';

/// Central color palette extracted from the NeighborCart Figma export.
/// Keep all raw color values here — screens/widgets should never use
/// Color(0x...) literals directly.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF22A45D); // main green (buttons, active states)
  static const Color primaryDark = Color(0xFF1B8A4C);
  static const Color primarySoft = Color(0xFFDFF3E6); // light green chip/badge background

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF3F5F1); // app background
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1E2A32); // near-black headings
  static const Color textSecondary = Color(0xFF6B7680); // gray subtext
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Accents
  static const Color warning = Color(0xFFE8792B); // "Closes Thu 8 PM", pending badges
  static const Color warningSoft = Color(0xFFFBEADB);
  static const Color success = primary;
  static const Color successSoft = primarySoft;

  // Borders / dividers
  static const Color border = Color(0xFFE6E8E3);
  static const Color divider = Color(0xFFE6E8E3);

  // Misc
  static const Color shadow = Color(0x14000000);
}

import 'package:flutter/material.dart';

/// Curated color palette for the Class Routine Notifier app.
///
/// ## Flutter Learning Note:
/// Centralizing colors in one file ensures consistency across the entire app.
/// Instead of using raw hex values in widgets, always reference these constants.
/// This makes it trivial to rebrand or add theme variants later.
class AppColors {
  AppColors._(); // Prevent instantiation

  // --- Background & Surface (Dark Theme) ---
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariantDark = Color(0xFF252542);
  static const Color cardDark = Color(0xFF16213E);

  // --- Background & Surface (Light Theme) ---
  static const Color backgroundLight = Color(0xFFF8F9FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F2F8);
  static const Color cardLight = Color(0xFFFFFFFF);

  // --- Primary & Accent ---
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryVariant = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentLight = Color(0xFF5DFFD0);

  // --- Semantic Colors ---
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFFF5252);
  static const Color info = Color(0xFF42A5F5);

  // --- Text ---
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFFB0B0C0);
  static const Color textTertiaryDark = Color(0xFF7A7A95);

  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF5A5A72);
  static const Color textTertiaryLight = Color(0xFF9A9AB0);

  // --- Room Type Color Coding ---
  static const Color labRoom = Color(0xFFFF6B9D);
  static const Color lectureRoom = Color(0xFF4ECDC4);
  static const Color tutorialRoom = Color(0xFFFFE66D);

  // --- Course Family Colors (auto-assigned by prefix) ---
  static const Color coursePROG = Color(0xFF7C4DFF);
  static const Color courseIRE = Color(0xFF00BCD4);
  static const Color courseCSE = Color(0xFFFF7043);
  static const Color courseMATH = Color(0xFF66BB6A);
  static const Color coursePHY = Color(0xFFFFCA28);
  static const Color courseEEE = Color(0xFFEF5350);
  static const Color courseENG = Color(0xFF42A5F5);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns the color for a given room type string.
  static Color roomColor(String roomType) {
    final type = roomType.toLowerCase();
    if (type.contains('lab')) return labRoom;
    if (type.contains('tutorial')) return tutorialRoom;
    return lectureRoom;
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds ───────────────────────────────────────────────
  static const Color background = Color(0xFFF1F7EC);         // Light-green wash
  static const Color backgroundSecondary = Color(0xFFE8F2DE);

  // ── Brand Green — exact from reference screenshots ────────────
  static const Color primary = Color(0xFF4CAF50);            // Vivid medium green (exact from photo)
  static const Color primaryDark = Color(0xFF388E3C);        // Deep forest green
  static const Color primaryLight = Color(0xFFE8F5E9);       // Pale green (card bg tint)
  static const Color primaryGlow = Color(0x664CAF50);

  // ── Secondary ─────────────────────────────────────────────────
  static const Color secondary = Color(0xFF66BB6A);
  static const Color secondaryLight = Color(0xFFC8E6C9);

  // ── Accent — Emergency Red ────────────────────────────────────
  static const Color accent = Color(0xFFEF5350);
  static const Color accentLight = Color(0xFFFFEBEE);

  // ── Surfaces ──────────────────────────────────────────────────
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE0EFE0);         // Green-tinted border
  static const Color divider = Color(0xFFEDF5ED);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1B2B1B);        // Near-black with green undertone
  static const Color textSecondary = Color(0xFF4A5D4A);      // Dark muted green
  static const Color textMuted = Color(0xFF7A967A);          // Soft green-grey
  static const Color textHint = Color(0xFFADC8AD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color star = Color(0xFFFFB300);
  static const Color success = Color(0xFF388E3C);

  // ── Header gradient ───────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFF1F7EC), Color(0xFFE8F2DE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Brand gradients ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE8F2DE), Color(0xFFF1F7EC), Color(0xFFF8FDF5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Banner gradients (teal-mint for promo banners) ────────────
  static const LinearGradient meshGradient1 = LinearGradient(
    colors: [Color(0xFF80DEEA), Color(0xFF4DB6AC), Color(0xFFB2EBF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient2 = LinearGradient(
    colors: [Color(0xFF80CBC4), Color(0xFF4CAF50), Color(0xFFB2DFDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient3 = LinearGradient(
    colors: [Color(0xFFA5D6A7), Color(0xFF4CAF50), Color(0xFFC8E6C9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── "Go Unlimited" green card gradient ───────────────────────
  static const LinearGradient subscriptionGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadow helpers ────────────────────────────────────────────
  static List<BoxShadow> cardShadow({double opacity = 0.07}) => [
        BoxShadow(
          color: const Color(0xFF4CAF50).withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> elevatedShadow({double opacity = 0.12}) => [
        BoxShadow(
          color: const Color(0xFF4CAF50).withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> glassShadow() => [
        BoxShadow(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: -4,
        ),
      ];

  // ── Green Button Shadow ───────────────────────────────────────
  static const List<BoxShadow> greenShadow = [
    BoxShadow(
      color: Color(0x554CAF50),
      blurRadius: 14,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
  ];

  // Keep tealShadow as alias for backward compatibility
  static const List<BoxShadow> tealShadow = greenShadow;
}
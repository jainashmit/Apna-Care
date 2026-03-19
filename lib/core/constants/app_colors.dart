import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF); // pure white
  static const Color backgroundSecondary = Color(0xFFF0F6FF); // light blue-grey

  // ── Headers / Sub-headers ────────────────────────────────────
  static const Color textMuted = Color(0xFF64748B); // muted grey-blue for sub-headers

  // ── Cards / Surfaces ─────────────────────────────────────────
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE8EEF8);

  // ── Primary — Medical Blue ────────────────────────────────────
  static const Color primary = Color(0xFF1565C0); // deep medical blue
  static const Color primaryMid = Color(0xFF1976D2); // medium blue
  static const Color primaryLight = Color(0xFFE3F0FF); // light blue tint
  static const Color primaryGlow = Color(0x441565C0); // blue 27% for glows

  // ── Secondary — Mint Green ────────────────────────────────────
  static const Color secondary = Color(0xFF00BFA5); // mint green
  static const Color secondaryLight = Color(0xFFE0F7F4); // mint tint

  // ── Accent — SOS Red ─────────────────────────────────────────
  static const Color accent = Color(0xFFE53935); // bright red
  static const Color accentLight = Color(0xFFFFEBEE); // red tint

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0D1B2A); // near-black
  static const Color textSecondary = Color(0xFF4A5568); // medium grey
  static const Color textHint = Color(0xFF9AA5B4); // light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ─────────────────────────────────────────────────
  static const Color star = Color(0xFFFFB300); // amber ratings
  static const Color success = Color(0xFF2E7D32);

  // ── Gradient helpers ─────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFECF4FF), Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Mesh Gradients (Soft Proxies) ──────────────────────────────
  static const LinearGradient meshGradient1 = LinearGradient(
    colors: [Color(0xFFE0F2FE), Color(0xFFF0FDFA), Color(0xFFF9FAFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient2 = LinearGradient(
    colors: [Color(0xFFFDF2F8), Color(0xFFFEF2F2), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient3 = LinearGradient(
    colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadow helpers ────────────────────────────────────────────
  static List<BoxShadow> cardShadow({double opacity = 0.10}) => [
        BoxShadow(
          color: const Color(0xFF1565C0).withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> elevatedShadow({double opacity = 0.18}) => [
        BoxShadow(
          color: const Color(0xFF1565C0).withValues(alpha: opacity),
          blurRadius: 28,
          offset: const Offset(0, 10),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ── Glass & Depth Shadows ─────────────────────────────────────
  static List<BoxShadow> glassShadow() => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1), // Dark Soft Shadow
          blurRadius: 20,
          offset: const Offset(10, 10),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.5), // Light Glow Shadow
          blurRadius: 20,
          offset: const Offset(-10, -10),
        ),
      ];
}
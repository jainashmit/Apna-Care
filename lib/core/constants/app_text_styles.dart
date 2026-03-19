import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── 3D Shadow helper (light-theme: blue shadows) ─────────────
  static List<Shadow> _shadow3d({Color color = const Color(0xFF1565C0)}) => [
        Shadow(color: color.withValues(alpha: 0.25), offset: const Offset(0, 2), blurRadius: 6),
        Shadow(color: color.withValues(alpha: 0.12), offset: const Offset(0, 4), blurRadius: 12),
      ];

  // ── Headings (Outfit ExtraBold + 3D shadow) ──────────────────
  static TextStyle heading1({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -1.2,
        shadows: _shadow3d(),
      );

  static TextStyle heading2({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.8,
        shadows: _shadow3d(),
      );

  static TextStyle heading3({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle subHeader({Color color = AppColors.textMuted}) =>
      GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.2,
      );

  // ── Body ─────────────────────────────────────────────────────
  static TextStyle body({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle bodyMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: color);

  static TextStyle bodySemiBold({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: color);

  // ── Labels / Caps ────────────────────────────────────────────
  static TextStyle label({Color color = AppColors.textSecondary}) =>
      GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.2);

  static TextStyle labelSmall({Color color = AppColors.textSecondary}) =>
      GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w400, color: color);

  static TextStyle labelBold({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: color);

  // ── App name (display) ────────────────────────────────────────
  static TextStyle appName() => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        letterSpacing: -1.0,
        shadows: [
          Shadow(color: AppColors.primary.withValues(alpha: 0.4), offset: const Offset(0, 3), blurRadius: 10),
          Shadow(color: AppColors.primary.withValues(alpha: 0.2), offset: const Offset(0, 6), blurRadius: 20),
          const Shadow(color: Color(0x11000000), offset: Offset(2, 4), blurRadius: 8),
        ],
      );

  // ── Button ────────────────────────────────────────────────────
  static TextStyle button() => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Colors.white,
      );
}

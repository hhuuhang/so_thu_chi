import 'package:flutter/material.dart';

/// Semantic color extension on [ColorScheme] so every screen can
/// pull the right color without hardcoding light/dark variants.
extension AppColors on ColorScheme {
  // ── Backgrounds ──────────────────────────────────────────────
  Color get scaffoldBg => brightness == Brightness.dark
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFF5F5F7);

  Color get cardBg => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.04)
      : Colors.white;

  Color get cardBorder => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.12)
      : Colors.grey.shade200;

  Color get elevatedCardBg => brightness == Brightness.dark
      ? const Color(0xFF2C2C2E)
      : Colors.white;

  // ── Text ─────────────────────────────────────────────────────
  Color get textPrimary => brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF1C1C1E);

  Color get textSecondary => brightness == Brightness.dark
      ? Colors.grey.shade400
      : Colors.grey.shade600;

  Color get textTertiary => brightness == Brightness.dark
      ? Colors.grey.shade500
      : Colors.grey.shade400;

  // ── Divider / borders ────────────────────────────────────────
  Color get subtleDivider => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.08)
      : Colors.grey.shade200;

  Color get strongDivider => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.14)
      : Colors.grey.shade300;

  // ── Semantic finance colors ──────────────────────────────────
  Color get incomeColor => brightness == Brightness.dark
      ? Colors.green.shade400
      : Colors.green.shade600;

  Color get expenseColor => brightness == Brightness.dark
      ? Colors.red.shade300
      : Colors.red.shade500;

  Color get incomeAccent => brightness == Brightness.dark
      ? Colors.lightBlue.shade300
      : Colors.blue.shade600;

  // ── Interactive elements ─────────────────────────────────────
  Color get chipSelectedBg => brightness == Brightness.dark
      ? Colors.grey.shade600
      : primary;

  Color get chipSelectedText => Colors.white;

  Color get chipUnselectedText => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.92)
      : Colors.grey.shade700;

  // ── Search / banners ─────────────────────────────────────────
  Color get bannerBg => brightness == Brightness.dark
      ? Colors.black.withOpacity(0.28)
      : Colors.blue.shade50;

  Color get bannerBorder => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.08)
      : Colors.blue.shade100;

  // ── Toolbar / overlay ────────────────────────────────────────
  Color get toolbarBg => brightness == Brightness.dark
      ? Colors.black.withOpacity(0.42)
      : Colors.grey.shade200;

  // ── Summary card ─────────────────────────────────────────────
  Color get summaryCardBg => brightness == Brightness.dark
      ? Colors.black.withOpacity(0.16)
      : Colors.white;

  Color get summaryCardBorder => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.16)
      : Colors.grey.shade200;

  // ── Shadow ───────────────────────────────────────────────────
  Color get shadowColor => brightness == Brightness.dark
      ? Colors.black.withOpacity(0.45)
      : Colors.black.withOpacity(0.08);

  // ── Calendar specific ────────────────────────────────────────
  Color get calendarOutsideBg => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.02)
      : Colors.grey.shade100;

  Color get calendarNormalBg => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.04)
      : Colors.white;

  Color get calendarOutsideBorder => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.08)
      : Colors.grey.shade200;

  Color get calendarNormalBorder => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.12)
      : Colors.grey.shade300;

  Color get calendarOutsideText => brightness == Brightness.dark
      ? Colors.grey.shade600
      : Colors.grey.shade400;

  // ── Numpad ───────────────────────────────────────────────────
  Color get numpadBg => brightness == Brightness.dark
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFF0F0F2);

  Color get numpadButtonBg => brightness == Brightness.dark
      ? Colors.grey.shade800
      : Colors.white;

  Color get numpadTextColor => brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF1C1C1E);

  Color get numpadDoneBg => brightness == Brightness.dark
      ? const Color(0xFF2C2C2E)
      : Colors.grey.shade200;

  Color get numpadDoneBorder => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.12)
      : Colors.grey.shade300;

  Color get numpadDoneText => brightness == Brightness.dark
      ? const Color(0xFFAEAEB2)
      : Colors.grey.shade700;

  Color get numpadDoneIcon => brightness == Brightness.dark
      ? const Color(0xFF636366)
      : Colors.grey.shade500;

  // ── Toast ────────────────────────────────────────────────────
  Color get toastBg => brightness == Brightness.dark
      ? const Color(0xFF1E1E1E)
      : Colors.white;

  Color get toastBorder => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.10)
      : Colors.grey.shade200;

  Color get toastSubtitle => brightness == Brightness.dark
      ? const Color(0xFF9E9E9E)
      : Colors.grey.shade600;

  // ── Input screen specific ────────────────────────────────────
  Color get inputTabSelectedBg => brightness == Brightness.dark
      ? Colors.white
      : primary;

  Color get inputTabSelectedText => brightness == Brightness.dark
      ? Colors.black
      : Colors.white;

  Color get inputTabUnselectedText => brightness == Brightness.dark
      ? Colors.white
      : Colors.grey.shade600;

  Color get inputTabBorder => brightness == Brightness.dark
      ? Colors.white
      : primary;

  Color get inputCategoryBg => brightness == Brightness.dark
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFF5F5F7);

  Color get inputCategoryBorder => brightness == Brightness.dark
      ? Colors.grey.shade700
      : Colors.grey.shade300;

  // ── Bottom sheet / modal ─────────────────────────────────────
  Color get bottomSheetBg => brightness == Brightness.dark
      ? Colors.grey.shade900
      : Colors.white;

  Color get bottomSheetHandle => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.16)
      : Colors.grey.shade300;

  // ── Settings ─────────────────────────────────────────────────
  Color get settingsTileBg => brightness == Brightness.dark
      ? const Color(0xFF2C2C2E)
      : Colors.white;

  Color get settingsSectionTitle => brightness == Brightness.dark
      ? Colors.grey.shade400
      : Colors.grey.shade600;

  Color get settingsIcon => brightness == Brightness.dark
      ? Colors.grey.shade300
      : Colors.grey.shade700;

  // ── Confirm Button ───────────────────────────────────────────
  Color get confirmButtonBg => brightness == Brightness.dark
      ? const Color(0xFF6366F1) // Modern Indigo
      : const Color(0xFF5B67F1);

  Color get confirmButtonPressedBg => brightness == Brightness.dark
      ? const Color(0xFF818CF8)
      : const Color(0xFF4F46E5);

  Color get confirmButtonText => Colors.white;
}


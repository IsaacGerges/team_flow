import 'package:flutter/material.dart';

/// AppColors — all app colors in one place.
class AppColors {
  AppColors._();

  // ── Primary (legacy purple, kept for auth screens) ──────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFF5F6FA);
  static const Color accent = Color(0xFF00C853);

  // ── Design-system Blue (Teams / Tasks / referènce) ───────────────────────
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryBlueDark = Color(0xFF2C5F8D);
  static const Color primaryBlueLight = Color(0xFFE3F2FD);

  // ── Secondary (Purple) ──────────────────────────────────────────────────
  static const Color secondaryPurple = Color(0xFF9C27B0);
  static const Color secondaryPurpleDark = Color(0xFF6A1B9A);
  static const Color secondaryPurpleLight = Color(0xFFF3E5F5);

  // ── Backgrounds ─────────────────────────────────────────────────────────
  static const Color backgroundScreen = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF5F5F5);

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textLink = Color(0xFF2196F3);

  // ── Status ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // ── Priority ────────────────────────────────────────────────────────────
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFFC107);
  static const Color priorityLow = Color(0xFF4CAF50);

  // ── Task Status ─────────────────────────────────────────────────────────
  static const Color taskTodo = Color(0xFFFFC107);
  static const Color taskInProgress = Color(0xFF2196F3);
  static const Color taskDone = Color(0xFF4CAF50);

  // ── Neutral Scale ───────────────────────────────────────────────────────
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color veryLightGray = Color(0xFFF5F5F5);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF666666);

  // ── Misc ────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color transparent = Colors.transparent;
  static const Color onlineStatus = Color(0xFF4CAF50);
  static const Color offlineStatus = Color(0xFF9E9E9E);
}

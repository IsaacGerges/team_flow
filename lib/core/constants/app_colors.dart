import 'package:flutter/material.dart';

/// Centralised colour palette for the entire TeamFlow app.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4192EE);
  static const Color secondary = Color(0xFFF5F6FA);
  static const Color accent = Color(0xFF00C853);

  // ── Design-system Blue (Unified Brand Identity) ──────────────────────────
  static const Color primaryBlue = Color(0xFF4192EE);
  static const Color primaryBlueDark = Color(0xFF2C5F8D);
  static const Color primaryBlueLight = Color(0xFFE3F2FD);
  static const Color blueBg = Color(0xFFEFF6FF);
  static const Color blueBorder = Color(0xFFDBEAFE);

  /// Legacy/Gradient tokens - Do not use for solid UI elements
  static const Color primaryBluePure = Color(0xFF2B6CEE);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue800 = Color(0xFF1E40AF);

  // ── Secondary Purple ─────────────────────────────────────────────────────
  static const Color secondaryPurple = Color(0xFF9C27B0);
  static const Color secondaryPurpleDark = Color(0xFF6A1B9A);
  static const Color secondaryPurpleLight = Color(0xFFF3E5F5);

  // ── Slate Palette (UI neutral tones) ──────────────────────────────────────
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color backgroundScreen = Color(0xFFF8F9FA);
  static const Color backgroundDashboard = Color(0xFFF6F7F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color bgLight = Color(0xFFF6F6F8);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textLink = Color(0xFF2196F3);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // ── Priority ─────────────────────────────────────────────────────────────
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFFC107);
  static const Color priorityLow = Color(0xFF4CAF50);

  // ── Task Status ──────────────────────────────────────────────────────────
  static const Color taskTodo = Color(0xFFFFC107);
  static const Color taskInProgress = Color(0xFF2196F3);
  static const Color taskDone = Color(0xFF4CAF50);

  // ── Task Status UI (pills & badges) ──────────────────────────────────────
  static const Color taskTodoBg = Color(0xFFF1F5F9);
  static const Color taskTodoText = Color(0xFF475569);
  static const Color taskInProgressBg = Color(0xFFFFF7ED);
  static const Color taskInProgressText = Color(0xFFC2410C);
  static const Color taskReviewBg = Color(0xFFFEF2F2);
  static const Color taskReviewText = Color(0xFFEF4444);
  static const Color taskDoneBg = Color(0xFFF0FDF4);
  static const Color taskDoneText = Color(0xFF15803D);

  // (Blue tokens moved to Design-system Blue section)
  static const Color purple = Color(0xFFA855F7);

  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange800 = Color(0xFF9A3412);
  static const Color orangeBg = Color(0xFFFFF7ED);
  static const Color orangeBorder = Color(0xFFFFEDD5);

  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color greenBg = Color(0xFFECFDF5);
  static const Color greenBorder = Color(0xFFD1FAE5);

  static const Color red500 = Color(0xFFEF4444);
  static const Color purple700 = Color(0xFF7E22CE);
  static const Color purpleBg = Color(0xFFFAF5FF);
  static const Color pink700 = Color(0xFFDB2777);
  static const Color pinkBg = Color(0xFFFCE7F3);
  static const Color amberBorder = Color(0xFFFEF3C7);

  // ── Neutral Scale ────────────────────────────────────────────────────────
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color veryLightGray = Color(0xFFF5F5F5);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF666666);

  // ── Notifications ────────────────────────────────────────────────────────
  static const Color notificationAmber = Color(0xFFF59E0B);
  static const Color notificationAmberBg = Color(0xFFFFFBEB);
  static const Color notificationPurple = Color(0xFF9333EA);
  static const Color notificationPurpleBg = Color(0xFFFAF5FF);
  static const Color unreadDot = primaryBlue;

  // ── Splash Screen Gradient ───────────────────────────────────────────────
  static const Color splashGradientStart = Color(0xFF4A90E2);
  static const Color splashGradientMiddle = Color(0xFF2B6CEE);
  static const Color splashGradientEnd = Color(0xFF1A4BB0);

  // ── Misc ─────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color transparent = Colors.transparent;
  static const Color onlineStatus = Color(0xFF4CAF50);
  static const Color offlineStatus = Color(0xFF9E9E9E);
}

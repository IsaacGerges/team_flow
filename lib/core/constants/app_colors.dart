import 'package:flutter/material.dart';

/// AppColors - جميع ألوان التطبيق في مكان واحد
class AppColors {
  // منع إنشاء instance من الكلاس (static only)
  AppColors._();

  // الألوان الأساسية
  static const Color primary = Color(0xFF6C63FF); // البنفسجي الشيك
  static const Color secondary = Color(0xFFF5F6FA); // الخلفية الرمادي الفاتح
  static const Color accent = Color(0xFF00C853); // الأخضر للنجاح

  // ألوان أساسية
  static const Color white = Colors.white;
  static const Color black = Colors.black87;

  // ألوان النصوص
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // ألوان الحالات
  static const Color success = Color(0xFF00C853);
  static const Color error = Colors.red;
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // ألوان إضافية
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color transparent = Colors.transparent;
}

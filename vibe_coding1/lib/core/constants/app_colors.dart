import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00BCD4);
  static const Color secondary = Color(0xFF26C6DA);
  static const Color accent = Color(0xFFFF6B9D);
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFCA28);
  static const Color info = Color(0xFF42A5F5);

  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color cardShadow = Color(0x1A000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

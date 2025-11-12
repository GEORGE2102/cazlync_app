import 'package:flutter/material.dart';

class AppColors {
  // Zambian Flag Colors - Primary Brand Colors
  static const Color zambianRed = Color(0xFFDE2010); // Zambian Red
  static const Color zambianOrange = Color(0xFFEF7D00); // Zambian Orange
  static const Color zambianGreen = Color(0xFF198A00); // Zambian Green
  
  // Primary Colors (using Zambian colors)
  static const Color primary = zambianRed; // Main brand color
  static const Color secondary = zambianGreen; // Secondary brand color
  static const Color accent = zambianOrange; // Accent color
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF757575);
  
  // Status Colors (using Zambian colors where appropriate)
  static const Color success = zambianGreen; // Green for success
  static const Color error = zambianRed; // Red for errors
  static const Color warning = zambianOrange; // Orange for warnings
  static const Color info = Color(0xFF29B6F6);
  
  // Additional Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [zambianRed, zambianOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [zambianOrange, zambianGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

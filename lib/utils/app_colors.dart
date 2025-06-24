import 'package:flutter/material.dart';

// This class holds all the color constants for the Tanavue app.
// Using a dedicated class for colors helps in maintaining consistency
// and makes it easier to update the color theme if needed.

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF4CAF50); // Main Green
  static const Color primaryDark = Color(0xFF388E3C); // Darker Green
  static const Color accent = Color(0xFF8BC34A); // Lighter Green / Accent

  // Text Colors
  static const Color textPrimary =
      Color(0xFF212121); // Dark Gray for primary text
  static const Color textSecondary =
      Color(0xFF757575); // Medium Gray for secondary text
  static const Color textWhite = Color(0xFFFFFFFF);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color lightGreenBackground =
      Color(0xFFE8F5E9); // Very Light Green
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Button Colors
  static const Color buttonGreen = Color(0xFF4CAF50);
  static const Color buttonTextWhite = Color(0xFFFFFFFF);

  // Icon Colors
  static const Color iconColor = Color(0xFF757575);
  static const Color iconColorActive = Color(0xFF4CAF50);

  // Other common colors
  static const Color dividerColor = Color(0xFFBDBDBD);
  static const Color transparent = Color(0x00000000); // Fully transparent
  static const Color shadowColor = Color(0x33000000); // Light shadow

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color cardGreen = Color(0xFF8BC34A);
  static const Color cardYellow = Color(0xFFFFC107);
  static const Color cardBlue = Color(0xFF00AEEF);
  static const Color greyText = Colors.grey;
  static const Color darkText = Colors.black87;
  static const Color placeholderBg = Color(0xFFF0F0F0); // Light grey
  static const Color iconGrey = Colors.grey;
  static const Color weatherNowBg = Color(0xFF8D8D8D); // Dark Grey
  static const Color weatherFutureBg = Color(0xFFE0E5EC); // Light Grey/Blueish
  static const Color weatherSun = Color(0xFFFFA000); // Orange for Sun

  static const Color divider = Color(0xFFE0E0E0);
  static const Color redWarning = Colors.red;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color backgroundDarkGray = Color(0xFF1E1E1E);
  static const Color backgroundNavy = Color(
    0xFF0A0B1A,
  ); // From first splash screen
  static const Color accentYellow = Color(0xFFEFFF33); // From the logo LetO
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB3B3B3);
  static const Color surfaceGray = Color(0xFF2C2C2C);
  static const Color surfaceLightGray = Color(0xFF3B3B3B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: textWhite,
      scaffoldBackgroundColor: backgroundNavy,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textWhite,
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textWhite,
            ),
            bodyLarge: GoogleFonts.inter(fontSize: 16, color: textWhite),
            bodyMedium: GoogleFonts.inter(fontSize: 14, color: textGray),
          ),
      colorScheme: ColorScheme.dark(
        primary: textWhite,
        secondary: accentYellow,
        background: backgroundNavy,
        surface: surfaceGray,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textWhite,
          foregroundColor: backgroundBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

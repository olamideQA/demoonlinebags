import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryGold = Color(0xFFC5A880);
  static const Color primaryGoldDark = Color(0xFFA68558);
  static const Color primaryGoldLight = Color(0xFFDFCCB1);
  
  static const Color obsidianNoir = Color(0xFF141416);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceGrey = Color(0xFFF4F3F0);
  static const Color backgroundLight = Color(0xFFFAFAF9);
  
  static const Color borderSubtle = Color(0xFFE5E2DC);
  static const Color borderStrong = Color(0xFF2C2C2E);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textDark = Color(0xFF18181B);
  
  static const Color successGreen = Color(0xFF15803D);
  static const Color errorRed = Color(0xFFB91C1C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: obsidianNoir,
        secondary: primaryGold,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: obsidianNoir,
        onSurface: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: obsidianNoir),
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: obsidianNoir,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: obsidianNoir,
          letterSpacing: 1.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: obsidianNoir,
          letterSpacing: 1.2,
          height: 1.15,
        ),
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: obsidianNoir,
          letterSpacing: 1.0,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: obsidianNoir,
          letterSpacing: 0.8,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: obsidianNoir,
          letterSpacing: 0.2,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: obsidianNoir,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: obsidianNoir,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textMuted,
          height: 1.45,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: obsidianNoir,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: obsidianNoir,
          side: const BorderSide(color: obsidianNoir, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderSubtle),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: obsidianNoir, width: 1.5),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13),
      ),
    );
  }
}

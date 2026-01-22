import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores Base
  static const Color primaryGreen = Color(0xFFB5EAD7);
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A); // Negro más profundo
  static const Color cardBlack = Color(0xFF2D2D2D);
  
  // Colores Pastel Vibrantes (Más saturados para destacar)
  static const Color pastelOrange = Color(0xFFFFDAC1);
  static const Color pastelLime = Color(0xFFC1E1C1); // Verde más fresco
  static const Color pastelLavender = Color(0xFFC7CEEA);
  static const Color pastelPink = Color(0xFFFFB7B2);
  static const Color pastelBlue = Color(0xFFA2E1DB); // Nuevo Cyan pastel

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        background: background,
        surface: surface,
      ),
      // Tipografía más grande y legible por defecto
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ).copyWith(
        bodyMedium: GoogleFonts.poppins(height: 1.2), // Reduce interlineado en texto normal
        bodyLarge: GoogleFonts.poppins(height: 1.2),
        titleLarge: GoogleFonts.poppins(height: 1.1), // Títulos más compactos
        headlineMedium: GoogleFonts.poppins(height: 1.1),
      ),
      scaffoldBackgroundColor: background,
    );
  }
}


import 'package:flutter/material.dart';

class AppTheme {
  // Define your core colors
  static const Color primaryGreen = Color(0xFF2E7D32); // A rich, organic green
  static const Color primaryBlue = Color(0xFF1565C0);  // A deep, trustworthy blue
  static const Color sacredGold = Color(0xFFFFB300);   // A warm gold for religious accents
  static const Color backgroundLight = Color(0xFFF5F5F5); // Clean off-white background
  static const Color textPrimary = Color(0xFF212121);    // Deep charcoal for headings
  static const Color textSecondary = Color(0xFF757575);  // Grey for body text

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      
      // 🎨 Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: primaryBlue,
        tertiary: sacredGold,
        surface: Colors.white,
      ),

      // ✍️ Typography Polish
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
      ),

      // 📱 AppBar Styling
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // 🧭 Navigation Bar Styling
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryGreen.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen, size: 28);
          }
          return const IconThemeData(color: primaryBlue);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: primaryBlue, fontSize: 12);
        }),
      ),

      // 🃏 Card Styling
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1, // Subtle elevation for a modern feel
        surfaceTintColor: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Softer corners
          side: BorderSide(color: Colors.grey.shade200), // Clean outline
        ),
      ),

      // 🔘 Button Styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ⌨️ Input (TextField) Styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}
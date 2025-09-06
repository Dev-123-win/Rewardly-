
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A provider class to manage the theme mode of the application.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  ThemeMode get themeMode => _themeMode;

  // Toggles the theme between light and dark mode.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

// Defines the application's theme data for both light and dark modes.
class RewardlyTheme {
  // Define the primary color seed for the theme.
  static const Color _primarySeedColor = Color(0xFF6200EE);

  // Internal text theme using Google Fonts for a modern look.
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500),
    titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
    labelMedium: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w500),
  );

  // Returns the light theme data for the application.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      snackBarTheme: _snackBarTheme(colorScheme),
      bottomNavigationBarTheme: _bottomNavBarTheme(colorScheme),
    );
  }

  // Returns the dark theme data for the application.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFFBB86FC), // Adjusted for dark mode
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: _appBarTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      snackBarTheme: _snackBarTheme(colorScheme),
      bottomNavigationBarTheme: _bottomNavBarTheme(colorScheme),
    );
  }

  // Defines the AppBar theme.
  static AppBarTheme _appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Defines the ElevatedButton theme.
  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        elevation: 5,
        shadowColor: colorScheme.primary.withAlpha(102),
      ),
    );
  }

  // Defines the SnackBar theme.
  static SnackBarThemeData _snackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.secondaryContainer,
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  // Defines the BottomNavigationBar theme.
  static BottomNavigationBarThemeData _bottomNavBarTheme(ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withAlpha(153),
      selectedLabelStyle: _textTheme.labelMedium,
      unselectedLabelStyle: _textTheme.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }
}

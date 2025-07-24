import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class AppTheme {
  static const Color primary = Color(0xFF10A37F);

  // Get platform-specific font family
  static String get fontFamily {
    if (Platform.isIOS) {
      return 'SF Pro Display'; // iOS native font
    } else {
      return 'Roboto'; // Android and other platforms
    }
  }

  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.black,
    secondary: Colors.black,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black87,
    surfaceContainer: Colors.grey.shade200,
    onSurfaceVariant: Colors.black54,
    inverseSurface: Colors.black,
    onInverseSurface: Colors.white,
    scrim: Colors.black26,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Colors.black,
    secondary: Colors.white,
    onSecondary: Colors.black,
    error: Colors.red.shade400,
    onError: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white70,
    surfaceContainer: Color(0xFF232325),
    onSurfaceVariant: Colors.white54,
    inverseSurface: Colors.white,
    onInverseSurface: Colors.black87,
    scrim: Colors.white24,
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(fontSize: 16, fontFamily: fontFamily),
      bodyMedium: TextStyle(fontSize: 14, fontFamily: fontFamily),
      bodySmall: TextStyle(fontSize: 12, fontFamily: fontFamily),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: false,
    ),
    scaffoldBackgroundColor: Colors.white,
    cardTheme: CardThemeData(
      color: Colors.grey[50],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.white,
      contentTextStyle: TextStyle(color: Colors.black87),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(fontSize: 16, fontFamily: fontFamily),
      bodyMedium: TextStyle(fontSize: 14, fontFamily: fontFamily),
      bodySmall: TextStyle(fontSize: 12, fontFamily: fontFamily),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D2D30),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    scaffoldBackgroundColor: Colors.black87,
    cardTheme: CardThemeData(
      color: const Color(0xFF2D2D30),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color(0xFF2D2D30),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF2D2D30),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

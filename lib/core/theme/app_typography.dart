import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type system: a serif-leaning display face for headings (premium,
/// editorial, distinct from the geometric sans every delivery app uses)
/// paired with a clean grotesque for body/UI text so it stays highly
/// readable and functional.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Color baseColor) => _buildTextTheme(baseColor);

  static TextTheme _buildTextTheme(Color baseColor) {
    final TextStyle Function({
      required double fontSize,
      required FontWeight fontWeight,
      double? height,
      double? letterSpacing,
    }) display = ({
      required double fontSize,
      required FontWeight fontWeight,
      double? height,
      double? letterSpacing,
    }) =>
        GoogleFonts.fraunces(
          color: baseColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          letterSpacing: letterSpacing,
        );

    final TextStyle Function({
      required double fontSize,
      required FontWeight fontWeight,
      double? height,
      double? letterSpacing,
      Color? color,
    }) body = ({
      required double fontSize,
      required FontWeight fontWeight,
      double? height,
      double? letterSpacing,
      Color? color,
    }) =>
        GoogleFonts.inter(
          color: color ?? baseColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          letterSpacing: letterSpacing,
        );

    return TextTheme(
      displayLarge: display(fontSize: 40, fontWeight: FontWeight.w600, height: 1.15),
      displayMedium: display(fontSize: 32, fontWeight: FontWeight.w600, height: 1.18),
      displaySmall: display(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2),
      headlineLarge: display(fontSize: 24, fontWeight: FontWeight.w600, height: 1.25),
      headlineMedium: display(fontSize: 20, fontWeight: FontWeight.w600, height: 1.28),
      headlineSmall: display(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      titleLarge: body(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
      titleMedium: body(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35),
      titleSmall: body(fontSize: 14, fontWeight: FontWeight.w600, height: 1.35),
      bodyLarge: body(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: body(fontSize: 12, fontWeight: FontWeight.w400, height: 1.45),
      labelLarge: body(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.2),
      labelMedium: body(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.3),
      labelSmall: body(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.4),
    );
  }
}

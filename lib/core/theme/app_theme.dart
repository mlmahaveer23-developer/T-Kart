import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(brightness: Brightness.light);
  static ThemeData get dark => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.forest300 : AppColors.forest700,
      onPrimary: isDark ? AppColors.charcoal900 : AppColors.pureWhite,
      primaryContainer: isDark ? AppColors.forest900 : AppColors.forest100,
      onPrimaryContainer: isDark ? AppColors.forest100 : AppColors.forest900,
      secondary: AppColors.brass600,
      onSecondary: AppColors.pureWhite,
      secondaryContainer: isDark ? AppColors.charcoal700 : AppColors.brass50,
      onSecondaryContainer: isDark ? AppColors.brass200 : AppColors.forest900,
      error: AppColors.error,
      onError: AppColors.pureWhite,
      surface: isDark ? AppColors.charcoal800 : AppColors.pureWhite,
      onSurface: isDark ? AppColors.ink100 : AppColors.ink900,
      surfaceContainerHighest:
          isDark ? AppColors.charcoal700 : AppColors.ivoryDim,
      outline: isDark ? AppColors.ink500 : AppColors.ink300,
      shadow: Colors.black,
    );

    final Color baseTextColor = isDark ? AppColors.ink100 : AppColors.ink900;
    final TextTheme textTheme = AppTypography.textTheme(baseTextColor);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.charcoal900 : AppColors.ivory,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: textTheme.headlineSmall,
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: BorderSide(
            color: isDark ? AppColors.charcoal700 : AppColors.ink100,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.primary, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.charcoal700 : AppColors.ivoryDim,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.ink300 : AppColors.ink500,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.charcoal700 : AppColors.forest100,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.forest300 : AppColors.forest700,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.charcoal700 : AppColors.ink100,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: isDark ? AppColors.ink300 : AppColors.ink500,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.ink100 : AppColors.ink900,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.ink900 : AppColors.ivory,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }
}

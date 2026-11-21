import 'package:flutter/material.dart';

/// Colours picked for WCAG AA contrast (>= 4.5:1 for text on its background).
/// Fixes the pale-on-pale "tips" boxes of the old UI.
class AppColors {
  static const primary = Color(0xFF1565C0);
  static const background = Color(0xFFF4F6FB);
  static const surface = Colors.white;
  static const text = Color(0xFF16202E);
  static const textMuted = Color(0xFF475467); // 7:1 on white
  static const border = Color(0xFFD0D5DD);
  static const success = Color(0xFF166534);
  static const successBg = Color(0xFFE7F6EC);
  static const warning = Color(0xFF8A4B00);
  static const warningBg = Color(0xFFFFF3DC);
  static const info = Color(0xFF0B4F8A);
  static const infoBg = Color(0xFFE3F0FC);
  static const error = Color(0xFFB3261E);
  static const errorBg = Color(0xFFFDEAE8);
  static const accent = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      onSurface: AppColors.text,
      error: AppColors.error,
    );
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle:
        TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.text, height: 1.4),
        bodySmall: TextStyle(color: AppColors.textMuted, height: 1.35),
      ),
      // 48dp minimum touch targets everywhere
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary, 2),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      chipTheme: const ChipThemeData(
        side: BorderSide(color: AppColors.border),
        labelStyle: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        selectedColor: AppColors.infoBg,
        backgroundColor: AppColors.surface,
        showCheckmark: true, // selection is never conveyed by colour alone
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      ),
      // Off switches stay clearly visible (old UI used near-invisible dark grey)
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? Colors.transparent : AppColors.textMuted),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = ThemeData.light().textTheme.apply(
        bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.activeOrange,
        secondary: AppColors.orbitBlue,
        surface: AppColors.card,
        error: AppColors.error,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.canvas,
        modalBackgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerColor: AppColors.divider,
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme => lightTheme;
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_palette.dart';
import 'cockpit_accent.dart';

export 'app_palette.dart';
export 'cockpit_accent.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme => buildTheme(
        brightness: Brightness.dark,
        accent: CockpitAccent.solar,
      );

  static ThemeData get lightTheme => buildTheme(
        brightness: Brightness.light,
        accent: CockpitAccent.solar,
      );

  static ThemeData buildTheme({
    required Brightness brightness,
    CockpitAccent accent = CockpitAccent.solar,
  }) {
    final isDark = brightness == Brightness.dark;
    final palette =
        isDark ? AppPalette.dark(accent) : AppPalette.light(accent);

    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = baseTextTheme.apply(
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
      fontFamily: 'Inter',
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.canvas,
      cardColor: palette.card,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.accent,
        onPrimary: Colors.white,
        secondary: palette.accentSecondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: palette.card,
        onSurface: palette.textPrimary,
      ),
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      splashFactory: InkSparkle.splashFactory,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.canvas,
        modalBackgroundColor: palette.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: IconThemeData(color: palette.textPrimary),
      dividerColor: palette.divider,
      fontFamily: 'Inter',
    );
  }
}

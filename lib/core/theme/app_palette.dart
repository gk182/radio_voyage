import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'cockpit_accent.dart';

/// Semantic palette tokens attached to ThemeData via ThemeExtension.
class AppPalette extends ThemeExtension<AppPalette> {
  final Brightness brightness;
  final CockpitAccent accentConfig;
  final Color canvas;
  final Color canvasHighlight;
  final Color surface;
  final Color card;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSecondary;
  final Color badgeBackground;
  final Color divider;
  final Color bottomNav;
  final List<BoxShadow> softShadow;
  final List<BoxShadow> controlShadow;

  const AppPalette({
    required this.brightness,
    required this.accentConfig,
    required this.canvas,
    required this.canvasHighlight,
    required this.surface,
    required this.card,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSecondary,
    required this.badgeBackground,
    required this.divider,
    required this.bottomNav,
    required this.softShadow,
    required this.controlShadow,
  });

  bool get isDark => brightness == Brightness.dark;

  factory AppPalette.dark(CockpitAccent accent) {
    return AppPalette(
      brightness: Brightness.dark,
      accentConfig: accent,
      canvas: AppColors.canvas,
      canvasHighlight: AppColors.canvasHighlight,
      surface: AppColors.surface,
      card: AppColors.card,
      cardBorder: AppColors.cardBorder,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textMuted: AppColors.textMuted,
      accent: accent.primary,
      accentSecondary: accent.secondary,
      badgeBackground: accent.badgeDark,
      divider: AppColors.divider,
      bottomNav: const Color(0xF21C222B),
      softShadow: AppShadows.soft,
      controlShadow: AppShadows.control,
    );
  }

  factory AppPalette.light(CockpitAccent accent) {
    return AppPalette(
      brightness: Brightness.light,
      accentConfig: accent,
      canvas: const Color(0xFFF1F5F9),
      canvasHighlight: const Color(0xFFFFFFFF),
      surface: const Color(0xFFE2E8F0),
      card: const Color(0xFFFFFFFF),
      cardBorder: const Color(0x18000000),
      textPrimary: const Color(0xFF0F172A),
      textSecondary: const Color(0xFF475569),
      textMuted: const Color(0xFF94A3B8),
      accent: accent.primary,
      accentSecondary: accent.secondary,
      badgeBackground: accent.primary.withOpacity(0.14),
      divider: const Color(0xFFE2E8F0),
      bottomNav: const Color(0xF8FFFFFF),
      softShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
      controlShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  @override
  AppPalette copyWith({
    Brightness? brightness,
    CockpitAccent? accentConfig,
    Color? canvas,
    Color? canvasHighlight,
    Color? surface,
    Color? card,
    Color? cardBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSecondary,
    Color? badgeBackground,
    Color? divider,
    Color? bottomNav,
    List<BoxShadow>? softShadow,
    List<BoxShadow>? controlShadow,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      accentConfig: accentConfig ?? this.accentConfig,
      canvas: canvas ?? this.canvas,
      canvasHighlight: canvasHighlight ?? this.canvasHighlight,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      badgeBackground: badgeBackground ?? this.badgeBackground,
      divider: divider ?? this.divider,
      bottomNav: bottomNav ?? this.bottomNav,
      softShadow: softShadow ?? this.softShadow,
      controlShadow: controlShadow ?? this.controlShadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      accentConfig: t < 0.5 ? accentConfig : other.accentConfig,
      canvas: Color.lerp(canvas, other.canvas, t) ?? canvas,
      canvasHighlight:
          Color.lerp(canvasHighlight, other.canvasHighlight, t) ??
              canvasHighlight,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      card: Color.lerp(card, other.card, t) ?? card,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSecondary:
          Color.lerp(accentSecondary, other.accentSecondary, t) ??
              accentSecondary,
      badgeBackground:
          Color.lerp(badgeBackground, other.badgeBackground, t) ??
              badgeBackground,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      bottomNav: Color.lerp(bottomNav, other.bottomNav, t) ?? bottomNav,
      softShadow: t < 0.5 ? softShadow : other.softShadow,
      controlShadow: t < 0.5 ? controlShadow : other.controlShadow,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark(CockpitAccent.solar)
          : AppPalette.light(CockpitAccent.solar));
}

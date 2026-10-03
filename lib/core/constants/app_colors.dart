import 'package:flutter/material.dart';

/// Central visual tokens for the Soft Retro Orbit design language.
abstract final class AppColors {
  static const canvas = Color(0xFFF7F5F0);
  static const surface = Color(0xFFEAE7E1);
  static const card = Color(0xFFFCFAF6);
  static const textPrimary = Color(0xFF1E232B);
  static const textSecondary = Color(0xFF7C808A);
  static const textMuted = Color(0xFF9A9997);
  static const primaryOrange = Color(0xFFF18B59);
  static const activeOrange = Color(0xFFFF6B3D);
  static const orbitBlue = Color(0xFF7AA9D3);
  static const night = Color(0xFF1A1F27);
  static const peach = Color(0xFFFFE7D6);
  static const divider = Color(0xFFE5E1DB);
  static const error = Color(0xFFC94B36);
  static const white = Color(0xFFFFFFFF);

  // Compatibility names retained for older secondary widgets.
  static const voidBlack = night;
  static const spaceBlack = night;
  static const deepNavy = night;
  static const cardNavy = card;
  static const glassNavy = card;
  static const glassSurface = Color(0x1AFFFFFF);
  static const neonCyan = orbitBlue;
  static const electricBlue = orbitBlue;
  static const neonGreen = primaryOrange;
  static const neonAmber = primaryOrange;
  static const neonMagenta = error;
  static const neonPurple = orbitBlue;
  static const borderCyan = divider;
  static const borderGlass = divider;
  static const radarGrid = Color(0x187AA9D3);
  static const radarSweep = Color(0x227AA9D3);
  static const radarPing = primaryOrange;
  static const success = primaryOrange;
  static const warning = primaryOrange;
}

abstract final class AppRadii {
  static const double control = 22;
  static const double chip = 18;
  static const double banner = 23;
  static const double card = 24;
}

abstract final class AppSpacing {
  static const double page = 22;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
}

abstract final class AppShadows {
  static const soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x170E1726),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0xA6FFFFFF),
      blurRadius: 2,
      offset: Offset(0, -1),
    ),
  ];

  static const control = <BoxShadow>[
    BoxShadow(
      color: Color(0x140E1726),
      blurRadius: 16,
      offset: Offset(0, 7),
    ),
  ];
}

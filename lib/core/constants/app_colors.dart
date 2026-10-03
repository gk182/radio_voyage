import 'package:flutter/material.dart';

/// Central visual tokens for the Soft Retro Orbit design language.
abstract final class AppColors {
  static const canvas = Color(0xFF10151C);
  static const canvasHighlight = Color(0xFF1B2028);
  static const surface = Color(0xFF282E37);
  static const card = Color(0xFF1C222B);
  static const cardBorder = Color(0x1FFFFFFF);
  static const textPrimary = Color(0xFFF5F2EC);
  static const textSecondary = Color(0xFFA9ADB5);
  static const textMuted = Color(0xFF747B85);
  static const primaryOrange = Color(0xFFF18B59);
  static const activeOrange = Color(0xFFFF6B3D);
  static const orbitBlue = Color(0xFF7AA9D3);
  static const night = Color(0xFF090D12);
  static const peach = Color(0xFF3A2723);
  static const divider = Color(0xFF323943);
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
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x10FFFFFF),
      blurRadius: 1,
      offset: Offset(0, -1),
    ),
  ];

  static const control = <BoxShadow>[
    BoxShadow(
      color: Color(0x5C000000),
      blurRadius: 16,
      offset: Offset(0, 7),
    ),
  ];
}

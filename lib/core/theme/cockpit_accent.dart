import 'package:flutter/material.dart';

/// Available cockpit color accents for the Sci-Fi interface.
enum CockpitAccent {
  solar(
    id: 'solar',
    label: 'Solar Orbit',
    vietnameseLabel: 'Cam Quỹ Đạo',
    primary: Color(0xFFFF6B3D),
    secondary: Color(0xFF7AA9D3),
    badgeDark: Color(0xFF3A2723),
  ),
  cyan(
    id: 'cyan',
    label: 'Cyber Cyan',
    vietnameseLabel: 'Xanh Hologram',
    primary: Color(0xFF00D2FF),
    secondary: Color(0xFF38BDF8),
    badgeDark: Color(0xFF0A2B3D),
  ),
  emerald(
    id: 'emerald',
    label: 'Matrix Emerald',
    vietnameseLabel: 'Lục Radar',
    primary: Color(0xFF00E676),
    secondary: Color(0xFF10B981),
    badgeDark: Color(0xFF092E1B),
  ),
  violet(
    id: 'violet',
    label: 'Nebula Purple',
    vietnameseLabel: 'Tím Tinh Vân',
    primary: Color(0xFFC084FC),
    secondary: Color(0xFFF43F5E),
    badgeDark: Color(0xFF2E1342),
  ),
  amber(
    id: 'amber',
    label: 'Cosmic Gold',
    vietnameseLabel: 'Vàng Kim',
    primary: Color(0xFFFFB800),
    secondary: Color(0xFFF59E0B),
    badgeDark: Color(0xFF3A2A04),
  );

  const CockpitAccent({
    required this.id,
    required this.label,
    required this.vietnameseLabel,
    required this.primary,
    required this.secondary,
    required this.badgeDark,
  });

  final String id;
  final String label;
  final String vietnameseLabel;
  final Color primary;
  final Color secondary;
  final Color badgeDark;
}

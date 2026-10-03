import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/radio_globe_provider.dart';

class HudCockpitOverlay extends StatelessWidget {
  final VoidCallback onOpenDirectory;

  const HudCockpitOverlay({
    super.key,
    required this.onOpenDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioGlobeProvider>(
      builder: (context, provider, child) {
        final station = provider.selectedStation;
        final stationCount = provider.stations.length;

        return Stack(
          children: [
            // Sci-Fi Cockpit Corner Reticles
            const Positioned(
              top: 50,
              left: 16,
              child: _CornerBracket(isTop: true, isLeft: true),
            ),
            const Positioned(
              top: 50,
              right: 16,
              child: _CornerBracket(isTop: true, isLeft: false),
            ),

            // Top Telemetry Header
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main Status Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.glassNavy,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.borderCyan, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Pulsing Radar Beacon Status
                          _StatusLed(isActive: provider.isPlaying),
                          const SizedBox(width: 10),

                          // Mission Title & Signal Lock
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'RADIO VOYAGE // ORBITAL RADAR',
                                  style: TextStyle(
                                    color: AppColors.neonCyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  station != null
                                      ? 'LOCKED: ${station.name.toUpperCase()} [${station.countryCode}]'
                                      : 'SCANNING FREQUENCIES...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Beacon Count Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cardNavy,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderGlass),
                            ),
                            child: Text(
                              '$stationCount BEACONS',
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Coordinates & Telemetry Ticker
                    if (station != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LAT: ${station.lat.toStringAsFixed(3)}°  LON: ${station.lon.toStringAsFixed(3)}°',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'BAND: ${station.frequencyLabel}',
                              style: const TextStyle(
                                color: AppColors.neonAmber,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Cockpit Floating Action Bar (Right edge)
            Positioned(
              right: 14,
              top: 140,
              child: Column(
                children: [
                  // Night/Day Texture Toggle
                  _CockpitFloatingButton(
                    icon: provider.isNightMode
                        ? CupertinoIcons.moon_stars_fill
                        : CupertinoIcons.sun_max_fill,
                    tooltip: 'Toggle Night/Day Earth',
                    activeColor: AppColors.neonCyan,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.toggleNightDayMode();
                    },
                  ),
                  const SizedBox(height: 10),

                  // Globe Rotation Toggle
                  _CockpitFloatingButton(
                    icon: CupertinoIcons.arrow_2_circlepath,
                    tooltip: 'Toggle Globe Orbit',
                    activeColor: provider.isRotating
                        ? AppColors.neonGreen
                        : AppColors.textMuted,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.toggleRotation();
                    },
                  ),
                  const SizedBox(height: 10),

                  // Warp / Random Station Hopper
                  _CockpitFloatingButton(
                    icon: CupertinoIcons.sparkles,
                    tooltip: 'Warp to Random Station',
                    activeColor: AppColors.neonMagenta,
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      _warpRandomStation(provider);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Open Search Directory
                  _CockpitFloatingButton(
                    icon: CupertinoIcons.search,
                    tooltip: 'Search Beacons',
                    activeColor: AppColors.neonCyan,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onOpenDirectory();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _warpRandomStation(RadioGlobeProvider provider) {
    final list = provider.stations;
    if (list.isEmpty) return;
    final random = Random();
    final randomIndex = random.nextInt(list.length);
    final target = list[randomIndex];
    provider.selectStation(target, autoPlay: true);
  }
}

class _StatusLed extends StatefulWidget {
  final bool isActive;

  const _StatusLed({required this.isActive});

  @override
  State<_StatusLed> createState() => _StatusLedState();
}

class _StatusLedState extends State<_StatusLed>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final color =
            widget.isActive ? AppColors.neonGreen : AppColors.neonCyan;
        final opacity = widget.isActive ? (0.4 + 0.6 * _pulse.value) : 0.8;

        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(opacity),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CockpitFloatingButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color activeColor;
  final VoidCallback onTap;

  const _CockpitFloatingButton({
    required this.icon,
    required this.tooltip,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.glassNavy,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderCyan, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: activeColor, size: 18),
          ),
        ),
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _BracketPainter(isTop: isTop, isLeft: isLeft),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _BracketPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) => false;
}

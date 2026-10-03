import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/radio_station.dart';
import '../providers/radio_globe_provider.dart';
import '../widgets/globe_3d_viewport.dart';
import '../widgets/station_player_sheet.dart';
import '../widgets/station_search_sheet.dart';

class RadioVoyageScreen extends StatefulWidget {
  const RadioVoyageScreen({super.key});

  @override
  State<RadioVoyageScreen> createState() => _RadioVoyageScreenState();
}

class _RadioVoyageScreenState extends State<RadioVoyageScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RadioGlobeProvider>().initializeGlobe();
    });
  }

  Future<void> _openDirectorySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StationSearchSheet(),
    );
  }

  Future<void> _handleNavigation(int index) async {
    if (index == 0) {
      setState(() => _navIndex = 0);
      return;
    }
    setState(() => _navIndex = index);
    if (index == 1) {
      await _openDirectorySheet();
    } else if (index == 2) {
      await _showFavorites();
    } else {
      await _showSettings();
    }
    if (mounted) setState(() => _navIndex = 0);
  }

  Future<void> _showFavorites() {
    final provider = context.read<RadioGlobeProvider>();
    final palette = context.palette;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: palette.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _StationListSheet(
        title: 'Favorites',
        emptyMessage: 'Save a station with the heart button to find it here.',
        stations: provider.favorites,
        onSelect: (station) {
          provider.selectStation(station, autoPlay: true);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _showSettings() {
    final palette = context.palette;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: palette.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Consumer<RadioGlobeProvider>(
        builder: (context, provider, child) {
          final palette = context.palette;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _SheetHandle()),
                const SizedBox(height: 20),
                Text(
                  'Settings & Appearance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),

                // Theme Mode Section
                Text(
                  'THEME MODE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ThemeModeOption(
                      icon: CupertinoIcons.moon_stars_fill,
                      label: 'Dark Orbit',
                      selected: provider.themeMode == ThemeMode.dark,
                      onTap: () => provider.setThemeMode(ThemeMode.dark),
                    ),
                    const SizedBox(width: 10),
                    _ThemeModeOption(
                      icon: CupertinoIcons.sun_max_fill,
                      label: 'Solar Light',
                      selected: provider.themeMode == ThemeMode.light,
                      onTap: () => provider.setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(width: 10),
                    _ThemeModeOption(
                      icon: CupertinoIcons.device_phone_portrait,
                      label: 'System',
                      selected: provider.themeMode == ThemeMode.system,
                      onTap: () => provider.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cockpit Accent Section
                Text(
                  'COCKPIT ACCENT COLOR',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CockpitAccent.values.map((accent) {
                      final selected = provider.accent == accent;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => provider.setCockpitAccent(accent),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accent.primary.withOpacity(0.18)
                                  : palette.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? accent.primary
                                    : palette.divider,
                                width: selected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: accent.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.primary.withOpacity(0.4),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  accent.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? accent.primary
                                        : palette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // 3D Globe Section
                Text(
                  '3D GLOBE CONTROLS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Sync Earth texture with theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Auto-switch night/day lights according to theme mode',
                    style: TextStyle(color: palette.textSecondary),
                  ),
                  value: provider.syncGlobeWithTheme,
                  activeTrackColor: palette.accent,
                  onChanged: (_) => provider.toggleSyncGlobeWithTheme(),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Night globe texture',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Show city night lights on Earth surface',
                    style: TextStyle(color: palette.textSecondary),
                  ),
                  value: provider.isNightMode,
                  activeTrackColor: palette.accent,
                  onChanged: (_) => provider.toggleNightDayMode(),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Automatic globe rotation',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  value: provider.isRotating,
                  activeTrackColor: palette.accent,
                  onChanged: (_) => provider.toggleRotation(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: palette.bottomNav,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: palette.canvas,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(.72, -.55),
            radius: 1.1,
            colors: [palette.canvasHighlight, palette.canvas],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _Header(onSearch: _openDirectorySheet),
                    const _ActiveStationBanner(),
                    const SizedBox(height: 2),
                    const Expanded(child: _GlobeStage()),
                    const _RegionFilters(),
                    const SizedBox(height: 10),
                    StationPlayerSheet(onOpenList: _openDirectorySheet),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _BottomNavigation(
                currentIndex: _navIndex,
                onTap: _handleNavigation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? palette.accent.withOpacity(0.18) : palette.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? palette.accent : palette.divider,
              width: selected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? palette.accent : palette.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? palette.accent : palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch});
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 112,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(AppSpacing.page, 18, AppSpacing.page, 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RADIO VOYAGE',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Discover the World',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 27,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.8,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Through Radio',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 27,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.8,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            _SurfaceButton(
              icon: CupertinoIcons.search,
              tooltip: 'Search stations',
              onTap: onSearch,
              size: 46,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveStationBanner extends StatelessWidget {
  const _ActiveStationBanner();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<RadioGlobeProvider>(
      builder: (context, provider, child) {
        final station = provider.selectedStation;
        return Container(
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: palette.card.withOpacity(.94),
            borderRadius: BorderRadius.circular(AppRadii.banner),
            border: Border.all(color: palette.cardBorder),
            boxShadow: palette.softShadow,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 15,
                height: 15,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: palette.accent, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: station == null
                    ? Text('Finding radio beacons…',
                        style: TextStyle(color: palette.textSecondary))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${station.country}  •  ${_shortFrequency(station.frequencyLabel, station.bitrate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: palette.badgeBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.signal_cellular_alt_rounded,
                        size: 13, color: palette.accent),
                    const SizedBox(width: 5),
                    Text(
                      '${provider.stations.length} BEACONS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: palette.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _shortFrequency(String frequency, int bitrate) {
    final value = frequency.split('//').first.trim();
    return value.isEmpty ? '$bitrate kbps' : value;
  }
}

class _GlobeStage extends StatelessWidget {
  const _GlobeStage();

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioGlobeProvider>(
      builder: (context, provider, child) => Stack(
        children: [
          const Positioned.fill(
            child: ClipRect(child: Globe3dViewport()),
          ),
          Positioned(
            top: 16,
            right: 14,
            child: Column(
              children: [
                _SurfaceButton(
                  size: 40,
                  icon: provider.isDarkMode
                      ? CupertinoIcons.sun_max_fill
                      : CupertinoIcons.moon_stars_fill,
                  tooltip: provider.isDarkMode
                      ? 'Switch to Light theme'
                      : 'Switch to Dark theme',
                  onTap: provider.toggleTheme,
                ),
                const SizedBox(height: 9),
                _SurfaceButton(
                  size: 40,
                  icon: provider.isNightMode
                      ? CupertinoIcons.globe
                      : CupertinoIcons.circle_grid_hex,
                  tooltip: provider.isNightMode
                      ? 'Earth: Night lights (tap for Day map)'
                      : 'Earth: Day map (tap for Night lights)',
                  onTap: provider.toggleNightDayMode,
                ),
                const SizedBox(height: 9),
                _SurfaceButton(
                  size: 40,
                  icon: CupertinoIcons.arrow_2_circlepath,
                  tooltip: 'Reset globe rotation',
                  onTap: provider.resetGlobe,
                ),
                const SizedBox(height: 9),
                _SurfaceButton(
                  size: 40,
                  icon: CupertinoIcons.sparkles,
                  tooltip: 'Discover a featured station',
                  onTap: provider.selectRandomStation,
                ),
                const SizedBox(height: 9),
                _SurfaceButton(
                  size: 40,
                  icon: CupertinoIcons.location,
                  tooltip: 'Go to home region',
                  onTap: provider.focusHomeLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceButton extends StatelessWidget {
  const _SurfaceButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkResponse(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          radius: size / 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: palette.card,
              shape: BoxShape.circle,
              border: Border.all(color: palette.cardBorder),
              boxShadow: palette.controlShadow,
            ),
            child: Icon(icon, size: size * .43, color: palette.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _RegionFilters extends StatelessWidget {
  const _RegionFilters();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<RadioGlobeProvider>(
      builder: (context, provider, child) => SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page, vertical: 3),
          scrollDirection: Axis.horizontal,
          itemCount: RadioGlobeProvider.regions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final region = RadioGlobeProvider.regions[index];
            final selected = provider.selectedRegion == region;
            return ChoiceChip(
              label: Text(region),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => provider.setRegion(region),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              labelStyle: TextStyle(
                color: selected ? Colors.white : palette.textPrimary,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: palette.card,
              selectedColor: palette.accent,
              side: BorderSide(
                  color: selected ? palette.accent : palette.divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.chip)),
              elevation: selected ? 2 : 0,
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const items = <(IconData, String)>[
      (CupertinoIcons.globe, 'Explore'),
      (CupertinoIcons.antenna_radiowaves_left_right, 'Stations'),
      (CupertinoIcons.heart, 'Favorites'),
      (CupertinoIcons.gear_alt, 'Settings'),
    ];
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: palette.bottomNav,
        border: Border(top: BorderSide(color: palette.divider, width: .6)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;
          return Expanded(
            child: InkResponse(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index].$1,
                    size: 23,
                    color: selected ? palette.accent : palette.textMuted,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[index].$2,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: selected ? palette.accent : palette.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StationListSheet extends StatelessWidget {
  const _StationListSheet({
    required this.title,
    required this.stations,
    required this.emptyMessage,
    required this.onSelect,
  });

  final String title;
  final List<RadioStation> stations;
  final String emptyMessage;
  final ValueChanged<RadioStation> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 420,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const _SheetHandle(),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: stations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(36),
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        leading: CircleAvatar(
                          backgroundColor: palette.badgeBackground,
                          child: Icon(
                            CupertinoIcons.antenna_radiowaves_left_right,
                            color: palette.accent,
                          ),
                        ),
                        title: Text(
                          station.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          station.country,
                          style: TextStyle(color: palette.textSecondary),
                        ),
                        onTap: () => onSelect(station),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: palette.divider,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

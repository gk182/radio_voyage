import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
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
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.canvas,
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
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Consumer<RadioGlobeProvider>(
        builder: (context, provider, child) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 22),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Settings',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Night globe texture'),
                subtitle: const Text('Show illuminated cities on Earth'),
                value: provider.isNightMode,
                activeTrackColor: AppColors.activeOrange,
                onChanged: (_) => provider.toggleNightDayMode(),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Automatic globe rotation'),
                value: provider.isRotating,
                activeTrackColor: AppColors.activeOrange,
                onChanged: (_) => provider.toggleRotation(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(.72, -.55),
            radius: 1.1,
            colors: [Color(0xFFFFFBF5), AppColors.canvas],
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

class _Header extends StatelessWidget {
  const _Header({required this.onSearch});
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(AppSpacing.page, 18, AppSpacing.page, 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RADIO VOYAGE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.4,
                    ),
                  ),
                  SizedBox(height: 8),
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
    return Consumer<RadioGlobeProvider>(
      builder: (context, provider, child) {
        final station = provider.selectedStation;
        return Container(
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(.94),
            borderRadius: BorderRadius.circular(AppRadii.banner),
            border: Border.all(color: Colors.white.withOpacity(.85)),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 15,
                height: 15,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: AppColors.activeOrange, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: station == null
                    ? const Text('Finding radio beacons…',
                        style: TextStyle(color: AppColors.textSecondary))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${station.country}  •  ${_shortFrequency(station.frequencyLabel, station.bitrate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.signal_cellular_alt_rounded,
                        size: 13, color: AppColors.activeOrange),
                    const SizedBox(width: 5),
                    Text(
                      '${provider.stations.length} BEACONS',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.activeOrange,
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
          const Positioned.fill(child: Globe3dViewport()),
          Positioned(
            top: 16,
            right: 14,
            child: Column(
              children: [
                _SurfaceButton(
                  size: 40,
                  icon: provider.isNightMode
                      ? CupertinoIcons.moon_stars
                      : CupertinoIcons.sun_max,
                  tooltip: 'Change Earth display mode',
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
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: AppShadows.control,
            ),
            child: Icon(icon, size: size * .43),
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
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: AppColors.card,
              selectedColor: AppColors.night,
              side: BorderSide(
                  color: selected ? AppColors.night : AppColors.divider),
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
    const items = <(IconData, String)>[
      (CupertinoIcons.globe, 'Explore'),
      (CupertinoIcons.antenna_radiowaves_left_right, 'Stations'),
      (CupertinoIcons.heart, 'Favorites'),
      (CupertinoIcons.gear_alt, 'Settings'),
    ];
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Color(0xEFFFFFFF),
        border: Border(top: BorderSide(color: AppColors.divider, width: .6)),
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
                    color:
                        selected ? AppColors.activeOrange : AppColors.textMuted,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[index].$2,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: selected
                          ? AppColors.activeOrange
                          : AppColors.textSecondary,
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
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
            ),
          ),
          Expanded(
            child: stations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(36),
                      child: Text(emptyMessage,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                : ListView.builder(
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.peach,
                          child: Icon(
                              CupertinoIcons.antenna_radiowaves_left_right,
                              color: AppColors.activeOrange),
                        ),
                        title: Text(station.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(station.country),
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
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
          color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
    );
  }
}

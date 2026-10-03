import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/radio_globe_provider.dart';

class StationSearchSheet extends StatefulWidget {
  const StationSearchSheet({super.key});

  @override
  State<StationSearchSheet> createState() => _StationSearchSheetState();
}

class _StationSearchSheetState extends State<StationSearchSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DraggableScrollableSheet(
      initialChildSize: .86,
      minChildSize: .55,
      maxChildSize: .94,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: palette.canvas,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Consumer<RadioGlobeProvider>(
          builder: (context, provider, child) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Find a station',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SearchBar(
                  controller: _controller,
                  hintText: 'Station, city, country or genre',
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(color: palette.textPrimary),
                  ),
                  hintStyle: WidgetStatePropertyAll(
                    TextStyle(color: palette.textSecondary),
                  ),
                  leading: Icon(
                    CupertinoIcons.search,
                    size: 20,
                    color: palette.textSecondary,
                  ),
                  trailing: [
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () => provider.search(_controller.text),
                      icon: Icon(
                        CupertinoIcons.arrow_right_circle_fill,
                        color: palette.accent,
                      ),
                    ),
                  ],
                  onSubmitted: provider.search,
                  backgroundColor: WidgetStatePropertyAll(palette.card),
                  elevation: const WidgetStatePropertyAll(0),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: palette.divider),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (provider.isLoadingStations)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: palette.accent,
                  backgroundColor: palette.badgeBackground,
                ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
                  itemCount: provider.stations.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 70,
                    endIndent: 12,
                    color: palette.divider,
                  ),
                  itemBuilder: (context, index) {
                    final station = provider.stations[index];
                    return ListTile(
                      minTileHeight: 66,
                      leading: CircleAvatar(
                        backgroundColor: palette.badgeBackground,
                        child: Text(_flag(station.countryCode),
                            style: const TextStyle(fontSize: 19)),
                      ),
                      title: Text(
                        station.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${station.country}  •  ${station.bitrate} kbps',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                      trailing: Icon(
                        CupertinoIcons.play_circle,
                        color: palette.accent,
                      ),
                      onTap: () {
                        provider.selectStation(station, autoPlay: true);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _flag(String code) {
    final normalized = code.toUpperCase();
    if (normalized.length != 2) return '📻';
    return String.fromCharCodes(
        normalized.codeUnits.map((unit) => unit + 127397));
  }
}

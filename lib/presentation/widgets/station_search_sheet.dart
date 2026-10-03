import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
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
    return DraggableScrollableSheet(
      initialChildSize: .86,
      minChildSize: .55,
      maxChildSize: .94,
      builder: (context, scrollController) => DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Consumer<RadioGlobeProvider>(
          builder: (context, provider, child) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 14, 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Find a station',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(CupertinoIcons.xmark_circle_fill,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SearchBar(
                  controller: _controller,
                  hintText: 'Station, city, country or genre',
                  leading: const Icon(CupertinoIcons.search, size: 20),
                  trailing: [
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () => provider.search(_controller.text),
                      icon: const Icon(CupertinoIcons.arrow_right_circle_fill,
                          color: AppColors.activeOrange),
                    ),
                  ],
                  onSubmitted: provider.search,
                  backgroundColor: const WidgetStatePropertyAll(AppColors.card),
                  elevation: const WidgetStatePropertyAll(0),
                  side: const WidgetStatePropertyAll(
                      BorderSide(color: AppColors.divider)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))),
                ),
              ),
              const SizedBox(height: 12),
              if (provider.isLoadingStations)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.activeOrange,
                  backgroundColor: AppColors.peach,
                ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
                  itemCount: provider.stations.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 70, endIndent: 12),
                  itemBuilder: (context, index) {
                    final station = provider.stations[index];
                    return ListTile(
                      minTileHeight: 66,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.peach,
                        child: Text(_flag(station.countryCode),
                            style: const TextStyle(fontSize: 19)),
                      ),
                      title: Text(
                        station.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${station.country}  •  ${station.bitrate} kbps',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(CupertinoIcons.play_circle,
                          color: AppColors.activeOrange),
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

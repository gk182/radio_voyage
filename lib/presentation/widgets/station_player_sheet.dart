import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../providers/radio_globe_provider.dart';

class StationPlayerSheet extends StatelessWidget {
  const StationPlayerSheet({super.key, required this.onOpenList});

  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioGlobeProvider>(
      builder: (context, provider, child) {
        final station = provider.selectedStation;
        if (station == null) return const SizedBox(height: 170);
        final statusText = provider.playbackError != null
            ? 'STREAM UNAVAILABLE'
            : provider.isBuffering
                ? 'CONNECTING'
                : 'LIVE NOW';

        return Container(
          height: 170,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 11),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(.98),
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: Colors.white.withOpacity(.8)),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 76,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: provider.playbackError == null
                                    ? AppColors.activeOrange
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              statusText,
                              style: const TextStyle(
                                color: AppColors.activeOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.15,
                              ),
                            ),
                            const Spacer(),
                            _FrequencyBadge(
                                label: _frequencyOrBitrate(
                                    station.frequencyLabel, station.bitrate)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          station.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${station.country}  •  ${_shortTags(station.tags)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundControl(
                    tooltip: provider.isFavorite
                        ? 'Remove favorite'
                        : 'Add favorite',
                    icon: provider.isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: provider.isFavorite
                        ? AppColors.activeOrange
                        : AppColors.textPrimary,
                    onTap: provider.toggleFavorite,
                  ),
                  IconButton(
                    tooltip: 'Previous station',
                    onPressed: () => provider.skipStation(-1),
                    icon:
                        const Icon(CupertinoIcons.backward_end_fill, size: 20),
                  ),
                  Semantics(
                    button: true,
                    label: provider.isPlaying
                        ? 'Pause live radio'
                        : 'Play live radio',
                    child: GestureDetector(
                      onTap: provider.togglePlayPause,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: AppColors.activeOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x35FF6B3D),
                                blurRadius: 18,
                                offset: Offset(0, 8)),
                          ],
                        ),
                        child: provider.isBuffering
                            ? const CupertinoActivityIndicator(
                                color: Colors.white)
                            : Icon(
                                provider.isPlaying
                                    ? CupertinoIcons.pause_fill
                                    : CupertinoIcons.play_fill,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next station',
                    onPressed: () => provider.skipStation(1),
                    icon: const Icon(CupertinoIcons.forward_end_fill, size: 20),
                  ),
                  _RoundControl(
                    tooltip: provider.isMuted ? 'Unmute' : 'Mute',
                    icon: provider.isMuted
                        ? CupertinoIcons.speaker_slash
                        : CupertinoIcons.speaker_2,
                    onTap: provider.toggleMute,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: provider.isPlaying ? .3 : .0,
                  color: AppColors.activeOrange,
                  backgroundColor: AppColors.surface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _shortTags(String tags) {
    if (tags.trim().isEmpty) return 'Worldwide radio';
    return tags.split(',').take(3).map((tag) => tag.trim()).join(', ');
  }

  static String _frequencyOrBitrate(String frequency, int bitrate) {
    final value = frequency.split('//').first.trim();
    return value.isEmpty ? '$bitrate kbps' : value;
  }
}

class _FrequencyBadge extends StatelessWidget {
  const _FrequencyBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 82),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.signal_cellular_alt_rounded, size: 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 25,
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: AppShadows.control,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

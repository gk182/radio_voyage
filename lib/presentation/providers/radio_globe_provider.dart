import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/sphere_style.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/curated_stations.dart';
import '../../data/models/radio_station.dart';
import '../../data/services/audio_player_service.dart';
import '../../data/services/radio_api_service.dart';

class RadioGlobeProvider extends ChangeNotifier {
  RadioGlobeProvider() {
    _globeController = FlutterEarthGlobeController(
      rotationSpeed: 0.025,
      zoom: 0.1,
      minZoom: 0.1,
      maxZoom: 0.8,
      isRotating: false,
      surface: Image.asset('assets/earth_day.png').image,
      sphereStyle: const SphereStyle(
        showShadow: true,
        shadowColor: Color(0x597AA9D3),
        shadowBlurSigma: 18,
        showGradientOverlay: true,
        gradientOverlay: RadialGradient(
          center: Alignment(-0.28, -0.38),
          radius: 0.95,
          colors: [
            Color(0x2AFFFFFF),
            Color(0x00FFFFFF),
            Color(0x330C2436),
          ],
          stops: [0, 0.64, 1],
        ),
      ),
    );
    _globeController.onLoaded = _handleGlobeLoaded;
    _audioService.statusStream.listen((_) => notifyListeners());
  }

  late final FlutterEarthGlobeController _globeController;
  final RadioApiService _apiService = RadioApiService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final Set<String> _favoriteIds = <String>{};

  List<RadioStation> _stations = <RadioStation>[];
  RadioStation? _selectedStation;
  bool _isGlobeInitialized = false;
  bool _isLoadingStations = false;
  bool _isNightMode = false;
  String _selectedRegion = 'All';

  FlutterEarthGlobeController get globeController => _globeController;
  List<RadioStation> get stations => _stations;
  RadioStation? get selectedStation => _selectedStation;
  bool get isGlobeInitialized => _isGlobeInitialized;
  bool get isLoadingStations => _isLoadingStations;
  bool get isNightMode => _isNightMode;
  bool get isRotating => _globeController.isRotating;
  StreamPlaybackStatus get playbackStatus => _audioService.status;
  bool get isPlaying => _audioService.isPlaying;
  bool get isBuffering => _audioService.isBuffering;
  bool get isMuted => _audioService.isMuted;
  String? get playbackError => _audioService.errorMessage;
  String get selectedRegion => _selectedRegion;
  bool get isFavorite =>
      _selectedStation != null && _favoriteIds.contains(_selectedStation!.id);
  List<RadioStation> get favorites =>
      _stations.where((station) => _favoriteIds.contains(station.id)).toList();

  static const regions = <String>[
    'All',
    'North America',
    'Europe',
    'Asia',
    'South America',
  ];

  void _handleGlobeLoaded() {
    if (_stations.isEmpty) {
      loadStations();
      return;
    }
    _focusSelected(animate: false);
    _refreshGlobePoints();
    notifyListeners();
  }

  void initializeGlobe() {
    if (_isGlobeInitialized) return;
    _isGlobeInitialized = true;
    notifyListeners();
    if (_stations.isEmpty && !_isLoadingStations) loadStations();
  }

  Future<void> loadStations() async {
    if (_isLoadingStations) return;
    _isLoadingStations = true;
    notifyListeners();
    try {
      _stations = await _apiService.fetchTopGeoStations(limit: 68);
    } catch (_) {
      _stations = CuratedStations.defaultStations;
    }

    if (_stations.isNotEmpty && _selectedStation == null) {
      _selectedStation = _stations.firstWhere(
        (station) => station.countryCode.toUpperCase() == 'CA',
        orElse: () => _stations.first,
      );
    }
    _focusSelected(animate: false);
    _refreshGlobePoints();
    _isLoadingStations = false;
    notifyListeners();
  }

  Iterable<RadioStation> get _visibleStations {
    return _stations.where((station) {
      final code = station.countryCode.toUpperCase();
      switch (_selectedRegion) {
        case 'North America':
          return const {'CA', 'US', 'MX'}.contains(code);
        case 'Europe':
          return const {
            'AT',
            'BE',
            'CH',
            'CZ',
            'DE',
            'DK',
            'ES',
            'FI',
            'FR',
            'GB',
            'GR',
            'HU',
            'IE',
            'IS',
            'IT',
            'NL',
            'NO',
            'PL',
            'PT',
            'RO',
            'SE',
            'UA',
          }.contains(code);
        case 'Asia':
          return const {
            'CN',
            'HK',
            'ID',
            'IN',
            'IQ',
            'JP',
            'KR',
            'MY',
            'PH',
            'SG',
            'TH',
            'TW',
            'VN'
          }.contains(code);
        case 'South America':
          return const {
            'AR',
            'BO',
            'BR',
            'CL',
            'CO',
            'EC',
            'PE',
            'PY',
            'UY',
            'VE'
          }.contains(code);
        default:
          return true;
      }
    });
  }

  void _refreshGlobePoints() {
    if (!_isGlobeInitialized) return;
    _globeController.points = _visibleStations.map((station) {
      final selected = station.id == _selectedStation?.id;
      return Point(
        id: station.id,
        coordinates: GlobeCoordinates(station.lat, station.lon),
        isLabelVisible: selected,
        labelOffset: const Offset(-76, -72),
        style: PointStyle(
          color: selected ? AppColors.activeOrange : const Color(0xFFFF9C63),
          size: selected ? 10 : 4.2,
        ),
        labelBuilder: selected
            ? (context, point, isHovering, isVisible) =>
                _StationGlobeLabel(station: station)
            : null,
        onTap: () => selectStation(station, autoPlay: true),
      );
    }).toList();
    _globeController.connections.clear();
  }

  void selectStation(RadioStation station, {bool autoPlay = true}) {
    _selectedStation = station;
    _focusSelected();
    _refreshGlobePoints();
    notifyListeners();
    if (autoPlay) {
      _audioService.playStream(station.streamUrl);
      _apiService.reportStationClick(station.id);
    }
  }

  void _focusSelected({bool animate = true}) {
    final station = _selectedStation;
    if (station == null) return;
    _globeController.focusOnCoordinates(
      GlobeCoordinates(station.lat, station.lon),
      animate: animate,
      duration: const Duration(milliseconds: 800),
    );
  }

  void setRegion(String region) {
    if (_selectedRegion == region) return;
    _selectedRegion = region;
    _refreshGlobePoints();
    notifyListeners();
  }

  void toggleFavorite() {
    final station = _selectedStation;
    if (station == null) return;
    if (!_favoriteIds.add(station.id)) _favoriteIds.remove(station.id);
    notifyListeners();
  }

  void skipStation(int delta) {
    if (_stations.isEmpty) return;
    var index = _selectedStation == null
        ? 0
        : _stations.indexWhere((s) => s.id == _selectedStation!.id);
    index = (index + delta) % _stations.length;
    if (index < 0) index += _stations.length;
    selectStation(_stations[index], autoPlay: true);
  }

  void selectRandomStation() {
    if (_stations.isEmpty) return;
    selectStation(_stations[Random().nextInt(_stations.length)],
        autoPlay: true);
  }

  void resetGlobe() {
    _globeController.resetRotation();
    _focusSelected();
  }

  void focusHomeLocation() {
    if (_stations.isEmpty) return;
    final home = _stations.firstWhere(
      (station) => station.countryCode.toUpperCase() == 'VN',
      orElse: () => _selectedStation ?? _stations.first,
    );
    selectStation(home, autoPlay: false);
  }

  void togglePlayPause() {
    final station = _selectedStation;
    if (station == null) return;
    if (isPlaying) {
      _audioService.pause();
    } else if (playbackStatus == StreamPlaybackStatus.paused) {
      _audioService.resume();
    } else {
      _audioService.playStream(station.streamUrl);
      _apiService.reportStationClick(station.id);
    }
    notifyListeners();
  }

  void toggleMute() {
    _audioService.toggleMute();
  }

  void toggleNightDayMode() {
    _isNightMode = !_isNightMode;
    _globeController.loadSurface(
      Image.asset(
              _isNightMode ? 'assets/earth_night.png' : 'assets/earth_day.png')
          .image,
    );
    notifyListeners();
  }

  void toggleRotation() {
    _globeController.isRotating = !_globeController.isRotating;
    if (_globeController.isRotating) {
      _globeController.startRotation();
    } else {
      _globeController.stopRotation();
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    _isLoadingStations = true;
    notifyListeners();
    try {
      _stations = await _apiService.searchStations(query);
      _refreshGlobePoints();
    } finally {
      _isLoadingStations = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    // FlutterEarthGlobe owns and disposes the controller's internal animation
    // controller. Disposing it here either races initialization or double-frees
    // that package-managed resource in widget tests.
    super.dispose();
  }
}

class _StationGlobeLabel extends StatelessWidget {
  const _StationGlobeLabel({required this.station});

  final RadioStation station;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.96),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.control,
      ),
      child: Row(
        children: [
          Text(_flag(station.countryCode),
              style: const TextStyle(fontSize: 19)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700),
                ),
                Text(
                  station.country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
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

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';
import '../models/curated_stations.dart';

/// Service implementing official Radio-Browser API standards:
/// Reference: https://api.radio-browser.info/
/// - Server discovery via DNS lookup ('all.api.radio-browser.info')
/// - Station identification using UUIDs (stationuuid)
/// - Country identification using ISO-3166-1 alpha-2 (countrycode)
/// - Mandatory descriptive User-Agent header
/// - Click count reporting (/json/url/{uuid})
class RadioApiService {
  static const String _localJsonPath = 'assets/data/stations.json';
  static const String _dnsDiscoveryHost = 'all.api.radio-browser.info';
  static const String _userAgent = 'RadioVoyage3D/1.0';

  static const List<String> _staticFallbacks = [
    'https://de1.api.radio-browser.info',
    'https://nl1.api.radio-browser.info',
    'https://at1.api.radio-browser.info',
  ];

  List<RadioStation>? _cachedStations;
  List<String>? _discoveredServers;

  /// Loads radio stations from the local JSON database file.
  /// If reading or parsing the local JSON fails, it automatically falls back
  /// to the Remote GET API with detailed logging.
  Future<List<RadioStation>> fetchTopGeoStations({int limit = 100}) async {
    if (_cachedStations != null && _cachedStations!.isNotEmpty) {
      debugPrint(
          '[RadioData] ⚡ Returning ${_cachedStations!.length} cached stations from memory.');
      return _cachedStations!;
    }

    try {
      debugPrint(
          '[RadioData] 📁 Attempting to load radio database from local JSON: "$_localJsonPath"...');
      final stations = await _loadFromLocalJson();

      if (stations.isNotEmpty) {
        debugPrint(
            '[RadioData] ✅ [LOCAL DB HIT] Successfully loaded ${stations.length} radio stations from local JSON.');
        _cachedStations = stations;
        return stations;
      } else {
        throw Exception('Local JSON contains 0 valid stations');
      }
    } catch (e, stack) {
      debugPrint(
          '[RadioData] ⚠️ [LOCAL DB ERROR] Failed to load local JSON ($e).');
      debugPrint(
          '[RadioData] 🌐 [API FALLBACK] Falling back to Remote GET API endpoints...');
      debugPrint('[RadioData] 🔍 Error details: $stack');

      try {
        final remoteStations = await _fetchFromRemoteApi(limit: limit);
        if (remoteStations.isNotEmpty) {
          debugPrint(
              '[RadioData] ✅ [API FALLBACK SUCCESS] Retrieved ${remoteStations.length} stations from Remote GET API.');
          _cachedStations = remoteStations;
          return remoteStations;
        } else {
          throw Exception('Remote API returned empty list');
        }
      } catch (apiError) {
        debugPrint(
            '[RadioData] 🚨 [CRITICAL ERROR] Remote GET API also failed: $apiError');
        debugPrint(
            '[RadioData] 🛡️ [FAILSAFE] Engaging in-memory curated stations fallback.');
        _cachedStations = CuratedStations.defaultStations;
        return CuratedStations.defaultStations;
      }
    }
  }

  /// Parses local JSON from Flutter asset bundle
  Future<List<RadioStation>> _loadFromLocalJson() async {
    final jsonString = await rootBundle.loadString(_localJsonPath);
    final List<dynamic> data = jsonDecode(jsonString);

    return data
        .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
        .where((s) => s.lat != 0.0 && s.lon != 0.0 && s.streamUrl.isNotEmpty)
        .toList();
  }

  /// Dynamically discovers available servers via DNS lookup per official docs
  Future<List<String>> _getServers() async {
    if (_discoveredServers != null && _discoveredServers!.isNotEmpty) {
      return _discoveredServers!;
    }

    try {
      debugPrint(
          '[RadioData] 🔍 [DNS DISCOVERY] Resolving DNS for $_dnsDiscoveryHost ...');
      final addresses = await InternetAddress.lookup(_dnsDiscoveryHost);
      final servers = <String>[];

      for (final addr in addresses) {
        try {
          final reverse = await addr.reverse();
          final serverUrl = 'https://${reverse.host}';
          if (!servers.contains(serverUrl)) {
            servers.add(serverUrl);
          }
        } catch (_) {
          servers.add('https://${addr.address}');
        }
      }

      if (servers.isNotEmpty) {
        // Randomize list for load balancing per docs recommendation
        servers.shuffle(Random());
        debugPrint(
            '[RadioData] 🌐 [DNS DISCOVERY] Discovered ${servers.length} servers: $servers');
        _discoveredServers = servers;
        return servers;
      }
    } catch (e) {
      debugPrint(
          '[RadioData] ⚠️ DNS discovery failed ($e). Using static fallback servers.');
    }

    _discoveredServers = List.from(_staticFallbacks)..shuffle();
    return _discoveredServers!;
  }

  /// Remote fallback: queries Radio Browser API endpoints
  Future<List<RadioStation>> _fetchFromRemoteApi({int limit = 100}) async {
    final hosts = await _getServers();

    for (final host in hosts) {
      try {
        final endpoint =
            '$host/json/stations/search?has_geo_info=true&is_online=true&hidebroken=true&order=clickcount&reverse=true&limit=$limit';
        debugPrint('[RadioData] 📡 Querying endpoint: $endpoint');

        final response = await http.get(
          Uri.parse(endpoint),
          headers: {'User-Agent': _userAgent},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final stations = data
              .map(
                  (item) => RadioStation.fromJson(item as Map<String, dynamic>))
              .where(
                  (s) => s.lat != 0.0 && s.lon != 0.0 && s.streamUrl.isNotEmpty)
              .toList();

          if (stations.isNotEmpty) {
            debugPrint(
                '[RadioData] 🌐 Host $host responded with ${stations.length} stations.');
            return stations;
          }
        } else {
          debugPrint(
              '[RadioData] ⚠️ Host $host responded with status: ${response.statusCode}');
        }
      } catch (err) {
        debugPrint(
            '[RadioData] ⚠️ Failed contacting host $host ($err). Retrying with next mirror...');
        continue;
      }
    }

    return [];
  }

  /// Searches stations within local database first, then queries Remote GET API
  Future<List<RadioStation>> searchStations(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return fetchTopGeoStations();
    }

    final qLower = cleanQuery.toLowerCase();
    debugPrint('[RadioData] 🔍 Initiating search for query: "$cleanQuery"...');

    // 1. Search in local cached / JSON database
    List<RadioStation> localPool = _cachedStations ?? [];
    if (localPool.isEmpty) {
      try {
        localPool = await _loadFromLocalJson();
        _cachedStations = localPool;
      } catch (_) {
        localPool = CuratedStations.defaultStations;
      }
    }

    final localMatches = localPool.where((s) {
      return s.name.toLowerCase().contains(qLower) ||
          s.country.toLowerCase().contains(qLower) ||
          s.countryCode.toLowerCase().contains(qLower) ||
          s.tags.toLowerCase().contains(qLower);
    }).toList();

    debugPrint(
        '[RadioData] 📁 [LOCAL DB SEARCH] Found ${localMatches.length} matches for "$cleanQuery".');

    if (localMatches.length >= 8) {
      return localMatches;
    }

    // 2. Query Remote GET API for expanded results
    debugPrint(
        '[RadioData] 🌐 [API SEARCH] Few local matches found. Querying Remote GET API for "$cleanQuery"...');
    final Map<String, RadioStation> combined = {
      for (final s in localMatches) s.id: s,
    };

    final hosts = await _getServers();
    for (final host in hosts) {
      try {
        final encoded = Uri.encodeComponent(cleanQuery);
        final searchUrl = Uri.parse(
          '$host/json/stations/search?name=$encoded&has_geo_info=true&is_online=true&hidebroken=true&order=clickcount&reverse=true&limit=25',
        );

        final response = await http.get(
          searchUrl,
          headers: {'User-Agent': _userAgent},
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final apiResults = data
              .map(
                  (item) => RadioStation.fromJson(item as Map<String, dynamic>))
              .where((s) =>
                  s.lat != 0.0 && s.lon != 0.0 && s.streamUrl.isNotEmpty);

          for (final r in apiResults) {
            if (!combined.containsKey(r.id)) {
              combined[r.id] = r;
            }
          }

          debugPrint(
              '[RadioData] ✅ Remote GET API returned ${combined.length} combined results for "$cleanQuery".');
          return combined.values.toList();
        }
      } catch (e) {
        debugPrint('[RadioData] ⚠️ Remote search failed on $host ($e).');
        continue;
      }
    }

    return combined.values.toList();
  }

  /// Sends click/play counter to Radio-Browser network per API documentation:
  /// "Send /json/url requests for every click the user makes, this helps to mark stations
  /// as popular and makes the database more useful to other people."
  void reportStationClick(String stationuuid) {
    if (stationuuid.isEmpty ||
        stationuuid.startsWith('scifi-') ||
        stationuuid.startsWith('vn-')) {
      return; // Skip curated custom IDs
    }

    Future.microtask(() async {
      final hosts = await _getServers();
      final host = hosts.isNotEmpty ? hosts.first : _staticFallbacks.first;
      try {
        final clickUrl = Uri.parse('$host/json/url/$stationuuid');
        await http.get(clickUrl, headers: {'User-Agent': _userAgent}).timeout(
          const Duration(seconds: 3),
        );
        debugPrint(
            '[RadioData] 📊 Click counter recorded for station UUID: $stationuuid');
      } catch (_) {
        // Fire & forget: ignore network reporting errors
      }
    });
  }
}

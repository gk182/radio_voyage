class RadioStation {
  final String id;
  final String name;
  final String streamUrl;
  final String country;
  final String countryCode;
  final double lat;
  final double lon;
  final String tags;
  final int bitrate;
  final String codec;
  final String frequencyLabel;
  final String? favicon;
  final String? homepage;

  const RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.country,
    required this.countryCode,
    required this.lat,
    required this.lon,
    required this.tags,
    required this.bitrate,
    required this.codec,
    required this.frequencyLabel,
    this.favicon,
    this.homepage,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    final rawLat = json['geo_lat'];
    final rawLon = json['geo_long'];

    double parsedLat = 0.0;
    double parsedLon = 0.0;
    if (rawLat != null) {
      parsedLat = double.tryParse(rawLat.toString()) ?? 0.0;
    }
    if (rawLon != null) {
      parsedLon = double.tryParse(rawLon.toString()) ?? 0.0;
    }

    final bitrateVal = json['bitrate'];
    final int parsedBitrate = bitrateVal is int
        ? bitrateVal
        : (int.tryParse(bitrateVal?.toString() ?? '') ?? 0);

    return RadioStation(
      id: json['stationuuid']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? 'Unknown Beacon',
      streamUrl:
          json['url_resolved']?.toString() ?? json['url']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Global',
      countryCode: json['countrycode']?.toString() ?? 'WW',
      lat: parsedLat,
      lon: parsedLon,
      tags: json['tags']?.toString() ?? '',
      bitrate: parsedBitrate,
      codec: json['codec']?.toString().toUpperCase() ?? 'MP3',
      // Radio Browser does not provide terrestrial frequencies for most
      // internet streams. Never synthesize one from coordinates.
      frequencyLabel: json['frequencyLabel']?.toString().trim() ?? '',
      favicon: json['favicon']?.toString(),
      homepage: json['homepage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationuuid': id,
      'name': name,
      'url_resolved': streamUrl,
      'country': country,
      'countrycode': countryCode,
      'geo_lat': lat,
      'geo_long': lon,
      'tags': tags,
      'bitrate': bitrate,
      'codec': codec,
      'frequencyLabel': frequencyLabel,
      'favicon': favicon,
      'homepage': homepage,
    };
  }
}

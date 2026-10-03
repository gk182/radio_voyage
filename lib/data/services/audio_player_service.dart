import 'dart:async';
import 'package:just_audio/just_audio.dart';

enum StreamPlaybackStatus {
  idle,
  buffering,
  playing,
  paused,
  error,
}

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  StreamPlaybackStatus _status = StreamPlaybackStatus.idle;
  String? _errorMessage;
  int _currentRequestId = 0;
  bool _isMuted = false;
  final StreamController<StreamPlaybackStatus> _statusController =
      StreamController<StreamPlaybackStatus>.broadcast();

  StreamPlaybackStatus get status => _status;
  bool get isPlaying => _status == StreamPlaybackStatus.playing;
  bool get isBuffering => _status == StreamPlaybackStatus.buffering;
  String? get errorMessage => _errorMessage;
  Stream<StreamPlaybackStatus> get statusStream => _statusController.stream;
  bool get isMuted => _isMuted;

  AudioPlayerService() {
    _initListener();
  }

  void _initListener() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _updateStatus(StreamPlaybackStatus.buffering);
      } else if (state.playing) {
        _errorMessage = null;
        _updateStatus(StreamPlaybackStatus.playing);
      } else if (state.processingState == ProcessingState.completed) {
        _updateStatus(StreamPlaybackStatus.idle);
      } else {
        if (_status != StreamPlaybackStatus.error &&
            _status != StreamPlaybackStatus.idle) {
          _updateStatus(StreamPlaybackStatus.paused);
        }
      }
    }, onError: (e) {
      final msg = e.toString().toLowerCase();
      if (!_isAbortError(msg)) {
        _errorMessage = 'Transmission interrupted: $e';
        _updateStatus(StreamPlaybackStatus.error);
      }
    });

    _player.playbackEventStream.listen((_) {}, onError: (e) {
      final msg = e.toString().toLowerCase();
      if (!_isAbortError(msg)) {
        _errorMessage = 'Signal link lost: $e';
        _updateStatus(StreamPlaybackStatus.error);
      }
    });
  }

  bool _isAbortError(String msg) {
    return msg.contains('abort') ||
        msg.contains('cancel') ||
        msg.contains('interrupted') ||
        msg.contains('disposed');
  }

  void _updateStatus(StreamPlaybackStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  Future<void> playStream(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      _errorMessage = 'Beacon URL is empty';
      _updateStatus(StreamPlaybackStatus.error);
      return;
    }

    final requestId = ++_currentRequestId;
    _errorMessage = null;
    _updateStatus(StreamPlaybackStatus.buffering);

    try {
      // Gracefully stop previous playback without triggering abort false positives
      await _player.stop();

      if (requestId != _currentRequestId) return;

      // Set audio source with standard streaming radio headers
      final audioSource = AudioSource.uri(
        Uri.parse(cleanUrl),
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 RadioVoyage/1.0',
          'Icy-MetaData': '1',
          'Accept': '*/*',
        },
      );

      await _player.setAudioSource(audioSource, preload: true);

      if (requestId != _currentRequestId) return;

      await _player.play();
    } catch (e) {
      // If a newer request has started, discard this error
      if (requestId != _currentRequestId) return;

      final msg = e.toString().toLowerCase();
      // Ignore normal abort when switching between stations
      if (_isAbortError(msg)) {
        return;
      }

      _errorMessage = 'Station unreachable: Stream offline or restricted';
      _updateStatus(StreamPlaybackStatus.error);
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _updateStatus(StreamPlaybackStatus.paused);
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      _errorMessage = null;
      await _player.play();
    } catch (e) {
      _errorMessage = 'Signal resume failure: $e';
      _updateStatus(StreamPlaybackStatus.error);
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _updateStatus(StreamPlaybackStatus.idle);
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _player.setVolume(_isMuted ? 0 : 1);
    _statusController.add(_status);
  }

  void dispose() {
    _player.dispose();
    _statusController.close();
  }
}

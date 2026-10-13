import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Фоновая мистическая музыка, зацикленная на всё время работы
/// приложения. Один и тот же плеер используется и в меню, и в игре,
/// чтобы музыка не прерывалась при переходах между экранами.
class MusicService {
  MusicService._internal();

  static final MusicService instance = MusicService._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;
  bool _playing = false;
  bool muted = false;

  static const double _volume = 0.55;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      muted = prefs.getBool('music_muted') ?? false;
    } catch (_) {
      // Если настройки недоступны — просто играем со звуком по умолчанию.
    }

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(muted ? 0 : _volume);
      await _player.play(AssetSource('audio/theme.mp3'));
      _playing = true;
    } catch (_) {
      // На некоторых платформах (например, веб без взаимодействия
      // пользователя) автозапуск звука может быть заблокирован —
      // в этом случае игра продолжает работать без музыки.
    }
  }

  /// В браузере автозапуск звука запрещён, пока пользователь не нажмёт
  /// на страницу. Этот метод вызывается при любом касании и запускает
  /// музыку, если она ещё не играет.
  Future<void> ensurePlaying() async {
    if (_playing || !_initialized) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(muted ? 0 : _volume);
      await _player.play(AssetSource('audio/theme.mp3'));
      _playing = true;
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    muted = !muted;

    try {
      await _player.setVolume(muted ? 0 : _volume);
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_muted', muted);
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    if (muted) return;
    try {
      await _player.resume();
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}

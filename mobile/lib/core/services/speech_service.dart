import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SpeechService {
  Future<void> speak(String text);
}

class SpeechPreferences {
  static const enabledKey = 'speech_enabled';
  static const rateKey = 'speech_rate';
  static const defaultRate = 0.42;
  static const minRate = 0.2;
  static const maxRate = 0.8;

  const SpeechPreferences({required this.enabled, required this.rate});

  final bool enabled;
  final double rate;

  static SpeechPreferences fromStorage({bool? enabled, double? rate}) {
    return SpeechPreferences(
      enabled: enabled ?? true,
      rate: clampRate(rate ?? defaultRate),
    );
  }

  static double clampRate(double rate) {
    if (rate.isNaN) return defaultRate;
    return rate.clamp(minRate, maxRate).toDouble();
  }
}

class DeviceSpeechService implements SpeechService {
  DeviceSpeechService({FlutterTts? tts, SpeechPreferences? preferences})
    : _tts = tts ?? FlutterTts(),
      _preferences = preferences;

  final FlutterTts _tts;
  final SpeechPreferences? _preferences;

  @override
  Future<void> speak(String text) async {
    final preferences = _preferences ?? await _loadPreferences();
    if (!preferences.enabled) {
      throw StateError('Speech is turned off in settings.');
    }
    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(preferences.rate);
    final available = await _tts.isLanguageAvailable('en-US');
    if (available != true) {
      throw StateError('English voice is unavailable on this device.');
    }
    final result = await _tts.speak(text);
    if (result != 1) throw StateError('The device could not start speech.');
  }

  Future<SpeechPreferences> _loadPreferences() async {
    final stored = await SharedPreferences.getInstance();
    return SpeechPreferences.fromStorage(
      enabled: stored.getBool(SpeechPreferences.enabledKey),
      rate: stored.getDouble(SpeechPreferences.rateKey),
    );
  }
}

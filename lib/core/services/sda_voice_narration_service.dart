import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import '../constants.dart';

enum SdaVoiceGender { male, female }

/// 🎙️ SDA Voice Narration Service
/// Configured specifically to speak in a solemn, reverent, and dignified cadence
/// reminiscent of a godly Seventh-day Adventist minister (Male) or gentle Bible worker (Female)
/// reading sacred Scripture, Spirit of Prophecy masterworks, and hymn lyrics.
class SdaVoiceNarrationService extends ChangeNotifier {
  static final SdaVoiceNarrationService instance = SdaVoiceNarrationService._internal();

  factory SdaVoiceNarrationService() => instance;

  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentIndex = 0;
  String _currentTitle = '';
  List<String> _currentQueue = [];
  Function(int index)? _onIndexChanged;
  VoidCallback? _onCompleteCallback;

  SdaVoiceGender _gender = SdaVoiceGender.male;
  double _speechRate = 0.44;
  double _pitch = 0.78;
  String _language = 'en-US';

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentIndex => _currentIndex;
  String get currentTitle => _currentTitle;
  SdaVoiceGender get gender => _gender;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  String get language => _language;

  SdaVoiceNarrationService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    if (_isInitialized) return;

    try {
      _restorePreferences();

      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setVolume(1.0);
      await _applyVoiceConfiguration();

      _tts.setStartHandler(() {
        _isPlaying = true;
        _isPaused = false;
        notifyListeners();
      });

      _tts.setCompletionHandler(() {
        _handleSegmentCompleted();
      });

      _tts.setPauseHandler(() {
        _isPlaying = false;
        _isPaused = true;
        notifyListeners();
      });

      _tts.setContinueHandler(() {
        _isPlaying = true;
        _isPaused = false;
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        _isPlaying = false;
        _isPaused = false;
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('[SdaVoiceNarrationService] Init Error: $e');
    }
  }

  void _restorePreferences() {
    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        final savedGender = box.get('sda_voice_gender');
        if (savedGender is String) {
          _gender = savedGender == 'female' ? SdaVoiceGender.female : SdaVoiceGender.male;
        }
        final savedRate = box.get('sda_speech_rate');
        if (savedRate is double) {
          _speechRate = savedRate;
        }
        final savedLang = box.get('sda_bible_language');
        if (savedLang is String) {
          _language = _mapLanguageToLocale(savedLang);
        }
      }
    } catch (_) {}
  }

  String _mapLanguageToLocale(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'swahili':
      case 'sw':
        return 'sw-KE';
      case 'spanish':
      case 'es':
        return 'es-ES';
      case 'french':
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US';
    }
  }

  Future<void> _applyVoiceConfiguration() async {
    try {
      final isMale = _gender == SdaVoiceGender.male;
      _pitch = isMale ? 0.65 : 1.15;
      await _tts.setSpeechRate(_speechRate);

      final voices = await _tts.getVoices;
      if (voices is List && voices.isNotEmpty) {
        Map<String, String>? chosenVoice;
        final langPrefix = _language.split('-').first.toLowerCase();

        for (final v in voices) {
          if (v is Map) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            final vGender = (v['gender'] ?? '').toString().toLowerCase();

            if (locale.startsWith(langPrefix)) {
              if (isMale) {
                if (vGender == 'male' ||
                    name.contains('male') ||
                    name.contains('man') ||
                    name.contains('david') ||
                    name.contains('guy') ||
                    name.contains('iob') ||
                    name.contains('iom') ||
                    name.contains('sfg#male') ||
                    name.contains('tpd') ||
                    name.contains('tpc')) {
                  chosenVoice = {'name': v['name'].toString(), 'locale': v['locale'].toString()};
                  break;
                }
              } else {
                if (vGender == 'female' ||
                    name.contains('female') ||
                    name.contains('woman') ||
                    name.contains('zira') ||
                    name.contains('samantha') ||
                    name.contains('tpf') ||
                    name.contains('iol') ||
                    name.contains('sfg#female')) {
                  chosenVoice = {'name': v['name'].toString(), 'locale': v['locale'].toString()};
                  break;
                }
              }
            }
          }
        }

        if (chosenVoice != null) {
          await _tts.setVoice(chosenVoice);
        }
      }
      // CRITICAL: Call setPitch AFTER setVoice so Android does not reset pitch to default voice pitch
      await _tts.setPitch(_pitch);
    } catch (e) {
      debugPrint('[SdaVoiceNarrationService] Apply Voice Error: $e');
    }
  }

  /// Toggle or set voice gender (Male Minister vs Gentle Sister) and save to persistent storage
  Future<void> setVoiceGender(SdaVoiceGender gender) async {
    _gender = gender;
    await _applyVoiceConfiguration();

    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        box.put('sda_voice_gender', gender.name);
      }
    } catch (_) {}

    // Immediately re-speak current segment in the newly chosen voice
    if (_isPlaying && _currentQueue.isNotEmpty && _currentIndex < _currentQueue.length) {
      await _tts.stop();
      _isPlaying = true;
      _isPaused = false;
      await _tts.speak(_currentQueue[_currentIndex]);
    }

    notifyListeners();
  }

  /// Change Speech Rate (0.8x, 1.0x, 1.2x, 1.4x) and save to persistent storage
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _tts.setSpeechRate(rate);

    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        box.put('sda_speech_rate', rate);
      }
    } catch (_) {}

    // Immediately apply new rate to current speech
    if (_isPlaying && _currentQueue.isNotEmpty && _currentIndex < _currentQueue.length) {
      await _tts.stop();
      _isPlaying = true;
      _isPaused = false;
      await _tts.speak(_currentQueue[_currentIndex]);
    }

    notifyListeners();
  }

  /// Change TTS Language (en-US, sw-KE, es-ES, fr-FR)
  Future<void> setLanguage(String locale) async {
    _language = locale;
    await _tts.setLanguage(locale);
    await _applyVoiceConfiguration();
    notifyListeners();
  }

  /// Speak a single text segment (e.g. a single verse or whole passage)
  Future<void> speakSingle(String text, {String title = 'Voice Narration', VoidCallback? onComplete}) async {
    await _initTts();
    await stop();

    _currentTitle = title;
    _currentQueue = [text];
    _currentIndex = 0;
    _onCompleteCallback = onComplete;
    _onIndexChanged = null;

    _isPlaying = true;
    _isPaused = false;
    notifyListeners();

    await _applyVoiceConfiguration();
    await _tts.speak(text);
  }

  /// Speak a queue of segments (e.g. verses in a chapter or paragraphs in an SOP book)
  Future<void> speakQueue({
    required List<String> segments,
    required String title,
    int startIndex = 0,
    Function(int index)? onIndexChanged,
    VoidCallback? onComplete,
  }) async {
    await _initTts();
    await stop();

    if (segments.isEmpty) return;

    _currentQueue = List.from(segments);
    _currentTitle = title;
    _currentIndex = startIndex.clamp(0, segments.length - 1);
    _onIndexChanged = onIndexChanged;
    _onCompleteCallback = onComplete;

    _isPlaying = true;
    _isPaused = false;
    notifyListeners();

    await _applyVoiceConfiguration();
    _speakCurrentIndex();
  }

  Future<void> _speakCurrentIndex() async {
    if (_currentIndex < 0 || _currentIndex >= _currentQueue.length) {
      await stop();
      _onCompleteCallback?.call();
      return;
    }

    _onIndexChanged?.call(_currentIndex);
    notifyListeners();

    final text = _currentQueue[_currentIndex];
    await _tts.speak(text);
  }

  void _handleSegmentCompleted() {
    if (_currentQueue.length > 1 && _currentIndex + 1 < _currentQueue.length) {
      _currentIndex++;
      _speakCurrentIndex();
    } else {
      _isPlaying = false;
      _isPaused = false;
      notifyListeners();
      _onCompleteCallback?.call();
    }
  }

  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (_) {
      await _tts.stop();
    }
    _isPlaying = false;
    _isPaused = true;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentQueue.isNotEmpty && _currentIndex < _currentQueue.length) {
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();
      await _speakCurrentIndex();
    }
  }

  Future<void> next() async {
    if (_currentIndex + 1 < _currentQueue.length) {
      await _tts.stop();
      _currentIndex++;
      await _speakCurrentIndex();
    }
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      await _tts.stop();
      _currentIndex--;
      await _speakCurrentIndex();
    }
  }

  Future<void> jumpToIndex(int index) async {
    if (index >= 0 && index < _currentQueue.length) {
      await _tts.stop();
      _currentIndex = index;
      await _speakCurrentIndex();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isPlaying = false;
    _isPaused = false;
    notifyListeners();
  }

  Future<void> setPacing({double? rate, double? pitch}) async {
    if (rate != null) {
      await setSpeechRate(rate);
    }
    if (pitch != null) {
      _pitch = pitch;
      await _tts.setPitch(_pitch);
    }
    notifyListeners();
  }
}

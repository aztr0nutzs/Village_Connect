import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'storage_service.dart';

// Text Size Options
enum TextSize { small, medium, large }

// Accessibility Preferences Model
class AccessibilityPreferences {
  final TextSize textSize;
  final bool highVisibilityMode;
  final bool textToSpeechEnabled;
  final bool voiceFeedbackEnabled;
  final double speechRate;
  final double speechPitch;
  final String speechLanguage;
  final bool screenReaderEnabled;
  final bool focusHighlightEnabled;
  final bool reduceMotion;

  AccessibilityPreferences({
    this.textSize = TextSize.medium,
    this.highVisibilityMode = false,
    this.textToSpeechEnabled = false,
    this.voiceFeedbackEnabled = false,
    this.speechRate = 0.5,
    this.speechPitch = 1.0,
    this.speechLanguage = 'en-US',
    this.screenReaderEnabled = true,
    this.focusHighlightEnabled = true,
    this.reduceMotion = false,
  });

  factory AccessibilityPreferences.fromJson(Map<String, dynamic> json) {
    return AccessibilityPreferences(
      textSize: TextSize.values[json['textSize'] ?? 1],
      highVisibilityMode: json['highVisibilityMode'] ?? false,
      textToSpeechEnabled: json['textToSpeechEnabled'] ?? false,
      voiceFeedbackEnabled: json['voiceFeedbackEnabled'] ?? false,
      speechRate: (json['speechRate'] ?? 0.5).toDouble(),
      speechPitch: (json['speechPitch'] ?? 1.0).toDouble(),
      speechLanguage: json['speechLanguage'] ?? 'en-US',
      screenReaderEnabled: json['screenReaderEnabled'] ?? true,
      focusHighlightEnabled: json['focusHighlightEnabled'] ?? true,
      reduceMotion: json['reduceMotion'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textSize': textSize.index,
      'highVisibilityMode': highVisibilityMode,
      'textToSpeechEnabled': textToSpeechEnabled,
      'voiceFeedbackEnabled': voiceFeedbackEnabled,
      'speechRate': speechRate,
      'speechPitch': speechPitch,
      'speechLanguage': speechLanguage,
      'screenReaderEnabled': screenReaderEnabled,
      'focusHighlightEnabled': focusHighlightEnabled,
      'reduceMotion': reduceMotion,
    };
  }

  AccessibilityPreferences copyWith({
    TextSize? textSize,
    bool? highVisibilityMode,
    bool? textToSpeechEnabled,
    bool? voiceFeedbackEnabled,
    double? speechRate,
    double? speechPitch,
    String? speechLanguage,
    bool? screenReaderEnabled,
    bool? focusHighlightEnabled,
    bool? reduceMotion,
  }) {
    return AccessibilityPreferences(
      textSize: textSize ?? this.textSize,
      highVisibilityMode: highVisibilityMode ?? this.highVisibilityMode,
      textToSpeechEnabled: textToSpeechEnabled ?? this.textToSpeechEnabled,
      voiceFeedbackEnabled: voiceFeedbackEnabled ?? this.voiceFeedbackEnabled,
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      speechLanguage: speechLanguage ?? this.speechLanguage,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      focusHighlightEnabled: focusHighlightEnabled ?? this.focusHighlightEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  // Get font size multiplier based on text size
  double getFontSizeMultiplier() {
    switch (textSize) {
      case TextSize.small:
        return 0.875;
      case TextSize.medium:
        return 1.0;
      case TextSize.large:
        return 1.25;
      default:
        return 1.0;
    }
  }

  // Get high visibility theme colors
  Map<String, Color> getHighVisibilityColors() {
    if (!highVisibilityMode) return {};

    return {
      'primary': const Color(0xFF000000), // Pure black
      'background': const Color(0xFFFFFFFF), // Pure white
      'surface': const Color(0xFFF5F5F5), // Light gray
      'textPrimary': const Color(0xFF000000), // Pure black text
      'textSecondary': const Color(0xFF333333), // Dark gray text
      'border': const Color(0xFF000000), // Black borders
      'error': const Color(0xFFCC0000), // Dark red
      'success': const Color(0xFF006600), // Dark green
    };
  }
}

// Accessibility Service
class AccessibilityService extends ChangeNotifier {
  final FlutterTts _flutterTts;
  final StorageService _storageService;

  AccessibilityPreferences _preferences = AccessibilityPreferences();
  bool _isInitialized = false;

  static const String _preferencesKey = 'accessibility_preferences';

  AccessibilityService(this._storageService) : _flutterTts = FlutterTts() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      // Load preferences
      await _loadPreferences();

      // Initialize TTS
      await _initializeTTS();

      _isInitialized = true;
      notifyListeners();

      debugPrint('AccessibilityService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AccessibilityService: $e');
    }
  }

  Future<void> _initializeTTS() async {
    try {
      await _flutterTts.setLanguage(_preferences.speechLanguage);
      await _flutterTts.setSpeechRate(_preferences.speechRate);
      await _flutterTts.setPitch(_preferences.speechPitch);
      await _flutterTts.setVolume(1.0);

      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS completed');
      });

      // Set error handler
      _flutterTts.setErrorHandler((error) {
        debugPrint('TTS error: $error');
      });
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  // Preferences Management
  Future<void> _loadPreferences() async {
    try {
      final data = await _storageService.getAppState();
      final prefsData = data[_preferencesKey];
      if (prefsData != null) {
        _preferences = AccessibilityPreferences.fromJson(prefsData);
      }
    } catch (e) {
      debugPrint('Error loading accessibility preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      await _storageService.saveAppState({_preferencesKey: _preferences.toJson()});
    } catch (e) {
      debugPrint('Error saving accessibility preferences: $e');
    }
  }

  Future<void> updatePreferences(AccessibilityPreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();

    // Update TTS settings if they changed
    if (_preferences.textToSpeechEnabled) {
      await _updateTTSSettings();
    }

    notifyListeners();
  }

  Future<void> _updateTTSSettings() async {
    try {
      await _flutterTts.setLanguage(_preferences.speechLanguage);
      await _flutterTts.setSpeechRate(_preferences.speechRate);
      await _flutterTts.setPitch(_preferences.speechPitch);
    } catch (e) {
      debugPrint('Error updating TTS settings: $e');
    }
  }

  AccessibilityPreferences get preferences => _preferences;

  // Text-to-Speech Methods
  Future<void> speak(String text) async {
    if (!_preferences.textToSpeechEnabled && !_preferences.voiceFeedbackEnabled) return;

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  Future<void> speakHeadline(String headline) async {
    if (!_preferences.voiceFeedbackEnabled) return;

    final text = 'Headline: $headline';
    await speak(text);
  }

  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  Future<void> pauseSpeaking() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('Error pausing TTS: $e');
    }
  }

  Future<void> resumeSpeaking() async {
    try {
      await _flutterTts.resume();
    } catch (e) {
      debugPrint('Error resuming TTS: $e');
    }
  }

  // Get available TTS languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      debugPrint('Error getting TTS languages: $e');
      return ['en-US'];
    }
  }

  // Get available TTS voices
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      debugPrint('Error getting TTS voices: $e');
      return [];
    }
  }

  // Test TTS functionality
  Future<void> testTTS() async {
    await speak('Testing text-to-speech functionality. This is a test message.');
  }

  // Text Size Methods
  double getScaledFontSize(double baseSize) {
    return baseSize * _preferences.getFontSizeMultiplier();
  }

  TextSize get currentTextSize => _preferences.textSize;

  Future<void> setTextSize(TextSize size) async {
    await updatePreferences(_preferences.copyWith(textSize: size));
  }

  // High Visibility Mode
  bool get isHighVisibilityMode => _preferences.highVisibilityMode;

  Future<void> toggleHighVisibilityMode() async {
    await updatePreferences(_preferences.copyWith(
      highVisibilityMode: !_preferences.highVisibilityMode,
    ));
  }

  Map<String, Color> getHighVisibilityColors() {
    return _preferences.getHighVisibilityColors();
  }

  // Voice Feedback
  bool get isVoiceFeedbackEnabled => _preferences.voiceFeedbackEnabled;

  Future<void> toggleVoiceFeedback() async {
    await updatePreferences(_preferences.copyWith(
      voiceFeedbackEnabled: !_preferences.voiceFeedbackEnabled,
    ));
  }

  // Text-to-Speech Toggle
  bool get isTextToSpeechEnabled => _preferences.textToSpeechEnabled;

  Future<void> toggleTextToSpeech() async {
    await updatePreferences(_preferences.copyWith(
      textToSpeechEnabled: !_preferences.textToSpeechEnabled,
    ));
  }

  // Screen Reader Support
  bool get isScreenReaderEnabled => _preferences.screenReaderEnabled;

  Future<void> toggleScreenReader() async {
    await updatePreferences(_preferences.copyWith(
      screenReaderEnabled: !_preferences.screenReaderEnabled,
    ));
  }

  // Focus Highlight
  bool get isFocusHighlightEnabled => _preferences.focusHighlightEnabled;

  Future<void> toggleFocusHighlight() async {
    await updatePreferences(_preferences.copyWith(
      focusHighlightEnabled: !_preferences.focusHighlightEnabled,
    ));
  }

  // Reduce Motion
  bool get shouldReduceMotion => _preferences.reduceMotion;

  Future<void> toggleReduceMotion() async {
    await updatePreferences(_preferences.copyWith(
      reduceMotion: !_preferences.reduceMotion,
    ));
  }

  // Speech Settings
  Future<void> setSpeechRate(double rate) async {
    await updatePreferences(_preferences.copyWith(speechRate: rate));
  }

  Future<void> setSpeechPitch(double pitch) async {
    await updatePreferences(_preferences.copyWith(speechPitch: pitch));
  }

  Future<void> setSpeechLanguage(String language) async {
    await updatePreferences(_preferences.copyWith(speechLanguage: language));
  }

  // WCAG Contrast Compliance Helpers
  static bool isWCAgCompliant(Color foreground, Color background) {
    // Calculate contrast ratio
    final double contrastRatio = _calculateContrastRatio(foreground, background);
    return contrastRatio >= 4.5; // WCAG AA standard for normal text
  }

  static double _calculateContrastRatio(Color color1, Color color2) {
    final double lum1 = _calculateLuminance(color1);
    final double lum2 = _calculateLuminance(color2);

    final double brightest = lum1 > lum2 ? lum1 : lum2;
    final double darkest = lum1 > lum2 ? lum2 : lum1;

    return (brightest + 0.05) / (darkest + 0.05);
  }

  static double _calculateLuminance(Color color) {
    final double r = color.red / 255.0;
    final double g = color.green / 255.0;
    final double b = color.blue / 255.0;

    final double rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final double gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final double bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  // Accessibility Widget Helpers
  static Widget buildAccessibleText(
    String text, {
    required double baseFontSize,
    required AccessibilityService accessibility,
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      key: key,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: accessibility.getScaledFontSize(baseFontSize),
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: accessibility.isScreenReaderEnabled ? text : null,
    );
  }

  static Widget buildAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required AccessibilityService accessibility,
    Key? key,
    ButtonStyle? style,
    FocusNode? focusNode,
  }) {
    return ElevatedButton(
      key: key,
      onPressed: onPressed,
      style: style?.copyWith(
        minimumSize: MaterialStateProperty.all(const Size(48, 48)),
      ) ?? ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
      focusNode: focusNode,
      child: child,
    );
  }

  // Service Status
  bool get isInitialized => _isInitialized;

  // Cleanup
  Future<void> dispose() async {
    await _flutterTts.stop();
    super.dispose();
  }
}
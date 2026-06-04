import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'dart:developer';

enum AppLanguage { english, french }

class TranslationService {
  // Singleton instance
  static final TranslationService _instance = TranslationService._internal();
  static TranslationService get instance => _instance;

  TranslationService._internal();

  OnDeviceTranslator? _translator;
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  AppLanguage _currentLanguage = AppLanguage.english;

  /// Initialize the service and ensure models are available
  Future<void> init() async {
    // Start download in background without blocking initialization
    _ensureModelDownloaded(TranslateLanguage.french);
  }

  /// Set the target language and recreate the translator
  void setLanguage(AppLanguage language) {
    if (_currentLanguage == language && _translator != null) return;

    _currentLanguage = language;
    _translator?.close();

    if (language == AppLanguage.french) {
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.french,
      );
    } else {
      _translator = null; // No translation needed for English (source)
    }
  }

  /// Downloads the model if not already present
  Future<void> _ensureModelDownloaded(TranslateLanguage language) async {
    final bool isDownloaded = await _modelManager.isModelDownloaded(
      language.bcpCode,
    );
    if (!isDownloaded) {
      log('Downloading ML Model for ${language.name}...');
      await _modelManager.downloadModel(language.bcpCode);
      log('Model downloaded successfully.');
    }
  }

  /// Translates a single string
  Future<String> translate(String text) async {
    if (_currentLanguage == AppLanguage.english ||
        _translator == null ||
        text.trim().isEmpty) {
      return text;
    }

    if (_shouldSkip(text)) return text;

    try {
      return await _translator!.translateText(text);
    } catch (e) {
      log('Translation error: $e');
      return text;
    }
  }

  /// Translates a list of strings
  Future<List<String>> translateList(List<String> list) async {
    List<String> translatedList = [];
    for (var item in list) {
      translatedList.add(await translate(item));
    }
    return translatedList;
  }

  /// Recursively walks and translates a JSON map
  Future<Map<String, dynamic>> translateMap(Map<String, dynamic> map) async {
    Map<String, dynamic> result = {};

    for (var entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        result[key] = await translate(value);
      } else if (value is Map<String, dynamic>) {
        result[key] = await translateMap(value);
      } else if (value is List) {
        result[key] = await _translateListRecursive(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /// Recursive helper for lists
  Future<List<dynamic>> _translateListRecursive(List<dynamic> list) async {
    List<dynamic> result = [];
    for (var item in list) {
      if (item is String) {
        result.add(await translate(item));
      } else if (item is Map<String, dynamic>) {
        result.add(await translateMap(item));
      } else if (item is List) {
        result.add(await _translateListRecursive(item));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// Logic to skip translation for non-human readable strings
  bool _shouldSkip(String text) {
    // 1. Skip if it's purely numeric (with optional decimals/signs)
    if (RegExp(r'^-?[0-9.]+$').hasMatch(text)) return true;

    // 2. Skip if it's a date (YYYY-MM-DD or similar)
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return true;

    // 3. Skip URLs
    if (text.startsWith('http://') || text.startsWith('https://')) return true;

    // 4. Skip short status codes/keys
    final statusCodes = {
      'active',
      'verified',
      'bike',
      'car',
      'cod',
      'pending',
      'cancelled',
      'completed',
    };
    if (statusCodes.contains(text.toLowerCase())) return true;

    // 5. Skip very short strings (usually IDs or codes)
    if (text.length <= 2 && !RegExp(r'[a-zA-Z]').hasMatch(text)) return true;

    return false;
  }

  /// Dispose the translator
  void dispose() {
    _translator?.close();
  }
}

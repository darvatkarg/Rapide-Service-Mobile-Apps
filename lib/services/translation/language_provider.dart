import 'package:flutter/material.dart';
import 'translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  Map<String, dynamic>? _rawHomeData;
  Map<String, dynamic>? _translatedHomeData;
  bool _isLoading = false;
  AppLanguage _lastTranslatedLanguage = AppLanguage.english;

  bool get isLoading => _isLoading;

  /// Returns translated data if available and French is active, otherwise raw
  Map<String, dynamic>? getHomeData(AppLanguage currentLanguage) {
    // If language changed since last translation, trigger a new translation
    if (currentLanguage == AppLanguage.french && 
        _rawHomeData != null && 
        (_translatedHomeData == null || _lastTranslatedLanguage != AppLanguage.french)) {
      _translateCurrentData(currentLanguage);
    }
    
    if (currentLanguage == AppLanguage.french) {
      return _translatedHomeData ?? _rawHomeData;
    }
    return _rawHomeData;
  }

  /// Entry point for new API data
  Future<void> setHomeData(Map<String, dynamic> raw, AppLanguage currentLanguage) async {
    _rawHomeData = raw;
    _translatedHomeData = null; // Reset translation for new data

    if (currentLanguage == AppLanguage.french) {
      await _translateCurrentData(currentLanguage);
    } else {
      notifyListeners();
    }
  }

  /// Private helper to perform the translation
  Future<void> _translateCurrentData(AppLanguage language) async {
    if (_rawHomeData == null || _isLoading) return;

    _isLoading = true;
    _lastTranslatedLanguage = language;
    // We don't call notifyListeners here if we are inside a build phase, 
    // but _translateCurrentData is usually called from setHomeData or via microtask
    
    Future.microtask(() async {
      try {
        _translatedHomeData = await TranslationService.instance.translateMap(_rawHomeData!);
      } catch (e) {
        debugPrint('Error translating home data: $e');
        _translatedHomeData = null;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Translate a single string on the fly
  Future<String> translateString(String text) async {
    return await TranslationService.instance.translate(text);
  }
}

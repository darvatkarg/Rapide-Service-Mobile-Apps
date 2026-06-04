import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'dart:developer' as developer;

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  OnDeviceTranslator? _translator;
  bool _isDownloading = false;

  /// Fields that should NEVER be translated
  final Set<String> _ignoredFields = {
    'pb_id', 'user_id', 'address_id', 'intercity_id',
    'pb_number', 'pb_deliveryCharge',
    'sd_lat', 'sd_long', 'rc_lat', 'rc_long',
    'sd_mobile', 'rc_mobile', 'sd_email',
    'sd_name', 'rc_name',
    'created_at', 'updated_at', 'assigned_at',
    'out_for_delivery', 'completed_at', 'cancelled_at',
  };

  /// Set the language and initialize the translator model
  Future<void> setLanguage(String targetLangCode) async {
    // English is the source, no translation needed
    if (targetLangCode == 'en') {
      _translator?.close();
      _translator = null;
      return;
    }

    TranslateLanguage? targetLanguage;
    switch (targetLangCode) {
      case 'fr':
        targetLanguage = TranslateLanguage.french;
        break;
      case 'hi':
        targetLanguage = TranslateLanguage.hindi;
        break;
      default:
        targetLanguage = null;
    }

    if (targetLanguage == null) {
      developer.log('Unsupported language code: $targetLangCode', name: 'TranslationService');
      _translator?.close();
      _translator = null;
      return;
    }

    _isDownloading = true;
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      // Ensure the model is downloaded
      await modelManager.downloadModel(targetLanguage.bcpCode);

      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      developer.log('Failed to initialize translator: $e', name: 'TranslationService');
      _translator = null;
    } finally {
      _isDownloading = false;
    }
  }

  /// Translate a single string
  Future<String> translate(String text) async {
    if (_translator == null || text.trim().isEmpty) {
      return text;
    }
    
    // Wait if model is currently downloading
    while (_isDownloading) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    try {
      return await _translator!.translateText(text);
    } catch (e) {
      developer.log('Translation failed: $e', name: 'TranslationService');
      return text; // Fallback to original
    }
  }

  /// Translate a single parcel object, skipping ignored fields
  Future<Map<String, dynamic>> translateParcel(Map<String, dynamic> parcel) async {
    if (_translator == null) return parcel;

    final translatedParcel = <String, dynamic>{...parcel};

    for (var key in translatedParcel.keys) {
      if (_ignoredFields.contains(key)) continue;

      final value = translatedParcel[key];
      if (value is String && value.trim().isNotEmpty) {
        translatedParcel[key] = await translate(value);
      } else if (value is Map<String, dynamic>) {
        translatedParcel[key] = await translateParcel(value);
      } else if (value is List) {
        // Basic list translation if needed, though mostly primitives in parcel
        translatedParcel[key] = await Future.wait(
          value.map((e) async {
            if (e is String) return await translate(e);
            if (e is Map<String, dynamic>) return await translateParcel(e);
            return e;
          })
        );
      }
    }
    return translatedParcel;
  }

  /// Translate a list of parcel objects
  Future<List<dynamic>> translateParcelList(List<dynamic> parcels) async {
    if (_translator == null) return parcels;

    return await Future.wait(
      parcels.map((parcel) async {
        if (parcel is Map<String, dynamic>) {
          return await translateParcel(parcel);
        }
        return parcel;
      })
    );
  }

  void dispose() {
    _translator?.close();
  }
}

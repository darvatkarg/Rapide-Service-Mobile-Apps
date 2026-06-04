/// =======================================================================
/// TRANSLATION SERVICE USAGE EXAMPLES
/// =======================================================================
///
/// Ensure you initialize the LanguageManager and TranslationService early
/// in your app lifecycle (e.g., in main.dart or splash screen).
/// 
/// Example Initialization:
/// ```dart
/// await LanguageManager.init();
/// await TranslationService().setLanguage(LanguageManager.currentLanguage);
/// ```

import 'package:hyper_local/services/translation_service.dart';
import 'package:dio/dio.dart';

class ParcelUsageExamples {
  final Dio _dio = Dio();
  final TranslationService _translationService = TranslationService();

  /// ---------------------------------------------------------------------
  /// EXAMPLE 1: Fetching and translating an Ongoing Parcels List
  /// ---------------------------------------------------------------------
  Future<List<dynamic>> fetchOngoingParcels() async {
    try {
      final response = await _dio.get('https://your-api.com/ongoing-parcels');
      
      if (response.data['success'] == true) {
        List<dynamic> rawParcels = response.data['data'];
        
        // Pass the list to TranslationService. It will iterate over each parcel,
        // ignore the specified IDs, coordinates, and timestamps, and translate
        // the remaining fields.
        List<dynamic> translatedParcels = await _translationService.translateParcelList(rawParcels);
        
        return translatedParcels;
      }
      return [];
    } catch (e) {
      // Example 3: Translating an error message
      final translatedError = await _translationService.translate('Failed to fetch ongoing parcels: $e');
      throw Exception(translatedError);
    }
  }

  /// ---------------------------------------------------------------------
  /// EXAMPLE 2: Fetching and translating a Single Parcel Detail
  /// ---------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchParcelDetails(String parcelId) async {
    try {
      final response = await _dio.get('https://your-api.com/parcel/$parcelId');
      
      if (response.data['success'] == true) {
        Map<String, dynamic> rawParcel = response.data['data']['parcel'];
        
        // Pass the single map to TranslationService.
        Map<String, dynamic> translatedParcel = await _translationService.translateParcel(rawParcel);
        
        return translatedParcel;
      }
      throw Exception('Parcel not found');
    } catch (e) {
      // Example 3: Translating an error message
      final translatedError = await _translationService.translate('Failed to fetch parcel details: $e');
      throw Exception(translatedError);
    }
  }
}

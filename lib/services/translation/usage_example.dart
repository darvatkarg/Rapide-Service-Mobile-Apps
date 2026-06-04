import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'translation_service.dart';
import 'language_provider.dart';
import '../../config/localization_service.dart';

/// 1. USAGE IN HOME SCREEN
class HomeTranslationExample extends StatelessWidget {
  const HomeTranslationExample({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. LISTEN TO BOTH PROVIDERS
    final localization = context.watch<LocalizationService>();
    final languageProvider = context.watch<LanguageProvider>();

    // Determine current AppLanguage enum from LocalizationService code
    final currentLang = localization.currentLanguageCode == 'fr' 
        ? AppLanguage.french 
        : AppLanguage.english;

    // 3. GET DATA (It will auto-translate if currentLang is French)
    final data = languageProvider.getHomeData(currentLang);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Translation'),
        actions: [
          // 4. THE TOGGLE (Changes hardcoded strings AND dynamic JSON)
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final newCode = localization.currentLanguageCode == 'en' ? 'fr' : 'en';
              localization.changeLanguage(newCode);
            },
          ),
        ],
      ),
      body: languageProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : data == null 
              ? const Center(child: Text("No Data. Press FAB to simulate API."))
              : ListView(
                  children: [
                    Text("Current Lang: ${localization.currentLanguageCode}"),
                    const Divider(),
                    Text("JSON DATA:"),
                    Text(data.toString()),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 5. SIMULATING API CALL
          final rawJson = {
            "success": true,
            "data": [
              {
                "key": "profile",
                "value": {"fullName": "John Doe", "status": "active"}
              },
              {
                "key": "summary",
                "value": {"message": "Welcome to your dashboard", "today_earnings": "150.00"}
              }
            ]
          };

          // Pass the current language so it knows whether to translate immediately
          context.read<LanguageProvider>().setHomeData(rawJson, currentLang);
        },
        child: const Icon(Icons.download),
      ),
    );
  }
}

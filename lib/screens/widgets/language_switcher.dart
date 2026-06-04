import 'package:flutter/material.dart';
import 'package:hyper_local/services/language_manager.dart';
import 'package:hyper_local/services/translation_service.dart';

class LanguageSwitcher extends StatefulWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageSwitcher({super.key, this.onLanguageChanged});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  bool _isLoading = false;

  Future<void> _changeLanguage(String? langCode) async {
    if (langCode == null || langCode == LanguageManager.currentLanguage) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Save language preference
      await LanguageManager.setLanguage(langCode);

      // 2. Initialize translation model (downloads if needed)
      await TranslationService().setLanguage(langCode);

      // 3. Notify parent to refresh UI
      widget.onLanguageChanged?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: LanguageManager.currentLanguage,
        icon: const Icon(Icons.language),
        onChanged: _changeLanguage,
        items: LanguageManager.supportedLanguages.map((lang) {
          return DropdownMenuItem<String>(
            value: lang['code'],
            child: Text(lang['name'] ?? ''),
          );
        }).toList(),
      ),
    );
  }
}

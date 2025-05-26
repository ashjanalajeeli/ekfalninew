import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state_provider.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier(ref);
});

class LanguageNotifier extends StateNotifier<Locale> {
  final Ref ref;
  
  LanguageNotifier(this.ref) : super(const Locale('en')) {
    _loadLanguage();
  }

  static const _languageKey = 'language_code';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    state = Locale(languageCode);
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    state = Locale(languageCode);
    
    // Trigger app refresh when language changes
    ref.read(appStateProvider.notifier).refreshApp();
  }

  bool get isArabic => state.languageCode == 'ar';
} 
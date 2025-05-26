import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../screens/profile.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('العربية'),
              leading: Radio<String>(
                value: 'ar',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.translate('settings')),
        leading: isArabic ? null : const BackButton(),
        actions: [
          if (isArabic) const BackButton(),
        ],
      ),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          children: [
            ListTile(
              title: Text(tr.translate('profile')),
              leading: const Icon(Icons.person, color: Colors.teal),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(tr.translate('change_language')),
              leading: const Icon(Icons.language, color: Colors.teal),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLanguageDialog(context, ref),
              subtitle: Text(isArabic ? 'العربية' : 'English'),
            ),
            ListTile(
              title: Text(tr.translate('dark_mode')),
              leading: const Icon(Icons.dark_mode),
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
            ),
            ListTile(
              title: Text(tr.translate('logout')),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () {
                // TODO: Implement logout functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}

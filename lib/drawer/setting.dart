import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../screens/profile.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.translate('settings')),
          leading: isArabic ? null : BackButton(),
          actions: [
            if (isArabic) BackButton(),
          ],
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text(tr.translate('profile')),
              leading: const Icon(Icons.person),
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
              leading: const Icon(Icons.language),
              trailing: Switch(
                value: isArabic,
                onChanged: (bool value) {
                  ref.read(languageProvider.notifier).setLanguage(
                    value ? 'ar' : 'en',
                  );
                },
              ),
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
              leading: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}

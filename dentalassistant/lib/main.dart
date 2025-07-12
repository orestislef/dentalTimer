import 'package:dentalassistant/screens/welcome.dart';
import 'package:dentalassistant/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'helpers/language.dart';
import 'helpers/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SharedPreferencesHelper().ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: LanguageHelper.getAvailableLocales(),
      path: LanguageHelper.getAssetsPath(),
      fallbackLocale: LanguageHelper.getAvailableLocales().first,
      child: const DentalApp(),
    ),
  );
}

class DentalApp extends StatelessWidget {
  const DentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dentist App',
      // Light theme
      theme: AppTheme.lightTheme,
      // Dark theme
      darkTheme: AppTheme.darkTheme,
      // Automatically follow system theme
      themeMode: ThemeMode.system,
      home: const WelcomePage(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
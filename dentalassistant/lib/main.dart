import 'package:dentalassistant/screens/admin/admin.dart';
import 'package:dentalassistant/screens/welcome.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'helpers/language_helper.dart';
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
        child: const DentalApp()),
  );
}

class DentalApp extends StatelessWidget {
  const DentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dentist App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomePage(),
    );
  }
}

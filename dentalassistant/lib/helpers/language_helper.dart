import 'package:flutter/material.dart';


class LanguageHelper {
  static String getLanguageUsedInApp(BuildContext context) {
    String languageCode = Localizations.localeOf(context).languageCode;
    return languageCode;
  }

  static String getLanguageUsedInAppLocale(BuildContext context) {
    return Localizations.localeOf(context).toLanguageTag();
  }

  static String getLanguageUsedInAppISO(BuildContext context) {
    return Localizations.localeOf(context).toLanguageTag().replaceAll('-', "_");
  }

  static int getLanguageUsedInAppInt(BuildContext context) {
    String languageCode = Localizations.localeOf(context).languageCode;
    switch (languageCode) {
      case 'en-US':
      case 'en_US':
      case 'en':
        return 1;
      case 'el-GR':
      case 'el_GR':
      case 'el':
        return 2;
      default:
        return 0;
    }
  }
  static String getLanguage(String languageTag) {
    switch (languageTag) {
      case 'en-US':
        return 'English';
      case 'el-GR':
        return 'Ελληνικά';
      default:
        return 'Unknown';
    }
  }

  static List<Locale> getAvailableLocales() {
    return [
      const Locale('en', 'US'),
      const Locale('el', 'GR'),
    ];
  }

  static String getAssetsPath() {
    return 'assets/translations';
  }
}

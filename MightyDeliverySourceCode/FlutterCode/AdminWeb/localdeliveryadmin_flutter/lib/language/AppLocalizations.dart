import 'package:flutter/material.dart';
import 'package:local_delivery_admin/language/BaseLanguage.dart';
import 'package:local_delivery_admin/language/LanguageEn.dart';
import 'package:local_delivery_admin/models/LanguageDataModel.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      default:
        return LanguageEn();
    }
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}

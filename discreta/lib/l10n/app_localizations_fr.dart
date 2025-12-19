// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get noInternetTitle => 'Pas de connexion Internet';

  @override
  String get noInternetConnection =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get retry => 'Réessayer';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get noInternetTitle => 'No Internet connection';

  @override
  String get noInternetConnection =>
      'Please verify your Internet connection and try again.';

  @override
  String get retry => 'Retry';
}

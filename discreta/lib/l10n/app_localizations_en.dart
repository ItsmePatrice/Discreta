// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get projectName => 'Discreta';

  @override
  String get noInternetTitle => 'No Internet connection';

  @override
  String get noInternetConnection =>
      'Please verify your Internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get slogan => 'Safety in complete discretion';

  @override
  String get brandMessage =>
      'One gesture. One alert. Reliable support,\n in complete discretion.';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInError => 'Sign in error';

  @override
  String get signInErrorMessage =>
      'We couldn’t complete your sign in. Please try again.';

  @override
  String get signInFailed => 'Sign in failed';

  @override
  String get signInFailedMessage =>
      'An unexpected error occurred. Please check your Internet connection or try again later.';

  @override
  String get home => 'Home';

  @override
  String get contacts => 'Contacts';

  @override
  String get guide => 'Guide';

  @override
  String get profile => 'Profile';
}

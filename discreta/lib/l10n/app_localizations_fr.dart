// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get projectName => 'Discreta';

  @override
  String get noInternetTitle => 'Pas de connexion Internet';

  @override
  String get noInternetConnection =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get retry => 'Réessayer';

  @override
  String get slogan => 'La sécurité, en toute discretion';

  @override
  String get brandMessage =>
      'Un geste. Une alerte. Un soutien fiable,\n en toute discrétion.';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signInError => 'Erreur de connexion';

  @override
  String get signInErrorMessage =>
      'Nous n’avons pas pu compléter la connexion. Veuillez réessayer.';

  @override
  String get signInFailed => 'Échec de la connexion';

  @override
  String get signInFailedMessage =>
      'Une erreur inattendue est survenue. Veuillez réessayer plus tard ou vérifier votre connexion Internet.';

  @override
  String get home => 'Accueil';

  @override
  String get contacts => 'Contacts';

  @override
  String get guide => 'Guide';

  @override
  String get profile => 'Profil';

  @override
  String get greeting => 'Bonjour';

  @override
  String get discretaWelcomeMessage => 'Discreta est là avec vous.';

  @override
  String get status => 'status';

  @override
  String get connected => 'connecté';

  @override
  String get notConnected => 'non connecté';

  @override
  String get safetyTimer => 'Minuteur de sécurité';

  @override
  String get activateProtection => 'Activer la protection';

  @override
  String get stop => 'Arrêter';

  @override
  String get alertIn => 'Vos contacts seront alertés dans ...';

  @override
  String get protection => 'Protection';
}

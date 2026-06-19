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
  String get signIn => 'Se connecter';

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
  String get discretaWelcomeMessage => 'Vous n\'êtes pas seule.';

  @override
  String get discretaReassuranceMessage => 'Discreta veille discrètement.';

  @override
  String get status => 'status';

  @override
  String get connected => 'Connecté';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get safetyTimer => 'Minuteur de sécurité';

  @override
  String get start => 'Démarrer';

  @override
  String get stop => 'Arrêter';

  @override
  String get alertIn => 'Vos contacts seront alertés dans';

  @override
  String get protection => 'Protection';

  @override
  String get contactsAndAlert => 'Contacts & Alerte';

  @override
  String get alertMessage => 'Message d\'alerte';

  @override
  String get alertMessagePlaceholder => 'Écrire votre message d\'alerte ici...';

  @override
  String get addContact => 'Ajouter un contact';

  @override
  String get maxContactMessage =>
      'Vous pouvez ajouter un maximum de 10 contacts';

  @override
  String get name => 'Nom';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get editContact => 'Modifier le contact';

  @override
  String get save => 'Sauvegarder';

  @override
  String get invalidPhoneNumberMessage =>
      'Veuillez entrer un numéro valide à 10 chiffres.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get settings => 'Paramètres';

  @override
  String get unknownError => 'Erreur inconnu';

  @override
  String get language => 'langue';

  @override
  String get timeBeforeAutomaticAlert => 'Durée avant alerte automatique';

  @override
  String get success => 'Succès';

  @override
  String get alertMessageSaved => 'Message d\'alerte enregistré.';

  @override
  String get confirmDeleteContact =>
      'Êtes-vous sûr de vouloir supprimer ce contact?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get howToUseDiscreta => 'Comment utiliser Discreta';

  @override
  String get step4 =>
      'Ajoutez votre message d’alerte et vos contacts de confiance dans l’onglet Contacts.';

  @override
  String get step6 =>
      'Appuyez deux fois sur le bouton pour envoyer une alerte immédiatement lorsqu\'il est allumé.';

  @override
  String get step6Observation =>
      'Vos contacts devraient recevoir votre message d’alerte avec votre position en temps réel. N’oubliez pas de confirmer que vous êtes en sécurité dans l’onglet Accueil pour arrêter le partage de votre position si la situation se calme.';

  @override
  String get step7 =>
      'Même si votre écran est fermé, assurez-vous que l\'application est ouverte et que votre téléphone est toujours connecté à Internet et au bouton.';

  @override
  String get step8 =>
      'Si vous utilisez Android, accédez à Paramètres → Applications → Discreta → Batterie et sélectionnez \"Sans restriction\".';

  @override
  String get step9 => 'Vous êtes prête.';

  @override
  String get batteryManagmentDirectives =>
      'Pour permettre Discreta de fonctionner quand votre écran est fermé, accédez à Paramètres → Applications → Discreta → Batterie et sélectionnez \"Sans restriction\".';

  @override
  String get safetyAlerts => 'Sécurité et alertes';

  @override
  String get sendAlert => 'Envoyer une alerte';

  @override
  String get alertSent => 'L\'alerte a été envoyée.';

  @override
  String get confirmSendAlert => 'Êtes-vous sûr de vouloir envoyer une alerte?';

  @override
  String get alertNoSent =>
      'L’alerte n’a pas été envoyée. Ajoutez au moins un contact pour continuer.';

  @override
  String get error => 'Erreur';

  @override
  String get locationRequired => 'Localisation précise requise';

  @override
  String get locationRequiredMessage =>
      'Nous avons besoin de votre localisation précise pour permettre à Discreta de fonctionner correctement et d’envoyer des alertes si nécessaire. Vous pouvez activer l’accès à la localisation à tout moment dans les paramètres de votre appareil.';

  @override
  String get locationPermanentlyDeniedMessage =>
      'L’accès à la localisation précise a été désactivé. Pour utiliser Discreta, veuillez activer l’autorisation de localisation dans les paramètres de votre appareil.';

  @override
  String get locationAccessReason =>
      'Discreta a besoin d’accéder à votre position afin de partager votre localisation en temps réel avec vos contacts de confiance en cas de danger.';

  @override
  String get noLocationConsequence =>
      'Sans l’accès à la localisation, Discreta ne peut pas fonctionner.';

  @override
  String get enableLocation => 'Activer la localisation';

  @override
  String get noTrustedContact => 'Aucun contact de confiance trouvé';

  @override
  String get enableLocationServices =>
      'Les services de localisation sont désactivés. Veuillez activer la localisation dans les paramètres de votre appareil pour continuer à utiliser Discreta.';

  @override
  String get pleaseAddContacts => 'Veuillez ajouter un contact de confiance';

  @override
  String get safetyConfirmed => 'Tout va bien';

  @override
  String get initializing => 'Initialisation…';

  @override
  String get scanning => 'Recherche de boutons…';

  @override
  String get safetyDevice => 'Dispositif de sécurité';

  @override
  String get pairButton => 'Associer le bouton';

  @override
  String get pairingInstructions =>
      'Après avoir appuyé sur Scanner, maintenez votre bouton enfoncé pendant 7 secondes pour l’associer.';

  @override
  String get stopScanning => 'Arrêter la recherche';

  @override
  String get scanForButton => 'Scanner';

  @override
  String get connectionSuccess =>
      'Votre bouton est connecté et déclenchera une alerte lorsqu’il sera appuyé deux fois.';

  @override
  String get tapToConnect => 'Touchez pour connecter';

  @override
  String get firstName => 'Prénom';

  @override
  String get email => 'Email';

  @override
  String get accessCode => 'Code d\'accès';

  @override
  String get signInErrorInvalidCredentials =>
      'Échec de la connexion. Veuillez vérifier que votre prénom, courriel et code d\'accès sont corrects.';

  @override
  String get signInErrorMaxUsesOrExpired =>
      'Ce code d\'accès a atteint son nombre maximal d\'utilisations ou est invalide.';

  @override
  String get signInErrorInvalidEmail =>
      'Veuillez entrer une adresse courriel valide.';

  @override
  String get unfilledAreas =>
      'Veuillez vous assurer d\'entrer un prénom, une adresse courriel et un code d\'accès.';

  @override
  String get locationAlwaysRequiredMessage =>
      'Discreta nécessite l’accès à la localisation « Toujours autoriser » pour fonctionner correctement. Si ce n\'est pas déja fait, Veuillez ouvrir les réglages et sélectionner : Localisation → Toujours autoriser pour Discreta.';

  @override
  String get reminder => 'Rappel';

  @override
  String get connectionReruirments =>
      'Veuillez vous assurer de ne pas fermer l’application et de rester toujours connecté à Internet, avec le Bluetooth activé.';
}

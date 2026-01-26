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

  @override
  String get greeting => 'Hello';

  @override
  String get discretaWelcomeMessage => 'You\'re not alone.';

  @override
  String get discretaReassuranceMessage => 'Discreta is quietly watching.';

  @override
  String get status => 'status';

  @override
  String get connected => 'bracelet connected';

  @override
  String get notConnected => 'bracelet not connected';

  @override
  String get safetyTimer => 'Safety timer';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get alertIn => 'Your contacts will be alerted in';

  @override
  String get protection => 'Protection';

  @override
  String get contactsAndAlert => 'Contacts & Alert';

  @override
  String get alertMessage => 'Alert message';

  @override
  String get alertMessagePlaceholder => 'Type your alert message here ...';

  @override
  String get addContact => 'Add contact';

  @override
  String get maxContactMessage => 'You can only add up to 5 contacts.';

  @override
  String get name => 'Name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get save => 'Save';

  @override
  String get invalidPhoneNumberMessage =>
      'Please enter a valid 10-digit number.';

  @override
  String get signOut => 'Sign out';

  @override
  String get settings => 'Settings';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get language => 'language';

  @override
  String get timeBeforeAutomaticAlert => 'Time before automatic alert';

  @override
  String get success => 'Success';

  @override
  String get alertMessageSaved => 'Alert message saved.';

  @override
  String get confirmDeleteContact =>
      'Are you sure you want to delete this contact?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get howToUseDiscreta => 'How to use Discreta';

  @override
  String get step1 =>
      'Hold the bracelet\'s power button for 3 seconds to turn it on.';

  @override
  String get step2 =>
      'Tap the bracelet\'s power button 3 times to turn on pairing mode.';

  @override
  String get step2Observations =>
      'You should see a blue light blinking under the bracelet.';

  @override
  String get step3 => 'Connect your phone to the bracelet trough bluetooth.';

  @override
  String get step3Observations =>
      'The light should turn back to green and you will see the bracelet status as connected on the Home page.';

  @override
  String get step4 =>
      'Add you alert message and your trusted contacts on the Contacts tab.';

  @override
  String get step6 =>
      'Double tap the power button on the bracelet to send an alert immediately.';

  @override
  String get step6Observation =>
      'Your contacts should receive your alert message with your real-time location, and the bracelet should vibrate on your wrist as a sign of confirmation. Don\'t forget to confirm your safety on the Home tab.';

  @override
  String get step7 =>
      'Make sure that your phone is always connected to the internet while using the bracelet.';

  @override
  String get step8 =>
      'Hold the power button for 3 seconds to switch off the bracelet.';

  @override
  String get step9 => 'You\'re good to go.';

  @override
  String get powerSetup => 'Power & Setup';

  @override
  String get pairingConnection => 'Pairing & Connection';

  @override
  String get safetyAlerts => 'Safety & Alerts';

  @override
  String get sendAlert => 'Send alert';

  @override
  String get alertSent => 'Alert has been sent.';

  @override
  String get confirmSendAlert =>
      'Are you sure you want to send an alert to your contacts?';

  @override
  String get alertNoSent =>
      'The alert wasn\'t sent. Please make sure you have at least 1 saved contact.';

  @override
  String get error => 'Error';

  @override
  String get locationRequired => 'Location required';

  @override
  String get locationAccessReason =>
      'Discreta requires access to your location to share your real-time position with trusted contacts in case of danger.';

  @override
  String get noLocationConsequence =>
      'Without location access, Discreta cannot function.';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get noTrustedContact => 'No trusted contact found';

  @override
  String get pleaseAddContacts => 'Please add a trusted contact';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Discreta'**
  String get projectName;

  /// No description provided for @noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet connection'**
  String get noInternetTitle;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Please verify your Internet connection and try again.'**
  String get noInternetConnection;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Safety in complete discretion'**
  String get slogan;

  /// No description provided for @brandMessage.
  ///
  /// In en, this message translates to:
  /// **'One gesture. One alert. Reliable support,\n in complete discretion.'**
  String get brandMessage;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInError.
  ///
  /// In en, this message translates to:
  /// **'Sign in error'**
  String get signInError;

  /// No description provided for @signInErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t complete your sign in. Please try again.'**
  String get signInErrorMessage;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get signInFailed;

  /// No description provided for @signInFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please check your Internet connection or try again later.'**
  String get signInFailedMessage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greeting;

  /// No description provided for @discretaWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re not alone.'**
  String get discretaWelcomeMessage;

  /// No description provided for @discretaReassuranceMessage.
  ///
  /// In en, this message translates to:
  /// **'Discreta is quietly watching.'**
  String get discretaReassuranceMessage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'status'**
  String get status;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'bracelet connected'**
  String get connected;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'bracelet not connected'**
  String get notConnected;

  /// No description provided for @safetyTimer.
  ///
  /// In en, this message translates to:
  /// **'Safety timer'**
  String get safetyTimer;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @alertIn.
  ///
  /// In en, this message translates to:
  /// **'Your contacts will be alerted in'**
  String get alertIn;

  /// No description provided for @protection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get protection;

  /// No description provided for @contactsAndAlert.
  ///
  /// In en, this message translates to:
  /// **'Contacts & Alert'**
  String get contactsAndAlert;

  /// No description provided for @alertMessage.
  ///
  /// In en, this message translates to:
  /// **'Alert message'**
  String get alertMessage;

  /// No description provided for @alertMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type your alert message here ...'**
  String get alertMessagePlaceholder;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContact;

  /// No description provided for @maxContactMessage.
  ///
  /// In en, this message translates to:
  /// **'You can only add up to 5 contacts.'**
  String get maxContactMessage;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @invalidPhoneNumberMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit number.'**
  String get invalidPhoneNumberMessage;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @timeBeforeAutomaticAlert.
  ///
  /// In en, this message translates to:
  /// **'Time before automatic alert'**
  String get timeBeforeAutomaticAlert;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @alertMessageSaved.
  ///
  /// In en, this message translates to:
  /// **'Alert message saved.'**
  String get alertMessageSaved;

  /// No description provided for @confirmDeleteContact.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this contact?'**
  String get confirmDeleteContact;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @howToUseDiscreta.
  ///
  /// In en, this message translates to:
  /// **'How to use Discreta'**
  String get howToUseDiscreta;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Hold the bracelet\'s power button for 3 seconds to turn it on.'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Tap the bracelet\'s power button 3 times to turn on pairing mode.'**
  String get step2;

  /// No description provided for @step2Observations.
  ///
  /// In en, this message translates to:
  /// **'You should see a blue light blinking under the bracelet.'**
  String get step2Observations;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Connect your phone to the bracelet trough bluetooth.'**
  String get step3;

  /// No description provided for @step3Observations.
  ///
  /// In en, this message translates to:
  /// **'The light should turn back to green and you will see the bracelet status as connected on the Home page.'**
  String get step3Observations;

  /// No description provided for @step4.
  ///
  /// In en, this message translates to:
  /// **'Add you alert message and your trusted contacts on the Contacts tab.'**
  String get step4;

  /// No description provided for @step6.
  ///
  /// In en, this message translates to:
  /// **'Double tap the power button on the bracelet to send an alert immediately.'**
  String get step6;

  /// No description provided for @step6Observation.
  ///
  /// In en, this message translates to:
  /// **'Your contacts should receive your alert message with your real-time location, and the bracelet should vibrate on your wrist as a sign of confirmation. Don\'t forget to confirm your safety on the Home tab.'**
  String get step6Observation;

  /// No description provided for @step7.
  ///
  /// In en, this message translates to:
  /// **'Make sure that your phone is always connected to the internet while using the bracelet.'**
  String get step7;

  /// No description provided for @step8.
  ///
  /// In en, this message translates to:
  /// **'Hold the power button for 3 seconds to switch off the bracelet.'**
  String get step8;

  /// No description provided for @step9.
  ///
  /// In en, this message translates to:
  /// **'You\'re good to go.'**
  String get step9;

  /// No description provided for @powerSetup.
  ///
  /// In en, this message translates to:
  /// **'Power & Setup'**
  String get powerSetup;

  /// No description provided for @pairingConnection.
  ///
  /// In en, this message translates to:
  /// **'Pairing & Connection'**
  String get pairingConnection;

  /// No description provided for @safetyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Safety & Alerts'**
  String get safetyAlerts;

  /// No description provided for @sendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send alert'**
  String get sendAlert;

  /// No description provided for @alertSent.
  ///
  /// In en, this message translates to:
  /// **'Alert has been sent.'**
  String get alertSent;

  /// No description provided for @confirmSendAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to send an alert to your contacts?'**
  String get confirmSendAlert;

  /// No description provided for @alertNoSent.
  ///
  /// In en, this message translates to:
  /// **'The alert wasn\'t sent. Please make sure you have at least 1 saved contact.'**
  String get alertNoSent;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location required'**
  String get locationRequired;

  /// No description provided for @locationAccessReason.
  ///
  /// In en, this message translates to:
  /// **'Discreta requires access to your location to share your real-time position with trusted contacts in case of danger.'**
  String get locationAccessReason;

  /// No description provided for @noLocationConsequence.
  ///
  /// In en, this message translates to:
  /// **'Without location access, Discreta cannot function.'**
  String get noLocationConsequence;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

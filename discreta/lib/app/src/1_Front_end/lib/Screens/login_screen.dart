import 'dart:io';

import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/auth_error_codes.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Classes/auth_exception.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_button.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/main_shell.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/notification_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:discreta/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _accessCodeController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _changeLanguage(Locale locale) {
    myAppKey.currentState?.setLocale(locale);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<bool> _checkLocationPermission() async {
    // 1. Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.locationRequired,
        message: AppLocalizations.of(context)!.enableLocationServices,
      );
      return false;
    }

    // 2. Check current permission state
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. If not determined, request permission (this is the ONLY place you prompt)
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 4. If still denied → STOP (do NOT send to settings automatically)
    if (permission == LocationPermission.denied) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.locationRequired,
        message: AppLocalizations.of(context)!.locationRequiredMessage,
      );
      return false;
    }

    // 5. If permanently denied → show explanation + optional manual button
    if (permission == LocationPermission.deniedForever) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.locationRequired,
        message: AppLocalizations.of(context)!.locationPermanentlyDeniedMessage,
      );
      return false;
    }

    // 6. iOS precise location handling (optional but good practice)
    if (Platform.isIOS) {
      final accuracy = await Geolocator.getLocationAccuracy();
      if (accuracy == LocationAccuracyStatus.reduced) {
        await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: "DiscreteTracking",
        );
      }
    }

    // 7. Background permission request (Android only, after success)
    if (permission == LocationPermission.whileInUse && Platform.isAndroid) {
      await _requestBackgroundPermission();
    }

    return true;
  }

  Future<void> _requestBackgroundPermission() async {
    if (Platform.isAndroid) {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signIn() async {
    // check if the user gave access to their precise location
    // If not, tell them to go to their settings and activate it

    // If they gave access to their precise location, then they may move to
    // the next plan

    final grantedPermision = await _checkLocationPermission();

    if (!grantedPermision) return;

    final firstName = _firstNameController.text.trim();
    final email = _emailController.text.trim();
    final accessCode = _accessCodeController.text.trim();

    if (firstName.isEmpty || email.isEmpty || accessCode.isEmpty) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.signInError,
        message: AppLocalizations.of(context)!.unfilledAreas,
      );
      return;
    }

    if (!_isValidEmail(email)) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.signInError,
        message: AppLocalizations.of(context)!.signInErrorInvalidEmail,
      );
      return;
    }

    _setIsLoading(true);
    try {
      await AuthService.instance.fetchOrCreateUser(
        firstName,
        email,
        accessCode,
      );
      await NotificationService.instance.saveTokenForCurrentUser();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    } catch (e) {
      if (!mounted) return;
      String message;
      if (e is AuthException) {
        switch (e.code) {
          case AuthErrorCode.invalidCredentials:
            message = AppLocalizations.of(
              context,
            )!.signInErrorInvalidCredentials;
            break;
          case AuthErrorCode.accessCodeMaxUsesOrInvalid:
            message = AppLocalizations.of(context)!.signInErrorMaxUsesOrExpired;
            break;
          default:
            message = AppLocalizations.of(context)!.signInFailedMessage;
        }
      } else {
        message = e
            .toString() /*AppLocalizations.of(context)!.signInFailedMessage*/;
      }
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.signInFailed,
        message: message,
      );
    } finally {
      if (mounted) _setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: screenHeight,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Language switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => _changeLanguage(const Locale('fr')),
                            child: Text(
                              'Fr',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    const Locale('fr').languageCode ==
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode
                                    ? Colors.black
                                    : Colors.grey,
                                decoration:
                                    const Locale('fr').languageCode ==
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationThickness: 2.0,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '|',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => _changeLanguage(const Locale('en')),
                            child: Text(
                              'En',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    const Locale('en').languageCode ==
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode
                                    ? Colors.black
                                    : Colors.grey,
                                decoration:
                                    const Locale('en').languageCode ==
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationThickness: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Logo
                      Image.asset(
                        "lib/app/src/1_Front_end/Assets/Images/Discreta_app_icon.png",
                        height: 200.h,
                        width: 200.w,
                      ),

                      DiscretaText(
                        text: AppLocalizations.of(context)!.projectName,
                        size: TextSize.large,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),
                      DiscretaText(
                        text: AppLocalizations.of(context)!.brandMessage,
                        size: TextSize.small,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),

                      // First name field
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.firstName,
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 12.h),

                      // Email field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 12.h),

                      // Access code field
                      TextField(
                        controller: _accessCodeController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.accessCode,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        child: DiscretaButton(
                          onPressed: _signIn,
                          text: AppLocalizations.of(context)!.signIn,
                          backgroundColor: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      DiscretaText(
                        text: AppLocalizations.of(context)!.slogan,
                        size: TextSize.small,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) LoadingOverlay(),
        ],
      ),
    );
  }
}

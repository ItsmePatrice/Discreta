import 'dart:async';

import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/google_sign_in_button.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/main_shell.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:discreta/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _changeLanguage(Locale locale) async {
    myAppKey.currentState?.setLocale(locale);
  }

  Future<dynamic> _signInWithGoogle() async {
    _setIsLoading(true);
    try {
      await AuthService.instance.signInWithGoogle();
      _setIsLoading(false);
      String? firebaseUid = AuthService.instance.currentUser?.uid;
      if (firebaseUid == null) {
        if (!mounted) return;
        MessageService.displayAlertDialog(
          context: context,
          title: AppLocalizations.of(context)!.signInError,
          message: AppLocalizations.of(context)!.signInErrorMessage,
        );
        return;
      }
      await AuthService.instance.fetchOrCreateUser();
      _setIsLoading(false);
      _leadUserToHomePage();
      return;
    } catch (e) {
      if (!mounted) return;
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.signInFailed,
        message: AppLocalizations.of(context)!.signInFailedMessage,
      );
      await AuthService.instance.signOutUser();
      return;
    } finally {
      if (mounted) {
        _setIsLoading(false);
      }
    }
  }

  Future<void> _leadUserToHomePage() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Main login form
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

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "lib/app/src/1_Front_end/Assets/Images/purple_lady.jpg",
                            height: 300.h,
                            width: 300.w,
                          ),
                        ],
                      ),
                      DiscretaText(
                        text: AppLocalizations.of(context)!.projectName,
                        size: TextSize.large,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 20.h),
                      DiscretaText(
                        text: AppLocalizations.of(context)!.brandMessage,
                        size: TextSize.small,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      // Sign in button
                      GoogleSignInButton(onPressed: _signInWithGoogle),
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

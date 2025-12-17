import 'dart:async';

import 'package:discreta/app/src/1_Front_end/lib/Classes/discreta_user.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/home_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

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
          title: "Sign in error",
          message: 'We couldn’t complete your sign in. Please try again.',
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
        title: "Sign in failed",
        message: 'An unexpected error occurred. Please try again later.',
      );
      return;
    } finally {
      if (mounted) {
        _setIsLoading(false);
      }
    }
  }

  Future<void> _leadUserToHomePage() async {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Sign in button
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "lib/app/src/1_Front_end/Assets/Images/android_neutral_sq_ctn.svg",
                              height: 50.h,
                              width: 50.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

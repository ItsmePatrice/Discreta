import 'dart:async';

import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      _setIsLoading(false);
      // check in the DB if the user exists. If so, return the user from the DB. If not, create a new user in the DB
      // and return the new user from the server. Either way, we get a user object from the server.
      _leadUserToHomePage(user);
      // In the home page, load all the user's data and make sure they cannot return to the lo
      return;
    } catch (e) {
      if (!mounted) return;
      MessageService.displayAlertDialog(
        context: context,
        title: "Sign in failed",
        message: 'An unexpected error occurred. Please try again.',
      );
      return;
    } finally {
      if (mounted) {
        _setIsLoading(false);
      }
    }
  }

  Future<void> _leadUserToHomePage(PlowDoorUser user) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePageShoveler()),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    SvgPicture.asset(
                      'lib/app/src/1_Front_end/Assets/Images/PlowDoorLogo.svg',
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.3,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Welcome to PlowDoor',
                      style: TextStyle(
                        fontSize: 25.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Premium snow removal.',
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Done your way.',
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 200.h),
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

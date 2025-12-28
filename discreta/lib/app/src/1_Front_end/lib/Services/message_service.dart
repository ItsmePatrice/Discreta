import 'package:discreta/app/src/1_Front_end/Assets/enum/button_size.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_button.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Assets/colors.dart';

class MessageService {
  // Show a basic alert dialog
  static void displayAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildDialog(
          context: context,
          title: title,
          message: message,
          buttonText: buttonText,
          onPressed: () {
            if (onButtonPressed != null) {
              onButtonPressed();
            }
          },
        );
      },
    );
  }

  static void displayNoConnectionDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Retry',
    required Function() onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildDialog(
          context: context,
          title: title,
          message: message,
          buttonText: buttonText,
          onPressed: () {
            onRetry();
          },
        );
      },
    );
  }

  static void displayConfirmationDialog({
    required BuildContext context,
    required VoidCallback onYesPressed,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildConfirmationDialog(
          context: context,
          message: message,
          onPressed: onYesPressed,
        );
      },
    );
  }

  static AlertDialog _buildConfirmationDialog({
    required BuildContext context,
    required String message,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: DiscretaText(
          text: message,
          size: TextSize.small,
          textAlign: TextAlign.center,
        ),
      ),
      actions: <Widget>[
        Center(
          child: SizedBox(
            width: screenWidth * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: DiscretaButton(
                    text: AppLocalizations.of(context)!.no,
                    size: ButtonSize.medium,
                    onPressed: () => {Navigator.of(context).pop()},
                  ),
                ),

                SizedBox(width: 5.w),
                Flexible(
                  child: DiscretaButton(
                    text: AppLocalizations.of(context)!.yes,
                    onPressed: () {
                      onPressed();
                    },
                    size: ButtonSize.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Private method to build dialog for code reuse
  static AlertDialog _buildDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20, // Increased font size for better readability
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ), // Consistent padding
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16), // Consistent text style
        ),
      ),
      actions: <Widget>[
        Center(
          child: SizedBox(
            width: screenWidth * 0.4, // Wider button for easier interaction
            child: TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                backgroundColor: AppColors.primaryColor, // Fixed button color
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Larger font for the button
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ensure button text is readable
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onPressed();
              },
            ),
          ),
        ),
      ],
    );
  }
}

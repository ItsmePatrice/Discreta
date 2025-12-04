import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/button_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscretaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;
  final Color backgroundColor;
  final Icon? icon;

  const DiscretaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primaryColor,
    this.size = ButtonSize.medium,
    this.icon,
  });

  double _getWidth() {
    switch (size) {
      case ButtonSize.small:
        return 175;
      case ButtonSize.medium:
        return 190;
      case ButtonSize.large:
        return 250;
      case ButtonSize.extraLarge:
        return 300;
    }
  }

  double _getFontSize(String text) {
    if (text.length <= 10) {
      return 16.sp;
    } else if (text.length <= 20) {
      return 14.sp;
    } else {
      return 12.sp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _getWidth(),
      height: 30.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: icon == null
            ? Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: _getFontSize(text),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // prevents overflow
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: _getFontSize(text),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscretaText extends StatelessWidget {
  final String text;
  final TextSize size;
  final Color color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  const DiscretaText({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.fontWeight,
    required this.size,
    this.textAlign,
  });

  double _getFontSize() {
    switch (size) {
      case TextSize.extraSmall:
        return 8;
      case TextSize.small:
        return 12;
      case TextSize.medium:
        return 17;
      case TextSize.large:
        return 25;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.left,
      style: TextStyle(
        fontSize: _getFontSize().sp,
        color: color,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}

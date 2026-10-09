import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';

// Font family (Plus Jakarta Sans) comes from the theme in main.dart.
class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.height,
  });

  final String text;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      softWrap: true,
      textAlign: textAlign ?? TextAlign.start,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        color: textColor ?? AppColors.textColor,
        fontWeight: fontWeight,
        height: height,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }

  /// Big time ranges ("14:00 ~ 16:00" on session headers)
  factory CustomText.headline({required String text, Color? textColor}) =>
      CustomText(text, fontSize: 24, fontWeight: FontWeight.w600, textColor: textColor);

  /// Screen titles
  factory CustomText.titleLarge({required String text, Color? textColor}) =>
      CustomText(text, fontSize: 20, fontWeight: FontWeight.w700, textColor: textColor);

  /// Card titles (Group Name, Payment, Schedule)
  factory CustomText.titleSmall({required String text, Color? textColor, int? maxLines}) =>
      CustomText(text, fontSize: 17, fontWeight: FontWeight.w600, textColor: textColor, maxLines: maxLines);

  /// Section headers (Running, Today, Attendance), time ranges on cards
  factory CustomText.bodyLarge({required String text, Color? textColor, TextAlign? textAlign, FontWeight? fontWeight}) =>
      CustomText(text, fontSize: 16, fontWeight: fontWeight ?? FontWeight.w600, textColor: textColor, textAlign: textAlign);

  factory CustomText.bodyMedium({required String text, Color? textColor, int? maxLines, TextAlign? textAlign, FontWeight? fontWeight}) =>
      CustomText(text, fontSize: 14, fontWeight: fontWeight ?? FontWeight.w500, textColor: textColor, maxLines: maxLines, textAlign: textAlign);

  /// Subtitles, labels, slider labels
  factory CustomText.bodySmall({required String text, Color? textColor, int? maxLines, TextAlign? textAlign, FontWeight? fontWeight}) =>
      CustomText(text, fontSize: 13, fontWeight: fontWeight ?? FontWeight.w400, textColor: textColor ?? AppColors.secondaryColor, maxLines: maxLines, textAlign: textAlign);

  /// Meta rows (6 Students • 2 Sessions / week), pills, bottom nav
  factory CustomText.caption({required String text, Color? textColor, FontWeight? fontWeight, TextAlign? textAlign}) =>
      CustomText(text, fontSize: 11, fontWeight: fontWeight ?? FontWeight.w500, textColor: textColor ?? AppColors.textColor, textAlign: textAlign);
}

import 'package:flutter/material.dart';

class AppColors {
  // Core
  static const Color primaryColor = Color(0xFFF26A21); // orange: active tab, CTA, back arrow
  static const Color primaryColorLight = Color(0xFFFDE8DD); // active tab background
  static const Color darkColor = Color(0xFF1E1E1E); // dark buttons, header cards
  static const Color backgroundColor = Color(0xFFFCF9F8);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceAltColor = Color(0xFFF3F1F1); // search field, icon circles
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color secondaryColor = Color(0xFF6B5A55); // brownish subtitles
  static const Color mutedColor = Color(0xFFA09694); // hints, unselected slider dots
  static const Color borderColor = Color(0xFFF0E6E3);
  static const Color accentBorderColor = Color(0xFFEFC9B7); // search / date fields

  // Semantic accents
  static const Color greenColor = Color(0xFF0E7A55); // present, marked, on time
  static const Color greenColorLight = Color(0xFFE3F5EC);
  static const Color redColor = Color(0xFFC21F1F); // absent, not held, late
  static const Color redColorLight = Color(0xFFFBDADA);
  static const Color blueColor = Color(0xFF2B4FD8); // pending, running, selected chips
  static const Color blueColorLight = Color(0xFFE5ECFF);
  static const Color greyColor = Color(0xFF9E9E9E); // disabled evaluation button
  static const Color greyColorLight = Color(0xFFEFEFEF); // unmarked pill

  // Evaluation scale (bad → good)
  static const Color scaleVeryWeak = Color(0xFFC21F1F);
  static const Color scaleWeak = Color(0xFFE07A1F);
  static const Color scaleAverage = Color(0xFFE0A020);
  static const Color scaleGood = Color(0xFF7FA02A);
  static const Color scaleExcellent = Color(0xFF0E7A55);
}

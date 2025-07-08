import 'package:flutter/material.dart';

import '../main.dart';

class AppColors {
  AppColors._();
  static final BuildContext _context = navigatorKey.currentContext!;
  static Color primary = Theme.of(_context).colorScheme.primary;
  static const Color secondary = Color(0xffe33838);
  static const Color darkGrey = Color(0xff666666);
  static const Color lightGrey = Color(0xffabaca6);
  static const Color text = Color(0xff73767a);
  static const Color whiteContainer = Color(0xffE7EAED);
  static const Color whiteGrayContainer = Color(0xffE7EAED);
  static const Color osinFontColor = Color(0xff3a3a3a);
  static const Color errorRed=Colors.red;
  static const Color primaryBlue = Color(0xFF8360c3); // Màu xanh chính, bạn có thể điều chỉnh
  static const Color textColor = Color(0xFF333333); // Màu chữ chính
  static const Color lightGrey2 = Color(0xFFF0F0F0); // Màu nền nhẹ
  static const Color borderGrey = Color(0xFFE0E0E0); // Màu viền input
  static const Color linkBlue = Color(0xFF4285F4); // Màu xanh dương cho liên kết
}

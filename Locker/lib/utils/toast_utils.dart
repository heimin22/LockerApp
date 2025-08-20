import 'package:flutter/material.dart';
import 'package:first_project/themes/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static const Color _toastBg = AppColors.primaryBackground;
  static const Color _lightText = AppColors.primaryText;

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: _toastBg,
      textColor: _lightText,
      fontSize: 16,
    );
  }
}
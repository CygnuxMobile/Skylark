import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor ?? AppColors.secondaryGreen,
      colorText: colorText ?? AppColors.white,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 3),
    );
  }

  static void success({required String message, String title = 'Success'}) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.secondaryGreen,
      colorText: AppColors.white,
    );
  }

  static void error({required String message, String title = 'Error'}) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }
}

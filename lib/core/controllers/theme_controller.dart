import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = Get.isDarkMode.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure we sync with the actual platform brightness if needed
    // But Get.isDarkMode should be sufficient if GetMaterialApp is set up correctly.
    // However, to be safe, let's check the platform brightness directly if Get.isDarkMode is not yet reliable in onInit
    // Actually, Get.isDarkMode works best after the app is mounted.
    // Let's default to system setting.
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode.value = brightness == Brightness.dark;
  }

  void toggleTheme() {
    final newValue = !isDarkMode.value;
    // Prevent redundant updates
    if (isDarkMode.value == newValue) return;

    isDarkMode.value = newValue;
    Get.changeThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
  }

  void setTheme(bool dark) {
    // Prevent redundant updates
    if (isDarkMode.value == dark) return;

    isDarkMode.value = dark;
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }
}

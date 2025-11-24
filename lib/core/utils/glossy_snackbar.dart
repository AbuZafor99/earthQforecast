import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class GlossySnackbar {
  static void show({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: _getBackgroundColor(type).withOpacity(0.9),
      colorText: Colors.white,
      icon: Icon(_getIcon(type), color: Colors.white, size: 28),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: _getBackgroundColor(type).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
      ],
      backgroundGradient: LinearGradient(
        colors: _getGradientColors(type),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 500),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.OPENING) {
          // Add haptic feedback if needed
        }
      },
    );
  }

  static Color _getBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF10B981);
      case SnackbarType.error:
        return const Color(0xFFEF4444);
      case SnackbarType.warning:
        return const Color(0xFFF59E0B);
      case SnackbarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  static List<Color> _getGradientColors(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case SnackbarType.error:
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case SnackbarType.warning:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case SnackbarType.info:
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
    }
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning_amber;
      case SnackbarType.info:
        return Icons.info;
    }
  }
}

enum SnackbarType { success, error, warning, info }

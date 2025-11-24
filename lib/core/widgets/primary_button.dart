import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ButtonStyleExtensions on BuildContext {
  Widget primaryButton({
    required VoidCallback onPressed,
    required String text,
    double? width,
    double? height,
    bool isLoading = false,
    Color backgroundColor = TColors.primary,
    Color textColor = TColors.account,
    double borderRadius = 12.0,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
  Widget secondaryButton({
    required VoidCallback onPressed,
    required Color btnBG,
    required String text,
    required Color btnTxtColor,
    required Color btnBorder,
    double? width,
    double? height,
    bool isLoading = false,
    double borderRadius = 12.0,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: btnBG, // 🔹 No background fill
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: btnBorder, width: 1.5),
            ),
            child: isLoading
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(btnTxtColor),
              ),
            )
                : Text(
              text,
              style: TextStyle(
                color: btnTxtColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

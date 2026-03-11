import 'package:flutter/material.dart';

/// Custom button with enabled/disabled states
/// Enabled: Dark black background
/// Disabled: Gray background, not clickable
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? enabledColor;
  final Color? disabledColor;
  final Color? textColor;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.enabledColor,
    this.disabledColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final enabledColor = this.enabledColor ?? Colors.black;
    final disabledColor = this.disabledColor ?? Colors.grey.shade400;
    final textColor = this.textColor ?? Colors.white;
    final borderRadius = this.borderRadius ?? 12.0;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? enabledColor : disabledColor,
          foregroundColor: textColor,
          disabledBackgroundColor: disabledColor,
          disabledForegroundColor: Colors.grey.shade600,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: enabled ? textColor : Colors.grey.shade600,
                ),
              ),
      ),
    );
  }
}

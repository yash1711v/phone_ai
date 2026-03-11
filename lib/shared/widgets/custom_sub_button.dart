import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom sub button (outline style)
/// Can display either an icon (SVG) or text widget
class CustomSubButton extends StatelessWidget {
  final Widget? icon;
  final String? svgIconPath;
  final Widget? text;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? borderColor;
  final Color? iconColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double? borderRadius;
  final String? tooltip;

  const CustomSubButton({
    super.key,
    this.icon,
    this.svgIconPath,
    this.text,
    this.onPressed,
    this.enabled = true,
    this.borderColor,
    this.iconColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.tooltip,
  }) : assert(
          (icon != null || svgIconPath != null || text != null) &&
              !(icon != null && svgIconPath != null),
          'Either icon, svgIconPath, or text must be provided, but not both icon and svgIconPath',
        );

  @override
  Widget build(BuildContext context) {
    final borderColor = this.borderColor ?? Colors.grey.shade300;
    final iconColor = this.iconColor ?? Colors.grey.shade700;
    final borderRadius = this.borderRadius ?? 8.0;

    Widget content;

    if (svgIconPath != null) {
      content = SvgPicture.asset(
        svgIconPath!,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          enabled ? iconColor : Colors.grey.shade400,
          BlendMode.srcIn,
        ),
      );
    } else if (icon != null) {
      content = icon!;
    } else if (text != null) {
      content = text!;
    } else {
      content = const SizedBox.shrink();
    }

    Widget button = Container(
      width: width,
      height: height ?? 40,
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: enabled ? borderColor : Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.transparent,
      ),
      child: Center(child: content),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: button,
      ),
    );
  }
}

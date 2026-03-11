import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_button.dart';

/// Auth button widget
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    );
  }
}

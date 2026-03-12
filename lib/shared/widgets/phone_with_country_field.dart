import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

/// Phone number field with country code picker (search + flag).
/// [dialCode] and [onDialCodeChanged] manage the country; [controller] is the rest of the number.
/// [countryCode] is used for initial picker selection (e.g. 'US'); [dialCode] for display.
/// Use [enabled: false] to show as disabled (e.g. on OTP screen).
class PhoneWithCountryField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final String dialCode;
  final String countryCode;
  final ValueChanged<CountryCode> onDialCodeChanged;
  final bool enabled;
  final String? Function(String?)? validator;

  const PhoneWithCountryField({
    super.key,
    this.label,
    required this.controller,
    this.dialCode = '+1',
    this.countryCode = 'US',
    required this.onDialCodeChanged,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CountryCodePicker(
              onChanged: onDialCodeChanged,
              initialSelection: countryCode,
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              favorite: const ['US', 'IN', 'GB', 'JP'],
              enabled: enabled,
              padding: EdgeInsets.zero,
              dialogSize: Size(MediaQuery.of(context).size.width * 0.9,
                  MediaQuery.of(context).size.height * 0.7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                validator: validator,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

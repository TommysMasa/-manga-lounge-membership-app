import 'package:flutter/cupertino.dart';

import '../../theme/app_theme.dart';

/// Reusable labeled text field with consistent styling
///
/// Used across registration and profile edit screens for text input fields.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder ?? 'Enter $label',
          prefix: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    prefixIcon,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.systemGrey4.color),
          ),
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          enabled: enabled,
          maxLength: maxLength,
        ),
      ],
    );
  }
}

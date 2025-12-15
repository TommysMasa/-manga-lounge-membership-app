import 'package:flutter/cupertino.dart';

import '../../theme/app_theme.dart';

/// Reusable labeled picker field with consistent styling
///
/// Used for fields that open a picker/modal (gender, date of birth).
/// Displays current value with a dropdown indicator.
class LabeledPickerField extends StatelessWidget {
  const LabeledPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.prefixIcon,
    this.enabled = true,
    this.placeholder,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? prefixIcon;
  final bool enabled;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? (placeholder ?? 'Select $label') : value;
    final isPlaceholder = value.isEmpty;

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
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CupertinoColors.systemGrey4),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 16,
                      color: isPlaceholder
                          ? CupertinoColors.placeholderText
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

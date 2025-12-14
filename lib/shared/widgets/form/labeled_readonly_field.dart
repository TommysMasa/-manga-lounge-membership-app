import 'package:flutter/cupertino.dart';

import '../../theme/app_theme.dart';

/// Reusable labeled read-only field with consistent styling
///
/// Used for fields that cannot be edited (e.g., phone number).
/// Displays a lock icon to indicate non-editable state.
class LabeledReadonlyField extends StatelessWidget {
  const LabeledReadonlyField({
    super.key,
    required this.label,
    required this.value,
    this.prefixIcon,
  });

  final String label;
  final String value;
  final IconData? prefixIcon;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
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
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.lock,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

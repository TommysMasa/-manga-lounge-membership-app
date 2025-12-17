import 'package:flutter/cupertino.dart';

/// Application theme configuration
class AppTheme {
  // Primary Colors (based on Manga Lounge logo: blue and orange)
  static const Color primaryBlue = Color(0xFF4A6FA4);
  static const Color primaryOrange = Color(0xFFFF9933);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFF4A6FA4);
  static const Color accentPurple = Color(0xFF6366F1);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFFC107);

  /// Cupertino Theme
  static CupertinoThemeData cupertinoTheme = const CupertinoThemeData(
    primaryColor: primaryBlue,
    primaryContrastingColor: textLight,
    scaffoldBackgroundColor: backgroundColor,
    barBackgroundColor: backgroundColor,
    textTheme: CupertinoTextThemeData(
      primaryColor: textPrimary,
      textStyle: TextStyle(fontSize: 16, color: textPrimary),
      navTitleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    ),
  );

  /// Show notification dialog (replaces SnackBar)
  static Future<void> showNotification(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(isError ? 'Error' : 'Notice'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog (replaces AlertDialog)
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    bool isDestructive = false,
  }) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show picker modal (replaces DropdownButtonFormField)
  static Future<int?> showPickerModal(
    BuildContext context, {
    required List<String> options,
    int initialIndex = 0,
  }) async {
    int selectedIndex = initialIndex;
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            // Toolbar with Done button
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.resolveFrom(context),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            // Picker
            Expanded(
              child: CupertinoPicker(
                itemExtent: 36,
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex,
                ),
                onSelectedItemChanged: (index) => selectedIndex = index,
                children: options
                    .map(
                      (e) => Center(
                        child: Text(e, style: const TextStyle(fontSize: 18)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
    return selectedIndex;
  }

  /// Show date picker modal
  static Future<DateTime?> showDatePickerModal(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) async {
    DateTime selectedDate = initialDate;
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            // Toolbar with Done button
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.resolveFrom(context),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            // Date Picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (date) => selectedDate = date,
              ),
            ),
          ],
        ),
      ),
    );
    return selectedDate;
  }
}

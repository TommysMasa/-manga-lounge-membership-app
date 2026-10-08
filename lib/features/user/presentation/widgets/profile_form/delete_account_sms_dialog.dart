import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../../../../core/error/result.dart';

class DeleteAccountSmsConfirmation {
  const DeleteAccountSmsConfirmation(this.verificationId, this.code);
  final String verificationId;
  final String code;
}

class DeleteAccountSmsDialog extends StatefulWidget {
  const DeleteAccountSmsDialog({
    super.key,
    required this.initialVerificationId,
    required this.resend,
    this.now = DateTime.now,
  });
  final String initialVerificationId;
  final AsyncResult<String> Function() resend;
  final DateTime Function() now;

  @override
  State<DeleteAccountSmsDialog> createState() => _DeleteAccountSmsDialogState();
}

class _DeleteAccountSmsDialogState extends State<DeleteAccountSmsDialog> {
  final _code = TextEditingController();
  late String _verificationId;
  Timer? _timer;
  late DateTime _availableAt;
  int _remaining = 30;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.initialVerificationId;
    _availableAt = widget.now().add(const Duration(seconds: 30));
    // Date-based countdown also handles returning from the SMS app.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final milliseconds = _availableAt.difference(widget.now()).inMilliseconds;
      final remaining = milliseconds <= 0 ? 0 : (milliseconds / 1000).ceil();
      if (remaining != _remaining) setState(() => _remaining = remaining);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_remaining > 0 || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
      _remaining = 30;
      _availableAt = widget.now().add(const Duration(seconds: 30));
    });
    try {
      final result = await widget.resend();
      if (!mounted) return;
      result.fold((failure) => setState(() => _error = failure.message), (id) {
        if (id.isEmpty) {
          setState(
            () => _error = 'Could not resend the SMS. Please try again.',
          );
          return;
        }
        setState(() {
          _verificationId = id;
          _code.clear();
          _remaining = 30;
          _availableAt = widget.now().add(const Duration(seconds: 30));
        });
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not resend the SMS. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _confirm() {
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Please enter the 6-digit SMS code.');
      return;
    }
    Navigator.of(
      context,
    ).pop(DeleteAccountSmsConfirmation(_verificationId, code));
  }

  @override
  Widget build(BuildContext context) => CupertinoAlertDialog(
    title: const Text('Verify Your Phone'),
    content: Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          CupertinoTextField(
            controller: _code,
            placeholder: '6-digit SMS code',
            style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
            placeholderStyle: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            cursorColor: CupertinoColors.activeBlue.resolveFrom(context),
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemBackground.resolveFrom(
                context,
              ),
              border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            maxLength: 6,
            autofocus: true,
            enabled: !_sending,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ),
          CupertinoButton(
            onPressed: _remaining == 0 && !_sending ? _resend : null,
            child: Text(
              _sending
                  ? 'Sending…'
                  : _remaining > 0
                  ? 'Resend in ${_remaining}s'
                  : 'Resend',
            ),
          ),
        ],
      ),
    ),
    actions: [
      CupertinoDialogAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: _sending ? null : _confirm,
        child: const Text('Verify and Delete'),
      ),
    ],
  );
}

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../config/push_notification_config.dart';
import '../../data/member_request_repository.dart';
import '../../../subscription/presentation/widgets/premium_widgets.dart';

class MemberRequestScreen extends ConsumerStatefulWidget {
  const MemberRequestScreen({
    super.key,
    required this.type,
    this.initialTitle = '',
    this.source = 'settings',
  });
  final MemberRequestType type;
  final String initialTitle;
  final String source;

  @override
  ConsumerState<MemberRequestScreen> createState() =>
      _MemberRequestScreenState();
}

class _MemberRequestScreenState extends ConsumerState<MemberRequestScreen> {
  late final TextEditingController _title = TextEditingController(
    text: widget.initialTitle,
  );
  final _volumes = TextEditingController();
  final _details = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _requestId;
  String? _error;
  String? _notificationMessage;
  bool get _isManga => widget.type == MemberRequestType.manga;

  @override
  void dispose() {
    _title.dispose();
    _volumes.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending || _sent) return;
    if ((_isManga && _title.text.trim().isEmpty) ||
        (!_isManga && _details.text.trim().isEmpty)) {
      setState(
        () => _error = _isManga
            ? 'Please enter a manga title.'
            : 'Please enter your suggestion.',
      );
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      // Retain the ID on network failure: a retry must not create a duplicate.
      _requestId ??= ref.read(newMemberRequestIdProvider)();
      await ref.read(submitMemberRequestProvider)(
        MemberRequestDraft(
          id: _requestId!,
          type: widget.type,
          title: _isManga ? _title.text : '',
          details: _details.text,
          volumes: _isManga ? _volumes.text : '',
          source: widget.source,
        ),
      );
      if (mounted) setState(() => _sent = true);
    } on FirebaseFunctionsException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.code == 'already-exists'
              ? 'This request was already received. Open a new form to send another request.'
              : 'Couldn’t send your request. Please try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Couldn’t send your request. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLength = 200,
    int lines = 1,
    String? placeholder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 9),
          CupertinoTextField(
            controller: controller,
            enabled: !_sending,
            placeholder: placeholder,
            maxLength: maxLength,
            minLines: lines,
            maxLines: lines == 1 ? 1 : 8,
            textCapitalization: TextCapitalization.sentences,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        middle: Text(widget.type.title),
      ),
      child: SafeArea(
        child: _sent
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.check_mark_circled,
                        color: kPremiumBlue,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Thank you!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isManga
                            ? 'Your manga request has been sent.'
                            : 'Your suggestion has been sent.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        onPressed: () async {
                          final allowed =
                              await PushNotificationConfig.requestPermission();
                          if (mounted) {
                            setState(
                              () => _notificationMessage = allowed
                                  ? 'Notifications are enabled.'
                                  : 'Enable notifications for Manga Lounge in your phone settings.',
                            );
                          }
                        },
                        child: Text(
                          _isManga
                              ? 'Enable arrival notifications'
                              : 'Enable update notifications',
                        ),
                      ),
                      if (_notificationMessage != null)
                        Text(
                          _notificationMessage!,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 24),
                      CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (_isManga)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 26),
                      child: Text(
                        '• Pro Member requests are reviewed with priority.\n'
                        '• Some titles may not be available.\n'
                        '• We’ll notify you when your request is fulfilled or if we’re unable to add it.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  else ...[
                    const Text(
                      'How can we improve your experience?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Share your ideas for our space, amenities, or service.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                  if (_isManga) ...[
                    _field(
                      'Manga title',
                      _title,
                      placeholder: 'Title or series name',
                    ),
                    _field(
                      'Volumes (optional)',
                      _volumes,
                      maxLength: 100,
                      placeholder: 'For example, volumes 1–5',
                    ),
                  ],
                  _field(
                    _isManga ? 'Details (optional)' : 'Your suggestion',
                    _details,
                    maxLength: 2000,
                    lines: 4,
                    placeholder: _isManga
                        ? 'Author, language, or other details'
                        : 'Tell us more…',
                  ),
                  if (_error != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  CupertinoButton(
                    color: kPremiumBlue,
                    onPressed: _sending ? null : _submit,
                    child: _sending
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : Text(
                            _isManga ? 'Submit Request' : 'Send Suggestion',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

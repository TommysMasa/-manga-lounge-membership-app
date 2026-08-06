import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/push_notification_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_state_notifier.dart';
import '../../../../shared/theme/app_theme.dart';

/// Waitlist join screen, opened from the poster QR
/// (`https://mangalounge.com/waitlist` universal link) or a
/// `waitlist_called` push notification tap.
///
/// Auth states are handled here (not by the router redirect) because a
/// cold start from the QR arrives before Firebase auth restores — same
/// pattern as SurveyScreen.
class WaitlistScreen extends ConsumerStatefulWidget {
  const WaitlistScreen({super.key});

  @override
  ConsumerState<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends ConsumerState<WaitlistScreen> {
  int _adults = 1;
  int _children = 0;
  bool _busy = false;

  /// null = not joined (or still loading); see [_loadedOnce]
  Map<String, dynamic>? _entry;

  /// Queue snapshot (parties ahead, estimated wait) shown on the join form.
  Map<String, dynamic>? _overview;
  bool _loadedOnce = false;
  Timer? _pollTimer;
  Timer? _overviewDebounce;

  @override
  void initState() {
    super.initState();
    // Refresh status while waiting (position changes, getting called).
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _refreshStatus();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _overviewDebounce?.cancel();
    super.dispose();
  }

  bool get _isAuthenticated => ref
      .read(authStateProvider)
      .maybeWhen(authenticated: (_) => true, orElse: () => false);

  Future<Map<String, dynamic>?> _call(Map<String, dynamic> data) async {
    final callable = ref
        .read(functionsProvider)
        .httpsCallable('joinWaitlistAsMember');
    final result = await callable.call<Map<dynamic, dynamic>>(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<void> _refreshStatus() async {
    if (!mounted || !_isAuthenticated) return;
    try {
      final data = await _call({
        'action': 'status',
        'party': _adults + _children,
      });
      if (!mounted || data == null) return;
      setState(() {
        _loadedOnce = true;
        if (data['status'] == 'none') {
          _entry = null;
          _overview = data;
        } else {
          _entry = data;
        }
      });
    } catch (_) {
      // Transient network/auth errors: keep the current view, next poll retries.
      if (mounted && !_loadedOnce) setState(() => _loadedOnce = true);
    }
  }

  Future<void> _join() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final data = await _call({
        'action': 'join',
        'adults': _adults,
        'children': _children,
      });
      if (!mounted) return;
      setState(() {
        _loadedOnce = true;
        _entry = data;
      });
      // The whole point of joining in the app: ask to be notified. The OS
      // prompt only appears if permission hasn't been decided yet.
      final granted = await PushNotificationConfig.requestPermission();
      if (!mounted) return;
      AppTheme.showNotification(
        context,
        message: granted
            ? "You're in line! We'll notify you when your seats are ready."
            : "You're in line! Keep this screen open to see your turn "
                  '(notifications are off).',
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'failed-precondition' => e.message ?? 'Could not join the waitlist.',
        'unavailable' => 'The waitlist is closed right now — please ask our staff.',
        _ => 'Could not join the waitlist. Please try again.',
      };
      AppTheme.showNotification(context, message: message, isError: true);
    } catch (_) {
      if (!mounted) return;
      AppTheme.showNotification(
        context,
        message: 'Network error. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave() async {
    final confirmed = await AppTheme.showConfirmation(
      context,
      title: 'Leave the waitlist?',
      message: "You'll lose your spot in line.",
      confirmText: 'Leave',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _call({'action': 'cancel'});
      if (!mounted) return;
      setState(() => _entry = null);
    } catch (_) {
      if (!mounted) return;
      AppTheme.showNotification(
        context,
        message: 'Network error. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _close() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      const HomeRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Re-check status once auth restores after a cold start from the QR.
    ref.listen(authStateProvider, (previous, next) {
      next.maybeWhen(authenticated: (_) => _refreshStatus(), orElse: () {});
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Waitlist'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _close,
          child: const Icon(CupertinoIcons.xmark),
        ),
      ),
      child: SafeArea(
        child: authState.maybeWhen(
          authenticated: (_) => _buildBody(),
          unauthenticated: () => _buildSignInPrompt(),
          error: (_) => _buildSignInPrompt(),
          orElse: () => const Center(child: CupertinoActivityIndicator()),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎟', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Sign in to join the waitlist',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll hold your spot and send a push notification "
            'when your seats are ready.',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => const SplashRoute().go(context),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_loadedOnce) {
      return const Center(child: CupertinoActivityIndicator());
    }
    final entry = _entry;
    if (entry == null) return _buildJoinForm();
    return _buildStatus(entry);
  }

  Widget _buildJoinForm() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 8),
        const Text(
          'The lounge is full right now',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Join the waitlist and we'll send you a push notification "
          'the moment your seats are ready.',
          style: TextStyle(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (_overview != null) ...[
          const SizedBox(height: 20),
          _overviewCard(_overview!),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 28),
        _counterRow(
          label: 'Adults',
          value: _adults,
          min: 1,
          onChanged: (v) {
            setState(() => _adults = v);
            _requoteSoon();
          },
        ),
        const SizedBox(height: 12),
        _counterRow(
          label: 'Children',
          value: _children,
          min: 0,
          onChanged: (v) {
            setState(() => _children = v);
            _requoteSoon();
          },
        ),
        const SizedBox(height: 28),
        CupertinoButton.filled(
          onPressed: _busy ? null : _join,
          child: _busy
              ? const CupertinoActivityIndicator()
              : const Text('Join waitlist'),
        ),
        const SizedBox(height: 12),
        const Text(
          "You'll have 10 minutes to check in at the counter "
          'once your seats are ready.',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Re-fetch the quote shortly after the party size changes (debounced so
  /// tapping +/+/+ doesn't fire a call per tap).
  void _requoteSoon() {
    _overviewDebounce?.cancel();
    _overviewDebounce = Timer(
      const Duration(milliseconds: 500),
      _refreshStatus,
    );
  }

  /// "X–Y min" / "over N hr" from a payload carrying wait bounds, or null.
  String? _waitQuote(Map<String, dynamic> m) {
    final lo = m['waitLowMinutes'] as int?;
    final hi = m['waitHighMinutes'] as int?;
    if (lo == null || hi == null) return null;
    if (hi >= 120) return 'over ${lo ~/ 60} hr';
    return '$lo–$hi min';
  }

  Widget _overviewCard(Map<String, dynamic> o) {
    final groups = o['groupsWaiting'] as int?;
    final people = o['peopleWaiting'] as int?;
    final noWait = o['noWait'] == true;
    final quote = _waitQuote(o);
    if (groups == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            groups == 0
                ? 'No parties waiting'
                : '$groups ${groups == 1 ? 'party' : 'parties'} ahead of you'
                      '${people != null ? ' ($people ${people == 1 ? 'person' : 'people'})' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            noWait
                ? 'No wait right now — come on in!'
                : quote != null
                ? 'Estimated wait: $quote'
                : '…',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: noWait ? AppTheme.successColor : AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterRow({
    required String label,
    required int value,
    required int min,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: value > min ? () => onChanged(value - 1) : null,
              child: const Icon(CupertinoIcons.minus_circle, size: 32),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => onChanged(value + 1),
              child: const Icon(CupertinoIcons.plus_circle, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatus(Map<String, dynamic> entry) {
    final status = entry['status'] as String? ?? 'waiting';
    final position = entry['position'] as int?;
    final groupsAhead = entry['groupsAhead'] as int?;
    final partySize = entry['partySize'] as int?;
    final graceMinutes = entry['graceMinutes'] as int? ?? 10;
    final paused = entry['paused'] == true;

    if (status == 'called') {
      return _statusMessage(
        emoji: '🎉',
        title: 'Your seats are ready!',
        body:
            'Please check in at the counter within '
            '$graceMinutes minutes.',
        showLeave: true,
      );
    }
    if (status == 'seated') {
      return _statusMessage(
        emoji: '📚',
        title: "You're checked in",
        body: 'Enjoy your stay!',
        showLeave: false,
      );
    }
    if (status != 'waiting') {
      return _statusMessage(
        emoji: 'ℹ️',
        title: 'Not on the waitlist',
        body: 'This entry is no longer active.',
        showLeave: false,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        Text(
          position != null ? '#$position' : '…',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryBlue,
          ),
        ),
        const Text(
          'IN LINE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          [
            if (groupsAhead != null)
              groupsAhead > 0
                  ? '$groupsAhead group${groupsAhead == 1 ? '' : 's'} ahead of you'
                  : "You're next!",
            if (partySize != null) 'Party of $partySize',
          ].join(' · '),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        if (_waitQuote(entry) != null) ...[
          const SizedBox(height: 8),
          Text(
            'Estimated wait: ${_waitQuote(entry)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
        if (paused) ...[
          const SizedBox(height: 12),
          const Text(
            'Calling is briefly paused — hang tight, your spot is safe.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          "We'll send a push notification when your seats are ready.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        CupertinoButton(
          onPressed: _busy ? null : _leave,
          child: const Text(
            'Leave the waitlist',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
      ],
    );
  }

  Widget _statusMessage({
    required String emoji,
    required String title,
    required String body,
    required bool showLeave,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (showLeave) ...[
            const SizedBox(height: 24),
            CupertinoButton(
              onPressed: _busy ? null : _leave,
              child: const Text(
                'Cancel my spot',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

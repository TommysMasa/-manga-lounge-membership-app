import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../features/auth/domain/entities/auth_state.dart';
import '../../../../features/auth/presentation/providers/auth_state_notifier.dart';
import '../../../../shared/theme/app_theme.dart';

/// In-app survey screen backed by a Tally form.
///
/// Opened via the universal link
/// `https://simpleapp-5c1c6.web.app/survey?form=<tallyFormId>`
/// (typically from a QR code posted in the lounge).
///
/// The current user's Firebase UID is passed to Tally through a hidden
/// field (`uid`), so responses can be tied to the member without the
/// user seeing or editing it. The Tally form must have a hidden field
/// named `uid` configured.
class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key, required this.formId});

  /// Tally form ID, e.g. "3xQK5O" for https://tally.so/r/3xQK5O
  final String formId;

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  void _initWebView(String uid) {
    if (_controller != null) return;

    final url = Uri.https('tally.so', '/r/${widget.formId}', {
      'uid': uid,
      // Tally embed option: hide the form's own title for a cleaner look
      'hideTitle': '1',
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CupertinoColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        middle: const Text(
          'Survey',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Opened directly from a deep link: fall back to home
              const HomeRoute().go(context);
            }
          },
          child: const Icon(
            CupertinoIcons.xmark,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      child: SafeArea(child: _buildBody(authState)),
    );
  }

  Widget _buildBody(AuthState authState) {
    if (widget.formId.isEmpty) {
      return _buildMessage('This survey link is invalid or has expired.');
    }

    return authState.when(
      // Auth state is still being restored (e.g. cold start from the QR
      // code); wait before deciding.
      initial: () => const Center(child: CupertinoActivityIndicator()),
      loading: () => const Center(child: CupertinoActivityIndicator()),
      otpSent: (verificationId, phoneNumber) => _buildSignInPrompt(),
      unauthenticated: () => _buildSignInPrompt(),
      error: (_) => _buildSignInPrompt(),
      authenticated: (uid) {
        _initWebView(uid);
        return Stack(
          children: [
            WebViewWidget(controller: _controller!),
            if (_isLoading) const Center(child: CupertinoActivityIndicator()),
          ],
        );
      },
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please sign in to take the survey.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () => const SplashRoute().go(context),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../shared/theme/app_theme.dart';

/// Manga library search. Opens as a clean white screen with just a search
/// field; results render in a web view of our libib catalog, driven
/// remotely (we fill libib's own search box via JS).
class MangaSearchScreen extends StatefulWidget {
  const MangaSearchScreen({super.key});

  @override
  State<MangaSearchScreen> createState() => _MangaSearchScreenState();
}

class _MangaSearchScreenState extends State<MangaSearchScreen> {
  static const _libraryUrl = 'https://www.libib.com/u/mangaloungemo';

  /// Hides libib's chrome (banners, their search box) and removes the
  /// fixed-header offsets, so only the results grid shows under our own
  /// search field. Conservative: layout stays libib's, so a site update
  /// degrades gracefully (their chrome reappears, nothing breaks).
  static const _tidyCss = '''
    #header-bar { display: none !important; }
    #navbar { display: none !important; }
    .navbar-spacer { display: none !important; }
    #powered { display: none !important; }
    #mobile-top-menu { display: none !important; }
    #search-pane { display: none !important; }
    #primary { top: 0 !important; }
    #publish-wrap { top: 0 !important; }
  ''';

  late final WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;
  bool _pageReady = false;
  String? _pendingQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _injectTidyCss() async {
    await _controller.runJavaScript(
      "(function(){"
      "var s=document.getElementById('ml-tidy');"
      "if(!s){s=document.createElement('style');s.id='ml-tidy';"
      "document.head.appendChild(s);}"
      's.textContent=`$_tidyCss`;})();',
    );
  }

  /// Drives libib's own (hidden) search input: their real search runs on an
  /// Enter keyup (which=13), so we fire exactly that through jQuery.
  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) return;
    final literal = jsonEncode(query.trim());
    await _controller.runJavaScript(
      '(function(){'
      'var jq=window.\$;'
      "jq('#search').prop('disabled',false).val($literal);"
      "var ev=jq.Event('keyup');ev.which=13;ev.keyCode=13;"
      "jq('#search').trigger(ev);"
      '})();',
    );
  }

  void _submit(String query) {
    setState(() => _hasSearched = true);
    _logSearch(query);
    if (_pageReady) {
      _runSearch(query);
    } else {
      _pendingQuery = query;
    }
  }

  /// Fire-and-forget search log (title demand signal for purchasing).
  /// Never awaited and never surfaces errors, so search feel is unchanged.
  /// `expireAt` is the TTL field: entries self-delete after a year once the
  /// Firestore TTL policy on it is enabled.
  void _logSearch(String query) {
    final trimmed = query.trim();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (trimmed.isEmpty || uid == null) return;
    unawaited(
      FirebaseFirestore.instance
          .collection('mangaSearches')
          .add({
            'uid': uid,
            'query': trimmed,
            'at': FieldValue.serverTimestamp(),
            'expireAt': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 365)),
            ),
          })
          .then((_) {}, onError: (_) {}),
    );
  }

  @override
  void initState() {
    super.initState();
    // Loads in the background while the screen still shows only the search
    // field, so the first search feels instant.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress >= 60) _injectTidyCss();
          },
          onPageFinished: (_) async {
            await _injectTidyCss();
            _pageReady = true;
            final pending = _pendingQuery;
            _pendingQuery = null;
            if (pending != null) await _runSearch(pending);
            if (mounted) setState(() {});
          },
        ),
      )
      ..loadRequest(Uri.parse(_libraryUrl));
  }

  Widget _searchField() {
    return CupertinoSearchTextField(
      controller: _searchController,
      placeholder: 'Search our manga library',
      onSubmitted: _submit,
    );
  }

  /// Google-style landing: logo, a one-liner, and a prominent pill search
  /// bar floating just above center.
  Widget _landing() {
    return Align(
      alignment: const Alignment(0, -0.35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_Alphabet1.png', height: 48),
            const SizedBox(height: 10),
            const Text(
              'Search 7,800+ manga on our shelves',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 26),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search titles or authors',
                onSubmitted: _submit,
                backgroundColor: const Color(0x00000000),
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(middle: Text('Manga Search')),
      child: SafeArea(
        // Before the first search: Google-style landing on white.
        // After: field docks to the top with results below.
        child: !_hasSearched
            ? _landing()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: _searchField(),
                  ),
                  Expanded(
                    child: !_pageReady
                        ? const Center(
                            child: CupertinoActivityIndicator(radius: 14),
                          )
                        : WebViewWidget(controller: _controller),
                  ),
                ],
              ),
      ),
    );
  }
}

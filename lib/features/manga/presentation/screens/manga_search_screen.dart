import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  bool _hasSearched = false;
  bool _pageReady = false;
  String? _pendingQuery;

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
    if (_pageReady) {
      _runSearch(query);
    } else {
      _pendingQuery = query;
    }
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(middle: Text('Manga Search')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: CupertinoSearchTextField(
                placeholder: 'Search our manga library',
                onSubmitted: _submit,
              ),
            ),
            Expanded(
              child: !_hasSearched
                  ? const ColoredBox(color: CupertinoColors.white)
                  : !_pageReady
                  ? const Center(child: CupertinoActivityIndicator(radius: 14))
                  : WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}

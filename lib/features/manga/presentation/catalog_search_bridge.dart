/// Observe Libib's completed search response, not an empty/loading DOM.
/// Only first-page searches emit a state; infinite scrolling is ignored.
const catalogSearchBridge = r'''
(function () {
  var jq = window.$;
  if (!jq) return;
  function result(settings, response, failed) {
    if (!/\/search$/.test(settings.url || '')) return;
    var params = new URLSearchParams(settings.data || '');
    if (params.get('offset') !== '0') return;
    var query = (params.get('keywords') || '').trim();
    if (!query) return;
    var empty = false;
    var ok = false;
    if (!failed) {
      try {
        var data = typeof response === 'string' ? JSON.parse(response) : response;
        ok = data && data.outcome === 'success';
        if (ok) {
          var parsed = new DOMParser().parseFromString(data['item-info'] || '', 'text/html');
          empty = /No items found with this query!/i.test(parsed.body.textContent || '');
        }
      } catch (_) {}
    }
    MangaSearchState.postMessage(JSON.stringify({query: query, empty: !!empty, ok: !!ok}));
  }
  jq(document).off('.mangaLounge');
  jq(document).on('ajaxSuccess.mangaLounge', function (_, xhr, settings, data) {
    result(settings, data, false);
  });
  jq(document).on('ajaxError.mangaLounge', function (_, xhr, settings) {
    result(settings, null, true);
  });
})();
''';

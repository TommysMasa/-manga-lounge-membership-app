/// Adds a request action below Libib's own no-results message. The catalog
/// remains visible and keeps its original layout and text.
/// Called only for a completed empty search by a Pro member.
const catalogRequestButton = r'''
(function () {
  var id = 'ml-request-manga';
  var old = document.getElementById(id);
  if (old) old.remove();
  var observer;
  function install() {
    var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
    var text;
    while ((text = walker.nextNode())) {
      if (text.nodeValue.replace(/\s+/g, ' ').trim() !==
          'No items found with this query!') continue;
      var message = text.parentElement;
      if (!message || document.getElementById(id)) return true;
      var button = document.createElement('button');
      button.id = id;
      button.type = 'button';
      button.textContent = 'Request this manga';
      button.setAttribute('aria-label', 'Request this manga');
      button.style.cssText =
        'display:block;width:max-content;min-height:48px;' +
        'margin:25px auto 0;padding:0 25px;border:0;border-radius:28px;' +
        'background:#F49A42;color:#1F1F1F;' +
        'font:600 15px -apple-system,BlinkMacSystemFont,Arial,sans-serif;' +
        'cursor:pointer;';
      button.addEventListener('click', function () {
        MangaRequestTap.postMessage('request');
      });
      message.insertAdjacentElement('afterend', button);
      if (observer) observer.disconnect();
      return true;
    }
    return false;
  }
  if (install()) return;
  observer = new MutationObserver(install);
  observer.observe(document.body, {childList: true, subtree: true});
  setTimeout(function () { observer.disconnect(); }, 2000);
})();
''';

const removeCatalogRequestButton = r'''
(function () {
  var button = document.getElementById('ml-request-manga');
  if (button) button.remove();
})();
''';

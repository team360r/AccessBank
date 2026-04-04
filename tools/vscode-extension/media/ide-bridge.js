// ide-bridge.js — postMessage abstraction for VS Code and Android Studio WebViews.
// Loaded after tutorial_panel.html's own scripts so it can override the stubs.

(function () {
  let _hostMessageCallback = null;

  // ── VS Code ───────────────────────────────────────────────────────────────
  if (typeof acquireVsCodeApi !== 'undefined') {
    const vscode = acquireVsCodeApi();

    window.postToHost = function (msg) {
      vscode.postMessage(msg);
    };

    window.onHostMessage = function (cb) {
      _hostMessageCallback = cb;
    };

    window.addEventListener('message', (event) => {
      if (_hostMessageCallback) _hostMessageCallback(event.data);
    });

    // Restore persisted state across WebView reloads.
    const saved = vscode.getState();
    if (saved) {
      window.addEventListener('DOMContentLoaded', () => {
        if (saved.state) applyState(saved.state);
        if (saved.content) {
          content = saved.content;
          renderChapterList();
          renderStep();
        }
      });
    }

    // Persist state on every tutorial state update.
    const _orig = window.applyState;
    window.applyState = function (s) {
      _orig(s);
      vscode.setState({ state: s, content: window.content });
    };

  // ── Android Studio (JBCefBrowser / CefSharp) ──────────────────────────────
  } else if (typeof cefQuery !== 'undefined' || typeof CefSharp !== 'undefined') {

    window.postToHost = function (msg) {
      const json = JSON.stringify(msg);
      if (typeof cefQuery !== 'undefined') {
        cefQuery({ request: json, onSuccess: function(){}, onFailure: function(){} });
      } else if (typeof CefSharp !== 'undefined') {
        CefSharp.PostMessage(json);
      }
    };

    window.onHostMessage = function (cb) {
      _hostMessageCallback = cb;
    };

    // Android Studio plugin calls this global to push messages into the panel.
    window.__accessguideReceive = function (json) {
      if (_hostMessageCallback) _hostMessageCallback(JSON.parse(json));
    };

  // ── Fallback (plain browser — for development) ────────────────────────────
  } else {
    window.postToHost = function (msg) {
      console.log('[AccessGuide → host]', msg);
    };

    window.onHostMessage = function (cb) {
      _hostMessageCallback = cb;
      // In dev mode, load content from the JSON file directly.
      fetch('tutorial_content.json')
        .then(r => r.json())
        .then(data => cb({ action: 'load_content', payload: data }))
        .catch(() => console.warn('tutorial_content.json not found — run the content generator'));
    };

    // Allow testing via browser console: window.__send({action:'tutorial_state', payload:{...}})
    window.__send = function (msg) {
      if (_hostMessageCallback) _hostMessageCallback(msg);
    };
  }
})();

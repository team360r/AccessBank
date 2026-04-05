# AccessGuide VS Code Extension + Tutorial Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the shared HTML tutorial panel and the VS Code extension that renders it, connects to the relay server, detects physical devices, auto-launches the Flutter app, and validates code changes via file watching.

**Architecture:** A single self-contained `tools/shared/tutorial_panel.html` renders in both VS Code's `WebviewPanel` and (later) Android Studio's `JBCefBrowser`. The VS Code extension (`tools/vscode-extension/`) is a thin TypeScript shell that: hosts the WebView, bridges messages to the relay server WebSocket, manages `flutter run` as a child process, and watches files for code validation.

**Tech Stack:** TypeScript, VS Code Extension API (`vscode.WebviewViewProvider`), Node.js `ws` package, HTML/CSS/JS with Prism.js for syntax highlighting.

**Deliverable:** Install `tools/vscode-extension/accessguide.vsix` in VS Code, open the project, connect a physical phone — the tutorial panel appears with chapter content, controls the phone, and ticks a green checkmark when the learner adds the expected code.

**Depends on:** Sub-Plan 1 (core infrastructure) — server must be running, `tools/shared/tutorial_content.json` must exist.
**Required before:** Sub-Plan 3 (Android Studio plugin — shares the HTML panel).

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `tools/shared/tutorial_panel.html` | Create | Self-contained HTML/CSS/JS panel UI |
| `tools/shared/ide-bridge.js` | Create | IDE-agnostic postMessage abstraction |
| `tools/vscode-extension/package.json` | Create | Extension manifest: activation, views, commands |
| `tools/vscode-extension/tsconfig.json` | Create | TypeScript config |
| `tools/vscode-extension/.vscodeignore` | Create | Exclude source from package |
| `tools/vscode-extension/src/extension.ts` | Create | Activation: start server, register provider, status bar |
| `tools/vscode-extension/src/tutorialPanel.ts` | Create | `WebviewViewProvider`: loads HTML, bridges messages |
| `tools/vscode-extension/src/relayClient.ts` | Create | WebSocket client to `ws://localhost:9274/ws` |
| `tools/vscode-extension/src/deviceManager.ts` | Create | Poll `flutter devices`, auto-launch `flutter run`, `adb reverse` |
| `tools/vscode-extension/src/fileWatcher.ts` | Create | Watch current step's `codeDiff.filePath` for expected pattern |
| `tools/vscode-extension/src/serverManager.ts` | Create | Start/stop the Dart tutorial server subprocess |
| `tools/vscode-extension/media/tutorial_panel.html` | Symlink/copy | Served to the WebView |
| `tools/vscode-extension/media/tutorial_content.json` | Symlink/copy | Bundled chapter data |

---

## Task 13: Tutorial panel HTML — skeleton and navigation

**Files:**
- Create: `tools/shared/tutorial_panel.html`

- [ ] **Step 1: Create the HTML skeleton with chapter list and step card**

Create `tools/shared/tutorial_panel.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>AccessGuide</title>
<style>
  /* ── Reset ── */
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
         font-size: 13px; line-height: 1.5; background: var(--bg); color: var(--fg); }

  /* ── Theme tokens (VS Code dark by default, overridden by ide-bridge) ── */
  :root {
    --bg: #1e1e1e; --fg: #cccccc; --border: #333;
    --primary: #4a90d9; --primary-fg: #fff;
    --surface: #252526; --surface2: #2d2d30;
    --success: #4caf50; --error: #f44336;
    --amber-bg: #fff8e1; --amber-border: #ffb300; --amber-fg: #5d4037;
    --cyan-bg: #e0f7fa; --cyan-border: #00acc1; --cyan-fg: #006064;
    --code-bg: #1e1e1e; --code-fg: #d4d4d4;
  }
  body.light {
    --bg: #f5f5f5; --fg: #333; --border: #ddd;
    --surface: #fff; --surface2: #f0f0f0;
    --amber-fg: #5d4037; --cyan-fg: #006064;
    --code-bg: #1e1e1e;
  }

  /* ── Layout ── */
  .shell { display: flex; flex-direction: column; height: 100vh; overflow: hidden; }
  .header { background: var(--primary); color: var(--primary-fg);
            padding: 8px 12px; display: flex; align-items: center; gap: 8px;
            flex-shrink: 0; }
  .header-title { flex: 1; font-weight: 600; font-size: 13px; overflow: hidden;
                  white-space: nowrap; text-overflow: ellipsis; }
  .connection-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
  .dot-connected { background: #4caf50; }
  .dot-disconnected { background: #f44336; }

  .progress-bar-wrap { height: 3px; background: var(--border); flex-shrink: 0; }
  .progress-bar-fill { height: 3px; background: var(--primary); transition: width 0.3s; }

  .body { display: flex; flex: 1; overflow: hidden; }
  .sidebar { width: 160px; flex-shrink: 0; border-right: 1px solid var(--border);
             overflow-y: auto; background: var(--surface); }
  .content { flex: 1; overflow-y: auto; padding: 12px; }

  /* ── Sidebar chapters ── */
  .ch-item { padding: 6px 10px; cursor: pointer; border-left: 3px solid transparent;
             font-size: 11px; color: var(--fg); display: flex; align-items: center; gap: 6px; }
  .ch-item:hover { background: var(--surface2); }
  .ch-item.active { border-left-color: var(--primary); background: var(--surface2); font-weight: 600; }
  .ch-item.locked { color: var(--border); cursor: default; }
  .ch-icon { font-size: 10px; flex-shrink: 0; }

  /* ── Step card ── */
  .step-badge { font-size: 11px; color: var(--primary); font-weight: 600; margin-bottom: 4px; }
  .step-title { font-size: 15px; font-weight: 700; margin-bottom: 10px; }
  .explanation { color: var(--fg); margin-bottom: 12px; line-height: 1.6; }
  .explanation p { margin-bottom: 8px; }
  .explanation code { background: var(--surface2); border-radius: 3px;
                      padding: 1px 4px; font-family: monospace; font-size: 12px; }
  .explanation strong { font-weight: 600; }

  /* ── Code diff ── */
  .diff-wrap { margin: 12px 0; }
  .diff-filepath { font-size: 10px; color: var(--primary); font-family: monospace;
                   margin-bottom: 6px; background: var(--surface2);
                   padding: 3px 8px; border-radius: 3px; display: inline-block; }
  .diff-panels { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
  @media (max-width: 500px) { .diff-panels { grid-template-columns: 1fr; } }
  .diff-panel { border-radius: 6px; overflow: hidden; }
  .diff-panel-header { padding: 4px 8px; font-size: 11px; font-weight: 600; color: #fff; }
  .diff-before .diff-panel-header { background: #c62828; }
  .diff-after .diff-panel-header { background: #2e7d32; }
  .diff-code { background: var(--code-bg); padding: 8px; overflow-x: auto;
               font-family: 'Cascadia Code', 'Fira Code', monospace; font-size: 11px;
               line-height: 1.6; max-height: 260px; overflow-y: auto; }

  /* ── Prism overrides ── */
  .token.comment { color: #6a9955; }
  .token.string { color: #ce9178; }
  .token.keyword { color: #569cd6; }
  .token.class-name { color: #4ec9b0; }
  .token.function { color: #dcdcaa; }
  .token.operator, .token.punctuation { color: #d4d4d4; }
  .token.number { color: #b5cea8; }

  /* ── Callouts ── */
  .callout { border-radius: 6px; padding: 10px 12px; margin: 10px 0; }
  .callout-why { background: var(--amber-bg); border-left: 4px solid var(--amber-border);
                 color: var(--amber-fg); }
  .callout-try { background: var(--cyan-bg); border-left: 4px solid var(--cyan-border);
                 color: var(--cyan-fg); }
  .callout-label { font-size: 10px; font-weight: 700; text-transform: uppercase;
                   letter-spacing: 0.5px; margin-bottom: 4px; }
  .callout label { display: flex; align-items: center; gap: 6px; margin-top: 8px;
                   cursor: pointer; font-size: 12px; }

  /* ── Code check ── */
  .code-check { display: flex; align-items: center; gap: 6px; margin: 8px 0;
                font-size: 12px; padding: 6px 10px; border-radius: 4px; }
  .code-check.pass { background: #e8f5e9; color: #2e7d32; }
  .code-check.pending { background: var(--surface2); color: var(--fg); }

  /* ── Quiz ── */
  .quiz-wrap { border: 1px solid var(--border); border-radius: 8px; padding: 12px; margin: 12px 0; }
  .quiz-title { font-weight: 700; font-size: 13px; margin-bottom: 10px; }
  .question { margin-bottom: 12px; }
  .question-text { font-weight: 500; margin-bottom: 6px; }
  .option { display: flex; align-items: flex-start; gap: 8px; padding: 5px 0; cursor: pointer; }
  .option input { margin-top: 2px; flex-shrink: 0; }
  .option.correct { color: var(--success); font-weight: 500; }
  .option.wrong { color: var(--error); }
  .explanation-text { font-size: 11px; margin-top: 4px; padding: 4px 8px;
                      background: var(--surface2); border-radius: 4px; }
  .score-banner { text-align: center; padding: 8px; border-radius: 6px; font-weight: 600;
                  margin: 8px 0; }
  .score-banner.pass { background: #e8f5e9; color: #2e7d32; }
  .score-banner.fail { background: #ffebee; color: #c62828; }

  /* ── Footer ── */
  .footer { padding: 8px 12px; border-top: 1px solid var(--border); flex-shrink: 0;
            background: var(--surface); display: flex; align-items: center; gap: 8px; }
  .toggle-row { display: flex; align-items: center; gap: 6px; font-size: 11px; flex: 1; }
  .toggle { position: relative; width: 36px; height: 18px; }
  .toggle input { opacity: 0; width: 0; height: 0; }
  .toggle-slider { position: absolute; inset: 0; background: var(--border); border-radius: 9px;
                   cursor: pointer; transition: 0.2s; }
  .toggle-slider::before { content: ''; position: absolute; width: 14px; height: 14px;
                            left: 2px; top: 2px; background: white; border-radius: 50%;
                            transition: 0.2s; }
  .toggle input:checked + .toggle-slider { background: var(--primary); }
  .toggle input:checked + .toggle-slider::before { transform: translateX(18px); }
  .badge { font-size: 10px; padding: 1px 6px; border-radius: 10px; font-weight: 600; }
  .badge-accessible { background: #e8f5e9; color: #2e7d32; }
  .badge-inaccessible { background: #ffebee; color: #c62828; }
  .nav-btn { padding: 5px 12px; border-radius: 4px; border: 1px solid var(--border);
             cursor: pointer; font-size: 12px; background: var(--surface2); color: var(--fg); }
  .nav-btn.primary { background: var(--primary); color: white; border-color: var(--primary); }
  .nav-btn:disabled { opacity: 0.4; cursor: default; }
</style>
</head>
<body>
<div class="shell">

  <!-- Header -->
  <div class="header">
    <span class="connection-dot dot-disconnected" id="connDot"></span>
    <span class="header-title" id="headerTitle">AccessGuide</span>
    <span id="connLabel" style="font-size:11px;opacity:0.8">Connecting...</span>
  </div>

  <!-- Progress -->
  <div class="progress-bar-wrap">
    <div class="progress-bar-fill" id="progressBar" style="width:0%"></div>
  </div>

  <!-- Body: sidebar + content -->
  <div class="body">
    <nav class="sidebar" id="chapterList"></nav>
    <main class="content" id="stepContent">
      <div style="padding:20px;color:var(--border)">Loading tutorial...</div>
    </main>
  </div>

  <!-- Footer -->
  <div class="footer">
    <div class="toggle-row">
      <span style="opacity:0.7">Before</span>
      <label class="toggle">
        <input type="checkbox" id="accessibleToggle" onchange="onToggleAccessible(this.checked)">
        <span class="toggle-slider"></span>
      </label>
      <span style="opacity:0.7">After</span>
      <span class="badge" id="accessibleBadge">Inaccessible</span>
    </div>
    <button class="nav-btn" id="prevBtn" onclick="onPrev()" disabled>← Prev</button>
    <button class="nav-btn primary" id="nextBtn" onclick="onNext()">Next →</button>
  </div>
</div>

<!-- Prism.js (bundled inline — syntax highlighting) -->
<script>
// Minimal Prism-like tokenizer for Dart (no external dependency)
function highlightDart(code) {
  const escaped = code
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return escaped
    .replace(/(\/\/[^\n]*)/g, '<span class="token comment">$1</span>')
    .replace(/('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")/g, '<span class="token string">$1</span>')
    .replace(/\b(class|extends|implements|override|return|final|const|var|void|bool|int|String|double|List|Map|null|true|false|async|await|if|else|for|in|import|export|new|this|super|required|late)\b/g,
      '<span class="token keyword">$1</span>')
    .replace(/\b(Semantics|MergeSemantics|ExcludeSemantics|SemanticsService|Widget|BuildContext|StatelessWidget|StatefulWidget|State|Key|MaterialApp|Scaffold)\b/g,
      '<span class="token class-name">$1</span>');
}
</script>

<script>
// ── State ──────────────────────────────────────────────────────────────────
let content = null;       // tutorial_content.json parsed
let state = {             // mirrors server TutorialState
  chapterIndex: 0, stepIndex: 0, completed: [], quizScores: {},
  showAccessible: false, showInspector: false, allowedTabIndex: null,
};
let codeCheckPassed = false;
let quizAnswers = {};     // questionIndex → selectedOption
let quizSubmitted = false;

// ── IDE bridge (loaded after this script) ─────────────────────────────────
function postToHost(msg)  { /* overridden by ide-bridge.js */ }
function onHostMessage(cb){ /* overridden by ide-bridge.js */ }

// ── Boot ──────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  // ide-bridge.js sets up postToHost / onHostMessage before this runs.
  onHostMessage(handleHostMessage);
  postToHost({ action: 'ready' });
});

function handleHostMessage(msg) {
  const { action, payload } = msg;
  switch (action) {
    case 'load_content':
      content = payload;
      renderChapterList();
      renderStep();
      break;
    case 'tutorial_state':
      applyState(payload);
      break;
    case 'code_check':
      codeCheckPassed = payload.passed;
      renderCodeCheck();
      break;
    case 'app_connected':
      setConnectionStatus(true, payload.device);
      break;
    case 'app_disconnected':
      setConnectionStatus(false, null);
      break;
  }
}

function applyState(s) {
  const chapterChanged = s.chapterIndex !== state.chapterIndex;
  state = { ...state, ...s };
  if (chapterChanged) { quizAnswers = {}; quizSubmitted = false; codeCheckPassed = false; }
  renderChapterList();
  renderStep();
  updateProgress();
  document.getElementById('accessibleToggle').checked = state.showAccessible;
  updateBadge(state.showAccessible);
}

// ── Sidebar ────────────────────────────────────────────────────────────────
function renderChapterList() {
  if (!content) return;
  const list = document.getElementById('chapterList');
  list.innerHTML = content.chapters.map((ch, i) => {
    const done = state.completed.includes(i);
    const active = i === state.chapterIndex;
    const locked = i > 0 && !state.completed.includes(i - 1) && !done && !active;
    const icon = done ? '✓' : locked ? '🔒' : active ? '▶' : '○';
    return `<div class="ch-item ${active ? 'active' : ''} ${locked ? 'locked' : ''}"
                 onclick="${locked ? '' : `goToChapter(${i})`}"
                 title="${ch.title}">
              <span class="ch-icon">${icon}</span>
              <span style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis">${ch.title}</span>
            </div>`;
  }).join('');
}

// ── Step card ──────────────────────────────────────────────────────────────
function renderStep() {
  if (!content) return;
  const ch = content.chapters[state.chapterIndex];
  if (!ch) return;
  const step = ch.steps[state.stepIndex];
  const isLastStep = state.stepIndex >= ch.steps.length - 1;
  const isLastChapter = state.chapterIndex >= content.chapters.length - 1;

  // Header
  document.getElementById('headerTitle').textContent =
    `Ch ${state.chapterIndex + 1}: ${ch.title}`;

  // Nav buttons
  const prevBtn = document.getElementById('prevBtn');
  const nextBtn = document.getElementById('nextBtn');
  prevBtn.disabled = state.chapterIndex === 0 && state.stepIndex === 0;
  nextBtn.textContent = isLastStep
    ? (isLastChapter ? 'Finish ✓' : 'Next Chapter →')
    : 'Next →';

  if (!step) { document.getElementById('stepContent').innerHTML = ''; return; }

  let html = `
    <div class="step-badge">Step ${state.stepIndex + 1} of ${ch.steps.length}</div>
    <div class="step-title">${step.title}</div>
    <div class="explanation">${renderMarkdown(step.explanation)}</div>
  `;

  if (step.codeDiff) {
    html += renderCodeDiff(step.codeDiff);
    html += `<div class="code-check ${codeCheckPassed ? 'pass' : 'pending'}" id="codeCheck">
      ${codeCheckPassed ? '✓ Code change detected' : '○ Make the code change shown above'}
    </div>`;
  }

  if (step.whyItMatters) {
    html += `<div class="callout callout-why">
      <div class="callout-label">💡 Why this matters</div>
      <div>${step.whyItMatters}</div>
    </div>`;
  }

  if (step.tryItPrompt) {
    html += `<div class="callout callout-try">
      <div class="callout-label">🖐 Try it yourself</div>
      <div>${step.tryItPrompt}</div>
      <label><input type="checkbox" id="tryCheck" ${getTryChecked() ? 'checked' : ''}
               onchange="setTryChecked(this.checked)"> I've tried this</label>
    </div>`;
  }

  if (step.referenceLinks && step.referenceLinks.length > 0) {
    html += `<div style="margin-top:12px;font-size:11px;">
      <span style="opacity:0.6">References: </span>
      ${step.referenceLinks.map(url =>
        `<a href="${url}" onclick="postToHost({action:'open_url',payload:{url:'${url}'}}); return false;"
            style="color:var(--primary);margin-right:8px;">${url.replace('https://', '')}</a>`
      ).join('')}
    </div>`;
  }

  // Quiz at end of chapter
  if (isLastStep && ch.quiz) {
    html += renderQuiz(ch.quiz, state.chapterIndex);
  }

  document.getElementById('stepContent').innerHTML = html;
  document.getElementById('stepContent').scrollTop = 0;
}

function renderCodeDiff(diff) {
  return `<div class="diff-wrap">
    <div class="diff-filepath">${diff.filePath}</div>
    <div class="diff-panels">
      <div class="diff-panel diff-before">
        <div class="diff-panel-header">Before</div>
        <pre class="diff-code"><code>${highlightDart(diff.before)}</code></pre>
      </div>
      <div class="diff-panel diff-after">
        <div class="diff-panel-header">After</div>
        <pre class="diff-code"><code>${highlightDart(diff.after)}</code></pre>
      </div>
    </div>
  </div>`;
}

function renderMarkdown(text) {
  return text
    .split('\n\n').map(para => `<p>${para
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/`(.+?)`/g, '<code>$1</code>')
      .replace(/\n/g, ' ')
    }</p>`).join('');
}

// ── Quiz ───────────────────────────────────────────────────────────────────
function renderQuiz(quiz, chapterId) {
  const score = quizSubmitted
    ? quiz.questions.reduce((sum, q, i) => sum + (quizAnswers[i] === q.correctIndex ? 1 : 0), 0)
    : null;

  let html = `<div class="quiz-wrap">
    <div class="quiz-title">📝 ${quiz.title}</div>`;

  if (quizSubmitted && score !== null) {
    const pass = score >= Math.ceil(quiz.questions.length * 0.7);
    html += `<div class="score-banner ${pass ? 'pass' : 'fail'}">
      ${pass ? '🎉' : '💪'} ${score}/${quiz.questions.length} correct
    </div>`;
  }

  quiz.questions.forEach((q, qi) => {
    html += `<div class="question">
      <div class="question-text">${qi + 1}. ${q.question}</div>`;
    q.options.forEach((opt, oi) => {
      const selected = quizAnswers[qi] === oi;
      const cls = quizSubmitted
        ? (oi === q.correctIndex ? 'correct' : selected ? 'wrong' : '')
        : '';
      html += `<label class="option ${cls}">
        <input type="radio" name="q${qi}" value="${oi}"
          ${selected ? 'checked' : ''}
          ${quizSubmitted ? 'disabled' : ''}
          onchange="selectAnswer(${qi}, ${oi})">
        <span>${opt}</span>
      </label>`;
    });
    if (quizSubmitted) {
      html += `<div class="explanation-text">${q.explanation}</div>`;
    }
    html += `</div>`;
  });

  const allAnswered = quiz.questions.every((_, i) => quizAnswers[i] !== undefined);
  html += `<div style="display:flex;gap:8px;margin-top:8px;">
    <button class="nav-btn ${!quizSubmitted ? 'primary' : ''}"
      onclick="submitQuiz(${chapterId}, ${JSON.stringify(quiz.questions.length)})"
      ${(!allAnswered || quizSubmitted) ? 'disabled' : ''}>
      Check Answers
    </button>
    ${quizSubmitted ? `<button class="nav-btn" onclick="resetQuiz()">Try Again</button>` : ''}
  </div></div>`;
  return html;
}

function selectAnswer(qi, oi) { quizAnswers[qi] = oi; }

function submitQuiz(chapterId, totalQuestions) {
  quizSubmitted = true;
  const score = content.chapters[chapterId].quiz.questions
    .reduce((sum, q, i) => sum + (quizAnswers[i] === q.correctIndex ? 1 : 0), 0);
  postToHost({ action: 'submit_quiz', payload: { chapterId, score } });
  renderStep();
}

function resetQuiz() { quizAnswers = {}; quizSubmitted = false; renderStep(); }

// ── Try-it persistence (session only) ─────────────────────────────────────
const _tryChecked = {};
function getTryChecked() { return !!_tryChecked[`${state.chapterIndex}-${state.stepIndex}`]; }
function setTryChecked(v) { _tryChecked[`${state.chapterIndex}-${state.stepIndex}`] = v; }

// ── Code check ────────────────────────────────────────────────────────────
function renderCodeCheck() {
  const el = document.getElementById('codeCheck');
  if (!el) return;
  el.className = `code-check ${codeCheckPassed ? 'pass' : 'pending'}`;
  el.textContent = codeCheckPassed ? '✓ Code change detected' : '○ Make the code change shown above';
}

// ── Navigation ────────────────────────────────────────────────────────────
function onNext() { postToHost({ action: 'next_step', payload: {} }); }
function onPrev() { postToHost({ action: 'previous_step', payload: {} }); }
function goToChapter(i) { postToHost({ action: 'go_to_chapter', payload: { chapterIndex: i } }); }

// ── Before/After toggle ───────────────────────────────────────────────────
function onToggleAccessible(value) {
  postToHost({ action: 'set_accessible', payload: { value } });
  updateBadge(value);
}
function updateBadge(value) {
  const badge = document.getElementById('accessibleBadge');
  badge.textContent = value ? 'Accessible' : 'Inaccessible';
  badge.className = `badge ${value ? 'badge-accessible' : 'badge-inaccessible'}`;
}

// ── Progress ──────────────────────────────────────────────────────────────
function updateProgress() {
  if (!content) return;
  const totalSteps = content.chapters.reduce((s, c) => s + c.steps.length, 0);
  const doneSteps = content.chapters.slice(0, state.chapterIndex)
    .reduce((s, c) => s + c.steps.length, 0) + state.stepIndex;
  document.getElementById('progressBar').style.width =
    `${Math.round((doneSteps / totalSteps) * 100)}%`;
}

// ── Connection status ─────────────────────────────────────────────────────
function setConnectionStatus(connected, deviceName) {
  const dot = document.getElementById('connDot');
  const label = document.getElementById('connLabel');
  dot.className = `connection-dot ${connected ? 'dot-connected' : 'dot-disconnected'}`;
  label.textContent = connected ? `📱 ${deviceName}` : 'No device';
}
</script>

<!-- ide-bridge.js is injected by the extension host AFTER this file -->
<script src="ide-bridge.js"></script>
</body>
</html>
```

- [ ] **Step 2: Verify HTML opens in a browser and renders correctly**

```bash
open tools/shared/tutorial_panel.html
```

Expected: Panel opens in Safari/Chrome. Shows sidebar "Loading tutorial..." and footer with Prev/Next buttons. No errors in browser console.

- [ ] **Step 3: Commit**

```bash
git add tools/shared/tutorial_panel.html
git commit -m "feat: add self-contained tutorial panel HTML/CSS/JS"
```

---

## Task 14: IDE bridge abstraction layer

**Files:**
- Create: `tools/shared/ide-bridge.js`

- [ ] **Step 1: Create the bridge**

Create `tools/shared/ide-bridge.js`:

```javascript
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
```

- [ ] **Step 2: Verify browser fallback loads content**

```bash
# Serve from tools/shared/ (not file://) so fetch() works
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/shared
python3 -m http.server 8888
```

Open `http://localhost:8888/tutorial_panel.html` in Chrome. Expected: Panel loads, chapter list populates from `tutorial_content.json`, chapter 0 step 1 renders.

```bash
# Stop server
```

- [ ] **Step 3: Commit**

```bash
git add tools/shared/ide-bridge.js
git commit -m "feat: add IDE bridge postMessage abstraction (VS Code + Android Studio + dev fallback)"
```

---

## Task 15: VS Code extension scaffold

**Files:**
- Create: `tools/vscode-extension/package.json`
- Create: `tools/vscode-extension/tsconfig.json`
- Create: `tools/vscode-extension/.vscodeignore`
- Create: `tools/vscode-extension/.gitignore`

- [ ] **Step 1: Create extension package.json**

Create `tools/vscode-extension/package.json`:

```json
{
  "name": "accessguide",
  "displayName": "AccessGuide — Flutter Accessibility Tutorial",
  "description": "Interactive Flutter accessibility tutorial panel with phone sync",
  "version": "0.1.0",
  "publisher": "accessguide",
  "engines": { "vscode": "^1.85.0" },
  "categories": ["Education"],
  "activationEvents": ["workspaceContains:pubspec.yaml"],
  "main": "./out/extension.js",
  "contributes": {
    "viewsContainers": {
      "activitybar": [{
        "id": "accessguide",
        "title": "AccessGuide",
        "icon": "media/icon.svg"
      }]
    },
    "views": {
      "accessguide": [{
        "type": "webview",
        "id": "accessguide.tutorialPanel",
        "name": "Tutorial"
      }]
    },
    "commands": [
      { "command": "accessguide.startServer", "title": "AccessGuide: Start Server" },
      { "command": "accessguide.nextStep",    "title": "AccessGuide: Next Step" },
      { "command": "accessguide.prevStep",    "title": "AccessGuide: Previous Step" }
    ]
  },
  "scripts": {
    "compile": "tsc -p ./",
    "watch":   "tsc -watch -p ./",
    "package": "vsce package --no-dependencies"
  },
  "dependencies": {
    "ws": "^8.16.0"
  },
  "devDependencies": {
    "@types/node":   "^20.0.0",
    "@types/vscode": "^1.85.0",
    "@types/ws":     "^8.5.10",
    "@vscode/vsce":  "^2.24.0",
    "typescript":    "^5.3.0"
  }
}
```

- [ ] **Step 2: Create tsconfig.json**

Create `tools/vscode-extension/tsconfig.json`:

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "ES2020",
    "outDir": "./out",
    "rootDir": "./src",
    "lib": ["ES2020"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "out"]
}
```

- [ ] **Step 3: Create .vscodeignore**

Create `tools/vscode-extension/.vscodeignore`:

```
src/
tsconfig.json
node_modules/
.gitignore
*.map
```

- [ ] **Step 4: Create a minimal SVG icon**

Create `tools/vscode-extension/media/icon.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="#4a90d9" stroke-width="2" stroke-linecap="round">
  <rect x="2" y="3" width="20" height="14" rx="2"/>
  <path d="M8 21h8M12 17v4"/>
  <circle cx="12" cy="10" r="3"/>
</svg>
```

- [ ] **Step 5: Install dependencies**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/vscode-extension
npm install
```

- [ ] **Step 6: Commit scaffold**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
git add tools/vscode-extension/
git commit -m "feat: add VS Code extension scaffold (package.json, tsconfig, icon)"
```

---

## Task 16: VS Code relay client

**Files:**
- Create: `tools/vscode-extension/src/relayClient.ts`

- [ ] **Step 1: Implement the relay client**

Create `tools/vscode-extension/src/relayClient.ts`:

```typescript
import WebSocket from 'ws';

export type RelayMessage = {
  type: string;
  source: string;
  action: string;
  payload: Record<string, unknown>;
};

type MessageHandler = (msg: RelayMessage) => void;

export class RelayClient {
  private ws: WebSocket | null = null;
  private reconnectTimer: NodeJS.Timeout | null = null;
  private handlers: MessageHandler[] = [];
  private readonly url: string;
  private _connected = false;

  constructor(url = 'ws://localhost:9274/ws') {
    this.url = url;
  }

  connect(): void {
    try {
      this.ws = new WebSocket(this.url);

      this.ws.on('open', () => {
        this._connected = true;
        this.clearReconnect();
        // Identify as IDE client.
        this.send({ type: 'event', source: 'ide', action: 'connected', payload: {} });
      });

      this.ws.on('message', (data) => {
        try {
          const msg = JSON.parse(data.toString()) as RelayMessage;
          this.handlers.forEach(h => h(msg));
        } catch { /* malformed JSON — ignore */ }
      });

      this.ws.on('close', () => {
        this._connected = false;
        this.scheduleReconnect();
      });

      this.ws.on('error', () => {
        this._connected = false;
        this.scheduleReconnect();
      });

    } catch {
      this.scheduleReconnect();
    }
  }

  send(msg: Partial<RelayMessage>): void {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(msg));
    }
  }

  onMessage(handler: MessageHandler): void {
    this.handlers.push(handler);
  }

  get connected(): boolean { return this._connected; }

  dispose(): void {
    this.clearReconnect();
    this.ws?.close();
    this.ws = null;
  }

  private scheduleReconnect(): void {
    this.clearReconnect();
    this.reconnectTimer = setTimeout(() => this.connect(), 3000);
  }

  private clearReconnect(): void {
    if (this.reconnectTimer) { clearTimeout(this.reconnectTimer); this.reconnectTimer = null; }
  }
}
```

- [ ] **Step 2: Compile and confirm no TypeScript errors**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/vscode-extension
npm run compile
```

Expected: No errors. `out/relayClient.js` created.

- [ ] **Step 3: Commit**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
git add tools/vscode-extension/src/relayClient.ts
git commit -m "feat: add VS Code relay WebSocket client"
```

---

## Task 17: VS Code device manager

**Files:**
- Create: `tools/vscode-extension/src/deviceManager.ts`

- [ ] **Step 1: Implement device manager**

Create `tools/vscode-extension/src/deviceManager.ts`:

```typescript
import { execSync, spawn, ChildProcess } from 'child_process';
import * as vscode from 'vscode';

type FlutterDevice = {
  id: string;
  name: string;
  platform: string;
  isEmulator: boolean;
};

export class DeviceManager {
  private pollTimer: NodeJS.Timeout | null = null;
  private flutterProcess: ChildProcess | null = null;
  private _connectedDevice: FlutterDevice | null = null;
  private onDeviceChange: (device: FlutterDevice | null) => void;

  constructor(onDeviceChange: (device: FlutterDevice | null) => void) {
    this.onDeviceChange = onDeviceChange;
  }

  start(): void {
    this.poll();
    this.pollTimer = setInterval(() => this.poll(), 5000);
  }

  stop(): void {
    if (this.pollTimer) { clearInterval(this.pollTimer); this.pollTimer = null; }
    this.stopFlutter();
  }

  private poll(): void {
    try {
      const raw = execSync('flutter devices --machine 2>/dev/null', { timeout: 8000 }).toString();
      const devices: FlutterDevice[] = JSON.parse(raw);
      // Physical devices only — reject all emulators and simulators.
      const physical = devices.filter(d => !d.isEmulator && d.id !== 'flutter-tester');

      const current = physical[0] ?? null;
      const prevId = this._connectedDevice?.id;

      if (current?.id !== prevId) {
        this._connectedDevice = current;
        this.onDeviceChange(current);
        if (current) {
          this.handleDeviceConnected(current);
        } else {
          this.stopFlutter();
        }
      }
    } catch {
      // flutter not on PATH or timed out — silent fail.
    }
  }

  private handleDeviceConnected(device: FlutterDevice): void {
    // For Android: set up port forwarding.
    if (device.platform.includes('android')) {
      try {
        execSync(`adb -s ${device.id} reverse tcp:9274 tcp:9274`, { timeout: 5000 });
      } catch { /* adb not available */ }
    }

    // Discover the tutorial server host for iOS (Mac's LAN IP).
    const tutorialHost = device.platform.includes('ios')
      ? this.getMacLanIp()
      : 'localhost';

    const workspaceRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!workspaceRoot) return;

    // Don't launch if already running.
    if (this.flutterProcess && !this.flutterProcess.killed) return;

    this.flutterProcess = spawn('flutter', [
      'run',
      '--device-id', device.id,
      '--dart-define', `TUTORIAL_HOST=${tutorialHost}`,
      '--dart-define', `TUTORIAL_PORT=9274`,
    ], {
      cwd: workspaceRoot,
      stdio: 'pipe',
    });

    this.flutterProcess.on('exit', () => { this.flutterProcess = null; });
  }

  private stopFlutter(): void {
    if (this.flutterProcess && !this.flutterProcess.killed) {
      this.flutterProcess.kill();
      this.flutterProcess = null;
    }
  }

  private getMacLanIp(): string {
    try {
      // Try en0 (WiFi), then en1.
      for (const iface of ['en0', 'en1']) {
        const ip = execSync(`ipconfig getifaddr ${iface} 2>/dev/null`).toString().trim();
        if (ip) return ip;
      }
    } catch { /* ignore */ }
    return 'localhost';
  }

  get connectedDevice(): FlutterDevice | null { return this._connectedDevice; }

  dispose(): void { this.stop(); }
}
```

- [ ] **Step 2: Compile**

```bash
npm run compile
```

Expected: No TypeScript errors.

- [ ] **Step 3: Commit**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
git add tools/vscode-extension/src/deviceManager.ts
git commit -m "feat: add VS Code device manager with physical-device filter and flutter run launcher"
```

---

## Task 18: VS Code server manager and file watcher

**Files:**
- Create: `tools/vscode-extension/src/serverManager.ts`
- Create: `tools/vscode-extension/src/fileWatcher.ts`

- [ ] **Step 1: Implement server manager**

Create `tools/vscode-extension/src/serverManager.ts`:

```typescript
import { spawn, ChildProcess } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

export class ServerManager {
  private process: ChildProcess | null = null;

  start(workspaceRoot: string): void {
    const portFile = path.join(workspaceRoot, '.tutorial', 'port');
    // Already running if port file is fresh (< 10 seconds old).
    if (fs.existsSync(portFile)) {
      const age = Date.now() - fs.statSync(portFile).mtimeMs;
      if (age < 10_000) return;
    }

    const serverEntry = path.join(workspaceRoot, 'tools', 'tutorial_server', 'bin', 'server.dart');
    if (!fs.existsSync(serverEntry)) return;

    this.process = spawn('dart', ['run', serverEntry, '--state-dir', '.tutorial'], {
      cwd: workspaceRoot,
      stdio: 'pipe',
    });

    this.process.on('exit', () => { this.process = null; });
  }

  stop(): void {
    this.process?.kill();
    this.process = null;
  }

  dispose(): void { this.stop(); }
}
```

- [ ] **Step 2: Implement file watcher**

Create `tools/vscode-extension/src/fileWatcher.ts`:

```typescript
import * as vscode from 'vscode';
import * as path from 'path';

export class FileWatcher {
  private watcher: vscode.FileSystemWatcher | null = null;
  private onResult: (passed: boolean) => void;
  private expectedPattern: RegExp | null = null;
  private watchedPath: string | null = null;

  constructor(onResult: (passed: boolean) => void) {
    this.onResult = onResult;
  }

  /** Watch a file for an expected code pattern. */
  watch(filePath: string, expectedSnippet: string): void {
    this.dispose();
    const workspaceRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!workspaceRoot) return;

    this.watchedPath = path.join(workspaceRoot, filePath);
    // Escape and match the key identifier from the expected snippet.
    // We look for a meaningful word in the "after" code as the signal.
    const keyToken = this.extractKeyToken(expectedSnippet);
    this.expectedPattern = keyToken ? new RegExp(keyToken) : null;

    const pattern = new vscode.RelativePattern(workspaceRoot, filePath);
    this.watcher = vscode.workspace.createFileSystemWatcher(pattern);

    const check = () => this.checkFile();
    this.watcher.onDidChange(check);
    this.watcher.onDidCreate(check);
    check(); // Check immediately on watch start.
  }

  private checkFile(): void {
    if (!this.watchedPath || !this.expectedPattern) return;
    try {
      const content = require('fs').readFileSync(this.watchedPath, 'utf8');
      this.onResult(this.expectedPattern.test(content));
    } catch {
      this.onResult(false);
    }
  }

  private extractKeyToken(snippet: string): string | null {
    // Extract the first Semantics-related identifier or the first quoted string.
    const semanticsMatch = snippet.match(
      /\b(Semantics|MergeSemantics|ExcludeSemantics|SemanticsService|liveRegion|label:|header:)\b/
    );
    if (semanticsMatch) return semanticsMatch[1];
    const labelMatch = snippet.match(/label:\s*['"]([^'"]{4,})['"]/);
    if (labelMatch) return labelMatch[1].substring(0, 8); // partial match
    return null;
  }

  dispose(): void {
    this.watcher?.dispose();
    this.watcher = null;
  }
}
```

- [ ] **Step 3: Compile**

```bash
npm run compile
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
git add tools/vscode-extension/src/serverManager.ts tools/vscode-extension/src/fileWatcher.ts
git commit -m "feat: add VS Code server manager and file watcher for code validation"
```

---

## Task 19: VS Code tutorial panel provider and extension entry

**Files:**
- Create: `tools/vscode-extension/src/tutorialPanel.ts`
- Create: `tools/vscode-extension/src/extension.ts`
- Create: `tools/vscode-extension/media/` (copy shared files)

- [ ] **Step 1: Copy shared media files**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
mkdir -p tools/vscode-extension/media
cp tools/shared/tutorial_panel.html tools/vscode-extension/media/
cp tools/shared/ide-bridge.js tools/vscode-extension/media/
cp tools/shared/tutorial_content.json tools/vscode-extension/media/
```

- [ ] **Step 2: Implement tutorial panel provider**

Create `tools/vscode-extension/src/tutorialPanel.ts`:

```typescript
import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { RelayClient, RelayMessage } from './relayClient';
import { FileWatcher } from './fileWatcher';

export class TutorialPanelProvider implements vscode.WebviewViewProvider {
  public static readonly viewId = 'accessguide.tutorialPanel';
  private view?: vscode.WebviewView;
  private fileWatcher: FileWatcher;
  private currentStepFilePath: string | null = null;
  private currentStepExpected: string | null = null;

  constructor(
    private readonly extensionUri: vscode.Uri,
    private readonly relay: RelayClient,
  ) {
    this.fileWatcher = new FileWatcher((passed) => {
      this.view?.webview.postMessage({ action: 'code_check', payload: { passed } });
      // For Chapter 8, run flutter test instead.
      if (this.currentStepFilePath?.startsWith('test/')) {
        this.runFlutterTest(this.currentStepFilePath);
      }
    });

    relay.onMessage((msg: RelayMessage) => this.handleRelayMessage(msg));
  }

  resolveWebviewView(webviewView: vscode.WebviewView): void {
    this.view = webviewView;

    webviewView.webview.options = {
      enableScripts: true,
      localResourceRoots: [vscode.Uri.joinPath(this.extensionUri, 'media')],
    };

    webviewView.webview.html = this.getHtml(webviewView.webview);

    // Messages from the HTML panel → relay server.
    webviewView.webview.onDidReceiveMessage((msg: { action: string; payload: unknown }) => {
      switch (msg.action) {
        case 'ready':
          // Push content and current state to the fresh WebView.
          this.sendContent();
          break;
        case 'open_url':
          vscode.env.openExternal(vscode.Uri.parse((msg.payload as { url: string }).url));
          break;
        default:
          // Forward all other actions to the relay server.
          this.relay.send({
            type: 'command', source: 'ide', action: msg.action,
            payload: msg.payload as Record<string, unknown>,
          });
      }
    });
  }

  private handleRelayMessage(msg: RelayMessage): void {
    if (!this.view) return;

    // Forward state updates to the WebView.
    if (msg.action === 'tutorial_state') {
      this.view.webview.postMessage({ action: 'tutorial_state', payload: msg.payload });
      // Start watching the new step's file if it has a codeDiff.
      this.watchCurrentStepFile(msg.payload);
    } else if (msg.action === 'connected') {
      this.view.webview.postMessage({
        action: 'app_connected',
        payload: { device: (msg.payload as Record<string, string>).device ?? 'Phone' },
      });
    } else if (msg.action === 'app_disconnected') {
      this.view.webview.postMessage({ action: 'app_disconnected', payload: {} });
    }
  }

  private watchCurrentStepFile(statePayload: Record<string, unknown>): void {
    const content = this.loadContent();
    if (!content) return;

    const chIdx = statePayload.chapterIndex as number ?? 0;
    const stIdx = statePayload.stepIndex as number ?? 0;
    const chapter = content.chapters[chIdx];
    const step = chapter?.steps[stIdx];
    const diff = step?.codeDiff;

    if (diff?.filePath) {
      this.fileWatcher.watch(diff.filePath, diff.after);
    } else {
      this.fileWatcher.dispose();
    }
  }

  private sendContent(): void {
    const content = this.loadContent();
    if (content && this.view) {
      this.view.webview.postMessage({ action: 'load_content', payload: content });
    }
  }

  private loadContent(): Record<string, unknown> | null {
    const jsonPath = path.join(this.extensionUri.fsPath, 'media', 'tutorial_content.json');
    try {
      return JSON.parse(fs.readFileSync(jsonPath, 'utf8')) as Record<string, unknown>;
    } catch { return null; }
  }

  private getHtml(webview: vscode.Webview): string {
    const htmlPath = path.join(this.extensionUri.fsPath, 'media', 'tutorial_panel.html');
    let html = fs.readFileSync(htmlPath, 'utf8');

    // Replace the ide-bridge.js src with the extension resource URI.
    const bridgeUri = webview.asWebviewUri(
      vscode.Uri.joinPath(this.extensionUri, 'media', 'ide-bridge.js')
    );
    html = html.replace('src="ide-bridge.js"', `src="${bridgeUri}"`);

    // Inject VS Code's nonce for CSP (security requirement).
    const nonce = getNonce();
    html = html.replace(/<script/g, `<script nonce="${nonce}"`);
    html = html.replace('<head>', `<head>
      <meta http-equiv="Content-Security-Policy"
            content="default-src 'none'; script-src 'nonce-${nonce}'; style-src 'unsafe-inline';">`);

    return html;
  }

  private runFlutterTest(testFile: string): void {
    const workspaceRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!workspaceRoot) return;
    const terminal = vscode.window.createTerminal('AccessGuide: flutter test');
    terminal.sendText(`flutter test ${testFile}`);
    terminal.show();
  }

  dispose(): void { this.fileWatcher.dispose(); }
}

function getNonce(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  return Array.from({ length: 32 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
}
```

- [ ] **Step 3: Implement the extension entry point**

Create `tools/vscode-extension/src/extension.ts`:

```typescript
import * as vscode from 'vscode';
import { RelayClient } from './relayClient';
import { TutorialPanelProvider } from './tutorialPanel';
import { DeviceManager } from './deviceManager';
import { ServerManager } from './serverManager';

export function activate(context: vscode.ExtensionContext): void {
  const workspaceRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
  if (!workspaceRoot) return;

  // 1. Start the tutorial server.
  const serverManager = new ServerManager();
  serverManager.start(workspaceRoot);

  // 2. Connect to the relay.
  const relay = new RelayClient();
  relay.connect();

  // 3. Register the tutorial panel WebView.
  const provider = new TutorialPanelProvider(context.extensionUri, relay);
  context.subscriptions.push(
    vscode.window.registerWebviewViewProvider(TutorialPanelProvider.viewId, provider)
  );

  // 4. Status bar item showing connection status.
  const statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 10);
  statusBar.text = '$(circle-slash) AccessGuide';
  statusBar.tooltip = 'No phone connected';
  statusBar.show();
  context.subscriptions.push(statusBar);

  // 5. Device manager — detect physical phone, launch flutter run.
  const deviceManager = new DeviceManager((device) => {
    if (device) {
      statusBar.text = `$(device-mobile) ${device.name}`;
      statusBar.tooltip = `AccessGuide: connected to ${device.name}`;
    } else {
      statusBar.text = '$(circle-slash) No device';
      statusBar.tooltip = 'AccessGuide: connect a physical phone via USB';
      vscode.window.showWarningMessage(
        'AccessGuide: No physical device detected. Connect an iPhone or Android phone via USB.'
      );
    }
  });
  deviceManager.start();

  // 6. Register commands.
  context.subscriptions.push(
    vscode.commands.registerCommand('accessguide.startServer', () => serverManager.start(workspaceRoot)),
    vscode.commands.registerCommand('accessguide.nextStep', () =>
      relay.send({ type: 'command', source: 'ide', action: 'next_step', payload: {} })),
    vscode.commands.registerCommand('accessguide.prevStep', () =>
      relay.send({ type: 'command', source: 'ide', action: 'previous_step', payload: {} })),
  );

  // Cleanup on deactivate.
  context.subscriptions.push({
    dispose: () => {
      relay.dispose();
      deviceManager.dispose();
      serverManager.dispose();
      provider.dispose();
    },
  });
}

export function deactivate(): void {}
```

- [ ] **Step 4: Compile the full extension**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/vscode-extension
npm run compile
```

Expected: No TypeScript errors. `out/` directory populated.

- [ ] **Step 5: Package the extension**

```bash
npm run package
```

Expected: `accessguide-0.1.0.vsix` created in `tools/vscode-extension/`.

- [ ] **Step 6: Install and smoke-test**

```bash
code --install-extension accessguide-0.1.0.vsix
```

Open VS Code in the project. Expected:
- AccessGuide icon appears in the activity bar
- Click it → Tutorial panel shows chapter 0 content
- Status bar shows "$(circle-slash) No device"
- Connect a physical phone → status bar updates to device name
- Tutorial panel shows chapter content from the JSON

- [ ] **Step 7: Commit**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
git add tools/vscode-extension/
git commit -m "feat: add VS Code extension with WebView panel, device manager, relay client"
```

---

## Verification

Sub-Plan 2 is complete when all of the following pass:

- [ ] `http://localhost:8888/tutorial_panel.html` (served via Python) shows all 10 chapters, renders chapter 0 step 1 with code diff and callouts
- [ ] Browser console shows `[AccessGuide → host]` on clicking Next (dev fallback mode)
- [ ] `npm run compile` in `tools/vscode-extension/` exits with 0 errors
- [ ] `npm run package` produces `accessguide-0.1.0.vsix`
- [ ] Installing the extension and opening the project shows the tutorial panel with chapter list
- [ ] Starting the relay server + connecting a physical phone causes the status bar to show the device name
- [ ] Clicking "Next" in the panel updates the phone's status bar chapter/step
- [ ] Adding `Semantics(` to the file specified in chapter 2 step 1's `codeDiff.filePath` causes the green checkmark to appear in the panel within 2 seconds

**Once this checklist passes, proceed to Sub-Plan 3 (Android Studio plugin + setup script).**

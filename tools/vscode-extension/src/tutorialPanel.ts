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

    // Register message handler BEFORE setting html to avoid missing the 'ready' event.
    webviewView.webview.onDidReceiveMessage((msg: { action: string; payload: unknown }) => {
      switch (msg.action) {
        case 'ready':
          this.sendContent();
          break;
        case 'open_url':
          vscode.env.openExternal(vscode.Uri.parse((msg.payload as { url: string }).url));
          break;
        default:
          this.relay.send({
            type: 'command', source: 'ide', action: msg.action,
            payload: msg.payload as Record<string, unknown>,
          });
      }
    });

    webviewView.webview.html = this.getHtml(webviewView.webview);

    // Belt-and-suspenders: also push content immediately in case 'ready' was already missed.
    setTimeout(() => this.sendContent(), 200);
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
    const chapter = (content.chapters as Array<{ steps: Array<{ codeDiff?: { filePath: string; after: string } }> }>)[chIdx];
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

  private getHtml(_webview: vscode.Webview): string {
    const htmlPath = path.join(this.extensionUri.fsPath, 'media', 'tutorial_panel.html');
    let html = fs.readFileSync(htmlPath, 'utf8');

    // Inline ide-bridge.js directly to avoid external resource loading issues.
    const bridgePath = path.join(this.extensionUri.fsPath, 'media', 'ide-bridge.js');
    const bridgeJs = fs.readFileSync(bridgePath, 'utf8');
    html = html.replace(
      '<script src="ide-bridge.js"></script>',
      `<script>\n${bridgeJs}\n</script>`
    );

    // Inject nonce on all scripts and a permissive-enough CSP.
    const nonce = getNonce();
    html = html.replace(/<script/g, `<script nonce="${nonce}"`);
    html = html.replace('<head>', `<head>
      <meta http-equiv="Content-Security-Policy"
            content="default-src 'none'; script-src 'nonce-${nonce}' 'unsafe-inline'; style-src 'unsafe-inline';">`);

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

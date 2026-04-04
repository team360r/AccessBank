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

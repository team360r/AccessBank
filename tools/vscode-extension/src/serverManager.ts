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

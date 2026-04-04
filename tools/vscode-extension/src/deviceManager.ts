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

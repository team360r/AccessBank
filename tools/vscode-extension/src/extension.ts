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

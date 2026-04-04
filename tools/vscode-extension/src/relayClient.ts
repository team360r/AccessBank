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

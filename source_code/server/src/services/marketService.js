const WebSocket = require('ws');

class MarketService {
    constructor(io) {
        this.io = io;
        this.ws = null;
        this.reconnectInterval = 5000;

        // Bybit linear perp pairs (usually most liquid)
        this.pairs = [
            'BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT', 'XRPUSDT',
            'DOGEUSDT', 'ADAUSDT', 'AVAXUSDT', 'DOTUSDT', 'LINKUSDT'
        ];
    }

    connect() {
        const wsUrl = `wss://stream.bybit.com/v5/public/linear`;

        console.log('Connecting to Bybit WebSocket...');
        this.ws = new WebSocket(wsUrl);

        this.ws.on('open', () => {
            console.log('Connected to Bybit WebSocket');
            
            // Subscribe to public trade stream for all pairs
            const args = this.pairs.map(p => `publicTrade.${p}`);
            this.ws.send(JSON.stringify({
                op: 'subscribe',
                args: args
            }));
            console.log(`Subscribed to streams: ${this.pairs.join(', ')}`);
        });

        this.ws.on('message', (raw) => {
            try {
                const message = JSON.parse(raw);

                // Bybit format: { topic: "publicTrade.BTCUSDT", type: "snapshot", data: [...] }
                if (!message.data || message.topic?.indexOf('publicTrade') !== 0) return;

                // Bybit sends an array of trades in the 'data' field
                for (const trade of message.data) {
                    const transformed = {
                        s: trade.s,                  // Symbol (BTCUSDT)
                        p: String(trade.p),          // Price (string)
                        q: String(trade.v),          // Volume/Quantity (string)
                        T: trade.T,                  // Timestamp (ms)
                        a: trade.i,                  // Trade ID
                        m: trade.S === 'Sell'        // isBuyerMaker (Sell side = maker is buyer)
                    };

                    this.io.emit('market:update', transformed);
                }
            } catch (error) {
                console.error('Error parsing Bybit WS message:', error);
            }
        });

        this.ws.on('close', (code, reason) => {
            console.log(`Bybit WS closed (code: ${code}). Reconnecting in ${this.reconnectInterval / 1000}s...`);
            setTimeout(() => this.connect(), this.reconnectInterval);
        });

        this.ws.on('error', (error) => {
            console.error('Bybit WS Error:', error.message);
            if (this.ws.readyState === WebSocket.OPEN) {
                this.ws.close();
            }
        });

        this._startPingCheck();
    }

    _startPingCheck() {
        if (this._pingInterval) clearInterval(this._pingInterval);

        // Bybit requires application-level ping every 20s to keep connection alive
        this._pingInterval = setInterval(() => {
            if (this.ws.readyState === WebSocket.OPEN) {
                this.ws.send(JSON.stringify({ op: "ping" }));
            }
        }, 20000);

        this.ws.on('close', () => {
            if (this._pingInterval) {
                clearInterval(this._pingInterval);
                this._pingInterval = null;
            }
        });
    }
}

module.exports = MarketService;

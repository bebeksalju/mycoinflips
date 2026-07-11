const dotenv = require('dotenv');
dotenv.config();
const app = require('./app');

const http = require('http');
const { Server } = require('socket.io');
const MarketService = require('./services/marketService');
const ChatService = require('./services/chatService');
const socketEmitter = require('./socketEmitter');
const { startSessionCleanup } = require('./services/sessionCleanup');

const PORT = process.env.PORT || 3000;

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Allow all for dev
    methods: ["GET", "POST"]
  }
});

// Init socket emitter singleton
socketEmitter.init(io);

// Handle root connections for Market Rooms
io.on('connection', (socket) => {
  socket.on('market:join', (symbol) => {
    // Leave all previous market rooms
    socket.rooms.forEach(room => {
      if (room.startsWith('pair:')) socket.leave(room);
    });
    if (symbol) {
      socket.join(`pair:${symbol}`);
    }
  });
});

// Start Market Service
const marketService = new MarketService(io);
marketService.connect();

// Start Chat Service
const chatService = new ChatService(io);

server.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  startSessionCleanup();
});

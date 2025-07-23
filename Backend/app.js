const express = require("express");
app = express();
const userRouter = require("./routes/userRoutes");
const messageRoute = require("./routes/messageRoutes");
const http = require('http');
const { Server } = require("socket.io");
const { initializeSocket } = require('./controller/socketController');


app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Allows connections from any origin
    methods: ["GET", "POST"]
  }
});

app.use((req, res, next) => {
  req.io = io;
  next();
});

app.use("/api/users" , userRouter);
app.use("/api/messages" , messageRoute);

initializeSocket(io);

module.exports = app;

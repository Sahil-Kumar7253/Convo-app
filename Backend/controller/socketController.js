const Message = require("../models/messageModel");

const userSocketMap = {};

const initializeSocket = (io) => {
    io.on("connection", (socket) => {
        console.log(`User Connected: ${socket.id}`);
        
        socket.on("register_user", (userId) => {
            if(userId){
                userSocketMap[userId] = socket.id;
                console.log(`User ${userId} registered with socket ${socket.id}`);
                console.log('Online users:', Object.keys(userSocketMap));
            }
        });
  
        socket.on('send_private_message', async (data) => {

        console.log('Data received from client for send_private_message:', data);

        const { senderId, receiverId, content} = data;
  
        try {
            const newMessage = new Message({
            sender: senderId,
            receiver: receiverId,
            content: content,
        });
    
        const savedMessage = await newMessage.save();
        await savedMessage.populate('sender', 'name email');

        console.log('Message saved successfully to DB:', savedMessage);

        const recipientSocketId = userSocketMap[receiverId];
    
        socket.emit('receive_private_message', savedMessage);
        if (recipientSocketId) {
            io.to(recipientSocketId).emit('receive_private_message', savedMessage);
        }

        } catch (error) {
            console.error('Error saving message to DB:', error.message);
        }
        });

        socket.on("disconnect", () => {
            console.log(`User disconnected: ${socket.id}`);
             
            for (const userId in userSocketMap) {
                if (userSocketMap[userId] === socket.id) {
                    delete userSocketMap[userId];
                    break;
                }
            }
            console.log('Online users:', Object.keys(userSocketMap));
        });
    });
}

module.exports = {
    initializeSocket,
    userSocketMap
};
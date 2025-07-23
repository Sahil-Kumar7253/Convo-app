const Message = require("../models/messageModel");

const userSocketMap = {};

const initializeSocket = (io) => {
    io.on("connection", (socket) => {
        console.log(`User Connected: ${socket.id}`);
        
        socket.on("register_user", (userId) => {
            if(userID){
                userSocketMap[userID] = socket.id;
                console.log(`User ${userId} registered with socket ${socket.id}`);
                console.log('Online users:', Object.keys(userSocketMap));
            }
        });
       
        socket.on("send_message", async (data) => {
            const { senderId, receiverId, content } = data;
            
            try{
                const newMessage = new Message({
                    sender: senderId,
                    receiver: receiverId,
                    content,
                });

                const savedMessage = await newMessage.save();
                await savedMessage.populate('sender', 'name email');
                 
                const receiverSocketId = userSocketMap[receiverId];

                if(receiverSocketId){
                    io.to(receiverSocketId).emit("receive_message", savedMessage);
                }

                socket.emit("receive_message", savedMessage);
            }catch(error){
                console.error('Error handling private message:', error);
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
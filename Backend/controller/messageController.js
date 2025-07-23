const Message = require('../models/messageModel');
const {userSocketMap} = require("./socketController")

async function getChatHistory(req ,res) {
    try{
       const senderId = req.user._id;
       const receiverId = req.params.receiverId;

       const messages = await Message.find({
      $or: [
        { sender: senderId, receiver: receiverId },
        { sender: receiverId, receiver: senderId },
      ],
      }).sort({ createdAt: 'asc' }).populate('sender', 'name email');

       res.json(messages);
    }catch(error){
        console.error('Error fetching chat history:', error);
    res.status(500).json({ message: 'Server Error' });
    }
}

const sendMessage = async (req, res) => {
  const { content, receiverId } = req.body;
  const senderId = req.user._id;

  const io = req.io;

  if (!content || !receiverId) {
    return res.status(400).json({ message: 'Content and receiverId are required.' });
  }

  try {
    const newMessage = new Message({
      sender: senderId,
      receiver: receiverId,
      content: content,
    });
    
    const savedMessage = await newMessage.save();
    await savedMessage.populate('sender', 'name email'); 

    const recipientSocketId = userSocketMap[receiverId];
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('receive_message', savedMessage);
    }
    
    res.status(201).json(savedMessage);

  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  getChatHistory,
  sendMessage
};
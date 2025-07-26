const Message = require('../models/messageModel');
const {userSocketMap} = require("./socketController")
const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: "dtvhcqamv",
  api_key: 487995442537151,
  api_secret:"xEzj01opQoTx1aq7tOLaZ5TMTvU",
});

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
  const { content, receiverId} = req.body;
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

async function sendImageMessage(req, res) {

  try{
    const {receiverId} = req.body;
    const senderId = req.user._id;
    
    console.log("\n--- [START] SEND IMAGE MESSAGE ---");
    console.log("Sender ID:", senderId.toString());
    console.log("Receiver ID:", receiverId);


    if(!req.file){
      return res.status(400).json({message : "No image file uploaded"});
    }
    if(!receiverId){
      return res.status(400).json({message : "User Not Found"});
    }
    const b64 = Buffer.from(req.file.buffer).toString("base64");
    let dataURI = "data:" + req.file.mimetype + ";base64," + b64;

    const result = await cloudinary.uploader.upload(dataURI, {
      folder: "chat_app_images",
    });

    const newMessage = new Message({
      sender: senderId,
      receiver: receiverId,
      messageType : "image",
      imageUrl : result.secure_url
    });

    const savedMessage = await newMessage.save();
    await savedMessage.populate('sender', 'name email'); 

    console.log("Message saved to DB. Attempting to emit via socket...");

    const io = req.io;

    console.log("Current Online Users (userSocketMap):", userSocketMap);

    const senderSocketId = userSocketMap[senderId.toString()];
    const recipientSocketId = userSocketMap[receiverId.toString()];

    console.log(`Lookup for sender's socket ID (${senderId.toString()}):`, senderSocketId || "Not Found");
    console.log(`Lookup for receiver's socket ID (${receiverId}):`, recipientSocketId || "Not Found");


    if (senderSocketId) {
      console.log(`Emitting to sender via socket ${senderSocketId}`);
      io.to(senderSocketId).emit('receive_private_message', savedMessage);
    }
    
    if (recipientSocketId && senderId.toString() !== receiverId.toString()) {
      console.log(`Emitting to receiver via socket ${recipientSocketId}`);
      io.to(recipientSocketId).emit('receive_private_message', savedMessage);
    }

    console.log("--- [END] SEND IMAGE MESSAGE ---");

    res.status(201).json(savedMessage);
  }catch(error){
    console.error("Image message error:", error);
    res.status(500).json({ message: 'Server error while sending image.' });
  }
}

async function handleDelteMessage(req, res) {
  try {
    const messageId = req.params.messageId;
    const userId = req.user._id; 

    const message = await Message.findOne(messageId);

    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }

    if (message.sender.toString() !== userId.toString()) {
      return res.status(401).json({ message: 'User not authorized to delete this message' });
    }

    await message.deleteOne();
    
    const io = req.io;
    const senderSocketId = userSocketMap[message.sender.toString()];
    const receiverSocketId = userSocketMap[message.receiver.toString()];
    
    const deletePayload = { messageId: message._id };

    if (senderSocketId) {
      io.to(senderSocketId).emit('message_deleted', deletePayload);
    }
    if (receiverSocketId) {
      io.to(receiverSocketId).emit('message_deleted', deletePayload);
    }
    
    res.json({ message: 'Message deleted successfully' });

  } catch (error) {
    console.error('Error deleting message:', error);
    res.status(500).json({ message: 'Server Error' });
  }}

module.exports = {
  getChatHistory,
  sendMessage,
  handleDelteMessage,
  sendImageMessage
};
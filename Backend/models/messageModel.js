const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String},
  imageUrl : {type : String},
  messageType : {type : String, enum : ['text', 'image'], default : 'text'}
}, { timestamps: true });

const Message = mongoose.model('Message', messageSchema);

module.exports = Message;
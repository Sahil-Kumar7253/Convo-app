const User = require("../models/userModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: "dtvhcqamv",
  api_key: 487995442537151,
  api_secret:"xEzj01opQoTx1aq7tOLaZ5TMTvU",
});

async function handleRegistration(req, res) {
    try{
      const {name,email,password} = req.body;
      const user = await User.create({name,email,password});

      return res.status(201).json({message:"User created successfully",user});
      
    }catch(err){
      return res.status(500).json({ error: "Internal server error"});
    }
}

async function handleLogin(req,res){
    const {email,password} = req.body;
    const user = await User.findOne({email});
    if(!user) return res.status(404).json({error:"User not found"});

   const validpassKey = await bcrypt.compare(password,user.password);
   if(!validpassKey) return res.status(401).json({error:"Invalid password"});

   const token = jwt.sign({ _id : user._id ,email : user.email, name : user.name},process.env.JWT_SECRET_KEY);
   return res.json({ token, _id: user._id, image : user.image });
}

async function handleUpdateUser(req,res){
  try {
        const user = await User.findOne(req.user.id);
        if(user){
          user.name = req.body.name || user.name;
          user.email = user.email;
          if (req.body.password) {
           user.password = req.body.password;
          }
        }
        const updatedUser = await user.save();
        return res.json({
          _id: updatedUser._id,
          name: updatedUser.name,
          email: updatedUser.email,
          token: jwt.sign({ _id : user._id ,email : user.email, name : user.name},process.env.JWT_SECRET_KEY)
        }); 
      } catch (error) {
        console.error('Error updating user:', error);
        return res.status(500).json({ error: 'Internal Server Error' });
    }
}

const getUsers = async (req, res) => {
  try {
    const currentUsers = await User.find({ _id: { $ne: req.user._id } });
    const existingRelations = [
    ...currentUsers.friends,
    ...currentUsers.friendRequestsSent,
    ...currentUsers.friendRequestsReceived,
    currentUsers._id, 
    ];

    const users = await User.find({ _id: { $nin: existingRelations } });
    
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
    console.log(error);
  }
};

async function uploadProfileImage(req, res) {
  try {
    console.log(process.env.CLOUDINARY_API_KEY);
    if (!req.file) {
      return res.status(400).json({ message: 'No image file uploaded.' });
    }

    const b64 = Buffer.from(req.file.buffer).toString("base64");
    let dataURI = "data:" + req.file.mimetype + ";base64," + b64;

    const result = await cloudinary.uploader.upload(dataURI, {
      folder: "chat_app_profiles",
    });
    
    const user = await User.findById(req.user._id);
  
    if (user) {
      user.image = result.secure_url;
      await user.save();
      return res.json({
        message: 'Image uploaded successfully',
        image: user.image,
      });
    } else {
      return res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error("Image upload error:", error);
    return res.status(500).json({ message: 'Server error during image upload.' });
  }
}

async function getSentFriendRequests(req,res) {
  const sender = await User.findById(req.user._id);
  const receiver = await User.findById(req.params.receiverId);
 
  if(!receiver) return res.status(404).json({message : "User not found"});
  if(sender._id.toString() === receiver._id.toString()) return res.status(400).json({message :"Can't send friend request to yourself"});
  if(sender.friends.includes(receiver._id)) return res.status(400).json({message : "Already friends"});
  if(sender.friendRequestsSent.includes(receiver._id)) return res.status(400).json({message : "Friend request already sent"});

  sender.friendRequestsSent.push(receiver._id);
  receiver.friendRequestsRecieved.push(sender._id);

  await sender.save();
  await receiver.save();

  res.status(200).json({message : "Friend request sent"});
}

async function acceptFriendRequest(req,res) {
  const reciever = await User.findById(req.user._id);
  const sender = await User.findById(req.params.senderId);

  if(!sender) return res.status(404).json({message : "User not found"});

  reciever.friends.push(sender._id);
  sender.friends.push(reciever._id);

  reciever.friendRequestsRecieved = reciever.friendRequestsRecieved.filter(reqId => !reqId.equals(sender._id));
  sender.friendRequestsSent = sender.friendRequestsSent.filter(reqId => !reqId.equals(reciever._id));
  
  await reciever.save();
  await sender.save();

  res.status(200).json({message : "Friend request accepted"});
}

async function getFriends(req,res) {
   const user = await User.findById(req.user._id).populate('friends', 'name email image');
   res.status(200).json(user.friends);
}

async function getRecievedFriendRequests(req,res) {
   const user = await User.findById(req.user._id).populate('friendRequestsRecieved', 'name email image');
   res.status(200).json(user.friendRequestsRecieved);
}

module.exports = {
    handleRegistration,
    handleLogin,
    handleUpdateUser,
    getUsers,
    uploadProfileImage,
    getSentFriendRequests,
    acceptFriendRequest,
    getFriends,
    getRecievedFriendRequests
};
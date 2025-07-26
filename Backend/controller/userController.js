const userModel = require("../models/userModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

async function handleRegistration(req, res) {
    try{
      const {name,email,password} = req.body;
      const user = await userModel.create({name,email,password});

      return res.status(201).json({message:"User created successfully",user});
      
    }catch(err){
      return res.status(500).json({ error: "Internal server error"});
    }
}

async function handleLogin(req,res){
    const {email,password} = req.body;
    const user = await userModel.findOne({email});
    if(!user) return res.status(404).json({error:"User not found"});

   const validpassKey = await bcrypt.compare(password,user.password);
   if(!validpassKey) return res.status(401).json({error:"Invalid password"});

   const token = jwt.sign({ _id : user._id ,email : user.email, name : user.name},process.env.JWT_SECRET_KEY);
   return res.json({ token, _id: user._id, });
}

async function handleUpdateUser(req,res){
  try {
        const user = await userModel.findOne(req.user.id);
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
    const users = await userModel.find({ _id: { $ne: req.user._id } });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
    console.log(error);
  }
};

async function uploadProfileImage(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No image file uploaded.' });
    }

    const b64 = Buffer.from(req.file.buffer).toString("base64");
    let dataURI = "data:" + req.file.mimetype + ";base64," + b64;

    const result = await cloudinary.uploader.upload(dataURI, {
      folder: "chat_app_profiles",
    });
    
    const user = await userModel.findOne(req.user._id);
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

module.exports = {
    handleRegistration,
    handleLogin,
    handleUpdateUser,
    getUsers,
    uploadProfileImage
};
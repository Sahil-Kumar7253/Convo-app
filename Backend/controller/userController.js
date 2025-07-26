const userModel = require("../models/userModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

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
        const user = await userModel.findOne(req.params.id,);
        if(user){
          user.name = req.body.name || user.name;
          user.email = req.body.email || user.email;

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

module.exports = {
    handleRegistration,
    handleLogin,
    handleUpdateUser,
    getUsers
};
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
   return res.json({ token });
}

module.exports = {
    handleRegistration,
    handleLogin
};
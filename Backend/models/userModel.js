const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const userSchema = new mongoose.Schema({
    name : {
        type : String,
        required : true,
        unique : true
    },
    email :{
        type : String,
        required : true,
        unique : true,
    },
    password : {
        type : String,
        required : true,
    },
    image: {
        type: String,
        required: false,
        default: 'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg',
    },
    friends : [{
        type : mongoose.Schema.Types.ObjectId,
        ref : "User"
    }],
    friendRequestsSent : [{
        type : mongoose.Schema.Types.ObjectId,
        ref : "User"
    }],
    friendRequestsRecieved : [{
        type : mongoose.Schema.Types.ObjectId,
        ref : "User"
    }]

}, {timestamps : true});

userSchema.pre("save" , async function(next){
    try{
        var user = this;
        if (!this.isModified('password')) {
         return next(); // FIX #2: Add 'return' to stop the password from being re-hashed.
        }
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(user.password, salt);
        user.password = hashedPassword;
    }catch(error){
        throw error;
    }
})

const User = mongoose.model("User", userSchema);

module.exports = User; 

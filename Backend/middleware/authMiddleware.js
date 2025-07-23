const jwt = require("jsonwebtoken");
const secret = process.env.JWT_SECRET_KEY;

function getUser(token){
    if(!token) return null;
    return jwt.verify(token, process.env.JWT_SECRET_KEY);
}

function checkforauthentication(req , res , next){
    const authorizationHeaderValue = req.headers["authorization"];

    if (!authorizationHeaderValue || !authorizationHeaderValue.startsWith("Bearer ")) {
        return next();
    }
   
    const token = authorizationHeaderValue.split('Bearer ')[1];
    const user = getUser(token);

    if (user) {
        req.user = user;
    }

    return next();
}

module.exports = {
    checkforauthentication
}
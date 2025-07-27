const express = require("express");
const router = express.Router();
const userController = require("../controller/userController");
const auth = require("../middleware/authMiddleware")
const multer = require('multer');

const upload = multer({ storage: multer.memoryStorage() });

router.get("/",auth.checkforauthentication, userController.getUsers);
router.post("/login", userController.handleLogin);
router.post("/register", userController.handleRegistration);
router.put("/profile" , auth.checkforauthentication, userController.handleUpdateUser);
router.post('/profile/image', auth.checkforauthentication, upload.single('image'), userController.uploadProfileImage);

router.get("/friends", auth.checkforauthentication,userController.getFriends);
router.delete("/friends/:friendId",auth.checkforauthentication,userController.removeFriend) ;
router.get("/friends-requests/received", auth.checkforauthentication,userController.getRecievedFriendRequests);
router.post("/friends-request/sent/:receiverId",auth.checkforauthentication,userController.getSentFriendRequests)
router.put("/friends-request/accept/:senderId",auth.checkforauthentication,userController.acceptFriendRequest); 
router.put("/friends-request/reject/:senderId",auth.checkforauthentication,userController.declineFriendRequest); 

module.exports = router;
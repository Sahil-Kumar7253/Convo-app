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
router.post("/friends-requests/recieved", auth.checkforauthentication,userController.getRecievedFriendRequests);
router.post("/friends-request/sent/:receiverId",auth.checkforauthentication,userController.getSentFriendRequests)
router.put("/friends-request/accept/:senderId",auth.checkforauthentication,userController.acceptFriendRequest) 

module.exports = router;
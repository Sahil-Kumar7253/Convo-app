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


module.exports = router;
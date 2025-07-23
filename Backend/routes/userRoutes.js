const express = require("express");
const router = express.Router();
const userController = require("../controller/userController");
const auth = require("../middleware/authMiddleware")

router.get("/",auth.checkforauthentication, userController.getUsers);
router.post("/login", userController.handleLogin);
router.post("/register", userController.handleRegistration);

module.exports = router;
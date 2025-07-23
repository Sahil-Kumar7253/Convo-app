const express = require("express");
const router = express.Router();
const userController = require("../controller/userController");

router.post("/login", userController.handleLogin);
router.post("/register", userController.handleRegistration);

module.exports = router;
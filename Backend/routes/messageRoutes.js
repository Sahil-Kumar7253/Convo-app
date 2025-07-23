const express = require("express");
const router = express.Router();
const { getChatHistory, sendMessage } = require("../controller/messageController");
const auth = require("../middleware/authMiddleware");

router.get("/:receiverId", auth.checkforauthentication, getChatHistory);
router.post('/send', auth.checkforauthentication, sendMessage);


module.exports = router;
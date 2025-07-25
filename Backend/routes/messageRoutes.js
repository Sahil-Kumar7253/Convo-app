const express = require("express");
const router = express.Router();
const { getChatHistory, sendMessage, handleDelteMessage } = require("../controller/messageController");
const auth = require("../middleware/authMiddleware");

router.get("/:receiverId", auth.checkforauthentication, getChatHistory);
router.post('/send', auth.checkforauthentication, sendMessage);
router.delete('/:id', auth.checkforauthentication, handleDelteMessage);

module.exports = router;
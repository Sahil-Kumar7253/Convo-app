const express = require("express");
const router = express.Router();
const { getChatHistory, sendMessage, handleDelteMessage, sendImageMessage } = require("../controller/messageController");
const auth = require("../middleware/authMiddleware");
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

router.get("/:receiverId", auth.checkforauthentication, getChatHistory);
router.post('/send', auth.checkforauthentication, sendMessage);
router.delete('/:id', auth.checkforauthentication, handleDelteMessage);
router.post("/image", auth.checkforauthentication,upload.single("image"), sendImageMessage);


module.exports = router;
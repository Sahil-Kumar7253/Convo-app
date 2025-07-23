const express = require("express");
app = express();
const userRouter = require("./routes/userRoutes");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/users" , userRouter);

module.exports = app;

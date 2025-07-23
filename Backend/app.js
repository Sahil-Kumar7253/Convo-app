const express = require("express");
app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

module.exports = app;

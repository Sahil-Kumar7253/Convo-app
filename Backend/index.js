const app = require("./app");
const dotenv = require("dotenv"); 
const connectDB = require("./config/mongooseConfig");

dotenv.config();
connectDB();

const port = process.env.PORT;
app.listen(port, () => {
      console.log(`Server is running on port: http://localhost:${port}`);
});

app.get("/" , (req, res) => {
    res.send("Hello World");
})
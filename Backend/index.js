const app = require("./app");
const dotenv = require("dotenv"); 
const connectDB = require("./config/mongooseConfig");

dotenv.config();
connectDB();

const port = process.env.PORT || 3000;
app.listen(port, () => {
      console.log(`Server is running on port: http://localhost:${port}`);
});

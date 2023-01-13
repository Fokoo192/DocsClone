//importing all the modules that were installed
const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const Document = require("./models/document");
const cors = require("cors");
const http = require("http");

const PORT = process.env.PORT | 3001;

const app = express();

var server = http.createServer(app);
var socket = require("socket.io");
var io = socket(server); 

//middleware
app.use(cors());
app.use(express.json()); 
app.use(authRouter);
app.use(documentRouter);

// connecting the database
const DB_URL = "mongodb+srv://fskhan:14112002Fu%40@cluster0.jbqpuyg.mongodb.net/?retryWrites=true&w=majority";

mongoose
    .connect(DB_URL)
    .then(() => { 
        console.log("Connection Successful!"); 
    })
    .catch((err) => { 
        console.log(err); 
    });

io.on("connection", (socket) => {
    socket.on("join", (documentId) => {
        socket.join(documentId);
        console.log("joined!");
    })

    socket.on("typing", (data) => {
        socket.broadcast.to(data.room).emit("changes", data);
    })

    socket.on("save", (data) => {
        saveData(data);
    })
});

// created a function outside because we cannot use async with socket.on()
const saveData = async (data) => {
    let document = await Document.findById(data.docId);
    document.contents = data.delta;
    document = await document.save();
}

//0.0.0.0 allows any IP address to access the server
server.listen(PORT, "0.0.0.0",() => {console.log(`connected at port ${PORT}`)});


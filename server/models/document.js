// document structure  => user id 
//                        time created
//                        title 
//                        contents

const mongoose = require("mongoose"); 

const documentSchema = mongoose.Schema({
    uid: {
        type: String,
        required: true
    },
    createdAt: {
        type: Number,
        required: true
    },
    title: {
        type: String,
        required: true,
        trim: true
    },
    contents: {
        type: Array,
        default: []
    }
})

const Document = mongoose.model("Document", documentSchema);

module.exports = Document; 
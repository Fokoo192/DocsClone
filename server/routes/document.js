const express = require("express");
const Document = require("../models/document");
const auth = require("../middlewares/auth");
const documentRouter = express.Router();

documentRouter.post("/doc/create", auth, async (req, res) => {
    try {
        const {createdAt} = req.body;
        let document = new Document({ 
            uid: req.user, 
            createdAt: createdAt, 
            title: "Untitled Document", 
        });

        document = await document.save()
        res.json(document);
    } catch (e) {
        res.status(500).json({error: e.message});
    }
});

documentRouter.get("/docs/me", auth, async (req, res) => {
    try {
        let documents = await Document.find({uid: req.user});
        res.json(documents);
    } catch (e) {
        res.status(500).json({error: e.message});
    }
});


documentRouter.post("/doc/title", auth, async (req, res) => {
    try {
        const {id, title} = req.body;
        let document = await Document.findByIdAndUpdate(id, {title});
        res.json(document);
    } catch (e) {
        res.status(500).json({error: e.message});
    }
});

documentRouter.get("/docs/:id", auth, async (req, res) => {
    try {
        const document = await Document.findById(req.params.id);
        res.json(document);
    } catch (e) {
        res.status(500).json({error: e.message});
    }
});

module.exports = documentRouter;
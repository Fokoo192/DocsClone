const express = require("express");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const auth = require("../middlewares/auth");

//const app = express(); a mych cleaner way is:
const authRouter = express.Router();

//routes
authRouter.post("/api/signup", async (req, res) => {
    try {
        const {name, email, profilePic} = req.body;

        //storing the data & checking if it is in the DB
        let user = await User.findOne({email:email});
        
        // if it is a new user... this is done to prevent duplication of enteries/reducing the calls to the db.
        // if (user == null)
        if (!user) {
            user = new User({name:name, email:email, profilePic:profilePic});
            user = await user.save(); //has the _id after being stored in the DB
        }
        
        //creating a jwt token
        const token = jwt.sign({id: user._id}, "passwordKey");

        //return data to the client side 
        res.json({ user, token });
    } catch (e) {
        res.status(500).json({error: e.message});
    }

});

authRouter.get("/", auth, async (req, res) => {
    try {
    // const user = await User.findOne({_id: req.user});
    const user = await User.findById(req.user);
    res.json({ user, token:req.token });
    } catch (e) {
        res.status(500).json({error: e.message});
    }


});
module.exports = authRouter;
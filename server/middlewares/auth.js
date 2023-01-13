const jwt = require("jsonwebtoken");


const auth = async (req, res, next) => {
    try {
        const token = req.header("x-auth-token");

        if (!token) 
            return res.status("401").json({error: "No auth token, access denied!"});

        const verified = jwt.verify(token, "passwordKey")
        
        if(!verified)
            return res.status("401").json({error: "Token verification failed, authorization denied"}) 

        req.user = verified.id;
        req.token = token;
        next(); //tells the middleware to go to the actual server

    } catch (e) {
        res.status("500").json({error:e.message});
    }
};

module.exports = auth;
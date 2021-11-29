const express = require("express");
const auth = require("../middlewares/auth");
const config = require("../config.json");

const router = express.Router();

router.use(
    auth.basic(auth.user(config.credentials.admin), {
        charset: "utf-8",
        ...config.credentials,
    })
);

router.get("/", (req, res) => {
    return res.json(req.headers);
});

module.exports = router;

require("dotenv").config();

const fs = require("fs");
const path = require("path");
const express = require("express");
const config = require("./config.json");

const analyticsLog = [];

const app = express();

app.use(express.json());

app.use((_err, _req, res, _next) => res.sendStatus(400));

app.post("/", (req, res) => {
    let dur, evq, iat, sid;

    try {
        ({ dur, evq, iat, sid } = req.body);
    } catch {
        return res.sendStatus(400);
    }

    const entry = { dur, evq, iat, sid };
    analyticsLog.push(entry);
    console.log(entry);

    return res.sendStatus(200);
});

app.listen(process.env.PORT, () => {
    console.log(`Server listening on port ${process.env.PORT}.`);
});

setInterval(() => {
    fs.promises.writeFile(path.resolve(config.analyticsLocation), JSON.stringify(analyticsLog));
}, config.analyticsLoggingInterval);

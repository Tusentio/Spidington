require("dotenv").config();

const fs = require("fs");
const path = require("path");
const semver = require("semver");
const express = require("express");
const config = require("./config.json");

const analyticsLog = [];

const app = express();

// Version checking
app.use((req, res, next) => {
    const version = semver.valid(req.headers["spidington"]);

    if (!version) {
        return res.sendStatus(400);
    }

    if (!semver.satisfies(version, config.versionSupport)) {
        return res.sendStatus(403);
    }

    return next();
});

app.use(express.json());

// Analytics
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

// Error handling
app.use((_err, _req, res, _next) => res.sendStatus(400));

app.listen(process.env.PORT, () => {
    console.log(`Server listening on port ${process.env.PORT}.`);
});

setInterval(() => {
    fs.promises.writeFile(path.resolve(config.analyticsLocation), JSON.stringify(analyticsLog));
}, config.analyticsLoggingInterval);

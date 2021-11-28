require("dotenv").config();

const semver = require("semver");
const express = require("express");
const analytics = require("./routes/analytics");
const config = require("./config.json");

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

// Analytics
app.use(analytics.router);

// Error handling
app.use((_err, _req, res, _next) => res.sendStatus(400));

app.listen(process.env.PORT, () => {
    console.log(`Server listening on port ${process.env.PORT}.`);
});

setInterval(analytics.save, config.analytics.saveInterval);

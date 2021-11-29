const fs = require("fs");
const semver = require("semver");
const express = require("express");
const analytics = require("./routes/analytics");
const config = require("./config.json");

const app = express();

if (config.secure) {
    app.use((req, res, next) => {
        if (req.protocol === "https") {
            return next();
        }

        if (!req.headers.host) {
            return res.sendStatus(400);
        }

        return res.redirect("https://" + req.headers.host + req.url);
    });

    (async () => {
        const options = {};

        if (config.ssl) {
            Object.assign(options, {
                key: await fs.promises.readFile(config.ssl.key),
                cert: await fs.promises.readFile(config.ssl.cert),
            });
        }

        require("https")
            .createServer(options, app)
            .listen(443, () => {
                console.log("Server listening on port 443.");
            });
    })();
}

app.use(express.static("public"));

app.get("/", (_req, res) => {
    return res.sendStatus(200);
});

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

app.listen(config.port, () => {
    console.log(`Server listening on port ${config.port}.`);
});

setInterval(analytics.save, config.analytics.saveInterval);

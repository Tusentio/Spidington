const fs = require("fs");
const semver = require("semver");
const express = require("express");
const analytics = require("./routes/analytics");
const config = require("./config.json");

const app = express();

// Require Host-header
app.use((req, res, next) => {
    if (req.headers.host) {
        return next();
    } else {
        return res.sendStatus(400);
    }
});

if (config.secure) {
    // Redirect HTTP to HTTPS
    app.use((req, res, next) => {
        if (req.protocol === "https") {
            return next();
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

app.get("/", (req, res) => {
    return res.json(req.headers);
});

// Admin
app.use("/admin", require("./routes/admin"));

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
app.use("/analytics", analytics.router);

// Error handling
app.use((err, _req, res, _next) => {
    console.error(err);
    return res.sendStatus(500);
});

app.listen(config.port, () => {
    console.log(`Server listening on port ${config.port}.`);
});

setInterval(analytics.save, config.analytics.saveInterval);

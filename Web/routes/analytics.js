const fs = require("fs");
const path = require("path");
const sanitize = require("sanitize-filename");
const express = require("express");
const config = require("../config.json");

const router = express.Router();

const log = [];

// Version checking
router.use((req, res, next) => {
    const version = semver.valid(req.headers["spidington"]);

    if (!version) {
        return res.sendStatus(400);
    }

    if (!semver.satisfies(version, config.versionSupport)) {
        return res.sendStatus(403);
    }

    return next();
});

router.use(express.json());

router.post("/", (req, res) => {
    if (!req.body.evq || !req.body.sid) {
        return res.sendStatus(400);
    }

    const entry = req.body;
    log.push(entry);

    if (config.analytics.echo) {
        console.log(entry);
    }

    return res.sendStatus(200);
});

module.exports = {
    router,
    async save() {
        const directory = config.analytics.directory;
        if (!fs.existsSync(directory)) {
            await fs.promises.mkdir(directory, { recursive: true });
        }

        if (log.length > 0) {
            const file = path.resolve(directory, sanitize(new Date().toISOString()) + ".json");
            await fs.promises.writeFile(file, JSON.stringify(log));

            // Clear log
            log.splice(0);
        }
    },
};

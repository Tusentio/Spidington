const fs = require("fs");
const path = require("path");
const semver = require("semver");
const sanitize = require("sanitize-filename");
const express = require("express");
const Ajv = require("ajv");
const config = require("../config.json");

const validatePacket = new Ajv().compile(require("../schemas/analytics-packet.json"));

const router = express.Router();

const log = [];

// Version checking
router.use((req, res, next) => {
    const version = semver.valid(req.headers["spidington"]);

    if (!version) {
        return res.status(400).send();
    }

    if (!semver.satisfies(version, config.versionSupport)) {
        return res.status(403).send();
    }

    return next();
});

router.use(express.json());

// Analytics logging
router.post("/", (req, res) => {
    const entry = req.body;

    if (!validatePacket(entry)) {
        return res.status(400).send();
    }

    log.push(entry);

    if (config.analytics.echo) {
        console.log(entry);
    }

    return res.status(200).send();
});

async function save() {
    const directory = config.analytics.directory;
    await fs.promises.mkdir(directory, { recursive: true }); // Ensure directory

    // Save new log file if there are unsaved entries
    if (log.length > 0) {
        const file = path.resolve(directory, sanitize(new Date().toISOString()) + ".json");
        await fs.promises.writeFile(file, JSON.stringify(log));

        // Clear log
        log.splice(0);
    }
}

module.exports = { router, save };

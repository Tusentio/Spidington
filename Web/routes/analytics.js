const fs = require("fs");
const path = require("path");
const sanitize = require("sanitize-filename");
const express = require("express");
const config = require("../config.json");

const router = express.Router();

let name = makeName();
const log = [];

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

async function makeName() {
    const dateformat = await import("dateformat");
    const format = config.analytics.nameFormat;
    return format.replace(/\\(.)|\{([^}]*)\}/g, (_match, escape, dateTemplate) => {
        return escape ?? dateformat.default(Date.now(), dateTemplate);
    });
}

module.exports = {
    router,
    async save() {
        const directory = config.analytics.directory;
        if (!fs.existsSync(directory)) {
            await fs.promises.mkdir(directory, { recursive: true });
        }

        const file = path.resolve(directory, sanitize(new Date().toISOString()) + ".json");
        await fs.promises.writeFile(file, JSON.stringify(log));
    },
};

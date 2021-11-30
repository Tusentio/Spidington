const fs = require("fs");
const path = require("path");
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

router.get("/", async (_req, res) => {
    return res.render("admin", {
        analyticsSize: JSON.stringify(await compileAnalytics()).length,
    });
});

router.get("/analytics", async (req, res) => {
    let analytics = await compileAnalytics();

    if (req.query["exclude_debug"]) {
        analytics = filterDebugBuilds(analytics);
    }

    if (req.query["by_player"]) {
        analytics = arrangeByPlayer(analytics);
    }

    return res.json(analytics);
});

router.get("/analytics/purge", async (req, res) => {
    if (req.query["confirm"] === "CONFIRM") {
        await clearAnalytics();
        return res.redirect("/admin");
    } else {
        return res.status(204).end();
    }
});

module.exports = router;

function arrangeByPlayer(analytics) {
    const byPlayer = {};

    for (const entry of analytics) {
        (byPlayer[entry.sid] ??= []).push(...entry.evq);
    }

    return byPlayer;
}

function filterDebugBuilds(analytics) {
    return analytics.filter((entry) => entry.rel !== 0);
}

async function compileAnalytics() {
    const analytics = [];
    const files = await fs.promises.readdir(config.analytics.directory);

    for (const name of files) {
        if (name.toLowerCase().endsWith(".json")) {
            const file = path.resolve(config.analytics.directory, name);
            const log = await fs.promises.readFile(file, "utf-8");

            try {
                analytics.push(...JSON.parse(log));
            } catch {}
        }
    }

    for (const entry of analytics) {
        for (const event of entry.evq) {
            if (event.m === 0) {
                delete event.m;
            }
        }
    }

    return analytics;
}

async function clearAnalytics() {
    const files = await fs.promises.readdir(config.analytics.directory);

    for (const name of files) {
        const file = path.resolve(config.analytics.directory, name);
        await fs.promises.unlink(file);
    }
}

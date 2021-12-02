const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
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

router.use(express.urlencoded());

router.get("/", async (_req, res) => {
    return res.render("admin", {
        analytics: await compileAnalytics(),
        snippets: await readSnippets(),
    });
});

router.get("/result/:data/*", (req, res) => {
    try {
        const data = Buffer.from(req.params.data, "base64").toString();
        const result = JSON.parse(data);
        return res.json(result);
    } catch (error) {
        return res.status(400).json({ error: `${error}` });
    }
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

router.post("/analytics/purge", async (req, res) => {
    if (req.body["confirm"] === "CONFIRM") {
        await clearAnalytics();
        return res.redirect("/admin");
    } else {
        return res.status(204).send();
    }
});

router.post("/analytics/snippet", async (req, res) => {
    const id = crypto.randomBytes(8).toString("base64url");
    const snippets = await readSnippets();

    snippets[id] = {
        name: req.body.name ?? "",
        code: req.body.code ?? "",
    };

    await saveSnippets(snippets);
    return res.redirect("/admin");
});

router.post("/analytics/snippet/:id", async (req, res) => {
    const id = req.params.id;
    const snippets = await readSnippets();

    const snippet = snippets[id];

    if (snippet) {
        snippet.name = req.body.name ?? snippet.name;
        snippet.code = req.body.code ?? snippet.code;
        await saveSnippets(snippets);
    }

    return res.redirect("/admin");
});

router.post("/analytics/snippet/:id/delete", async (req, res) => {
    const id = req.params.id;
    const snippets = await readSnippets();

    delete snippets[id];

    await saveSnippets(snippets);
    return res.redirect("/admin");
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

async function readSnippets() {
    return JSON.parse(
        fs.existsSync("./.snippets.json")
            ? await fs.promises.readFile("./.snippets.json", "utf-8")
            : JSON.stringify({})
    );
}

async function saveSnippets(snippets) {
    await fs.promises.writeFile("./.snippets.json", JSON.stringify(snippets));
}

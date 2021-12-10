/**
 *
 * @param {(user: string, password: string) => boolean} verifier
 * @param {object} [options]
 * @param {string} [options.realm]
 * @param {"utf-8"} [options.charset]
 * @returns
 */
function basic(verifier, options = {}) {
    return (req, res, next) => {
        const { realm = req.headers.host, charset } = options;
        const auth = req.headers.authorization ?? "";

        if (auth.startsWith("Basic ")) {
            const [user, password] = Buffer.from(auth.slice(6), "base64").toString().split(":", 2);

            if (verifier(user, password)) {
                req.user = user;
                return next();
            }
        }

        return res
            .header("www-authenticate", "Basic " + formatParams({ realm, charset }))
            .status(401)
            .send();
    };
}

/**
 *
 * @param {object} credentials
 * @param {string} [credentials.user]
 * @param {string} credentials.password
 */
function user(credentials) {
    return (user, password) => {
        if (credentials.user && user !== credentials.user) {
            return false;
        }

        return password === credentials.password;
    };
}

module.exports = {
    basic,
    user,
};

function formatParams(params) {
    return Object.entries(JSON.parse(JSON.stringify(params)))
        .map(([key, value]) => key + "=" + JSON.stringify(value))
        .join();
}

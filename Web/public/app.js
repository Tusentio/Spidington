const analytics = JSON.parse(decodeURIComponent(escape(window.atob(_analytics.innerText))));

const exec = function (name, src, ...args) {
    const func = new Function("...args", src);
    const result = func(...args);

    if (result !== undefined) {
        const json = JSON.stringify(result);
        const data = window.btoa(unescape(encodeURIComponent(json)));
        window.open(
            "/admin/result/" + encodeURIComponent(data) + "/" + encodeURIComponent(name),
            "_blank",
            "popup,top"
        );
    }
};

const _run = function (button) {
    const id = button.getAttribute("data-id");
    const name = button.getAttribute("data-name");
    const snippet = document.getElementById("_snippet_" + id);
    const src = snippet.querySelector("textarea").value;
    exec(name, src, analytics);
};

const _handleTab = function (e) {
    if (e.key !== "Tab") return;
    e.preventDefault();

    const target = e.target;
    const _sel = {
        start: target.selectionStart,
        end: target.selectionEnd,
    };

    const start = target.value.substring(0, _sel.start).split("\n").length - 1;
    const end = target.value.substring(0, _sel.end).split("\n").length - 1;
    const lines = target.value.split("\n");

    if (e.shiftKey) {
        for (let l = start; l <= end; l++) {
            const _length = lines[l].length;
            lines[l] = lines[l].replace(/^[ ]{1,4}|^\t/, "");

            const diff = lines[l].length - _length;
            _sel.end += diff;

            if (l === start) {
                _sel.start += diff;
            }
        }
    } else {
        for (let l = start; l <= end; l++) {
            let _length = lines[l].length;
            lines[l] = "    " + lines[l];

            const diff = lines[l].length - _length;
            _sel.end += diff;

            if (l === start) {
                _sel.start += diff;
            }
        }
    }

    target.value = lines.join("\n");
    target.selectionStart = _sel.start;
    target.selectionEnd = _sel.end;
};

const _run = async function (e) {
    const button = e.target;
    const id = button.getAttribute("data-id");
    const name = button.getAttribute("data-name");
    const snippet = document.getElementById("_snippet_" + id);
    const src = snippet.querySelector("textarea").value;

    const response = await fetch("/admin/analytics");
    if (!response.ok) return;

    const analytics = await response.json();

    const func = new Function("...args", src);
    const result = func(analytics) ?? null;
    const json = JSON.stringify(result, null, 4);

    const file = new Blob([json], { type: "application/json" });
    const url = URL.createObjectURL(file);
    const a = document.createElement("a");

    a.href = url;
    a.download = name + ".json";
    document.body.appendChild(a);
    a.click();

    setTimeout(() => {
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
    }, 0);
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

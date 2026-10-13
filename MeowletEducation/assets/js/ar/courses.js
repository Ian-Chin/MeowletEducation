(function () {
    "use strict";

    /** @type {HTMLElement|null} */
    var dataEl = document.getElementById("coursePreviewData");
    /** @type {HTMLElement|null} */
    var modal = document.getElementById("coursePreviewModal");
    if (!dataEl || !modal) return;

    /** @type {any[]} */
    var courses = [];
    try {
        var rawJson = dataEl.textContent;
        courses = JSON.parse(rawJson ? rawJson : "[]");
    } catch (err) {
        courses = [];
    }

    /** @type {Record<string, any>} */
    var byId = {};
    for (var i = 0; i < courses.length; i++) {
        /** @type {any} */
        var item = courses[i];
        if (item && item.id != null) {
            byId[String(item.id)] = item;
        }
    }

    /** @type {HTMLElement|null} */
    var codeEl = document.getElementById("cpCode");
    /** @type {HTMLElement|null} */
    var titleEl = document.getElementById("cpTitle");
    /** @type {HTMLElement|null} */
    var descEl = document.getElementById("cpDesc");
    /** @type {HTMLElement|null} */
    var metaEl = document.getElementById("cpMeta");
    /** @type {HTMLElement|null} */
    var outlineEl = document.getElementById("cpOutline");
    /** @type {HTMLElement|null} */
    var closeBtn = document.getElementById("cpClose");
    /** @type {HTMLElement|null} */
    var imgWrap = document.getElementById("cpImageWrap");
    /** @type {HTMLImageElement|null} */
    var imgEl = /** @type {HTMLImageElement|null} */ (document.getElementById("cpImage"));

    if (!codeEl || !titleEl || !descEl || !metaEl || !outlineEl || !closeBtn) return;

    /** @type {HTMLElement|null} */
    var lastFocus = null;

    /**
     * @param {any} s
     * @returns {string}
     */
    function esc(s) {
        return String(s == null ? "" : s)
            .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
    }

    /**
     * @param {any} lvl
     * @returns {string}
     */
    function levelClass(lvl) {
        return "level-tag level-" + String(lvl || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
    }

    /**
     * @param {string} id
     */
    function openPreview(id) {
        if (!codeEl || !titleEl || !descEl || !metaEl || !outlineEl || !closeBtn || !modal) return;
        var c = byId[String(id)];
        if (!c) return;

        var lvl = c.level || "";
        codeEl.innerHTML = esc(c.code) + " · <span class='" + levelClass(lvl) + "'>" + esc(lvl) + "</span> · " + esc(c.category);

        if (imgWrap && imgEl) {
            if (c.image) {
                imgEl.src = String(c.image);
                imgWrap.hidden = false;
            } else {
                imgEl.removeAttribute("src");
                imgWrap.hidden = true;
            }
        }

        titleEl.textContent = String(c.title || "");
        descEl.textContent = String(c.description || "No description yet.");
        var count = c.lessonCount || (c.lessons && c.lessons.length) || 0;
        metaEl.textContent = count + " lessons · Tutor: " + (c.tutorName || "Meowlet team");

        var html = "";
        /** @type {any[]} */
        var lessons = c.lessons || [];
        for (var j = 0; j < lessons.length; j++) {
            /** @type {any} */
            var l = lessons[j];
            html += "<li><span class=\"pos\">" + esc(l.position) + "</span>" +
                "<span>" + esc(l.title) + "</span>" +
                "<span class=\"type\">" + esc(l.contentType) + " · " + esc(l.durationMinutes) + " min</span></li>";
        }
        outlineEl.innerHTML = html || "<li>No lessons listed yet.</li>";

        lastFocus = /** @type {HTMLElement|null} */ (document.activeElement);
        modal.hidden = false;
        modal.classList.add("is-open");
        document.body.style.overflow = "hidden";
        closeBtn.focus();
    }

    function closePreview() {
        if (!modal) return;
        modal.classList.remove("is-open");
        document.body.style.overflow = "";
        setTimeout(function () {
            if (modal && !modal.classList.contains("is-open")) modal.hidden = true;
        }, 200);
        if (lastFocus && typeof lastFocus.focus === "function") lastFocus.focus();
    }

    document.addEventListener("click", function (/** @type {MouseEvent} */ e) {
        var target = /** @type {HTMLElement|null} */ (e.target);
        if (!target || typeof target.closest !== "function") return;
        var btn = /** @type {HTMLElement|null} */ (target.closest("[data-preview-id]"));
        if (!btn) return;
        e.preventDefault();
        var previewId = btn.getAttribute("data-preview-id");
        if (previewId) {
            openPreview(previewId);
        }
    });

    closeBtn.addEventListener("click", closePreview);
    modal.addEventListener("click", function (/** @type {MouseEvent} */ e) {
        if (e.target === modal) closePreview();
    });
    document.addEventListener("keydown", function (/** @type {KeyboardEvent} */ e) {
        if (e.key === "Escape" && modal && modal.classList.contains("is-open")) closePreview();
    });

    // ---------- Catalog search + filters ----------
    var rawCards = document.querySelectorAll(".course-card[data-search]");
    /** @type {HTMLElement[]} */
    var cards = [];
    for (var k = 0; k < rawCards.length; k++) {
        cards.push(/** @type {HTMLElement} */(rawCards[k]));
    }

    /** @type {HTMLInputElement|null} */
    var qEl = /** @type {HTMLInputElement|null} */ (document.getElementById("catQ"));
    /** @type {HTMLSelectElement|null} */
    var catEl = /** @type {HTMLSelectElement|null} */ (document.getElementById("catCategory"));
    /** @type {HTMLSelectElement|null} */
    var lvlEl = /** @type {HTMLSelectElement|null} */ (document.getElementById("catLevel"));
    /** @type {HTMLElement|null} */
    var countEl = document.getElementById("catCount");
    /** @type {HTMLElement|null} */
    var noMatch = document.getElementById("catNoMatch");
    /** @type {HTMLElement|null} */
    var resetBtn = document.getElementById("catReset");

    if (!qEl || !catEl || !lvlEl) return;

    /**
     * @param {HTMLSelectElement} sel
     * @param {string} key
     */
    function fillSelect(sel, key) {
        /** @type {Record<string, boolean>} */
        var seen = {};
        /** @type {string[]} */
        var vals = [];
        cards.forEach(function (/** @type {HTMLElement} */ c) {
            var v = c.getAttribute("data-" + key);
            if (v && !seen[v]) { seen[v] = true; vals.push(v); }
        });
        vals.sort();
        vals.forEach(function (/** @type {string} */ v) {
            var o = document.createElement("option");
            o.value = v;
            o.textContent = v;
            sel.appendChild(o);
        });
    }
    fillSelect(catEl, "category");
    fillSelect(lvlEl, "level");

    function apply() {
        if (!qEl || !catEl || !lvlEl) return;
        var terms = qEl.value.toLowerCase().split(/\s+/).filter(Boolean);
        var cat = catEl.value;
        var lvl = lvlEl.value;
        var shown = 0;

        cards.forEach(function (/** @type {HTMLElement} */ card) {
            var hay = (card.getAttribute("data-search") || "").toLowerCase();
            var ok = terms.every(function (/** @type {string} */ t) { return hay.indexOf(t) > -1; }) &&
                (!cat || card.getAttribute("data-category") === cat) &&
                (!lvl || card.getAttribute("data-level") === lvl);

            card.hidden = !ok;
            if (ok) shown++;
        });

        if (countEl) countEl.textContent = "Showing " + shown + (shown === 1 ? " course" : " courses");
        if (noMatch) noMatch.hidden = !(cards.length > 0 && shown === 0);

        if (window.history && history.replaceState) {
            var q = qEl.value.trim();
            history.replaceState(null, "", window.location.pathname + (q ? "?q=" + encodeURIComponent(q) : ""));
        }
    }

    qEl.addEventListener("input", apply);
    catEl.addEventListener("change", apply);
    lvlEl.addEventListener("change", apply);
    qEl.addEventListener("keydown", function (/** @type {KeyboardEvent} */ e) {
        if (e.key === "Enter") e.preventDefault();
    });

    if (resetBtn) {
        resetBtn.addEventListener("click", function () {
            if (!qEl || !catEl || !lvlEl) return;
            qEl.value = "";
            catEl.value = "";
            lvlEl.value = "";
            apply();
            qEl.focus();
        });
    }

    var m = /[?&]q=([^&]*)/.exec(window.location.search);
    if (m && qEl) {
        try {
            qEl.value = decodeURIComponent(m[1].replace(/\+/g, " "));
        } catch (err) { }
    }
    apply();
})();
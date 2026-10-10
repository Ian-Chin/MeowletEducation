/* ============================================================
   Meowlet Educations, course builder (AdminCourse.aspx)
   Chapters on the left, the selected chapter's content on the
   right. Every change saves itself through AdminCourseApi.ashx.
   Chapters and content items reorder by drag and drop or with
   the arrow buttons; content dropped on a chapter moves there.
   ============================================================ */
(function () {
    "use strict";

    var API = "AdminCourseApi.ashx";
    var courseId = document.body.getAttribute("data-course-id");
    var sideList = document.getElementById("chapterList");
    var editor = document.getElementById("chapterEditor");
    var countEl = document.getElementById("chapterCount");
    var statusEl = document.getElementById("saveStatus");

    var state = { chapters: [], selected: null };
    var dragging = null;          // { kind: "chapter" | "block", id }
    var timers = {};              // pending debounced saves, by key
    var pending = 0;

    var TYPES = {
        Text: { label: "Content", icon: "bi-text-paragraph" },
        Media: { label: "Media", icon: "bi-image" },
        Quiz: { label: "Quiz", icon: "bi-patch-question" }
    };

    /* ---------- small helpers ---------- */

    function h(tag, attrs, children) {
        var el = document.createElement(tag);
        Object.keys(attrs || {}).forEach(function (k) {
            var v = attrs[k];
            if (v === null || v === undefined || v === false) return;
            if (k === "text") el.textContent = v;
            else if (k === "className") el.className = v;
            else if (k.indexOf("on") === 0) el.addEventListener(k.slice(2), v);
            else if (k === "value") el.value = v;
            else el.setAttribute(k, v === true ? "" : v);
        });
        (children || []).forEach(function (c) { if (c) el.appendChild(c); });
        return el;
    }

    function icon(name) { return h("i", { className: "bi " + name, "aria-hidden": "true" }); }

    function iconButton(name, label, onclick, extra) {
        return h("button", { type: "button", className: "cb-icon" + (extra ? " " + extra : ""), title: label, "aria-label": label, onclick: onclick }, [icon(name)]);
    }

    function chapterById(id) {
        for (var i = 0; i < state.chapters.length; i++) if (state.chapters[i].id === id) return state.chapters[i];
        return null;
    }

    function findBlock(id) {
        for (var i = 0; i < state.chapters.length; i++) {
            var blocks = state.chapters[i].blocks;
            for (var j = 0; j < blocks.length; j++) if (blocks[j].id === id) return { chapter: state.chapters[i], block: blocks[j], index: j };
        }
        return null;
    }

    function setStatus(text, error) {
        statusEl.textContent = text;
        statusEl.className = "cb-save" + (error ? " is-error" : "");
    }

    /* ---------- talking to the server ---------- */

    function post(action, data) {
        var body = new URLSearchParams();
        body.append("action", action);
        body.append("courseId", courseId);
        Object.keys(data || {}).forEach(function (k) { body.append(k, data[k] == null ? "" : data[k]); });

        pending++;
        setStatus("Saving...");
        return fetch(API, {
            method: "POST",
            credentials: "same-origin",
            headers: { "Content-Type": "application/x-www-form-urlencoded", "X-Requested-With": "fetch" },
            body: body.toString()
        }).then(function (res) {
            return res.json().catch(function () { return {}; }).then(function (json) {
                if (!res.ok) throw new Error(json.error || "Something went wrong.");
                return json;
            });
        }).then(function (json) {
            pending--;
            if (!pending) setStatus("All changes saved");
            return json;
        }, function (err) {
            pending--;
            setStatus("Not saved: " + err.message, true);
            throw err;
        });
    }

    // Waits for typing to pause before saving the same thing again.
    function later(key, fn, wait) {
        clearTimeout(timers[key]);
        setStatus("Unsaved changes");
        timers[key] = setTimeout(function () { delete timers[key]; fn(); }, wait || 700);
    }

    function saveOrder() {
        var layout = { chapters: [], blocks: {} };
        state.chapters.forEach(function (c) {
            layout.chapters.push(c.id);
            layout.blocks[c.id] = c.blocks.map(function (b) { return b.id; });
        });
        return post("reorder", { layout: JSON.stringify(layout) }).catch(function () { });
    }

    // Uploads with progress, which fetch can't report.
    function upload(file, kind, onProgress) {
        return new Promise(function (resolve, reject) {
            var form = new FormData();
            form.append("action", "upload");
            form.append("courseId", courseId);
            form.append("kind", kind);
            form.append("file", file);

            var xhr = new XMLHttpRequest();
            xhr.open("POST", API);
            xhr.setRequestHeader("X-Requested-With", "fetch");
            xhr.upload.onprogress = function (e) { if (e.lengthComputable) onProgress(Math.round(e.loaded * 100 / e.total)); };
            xhr.onload = function () {
                var json = {};
                try { json = JSON.parse(xhr.responseText); } catch (e) { }
                if (xhr.status >= 200 && xhr.status < 300) resolve(json);
                else reject(new Error(json.error || (xhr.status === 404 || xhr.status === 413 ? "The file is too big." : "The upload failed.")));
            };
            xhr.onerror = function () { reject(new Error("The upload failed.")); };
            xhr.send(form);
        });
    }

    /* ---------- moving things ---------- */

    function move(list, from, to) {
        if (to < 0 || to >= list.length || from === to) return false;
        list.splice(to, 0, list.splice(from, 1)[0]);
        return true;
    }

    // Before or after the element under the pointer, by its vertical middle.
    function dropAfter(el, e) {
        var r = el.getBoundingClientRect();
        return e.clientY > r.top + r.height / 2;
    }

    function clearDropMarks() {
        Array.prototype.forEach.call(document.querySelectorAll(".is-drop-before, .is-drop-after, .is-drop-into"), function (el) {
            el.classList.remove("is-drop-before", "is-drop-after", "is-drop-into");
        });
    }

    /* ---------- left: chapter list ---------- */

    function renderSide() {
        sideList.innerHTML = "";
        countEl.textContent = state.chapters.length;

        state.chapters.forEach(function (c, i) {
            var li = h("li", {
                className: "cb-chap" + (c.id === state.selected ? " is-selected" : ""),
                draggable: "true",
                "data-id": c.id
            }, [
                h("span", { className: "cb-grip", "aria-hidden": "true" }, [icon("bi-grip-vertical")]),
                h("button", {
                    type: "button",
                    className: "cb-chap__open",
                    "aria-current": c.id === state.selected ? "true" : null,
                    onclick: function () { select(c.id); }
                }, [
                    h("span", { className: "cb-chap__num", text: String(i + 1) }),
                    h("span", { className: "cb-chap__text" }, [
                        h("span", { className: "cb-chap__title", text: c.title }),
                        h("span", { className: "cb-chap__meta", text: c.blocks.length + (c.blocks.length === 1 ? " item" : " items") + ", " + c.minutes + " min" })
                    ])
                ]),
                h("span", { className: "cb-chap__move" }, [
                    iconButton("bi-chevron-up", "Move chapter up", function () { if (move(state.chapters, i, i - 1)) { renderSide(); saveOrder(); } }),
                    iconButton("bi-chevron-down", "Move chapter down", function () { if (move(state.chapters, i, i + 1)) { renderSide(); saveOrder(); } })
                ])
            ]);

            li.addEventListener("dragstart", function (e) {
                dragging = { kind: "chapter", id: c.id };
                e.dataTransfer.effectAllowed = "move";
                e.dataTransfer.setData("text/plain", "chapter");
                li.classList.add("is-dragging");
            });
            li.addEventListener("dragend", function () { li.classList.remove("is-dragging"); clearDropMarks(); dragging = null; });

            li.addEventListener("dragover", function (e) {
                if (!dragging) return;
                if (dragging.kind === "chapter" && dragging.id === c.id) return;
                e.preventDefault();
                clearDropMarks();
                if (dragging.kind === "block") li.classList.add("is-drop-into");
                else li.classList.add(dropAfter(li, e) ? "is-drop-after" : "is-drop-before");
            });
            li.addEventListener("dragleave", function () { li.classList.remove("is-drop-before", "is-drop-after", "is-drop-into"); });

            li.addEventListener("drop", function (e) {
                e.preventDefault();
                if (!dragging) return;

                if (dragging.kind === "chapter") {
                    var from = state.chapters.indexOf(chapterById(dragging.id));
                    var to = state.chapters.indexOf(c) + (dropAfter(li, e) ? 1 : 0);
                    if (from < to) to--;
                    if (move(state.chapters, from, to)) { renderSide(); saveOrder(); }
                } else {
                    // content dropped on a chapter goes to the end of that chapter
                    var found = findBlock(dragging.id);
                    if (found && found.chapter !== c) {
                        found.chapter.blocks.splice(found.index, 1);
                        c.blocks.push(found.block);
                        renderAll();
                        saveOrder();
                    }
                }
                clearDropMarks();
            });

            sideList.appendChild(li);
        });
    }

    /* ---------- right: the selected chapter ---------- */

    function select(id) {
        state.selected = id;
        renderAll();
    }

    function renderMain() {
        editor.innerHTML = "";
        var c = chapterById(state.selected);

        if (!c) {
            editor.appendChild(h("div", { className: "cb-empty" }, [
                icon("bi-journal-plus"),
                h("h2", { text: "Start with a chapter" }),
                h("p", { text: "Chapters are the steps learners go through. Add one, then fill it with content, media and quizzes." }),
                h("button", { type: "button", className: "btn btn--primary btn--sm", onclick: addChapter }, [icon("bi-plus-lg"), document.createTextNode("Add chapter")])
            ]));
            return;
        }

        var number = state.chapters.indexOf(c) + 1;

        var title = h("input", { className: "ad-input cb-title-input", type: "text", maxlength: "200", value: c.title, "aria-label": "Chapter title" });
        var minutes = h("input", { className: "ad-input cb-minutes", type: "number", min: "1", max: "600", value: c.minutes, "aria-label": "Minutes" });

        function saveChapter() {
            var t = title.value.trim();
            var m = parseInt(minutes.value, 10);
            if (!t) { setStatus("Not saved: a chapter needs a title.", true); return; }
            if (!(m >= 1 && m <= 600)) { setStatus("Not saved: minutes must be 1 to 600.", true); return; }
            c.title = t;
            c.minutes = m;
            renderSide();
            post("updateChapter", { id: c.id, title: t, minutes: m }).catch(function () { });
        }

        title.addEventListener("input", function () { later("chapter" + c.id, saveChapter); });
        minutes.addEventListener("input", function () { later("chapter" + c.id, saveChapter); });

        editor.appendChild(h("div", { className: "cb-chapter-head" }, [
            h("div", { className: "cb-chapter-head__main" }, [
                h("p", { className: "cb-eyebrow", text: "Chapter " + number }),
                title
            ]),
            h("label", { className: "cb-minutes-wrap" }, [minutes, h("span", { text: "min" })]),
            iconButton("bi-trash", "Delete chapter", function () { deleteChapter(c); }, "cb-icon--danger")
        ]));

        var list = h("ol", { className: "cb-blocks", "aria-label": "Content in this chapter" });
        c.blocks.forEach(function (b, i) { list.appendChild(renderBlock(c, b, i)); });

        if (!c.blocks.length) {
            list.appendChild(h("li", { className: "cb-blocks__empty", text: "Nothing in this chapter yet. Add content, media or a quiz below." }));
        }

        editor.appendChild(list);

        editor.appendChild(h("div", { className: "cb-addbar" }, [
            h("span", { text: "Add to this chapter" }),
            addButton(c, "Text"),
            addButton(c, "Media"),
            addButton(c, "Quiz")
        ]));
    }

    function addButton(c, type) {
        return h("button", { type: "button", className: "btn btn--ghost btn--sm", onclick: function () { addBlock(c, type); } },
            [icon(TYPES[type].icon), document.createTextNode(TYPES[type].label)]);
    }

    function renderBlock(c, b, i) {
        var grip = h("span", { className: "cb-grip", title: "Drag to move", "aria-hidden": "true" }, [icon("bi-grip-vertical")]);
        var li = h("li", { className: "cb-block cb-block--" + b.type.toLowerCase(), "data-id": b.id }, [
            h("div", { className: "cb-block__head" }, [
                grip,
                h("span", { className: "cb-block__type" }, [icon(TYPES[b.type].icon), document.createTextNode(TYPES[b.type].label)]),
                h("span", { className: "cb-block__tools" }, [
                    moveToChapter(c, b),
                    iconButton("bi-chevron-up", "Move up", function () { if (move(c.blocks, i, i - 1)) { renderMain(); saveOrder(); } }),
                    iconButton("bi-chevron-down", "Move down", function () { if (move(c.blocks, i, i + 1)) { renderMain(); saveOrder(); } }),
                    iconButton("bi-trash", "Delete", function () { deleteBlock(c, b); }, "cb-icon--danger")
                ])
            ]),
            b.type === "Text" ? textEditor(b) : b.type === "Media" ? mediaEditor(b) : quizEditor(b)
        ]);

        // only the grip starts a drag, so text inside can still be selected
        grip.addEventListener("mousedown", function () { li.setAttribute("draggable", "true"); });
        li.addEventListener("mouseup", function () { li.removeAttribute("draggable"); });

        li.addEventListener("dragstart", function (e) {
            dragging = { kind: "block", id: b.id };
            e.dataTransfer.effectAllowed = "move";
            e.dataTransfer.setData("text/plain", "block");
            li.classList.add("is-dragging");
        });
        li.addEventListener("dragend", function () {
            li.classList.remove("is-dragging");
            li.removeAttribute("draggable");
            clearDropMarks();
            dragging = null;
        });
        li.addEventListener("dragover", function (e) {
            if (!dragging || dragging.kind !== "block" || dragging.id === b.id) return;
            e.preventDefault();
            clearDropMarks();
            li.classList.add(dropAfter(li, e) ? "is-drop-after" : "is-drop-before");
        });
        li.addEventListener("drop", function (e) {
            e.preventDefault();
            if (!dragging || dragging.kind !== "block") return;
            var found = findBlock(dragging.id);
            if (!found) return;
            var after = dropAfter(li, e);
            found.chapter.blocks.splice(found.index, 1);
            var to = c.blocks.indexOf(b) + (after ? 1 : 0);
            c.blocks.splice(to, 0, found.block);
            clearDropMarks();
            renderAll();
            saveOrder();
        });

        return li;
    }

    // A select for moving an item to another chapter without dragging.
    function moveToChapter(c, b) {
        if (state.chapters.length < 2) return null;
        var sel = h("select", { className: "cb-moveto", "aria-label": "Move to chapter" }, [h("option", { value: "", text: "Move to..." })]);
        state.chapters.forEach(function (other, i) {
            if (other !== c) sel.appendChild(h("option", { value: other.id, text: (i + 1) + ". " + other.title }));
        });
        sel.addEventListener("change", function () {
            var target = chapterById(parseInt(sel.value, 10));
            if (!target) return;
            c.blocks.splice(c.blocks.indexOf(b), 1);
            target.blocks.push(b);
            renderAll();
            saveOrder();
        });
        return sel;
    }

    /* ---------- block editors ---------- */

    function saveBlock(b) {
        later("block" + b.id, function () {
            post("updateBlock", { id: b.id, body: b.body || "", mediaKind: b.mediaKind || "", mediaUrl: b.mediaUrl || "" })
                .catch(function () { });
        });
    }

    function autosize(area) {
        area.style.height = "auto";
        area.style.height = Math.max(area.scrollHeight, 120) + "px";
    }

    function textEditor(b) {
        var area = h("textarea", {
            className: "ad-input cb-text",
            "aria-label": "Content",
            placeholder: "Write the lesson content. Line breaks are kept.",
            value: b.body || ""
        });
        area.addEventListener("input", function () { b.body = area.value; autosize(area); saveBlock(b); });
        setTimeout(function () { autosize(area); }, 0);
        return h("div", { className: "cb-block__body" }, [area]);
    }

    function embedFor(url) {
        var m = /(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([\w-]{11})/.exec(url);
        if (m) return "https://www.youtube-nocookie.com/embed/" + m[1];
        m = /vimeo\.com\/(\d+)/.exec(url);
        if (m) return "https://player.vimeo.com/video/" + m[1];
        return null;
    }

    function mediaPreview(b) {
        if (!b.mediaUrl) {
            return h("div", { className: "cb-media__empty" }, [
                icon(b.mediaKind === "Video" ? "bi-camera-video" : "bi-image"),
                h("span", { text: b.mediaKind === "Video" ? "Paste a video link or upload a video" : "Paste a picture link or upload a picture" })
            ]);
        }
        if (b.mediaKind === "Video") {
            var embed = embedFor(b.mediaUrl);
            return embed
                ? h("iframe", { className: "cb-media__frame", src: embed, title: "Video preview", allowfullscreen: true, loading: "lazy" })
                : h("video", { className: "cb-media__video", src: b.mediaUrl, controls: true, preload: "metadata" });
        }
        return h("img", { className: "cb-media__img", src: b.mediaUrl, alt: b.body || "Lesson picture" });
    }

    function mediaEditor(b) {
        var wrap = h("div", { className: "cb-block__body cb-media" });

        function draw() {
            wrap.innerHTML = "";

            var kinds = h("div", { className: "ad-switch", role: "group", "aria-label": "Media type" });
            ["Image", "Video"].forEach(function (k) {
                kinds.appendChild(h("button", {
                    type: "button",
                    className: b.mediaKind === k ? "is-on" : "",
                    "aria-pressed": b.mediaKind === k ? "true" : "false",
                    onclick: function () {
                        if (b.mediaKind === k) return;
                        b.mediaKind = k;
                        draw();
                        saveBlock(b);
                    }
                }, [icon(k === "Video" ? "bi-camera-video" : "bi-image"), document.createTextNode(k === "Video" ? "Video" : "Picture")]));
            });

            var url = h("input", {
                className: "ad-input",
                type: "url",
                placeholder: b.mediaKind === "Video" ? "https://www.youtube.com/watch?v=..." : "https://...",
                value: b.mediaUrl && b.mediaUrl.indexOf("assets/") !== 0 ? b.mediaUrl : "",
                "aria-label": b.mediaKind === "Video" ? "Video link" : "Picture link"
            });
            url.addEventListener("input", function () {
                b.mediaUrl = url.value.trim();
                preview.replaceWith(preview = mediaPreview(b));
                saveBlock(b);
            });

            var file = h("input", {
                type: "file",
                className: "cb-file",
                accept: b.mediaKind === "Video" ? "video/mp4,video/webm" : "image/jpeg,image/png,image/gif,image/webp"
            });
            var progress = h("span", { className: "cb-upload__note" });
            var pick = h("button", { type: "button", className: "btn btn--ghost btn--sm", onclick: function () { file.click(); } },
                [icon("bi-upload"), document.createTextNode(b.mediaKind === "Video" ? "Upload video" : "Upload picture")]);

            file.addEventListener("change", function () {
                if (!file.files[0]) return;
                pick.disabled = true;
                progress.textContent = "Uploading 0%";
                upload(file.files[0], b.mediaKind, function (p) { progress.textContent = "Uploading " + p + "%"; })
                    .then(function (res) {
                        b.mediaUrl = res.url;
                        draw();
                        saveBlock(b);
                    }, function (err) {
                        pick.disabled = false;
                        progress.textContent = err.message;
                        progress.className = "cb-upload__note is-error";
                    });
            });

            var uploaded = b.mediaUrl && b.mediaUrl.indexOf("assets/") === 0;
            var preview = mediaPreview(b);

            var caption = h("input", {
                className: "ad-input",
                type: "text",
                maxlength: "500",
                placeholder: "Caption (optional)",
                value: b.body || "",
                "aria-label": "Caption"
            });
            caption.addEventListener("input", function () { b.body = caption.value; saveBlock(b); });

            wrap.appendChild(kinds);
            wrap.appendChild(h("div", { className: "cb-media__source" }, [
                url,
                h("span", { className: "cb-or", text: "or" }),
                pick,
                file
            ]));
            wrap.appendChild(h("p", { className: "cb-upload__row" }, [
                uploaded ? h("span", { className: "cb-upload__note" }, [icon("bi-check2-circle"), document.createTextNode(" Uploaded file in use")]) : null,
                uploaded ? h("button", {
                    type: "button", className: "cb-link", onclick: function () { b.mediaUrl = ""; draw(); saveBlock(b); }
                }, [document.createTextNode("Remove")]) : null,
                progress
            ]));
            wrap.appendChild(preview);
            wrap.appendChild(caption);
        }

        draw();
        return wrap;
    }

    function readQuiz(b) {
        try {
            var q = JSON.parse(b.body || "{}");
            if (q && q.questions && q.questions.length) return q;
        } catch (e) { }
        return { questions: [{ q: "", options: ["", ""], answer: 0 }] };
    }

    function quizEditor(b) {
        var quiz = readQuiz(b);
        var wrap = h("div", { className: "cb-block__body cb-quiz" });

        function changed(redraw) {
            b.body = JSON.stringify(quiz);
            if (redraw) draw();
            saveBlock(b);
        }

        function draw() {
            wrap.innerHTML = "";
            quiz.questions.forEach(function (q, qi) {
                var group = "q" + b.id + "_" + qi;
                var question = h("input", { className: "ad-input", type: "text", maxlength: "500", value: q.q, placeholder: "Type the question", "aria-label": "Question " + (qi + 1) });
                question.addEventListener("input", function () { q.q = question.value; changed(false); });

                var options = h("ul", { className: "cb-options" });
                q.options.forEach(function (opt, oi) {
                    var radio = h("input", { type: "radio", name: group, checked: q.answer === oi, "aria-label": "Mark option " + (oi + 1) + " as the right answer" });
                    radio.addEventListener("change", function () {
                        q.answer = oi;
                        Array.prototype.forEach.call(options.children, function (row, ri) { row.classList.toggle("is-answer", ri === oi); });
                        changed(false);
                    });
                    var text = h("input", { className: "ad-input", type: "text", maxlength: "300", value: opt, placeholder: "Option " + (oi + 1), "aria-label": "Option " + (oi + 1) });
                    text.addEventListener("input", function () { q.options[oi] = text.value; changed(false); });

                    options.appendChild(h("li", { className: q.answer === oi ? "is-answer" : "" }, [
                        radio,
                        text,
                        q.options.length > 2
                            ? iconButton("bi-x-lg", "Remove option", function () {
                                q.options.splice(oi, 1);
                                if (q.answer >= q.options.length || q.answer === oi) q.answer = 0;
                                changed(true);
                            })
                            : null
                    ]));
                });

                wrap.appendChild(h("fieldset", { className: "cb-question" }, [
                    h("div", { className: "cb-question__head" }, [
                        h("legend", { text: "Question " + (qi + 1) }),
                        quiz.questions.length > 1 ? iconButton("bi-trash", "Remove question", function () { quiz.questions.splice(qi, 1); changed(true); }, "cb-icon--danger") : null
                    ]),
                    question,
                    h("p", { className: "cb-quiz__hint", text: "Pick the right answer with the circle." }),
                    options,
                    q.options.length < 6
                        ? h("button", { type: "button", className: "cb-link", onclick: function () { q.options.push(""); changed(true); } }, [icon("bi-plus"), document.createTextNode(" Add option")])
                        : null
                ]));
            });

            wrap.appendChild(h("button", {
                type: "button",
                className: "btn btn--ghost btn--sm",
                onclick: function () { quiz.questions.push({ q: "", options: ["", ""], answer: 0 }); changed(true); }
            }, [icon("bi-plus-lg"), document.createTextNode("Add question")]));
        }

        draw();
        return wrap;
    }

    /* ---------- actions ---------- */

    /* ---------- add chapter popup ---------- */

    var dialog = document.getElementById("chapterDialog");
    var newTitle = document.getElementById("newChapterTitle");
    var starts = dialog.querySelectorAll(".cb-start[data-start]");

    function addChapter() {
        newTitle.value = "";
        Array.prototype.forEach.call(starts, function (b) { b.disabled = false; });
        if (dialog.showModal) dialog.showModal(); else dialog.setAttribute("open", "open");
        newTitle.focus();
    }

    function closeDialog() {
        if (dialog.close) dialog.close(); else dialog.removeAttribute("open");
    }

    // Creates the chapter, then (unless empty) its first item of the chosen type.
    function createChapter(type) {
        var title = newTitle.value.trim() || "Untitled chapter";
        Array.prototype.forEach.call(starts, function (b) { b.disabled = true; });

        post("addChapter", { title: title }).then(function (c) {
            c.blocks = [];
            state.chapters.push(c);
            closeDialog();
            select(c.id);
            if (type) {
                addBlock(c, type);
            } else {
                var input = editor.querySelector(".cb-title-input");
                if (input) { input.focus(); input.select(); }
            }
        }, function () {
            Array.prototype.forEach.call(starts, function (b) { b.disabled = false; });
        });
    }

    Array.prototype.forEach.call(starts, function (b) {
        b.addEventListener("click", function () { createChapter(b.getAttribute("data-start")); });
    });
    document.getElementById("startEmpty").addEventListener("click", function () { createChapter(null); });
    document.getElementById("chapterDialogClose").addEventListener("click", closeDialog);

    // WhiskerAI is shown but not wired up yet, so it does nothing.
    document.getElementById("startWhiskerAI").addEventListener("click", function (e) { e.preventDefault(); });

    // Enter in the title field starts an empty chapter rather than submitting nothing.
    newTitle.addEventListener("keydown", function (e) {
        if (e.key === "Enter") { e.preventDefault(); createChapter(null); }
    });

    function deleteChapter(c) {
        var what = c.blocks.length ? " and its " + c.blocks.length + (c.blocks.length === 1 ? " item" : " items") : "";
        if (!confirm('Delete "' + c.title + '"' + what + "? Learners' progress on it is removed too. This can't be undone.")) return;
        post("deleteChapter", { id: c.id }).then(function () {
            var i = state.chapters.indexOf(c);
            state.chapters.splice(i, 1);
            var next = state.chapters[Math.min(i, state.chapters.length - 1)];
            select(next ? next.id : null);
        }, function () { });
    }

    function addBlock(c, type) {
        post("addBlock", { chapterId: c.id, type: type }).then(function (b) {
            c.blocks.push(b);
            renderAll();
            var added = editor.querySelector('.cb-block[data-id="' + b.id + '"]');
            if (added) {
                added.scrollIntoView({ behavior: "smooth", block: "center" });
                var first = added.querySelector("textarea, input[type=text], input[type=url]");
                if (first) first.focus({ preventScroll: true });
            }
        }, function () { });
    }

    function deleteBlock(c, b) {
        if (!confirm("Delete this " + TYPES[b.type].label.toLowerCase() + "? This can't be undone.")) return;
        clearTimeout(timers["block" + b.id]);
        post("deleteBlock", { id: b.id }).then(function () {
            c.blocks.splice(c.blocks.indexOf(b), 1);
            renderAll();
        }, function () { });
    }

    function renderAll() {
        renderSide();
        renderMain();
    }

    /* ---------- admin sidebar collapse (same setting as the dashboard) ---------- */

    (function () {
        var shell = document.getElementById("adminShell");
        var toggle = document.getElementById("sidebarToggle");
        if (!shell || !toggle) return;
        var items = document.querySelectorAll(".ad-side .ad-nav");

        function sync() {
            var collapsed = shell.classList.contains("is-collapsed");
            toggle.setAttribute("aria-pressed", collapsed ? "true" : "false");
            toggle.setAttribute("aria-label", collapsed ? "Expand sidebar" : "Collapse sidebar");
            toggle.querySelector("span").textContent = collapsed ? "Expand" : "Collapse";
            Array.prototype.forEach.call(items, function (item) {
                if (collapsed) item.title = item.querySelector("span").textContent; else item.removeAttribute("title");
            });
        }

        toggle.addEventListener("click", function () {
            var collapsed = shell.classList.toggle("is-collapsed");
            try { localStorage.setItem("meowletAdminSidebar", collapsed ? "collapsed" : "expanded"); } catch (e) { }
            sync();
        });
        sync();
    })();

    /* ---------- start ---------- */

    document.getElementById("addChapter").addEventListener("click", addChapter);

    window.addEventListener("beforeunload", function (e) {
        if (pending || Object.keys(timers).length) { e.preventDefault(); e.returnValue = ""; }
    });

    fetch(API + "?courseId=" + encodeURIComponent(courseId), { credentials: "same-origin", cache: "no-store" })
        .then(function (res) { return res.json().then(function (json) { if (!res.ok) throw new Error(json.error); return json; }); })
        .then(function (data) {
            state.chapters = data.chapters;
            state.selected = data.chapters.length ? data.chapters[0].id : null;
            setStatus("All changes saved");
            renderAll();
        }, function (err) {
            editor.innerHTML = "";
            editor.appendChild(h("p", { className: "cb-loading is-error", text: "The course couldn't be loaded. " + (err.message || "") }));
        });
})();

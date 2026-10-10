/* ============================================================
   Meowlet Educations, page behaviour
   Sticky header state, scroll reveal, animated progress bars.
   ============================================================ */
(function () {
    "use strict";

    var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    /* Tell the stylesheet the script is alive. Until this class lands,
       .reveal elements stay fully visible. A blocked or failed script
       can never leave the page blank. */
    document.documentElement.classList.add("has-js");

    /* ---------- sticky header shadow ---------- */
    var header = document.getElementById("siteHeader");
    function onScroll() {
        if (!header) return;
        header.classList.toggle("is-stuck", window.scrollY > 8);
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();

    /* ---------- scroll reveal + progress bars ---------- */
    var revealables = document.querySelectorAll(".reveal");
    var bars = document.querySelectorAll(".progress__bar");

    function fillBar(bar) {
        bar.style.width = (bar.getAttribute("data-progress") || 0) + "%";
    }

    function show(el) {
        if (el.classList.contains("is-in")) return;
        el.classList.add("is-in");
        Array.prototype.forEach.call(el.querySelectorAll(".progress__bar"), fillBar);
    }

    function showAll() {
        Array.prototype.forEach.call(revealables, show);
        Array.prototype.forEach.call(bars, fillBar);
    }

    if (!("IntersectionObserver" in window) || reduceMotion) {
        showAll();
        return;
    }

    var observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            show(entry.target);
            observer.unobserve(entry.target);
        });
    }, { threshold: 0.12, rootMargin: "0px 0px -40px 0px" });

    Array.prototype.forEach.call(revealables, function (el, i) {
        el.style.transitionDelay = (Math.min(i % 4, 3) * 70) + "ms";
        observer.observe(el);
    });

    /* Safety net: some environments (throttled or never-painted tabs)
       do not run observer callbacks. Sweep by geometry instead so
       anything already on screen still appears. */
    function sweep() {
        Array.prototype.forEach.call(revealables, function (el) {
            if (el.classList.contains("is-in")) return;
            var r = el.getBoundingClientRect();
            if (r.top < (window.innerHeight || 0) - 40 && r.bottom > 0) {
                show(el);
                observer.unobserve(el);
            }
        });
    }
    window.addEventListener("load", function () { setTimeout(sweep, 900); });
    setTimeout(sweep, 1600);
})();

/* ---------- signed-in state ----------
   index.html is static, so Account.ashx says who is signed in. Signed in:
   hide Log in / Join free, show the profile menu, and point the sign-up
   buttons at the dashboard instead. */
(function () {
    "use strict";

    var user = document.getElementById("navUser");
    if (!user || !window.fetch) return;

    var btn = document.getElementById("navUserBtn");
    var menu = document.getElementById("navUserMenu");

    function each(selector, fn) {
        Array.prototype.forEach.call(document.querySelectorAll(selector), fn);
    }

    function apply(me) {
        each('[data-auth="guest"]', function (el) { el.hidden = me.signedIn; });
        each('[data-auth="user"]', function (el) { el.hidden = !me.signedIn; });
        if (!me.signedIn) return;

        document.getElementById("navUserName").textContent = me.name;
        document.getElementById("navUserInitials").textContent = me.initials;
        btn.setAttribute("aria-label", "Account menu for " + me.name);

        each('[data-auth-link="dashboard"]', function (a) { a.href = me.dashboard; });
        each('[data-auth-link="profile"]', function (a) {
            if (me.profile) a.href = me.profile; else a.hidden = true;
        });
        each("[data-auth-cta]", function (a) {
            a.href = me.dashboard;
            a.textContent = "Go to my dashboard";
        });
    }

    function setOpen(open) {
        menu.hidden = !open;
        btn.setAttribute("aria-expanded", open ? "true" : "false");
    }

    btn.addEventListener("click", function () { setOpen(menu.hidden); });
    document.addEventListener("click", function (e) { if (!user.contains(e.target)) setOpen(false); });
    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape" && !menu.hidden) { setOpen(false); btn.focus(); }
    });

    document.getElementById("navUserLogout").addEventListener("click", function () {
        fetch("Account.ashx", {
            method: "POST",
            credentials: "same-origin",
            headers: { "Content-Type": "application/x-www-form-urlencoded", "X-Requested-With": "fetch" },
            body: "action=logout"
        }).then(function () { window.location.reload(); });
    });

    fetch("Account.ashx", { credentials: "same-origin", cache: "no-store" })
        .then(function (res) { return res.ok ? res.json() : null; })
        .then(function (me) { if (me) apply(me); })
        .catch(function () { });
})();

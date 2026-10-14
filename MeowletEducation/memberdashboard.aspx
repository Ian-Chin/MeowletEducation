<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="memberdashboard.aspx.cs" Inherits="MeowletEducation.MemberDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Dashboard - Meowlet Education</title>
    <link rel="icon" href="favicon.ico" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="assets/css/style.css" />
    <script type="text/javascript">
        // @ts-nocheck
        // Same theme as the admin panel: dark unless this browser chose light.
        (function () {
            var theme = 'dark';
            try { theme = localStorage.getItem('meowletMemberTheme') || 'dark'; } catch (e) { }
            document.documentElement.setAttribute('data-theme', theme === 'light' ? 'light' : 'dark');
        })();
    </script>
    <style>
        /* Member dashboard, laid out from the "Meowlet Wireframe" Figma file
           (frames Member - Dashboard, Member - My Courses, Member - Course
           Catalog). The wireframe sets the layout; colours and type come from
           the site: ink, the one yellow, Aeonik for text and General Sans
           where real bold weights are needed. Page-specific classes use md-. */

        @font-face { font-family: "General Sans"; font-weight: 500; font-display: swap; src: url("assets/fonts/GeneralSans-Medium.woff2") format("woff2"); }
        @font-face { font-family: "General Sans"; font-weight: 600; font-display: swap; src: url("assets/fonts/GeneralSans-Semibold.woff2") format("woff2"); }

        /* ---------- Themes ---------- */
        :root {
            --paper: #ffffff;
            --cream: #f5f5f2;
            --beige: #ffffff;
            --beige-deep: #e9e9e5;
            --sand: #d4d4d0;
            --ink: #141413;
            --ink-soft: #2b2b29;
            --ink-mute: #5f5f5b;
            --ink-faint: #85857f;
            --accent: #f5c518;
            --accent-soft: #fdf3c4;
            --line: rgba(20, 20, 19, .1);
            --line-strong: rgba(20, 20, 19, .18);
            --shadow-sm: 0 1px 2px rgba(40, 32, 0, .06);
            --shadow: 0 6px 18px -10px rgba(40, 32, 0, .28);
            --md-display: "General Sans", var(--font);
            --md-r: 10px;
            --md-r-sm: 8px;
            --md-main-bg: #ffffff;
            --md-pill: #ecebe7;
            --md-danger: #b42318;
            --md-danger-bg: #fdecea;
            --md-danger-line: #f5c2bd;
            --md-accent-text: #7a5c00;
            color-scheme: light;
        }

        html[data-theme="dark"] {
            --paper: #171716;
            --cream: #121211;
            --beige: #111110;
            --beige-deep: #262624;
            --sand: #3a3a37;
            --ink: #f3f3f0;
            --ink-soft: #d4d4cf;
            --ink-mute: #a3a39d;
            --ink-faint: #85857f;
            --accent-soft: rgba(245, 197, 24, .14);
            --line: rgba(255, 255, 255, .08);
            --line-strong: rgba(255, 255, 255, .16);
            --shadow-sm: 0 1px 2px rgba(0, 0, 0, .5);
            --shadow: 0 8px 22px -12px rgba(0, 0, 0, .9);
            --md-main-bg: #0e0e0d;
            --md-pill: #1f1f1d;
            --md-danger: #f59a8f;
            --md-danger-bg: rgba(240, 82, 64, .12);
            --md-danger-line: rgba(240, 82, 64, .4);
            --md-accent-text: #f5c518;
            color-scheme: dark;
        }

        body {
            font-size: 14px;
            line-height: 1.5;
            color: var(--ink-soft);
            background: var(--md-main-bg);
            overflow-x: visible;
        }

        /* ---------- Buttons (rounded, as drawn in the wireframe) ---------- */
        .md-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            height: 40px;
            padding: 0 18px;
            border: 1px solid var(--line-strong);
            border-radius: var(--md-r-sm);
            background: var(--paper);
            box-shadow: var(--shadow-sm);
            font-family: var(--md-display);
            font-size: .88rem;
            font-weight: 500;
            color: var(--ink);
            white-space: nowrap;
            transition: background-color .2s ease-out, border-color .2s ease-out, color .2s ease-out, transform .15s ease-out;
        }

        .md-btn:hover { border-color: var(--ink); }
        .md-btn:active { transform: translateY(1px); }

        .md-btn--sm { height: 32px; padding: 0 14px; font-size: .8rem; }

        .md-btn--ink { border-color: var(--ink); background: var(--ink); color: var(--paper); }
        .md-btn--ink:hover { background: #000000; }
        html[data-theme="dark"] .md-btn--ink:hover { background: #ffffff; }

        .md-btn--accent { border-color: #e0b30f; background: var(--accent); color: #141413; }
        .md-btn--accent:hover { border-color: #c99d00; background: #ffd43b; }

        .md-btn--danger { color: var(--md-danger); }
        .md-btn--danger:hover { border-color: var(--md-danger-line); background: var(--md-danger-bg); }

        .md-btn:disabled { opacity: .4; pointer-events: none; }

        /* ---------- Shell ---------- */
        .md-shell { display: flex; min-height: 100vh; min-height: 100dvh; }

        /* the sidebar is black in both themes, as in the wireframe */
        .md-side {
            width: 200px;
            flex-shrink: 0;
            position: sticky;
            top: 0;
            height: 100vh;
            height: 100dvh;
            display: flex;
            flex-direction: column;
            padding: 22px 18px 18px;
            background: #0b0b0a;
            color: #d4d4cf;
        }

        .md-side__brand { display: flex; justify-content: center; margin-bottom: 40px; }
        .md-side__logo { height: 44px; width: auto; }
        .md-side__mark { display: none; height: 34px; width: 34px; border-radius: 8px; }

        .md-side nav { display: flex; flex-direction: column; gap: 10px; }

        .md-nav {
            display: flex;
            align-items: center;
            gap: 11px;
            width: 100%;
            height: 40px;
            padding: 0 14px;
            border: 0;
            border-radius: var(--md-r-sm);
            background: #262624;
            font-size: .88rem;
            color: #d4d4cf;
            text-align: left;
            white-space: nowrap;
            overflow: hidden;
            transition: background-color .15s ease-out, color .15s ease-out;
        }

        .md-nav .bi { font-size: 1rem; flex-shrink: 0; color: #85857f; }
        .md-nav:hover { background: #33332f; color: #ffffff; }

        .md-nav.is-active { background: var(--accent); color: #141413; font-family: var(--md-display); font-weight: 500; }
        .md-nav.is-active .bi { color: #141413; }

        .md-side__out {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            height: 40px;
            margin-top: auto;
            border: 1px solid rgba(255, 255, 255, .7);
            border-radius: var(--md-r-sm);
            color: #ffffff;
            font-size: .88rem;
            transition: background-color .15s ease-out, border-color .15s ease-out;
        }

        .md-side__out:hover { border-color: #f59a8f; background: rgba(240, 82, 64, .14); color: #ffffff; }

        @media (max-width: 760px) {
            .md-side { width: 68px; padding-inline: 12px; }
            .md-side__logo { display: none; }
            .md-side__mark { display: block; }
            .md-nav,
            .md-side__out { justify-content: center; padding: 0; }
            .md-nav > span,
            .md-side__out > span { display: none; }
        }

        .md-main { flex: 1; min-width: 0; }

        /* ---------- Top bar ---------- */
        .md-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            min-height: 76px;
            padding: 14px clamp(16px, 3vw, 36px);
        }

        /* My Courses and Course Catalog draw a rule under the bar; the dashboard doesn't */
        .md-main:not([data-pane="pane-overview"]) .md-top { border-bottom: 1px solid var(--line-strong); }

        .md-title {
            margin: 0;
            font-family: var(--md-display);
            font-size: 1.35rem;
            font-weight: 600;
            letter-spacing: -.02em;
            line-height: 1.2;
            color: var(--ink);
        }

        .md-title em { font-style: normal; color: var(--md-accent-text); }

        .md-top__tools { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }

        .md-search { position: relative; display: block; }
        .md-search .bi { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--ink-faint); pointer-events: none; }
        .md-search .md-input { padding-left: 38px; }

        /* the grey pill in the wireframe */
        .md-global { width: 290px; }
        .md-global .md-input { border-color: transparent; border-radius: 999px; background: var(--md-pill); }
        .md-global .md-input:hover { border-color: var(--line-strong); }
        @media (max-width: 1040px) { .md-global { display: none; } }

        .md-icon-btn {
            display: inline-grid;
            place-items: center;
            width: 42px;
            height: 40px;
            border: 1px solid var(--line-strong);
            border-radius: var(--md-r-sm);
            background: var(--paper);
            box-shadow: var(--shadow-sm);
            color: var(--ink);
        }

        .md-icon-btn:hover { border-color: var(--ink); }

        /* ---------- Profile menu ---------- */
        .md-menu { position: relative; }

        .md-menu__btn {
            display: flex;
            align-items: center;
            gap: 9px;
            height: 40px;
            min-width: 140px;
            padding: 0 12px 0 6px;
            border: 1px solid var(--line-strong);
            border-radius: var(--md-r-sm);
            background: var(--paper);
            box-shadow: var(--shadow-sm);
            font-family: var(--md-display);
            font-weight: 500;
            color: var(--ink);
            white-space: nowrap;
        }

        .md-menu__btn .bi-chevron-down { margin-left: auto; font-size: 11px; color: var(--ink-faint); }

        .md-mono {
            display: inline-grid;
            place-items: center;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: var(--accent);
            font-family: var(--md-display);
            font-size: .8rem;
            font-weight: 600;
            color: #141413;
        }

        .md-menu__pop {
            position: absolute;
            top: 100%;
            right: 0;
            z-index: 20;
            min-width: 210px;
            padding-top: 6px;
            visibility: hidden;
            opacity: 0;
            transition: opacity .15s ease-out, visibility .15s;
        }

        .md-menu:hover .md-menu__pop,
        .md-menu:focus-within .md-menu__pop { visibility: visible; opacity: 1; }

        .md-menu__card { padding: 6px; border: 1px solid var(--line); border-radius: var(--md-r-sm); background: var(--paper); box-shadow: var(--shadow); }
        .md-menu__who { padding: 8px 10px 10px; margin-bottom: 4px; border-bottom: 1px solid var(--line); }
        .md-menu__who strong { display: block; font-family: var(--md-display); font-weight: 500; color: var(--ink); }
        .md-menu__who span { font-size: .8rem; color: var(--ink-faint); }

        .md-menu__item {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            padding: 8px 10px;
            border: 0;
            border-radius: 6px;
            background: transparent;
            color: var(--ink-soft);
            text-align: left;
        }

        .md-menu__item:hover { background: var(--cream); color: var(--ink); }
        .md-menu__item--danger { color: var(--md-danger); }
        .md-menu__item--danger:hover { background: var(--md-danger-bg); color: var(--md-danger); }

        /* ---------- Content area ---------- */
        .md-body { padding: 22px clamp(16px, 3vw, 36px) 96px; }

        .md-flash { margin: 0 0 18px; padding: 10px 14px; border: 1px solid var(--line); border-radius: var(--md-r-sm); background: var(--paper); color: var(--ink); }
        .md-flash--error { border-color: var(--md-danger-line); background: var(--md-danger-bg); color: var(--md-danger); }

        .md-pane { display: none; }
        .md-pane.is-active { display: block; }

        .md-card {
            border: 1px solid var(--line);
            border-radius: var(--md-r);
            background: var(--paper);
            box-shadow: var(--shadow);
        }

        /* ---------- Action bar: buttons left, filter right ---------- */
        .md-bar {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }

        .md-bar__group { display: flex; flex-wrap: wrap; align-items: center; gap: 12px; }
        .md-bar .md-btn { min-width: 160px; }

        /* segmented filter: the black thumb in the wireframe */
        .md-switch {
            display: inline-flex;
            min-width: 280px;
            height: 40px;
            padding: 4px;
            border: 1px solid var(--line-strong);
            border-radius: var(--md-r-sm);
            background: var(--paper);
            box-shadow: var(--shadow-sm);
        }

        .md-switch button {
            flex: 1;
            padding: 0 12px;
            border: 0;
            border-radius: 6px;
            background: transparent;
            font-size: .82rem;
            color: var(--ink-mute);
            white-space: nowrap;
        }

        .md-switch button:hover { color: var(--ink); }
        .md-switch button.is-on { background: var(--ink); color: var(--paper); font-family: var(--md-display); font-weight: 500; }

        /* ---------- Stat cards ---------- */
        .md-stats {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 20px;
            margin-bottom: 22px;
        }

        .md-stat { padding: 16px 20px 18px; }
        .md-stat__label { margin: 0; font-size: .82rem; color: var(--ink-mute); }

        .md-stat__value {
            margin: 10px 0 0;
            font-family: var(--md-display);
            font-size: 2.1rem;
            font-weight: 500;
            line-height: 1;
            letter-spacing: -.03em;
            color: var(--ink);
            font-variant-numeric: tabular-nums;
        }

        /* the count you can act on gets the yellow underline */
        .md-stat--progress .md-stat__value { display: inline-block; box-shadow: inset 0 -.3em 0 var(--accent-soft); }

        @media (max-width: 720px) { .md-stats { grid-template-columns: minmax(0, 1fr); gap: 12px; } }

        /* ---------- My Courses + My Profile ---------- */
        .md-pair {
            display: grid;
            grid-template-columns: minmax(0, 2.15fr) minmax(260px, 1fr);
            gap: 20px;
            align-items: stretch;
        }

        @media (max-width: 1000px) { .md-pair { grid-template-columns: minmax(0, 1fr); } }

        .md-panel { padding: 18px 20px 20px; }
        .md-panel__title { margin: 0 0 14px; font-family: var(--md-display); font-size: 1.08rem; font-weight: 500; color: var(--ink); }

        /* course rows: one shadowed strip per course, a button at the end */
        .md-rows { display: flex; flex-direction: column; gap: 10px; }

        .md-row {
            display: flex;
            align-items: center;
            gap: 16px;
            min-height: 52px;
            padding: 9px 10px 9px 16px;
            border: 1px solid var(--line);
            border-radius: var(--md-r-sm);
            background: var(--paper);
            box-shadow: var(--shadow-sm), 0 3px 8px -6px rgba(0, 0, 0, .25);
            transition: border-color .2s ease-out;
        }

        .md-row:hover { border-color: var(--line-strong); }
        .md-row[hidden] { display: none; }

        .md-row__main { flex: 1; min-width: 0; }
        .md-row__title { display: block; font-family: var(--md-display); font-weight: 500; color: var(--ink); line-height: 1.35; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .md-row__meta { display: block; font-size: .78rem; color: var(--ink-faint); }
        .md-row__meta b { font-weight: 400; color: var(--md-accent-text); font-variant-numeric: tabular-nums; }
        [data-state="completed"] .md-row__meta b { color: var(--ink); }

        .md-row__tutor { color: var(--ink-mute); }
        .md-row__btns { display: flex; gap: 8px; flex-shrink: 0; }
        .md-row__btns .md-btn { min-width: 66px; }

        .md-code { font-family: var(--mono); font-size: .74rem; color: var(--ink-faint); }

        .md-empty-block { padding: 28px 16px; text-align: center; color: var(--ink-mute); }
        .md-empty-block strong { display: block; margin-bottom: 2px; font-family: var(--md-display); font-weight: 500; color: var(--ink); }
        .md-empty-block[hidden] { display: none; }
        .md-empty-block__cat { display: block; width: 96px; height: auto; margin: 0 auto 10px; }

        /* profile card: centred picture and name, label/value rows, black button */
        .md-profile { display: flex; flex-direction: column; }
        .md-profile .md-panel__title { margin-bottom: 18px; }

        .md-avatar {
            display: grid;
            place-items: center;
            width: 92px;
            height: 92px;
            margin: 0 auto;
            border-radius: 50%;
            background: var(--accent);
            font-family: var(--md-display);
            font-size: 2.1rem;
            font-weight: 600;
            color: #141413;
        }

        .md-profile__name { margin: 12px 0 14px; font-family: var(--md-display); font-weight: 500; color: var(--ink); text-align: center; }
        .md-profile__role { display: block; font-family: var(--font); font-size: .78rem; font-weight: 400; color: var(--ink-faint); }

        .md-facts { margin: 0 0 18px; padding: 0; }

        .md-facts div {
            display: grid;
            grid-template-columns: 96px minmax(0, 1fr);
            gap: 10px;
            padding: 5px 0;
            font-size: .82rem;
        }

        .md-facts dt { color: var(--ink-faint); }
        .md-facts dd { margin: 0; color: var(--ink); overflow-wrap: anywhere; }

        .md-profile .md-btn { width: 100%; margin-top: auto; }

        /* ---------- My Courses pane ---------- */
        .md-courses-bar .md-search { width: 260px; }
        @media (max-width: 860px) { .md-courses-bar .md-search { width: 100%; } }

        .md-list { padding: 16px; }

        /* ---------- Catalog pane ---------- */
        .md-find { display: flex; gap: 10px; margin-bottom: 14px; }
        .md-find .md-search { flex: 1; max-width: 420px; }
        .md-find .md-btn { min-width: 64px; }

        .md-pager { display: flex; align-items: center; gap: 14px; margin-top: 16px; font-size: .82rem; color: var(--ink-faint); font-variant-numeric: tabular-nums; }
        .md-pager .md-btn { width: 40px; padding: 0; }
        .md-pager[hidden] { display: none; }

        @media (max-width: 620px) {
            .md-row { flex-wrap: wrap; }
            .md-row__btns { width: 100%; }
            .md-row__btns .md-btn { flex: 1; }
        }

        /* ---------- Forms ---------- */
        .md-input {
            width: 100%;
            height: 40px;
            padding: 0 12px;
            border: 1px solid var(--line-strong);
            border-radius: var(--md-r-sm);
            background: var(--paper);
            color: var(--ink);
            font: inherit;
            transition: border-color .15s ease-out, box-shadow .15s ease-out;
        }

        .md-input::placeholder { color: var(--ink-faint); }
        .md-input:hover { border-color: var(--sand); }
        .md-input:focus { border-color: var(--ink); outline: none; box-shadow: 0 0 0 3px var(--accent-soft); }

        /* ---------- Floating theme switch (bottom right in the wireframe) ---------- */
        .md-theme {
            position: fixed;
            right: 24px;
            bottom: 24px;
            z-index: 30;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            height: 46px;
            padding: 5px 16px 5px 5px;
            border: 1px solid var(--line-strong);
            border-radius: var(--md-r);
            background: var(--ink);
            box-shadow: var(--shadow);
            font-family: var(--md-display);
            font-size: .82rem;
            font-weight: 500;
            color: var(--paper);
        }

        .md-theme__knob {
            display: grid;
            place-items: center;
            width: 36px;
            height: 34px;
            border-radius: 7px;
            background: var(--paper);
            color: var(--ink);
            transition: transform .25s var(--ease);
        }

        .md-theme:hover .md-theme__knob { transform: rotate(-12deg); }

        @media (prefers-reduced-motion: reduce) {
            .md-menu__pop,
            .md-nav,
            .md-btn,
            .md-theme__knob { transition: none; }
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnPane" runat="server" Value="pane-overview" />

        <div class="md-shell">

            <!-- ================= SIDEBAR ================= -->
            <aside class="md-side">
                <a class="md-side__brand" href="index.html" title="Open the public site">
                    <img class="md-side__logo" src="assets/img/meowlet-logo-dark.png" alt="Meowlet Education" />
                    <img class="md-side__mark" src="assets/img/meowlet-mark.png" alt="Meowlet Education" />
                </a>

                <nav aria-label="Member sections">
                    <button type="button" class="md-nav is-active" data-pane="pane-overview">
                        <i class="bi bi-grid-1x2" aria-hidden="true"></i><span>Dashboard</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-courses">
                        <i class="bi bi-journal-bookmark" aria-hidden="true"></i><span>My Courses</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-catalog">
                        <i class="bi bi-book" aria-hidden="true"></i><span>Course Catalog</span>
                    </button>
                    <a class="md-nav" href="Profile.aspx">
                        <i class="bi bi-person" aria-hidden="true"></i><span>My Profile</span>
                    </a>
                    <a class="md-nav" href="index.html">
                        <i class="bi bi-house" aria-hidden="true"></i><span>Public Site</span>
                    </a>
                </nav>

                <asp:LinkButton ID="lnkSideSignOut" runat="server" CssClass="md-side__out"
                    OnClick="lnkLogout_Click"
                    OnClientClick="return confirm('Sign out of Meowlet?');">
                    <i class="bi bi-box-arrow-right" aria-hidden="true"></i><span>Sign Out</span>
                </asp:LinkButton>
            </aside>

            <!-- ================= MAIN ================= -->
            <main class="md-main" id="main" data-pane="pane-overview">

                <header class="md-top">
                    <h1 class="md-title" id="pageTitle">Welcome Back, <em><asp:Literal ID="litWelcomeName" runat="server">Member</asp:Literal></em></h1>
                    <div class="md-top__tools">
                        <label class="md-search md-global">
                            <i class="bi bi-search" aria-hidden="true"></i>
                            <input type="search" id="globalSearch" class="md-input" placeholder="Search courses" aria-label="Search the course catalog" />
                        </label>
                        <a class="md-icon-btn" href="index.html" title="Public site" aria-label="Public site">
                            <i class="bi bi-house" aria-hidden="true"></i>
                        </a>
                        <div class="md-menu">
                            <button type="button" class="md-menu__btn" aria-haspopup="true">
                                <span class="md-mono" aria-hidden="true"><asp:Literal ID="litMenuAvatar" runat="server">?</asp:Literal></span>
                                <asp:Literal ID="litMemberName" runat="server">Member</asp:Literal>
                                <i class="bi bi-chevron-down" aria-hidden="true"></i>
                            </button>
                            <div class="md-menu__pop">
                                <div class="md-menu__card">
                                    <div class="md-menu__who">
                                        <strong><asp:Literal ID="litMenuName" runat="server">Member</asp:Literal></strong>
                                        <span><asp:Literal ID="litMenuEmail" runat="server" /></span>
                                    </div>
                                    <button type="button" class="md-menu__item" data-go="pane-courses"><i class="bi bi-journal-bookmark" aria-hidden="true"></i>My courses</button>
                                    <a class="md-menu__item" href="Profile.aspx"><i class="bi bi-person" aria-hidden="true"></i>Edit profile</a>
                                    <asp:LinkButton ID="lnkLogout" runat="server" CssClass="md-menu__item md-menu__item--danger"
                                        OnClick="lnkLogout_Click"
                                        OnClientClick="return confirm('Sign out of Meowlet?');">
                                        <i class="bi bi-box-arrow-right" aria-hidden="true"></i>Sign out
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </header>

                <div class="md-body">
                    <asp:Literal ID="litFlash" runat="server" EnableViewState="false" />

                    <!-- ---------- DASHBOARD (frame: Member - Dashboard) ---------- -->
                    <section id="pane-overview" class="md-pane is-active" aria-labelledby="pageTitle">

                        <div class="md-bar">
                            <div class="md-bar__group">
                                <button type="button" class="md-btn" data-go="pane-catalog"><i class="bi bi-search" aria-hidden="true"></i>Browse courses</button>
                                <button type="button" class="md-btn" data-continue="1"><i class="bi bi-play-fill" aria-hidden="true"></i>Continue learning</button>
                            </div>
                            <div class="md-switch" role="group" aria-label="Show courses" id="overviewFilter">
                                <button type="button" class="is-on" data-filter="" aria-pressed="true">All</button>
                                <button type="button" data-filter="progress" aria-pressed="false">In progress</button>
                                <button type="button" data-filter="completed" aria-pressed="false">Completed</button>
                            </div>
                        </div>

                        <div class="md-stats">
                            <div class="md-card md-stat">
                                <p class="md-stat__label">Enrolled Courses</p>
                                <p class="md-stat__value"><asp:Literal ID="litStatEnrolled" runat="server">0</asp:Literal></p>
                            </div>
                            <div class="md-card md-stat">
                                <p class="md-stat__label">Completed</p>
                                <p class="md-stat__value"><asp:Literal ID="litStatCompleted" runat="server">0</asp:Literal></p>
                            </div>
                            <div class="md-card md-stat md-stat--progress">
                                <p class="md-stat__label">In Progress</p>
                                <p class="md-stat__value"><asp:Literal ID="litStatInProgress" runat="server">0</asp:Literal></p>
                            </div>
                        </div>

                        <div class="md-pair">
                            <div class="md-card md-panel">
                                <h2 class="md-panel__title">My Courses</h2>
                                <div class="md-rows" id="overviewRows">
                                    <asp:Repeater ID="rptRecentCourses" runat="server">
                                        <ItemTemplate>
                                            <div class="md-row" data-state="<%# Eval("State") %>">
                                                <div class="md-row__main">
                                                    <span class="md-row__title"><%# Html(Eval("Title")) %></span>
                                                    <span class="md-row__meta"><span class="md-code"><%# Html(Eval("CourseCode")) %></span> · Progress: <b><%# Eval("Percent") %>%</b></span>
                                                </div>
                                                <span class="md-row__btns">
                                                    <a class="md-btn md-btn--sm" href="course.aspx?id=<%# Eval("CourseId") %>">
                                                        <%# (string)Eval("State") == "completed" ? "Review" : "Continue" %>
                                                    </a>
                                                </span>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <p class="md-empty-block" id="overviewNoMatch" hidden="hidden">No courses in this group yet.</p>
                                </div>
                                <asp:PlaceHolder ID="phNoRecent" runat="server" Visible="false">
                                    <div class="md-empty-block">
                                        <img class="md-empty-block__cat" src="assets/img/cat-reach.webp" alt="" />
                                        <strong>You haven't enrolled in a course yet</strong>
                                        Find one in the catalog to get started.
                                    </div>
                                </asp:PlaceHolder>
                            </div>

                            <div class="md-card md-panel md-profile">
                                <h2 class="md-panel__title">My Profile</h2>
                                <span class="md-avatar" aria-hidden="true"><asp:Literal ID="litAvatar" runat="server">?</asp:Literal></span>
                                <p class="md-profile__name"><asp:Literal ID="litProfileName" runat="server" /><span class="md-profile__role"><asp:Literal ID="litRole" runat="server">Student</asp:Literal></span></p>
                                <dl class="md-facts">
                                    <div><dt>Email</dt><dd><asp:Literal ID="litProfileEmail" runat="server" /></dd></div>
                                    <div><dt>Age range</dt><dd><asp:Literal ID="litProfileAge" runat="server">Not set</asp:Literal></dd></div>
                                    <div><dt>Experience</dt><dd><asp:Literal ID="litProfileLevel" runat="server">Not set</asp:Literal></dd></div>
                                    <div><dt>Member since</dt><dd><asp:Literal ID="litProfileJoined" runat="server" /></dd></div>
                                </dl>
                                <a class="md-btn md-btn--ink" href="Profile.aspx">Edit Profile</a>
                            </div>
                        </div>
                    </section>

                    <!-- ---------- MY COURSES (frame: Member - My Courses) ---------- -->
                    <section id="pane-courses" class="md-pane" aria-labelledby="pageTitle">
                        <div class="md-bar md-courses-bar">
                            <div class="md-switch" role="group" aria-label="Show courses" id="courseFilter">
                                <button type="button" class="is-on" data-filter="" aria-pressed="true">All</button>
                                <button type="button" data-filter="progress" aria-pressed="false">In progress</button>
                                <button type="button" data-filter="completed" aria-pressed="false">Completed</button>
                            </div>
                            <div class="md-bar__group">
                                <label class="md-search">
                                    <i class="bi bi-search" aria-hidden="true"></i>
                                    <input type="search" id="courseSearch" class="md-input" placeholder="Search my courses" aria-label="Search my courses" />
                                </label>
                                <button type="button" class="md-btn md-btn--accent" data-continue="1"><i class="bi bi-play-fill" aria-hidden="true"></i>Continue learning</button>
                                <button type="button" class="md-btn md-btn--ink" data-go="pane-catalog">Browse catalog</button>
                            </div>
                        </div>

                        <div class="md-card md-list">
                            <div class="md-rows" id="courseRows">
                                <asp:Repeater ID="rptMyCourses" runat="server" OnItemCommand="rptMyCourses_ItemCommand">
                                    <ItemTemplate>
                                        <div class="md-row" data-state="<%# Eval("State") %>" data-text="<%# Attr(Eval("Title")) %> <%# Attr(Eval("CourseCode")) %>">
                                            <div class="md-row__main">
                                                <span class="md-row__title"><%# Html(Eval("Title")) %></span>
                                                <span class="md-row__meta">
                                                    Progress: <b><%# Eval("Percent") %>%</b> · <%# Eval("DoneLessons") %> of <%# Eval("TotalLessons") %> lessons · <span class="md-code"><%# Html(Eval("CourseCode")) %></span>
                                                </span>
                                            </div>
                                            <span class="md-row__btns">
                                                <a class="md-btn md-btn--sm" href="course.aspx?id=<%# Eval("CourseId") %>">
                                                    <%# (string)Eval("State") == "completed" ? "Review" : "Open" %>
                                                </a>
                                                <asp:LinkButton runat="server" CommandName="Drop" CommandArgument='<%# Eval("CourseId") %>'
                                                    CssClass="md-btn md-btn--sm md-btn--danger" Text="Drop"
                                                    OnClientClick="return confirm('Drop this course? Your lesson progress is kept if you enrol again.');" />
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <p class="md-empty-block" id="courseNoMatch" hidden="hidden">No courses match.</p>
                            </div>
                            <asp:PlaceHolder ID="phNoCourses" runat="server" Visible="false">
                                <div class="md-empty-block">
                                    <img class="md-empty-block__cat" src="assets/img/cat-reach.webp" alt="" />
                                    <strong>No courses yet</strong>
                                    Courses you enrol in from the catalog show up here.
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </section>

                    <!-- ---------- COURSE CATALOG (frame: Member - Course Catalog) ---------- -->
                    <section id="pane-catalog" class="md-pane" aria-labelledby="pageTitle">
                        <div class="md-card md-list">
                            <div class="md-find">
                                <label class="md-search">
                                    <i class="bi bi-search" aria-hidden="true"></i>
                                    <input type="search" id="catalogSearch" class="md-input" placeholder="Search courses..." aria-label="Search courses" />
                                </label>
                                <button type="button" class="md-btn" id="catalogGo">Go</button>
                            </div>

                            <div class="md-rows" id="catalogRows">
                                <asp:Repeater ID="rptCatalog" runat="server" OnItemCommand="rptCatalog_ItemCommand">
                                    <ItemTemplate>
                                        <div class="md-row md-course"
                                            data-text="<%# Attr(Eval("Title")) %> <%# Attr(Eval("CourseCode")) %> <%# Attr(Eval("TutorName")) %> <%# Attr(Eval("Category")) %> <%# Attr(Eval("Level")) %>">
                                            <div class="md-row__main">
                                                <span class="md-row__title"><%# Html(Eval("Title")) %> <span class="md-row__tutor">- <%# Html(Eval("TutorName")) %></span></span>
                                                <span class="md-row__meta"><span class="md-code"><%# Html(Eval("CourseCode")) %></span> · <%# Html(Eval("Category")) %> · <%# Html(Eval("Level")) %> · <%# Eval("Lessons") %> lessons</span>
                                            </div>
                                            <span class="md-row__btns">
                                                <a class="md-btn md-btn--sm" href="course.aspx?id=<%# Eval("CourseId") %>">View</a>
                                                <asp:LinkButton runat="server" CommandName="Enrol" CommandArgument='<%# Eval("CourseId") %>'
                                                    CssClass="md-btn md-btn--sm md-btn--accent" Text="Enrol" />
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <p class="md-empty-block" id="catalogNoMatch" hidden="hidden"><strong>No matches</strong>Try another search.</p>
                            </div>
                            <asp:PlaceHolder ID="phNoCatalog" runat="server" Visible="false">
                                <div class="md-empty-block">
                                    <img class="md-empty-block__cat" src="assets/img/cat-reach.webp" alt="" />
                                    <strong>You're enrolled in every course</strong>
                                    New courses appear here once they're published.
                                </div>
                            </asp:PlaceHolder>

                            <div class="md-pager" id="catalogPager" hidden="hidden">
                                <button type="button" class="md-btn" id="catalogPrev" aria-label="Previous page"><i class="bi bi-chevron-left" aria-hidden="true"></i></button>
                                <span id="catalogPage" aria-live="polite">Page 1 of 1</span>
                                <button type="button" class="md-btn" id="catalogNext" aria-label="Next page"><i class="bi bi-chevron-right" aria-hidden="true"></i></button>
                            </div>
                        </div>
                    </section>
                </div>
            </main>
        </div>

        <button type="button" class="md-theme" id="themeToggle" aria-label="Switch theme">
            <span class="md-theme__knob"><i class="bi bi-moon-stars" aria-hidden="true"></i></span>
            <span id="themeLabel">Dark</span>
        </button>

        <%-- server data for the script below; arrives JS-encoded --%>
        <script type="application/json" id="memberData">{"name":"<asp:Literal ID="litMemberNameJs" runat="server">Member</asp:Literal>"}</script>

        <script type="text/javascript">
            // @ts-nocheck
            (function () {
                var memberData = JSON.parse(document.getElementById('memberData').textContent);

                var titles = {
                    'pane-courses': 'My Courses',
                    'pane-catalog': 'Course Catalog'
                };

                var hdnPane = document.getElementById('<%= hdnPane.ClientID %>');
                var main = document.getElementById('main');
                var navItems = document.querySelectorAll('.md-nav[data-pane]');
                var panes = document.querySelectorAll('.md-pane');
                var title = document.getElementById('pageTitle');

                // ---- panes (the choice survives postbacks via hdnPane) ----
                function show(paneId, keepScroll) {
                    if (!document.getElementById(paneId)) { paneId = 'pane-overview'; }
                    for (var i = 0; i < panes.length; i++) {
                        panes[i].className = panes[i].id === paneId ? 'md-pane is-active' : 'md-pane';
                    }
                    for (var j = 0; j < navItems.length; j++) {
                        var on = navItems[j].getAttribute('data-pane') === paneId;
                        navItems[j].className = on ? 'md-nav is-active' : 'md-nav';
                        if (on) { navItems[j].setAttribute('aria-current', 'page'); } else { navItems[j].removeAttribute('aria-current'); }
                    }
                    if (paneId === 'pane-overview') {
                        var em = document.createElement('em');
                        em.textContent = memberData.name;
                        title.textContent = 'Welcome Back, ';
                        title.appendChild(em);
                    } else {
                        title.textContent = titles[paneId];
                    }
                    main.setAttribute('data-pane', paneId);
                    var flash = document.querySelector('.md-body > .md-flash');
                    if (flash && !keepScroll) { flash.parentNode.removeChild(flash); }
                    hdnPane.value = paneId;
                    if (!keepScroll) { window.scrollTo(0, 0); }
                }

                for (var k = 0; k < navItems.length; k++) {
                    navItems[k].onclick = function () { show(this.getAttribute('data-pane')); };
                }

                var jumps = document.querySelectorAll('[data-go]');
                for (var g = 0; g < jumps.length; g++) {
                    jumps[g].onclick = function () {
                        show(this.getAttribute('data-go'));
                        if (document.activeElement && document.activeElement.blur) { document.activeElement.blur(); }
                    };
                }

                // "Continue learning" opens the newest course that isn't finished,
                // or the catalog when there is none.
                var resume = document.querySelector('#courseRows .md-row[data-state="progress"] a.md-btn');
                var continues = document.querySelectorAll('[data-continue]');
                for (var r = 0; r < continues.length; r++) {
                    continues[r].onclick = function () {
                        if (resume) { window.location.href = resume.getAttribute('href'); } else { show('pane-catalog'); }
                    };
                }

                show(hdnPane.value || 'pane-overview', true);

                // ---- theme (floating toggle) ----
                var themeToggle = document.getElementById('themeToggle');

                function syncTheme() {
                    var dark = document.documentElement.getAttribute('data-theme') === 'dark';
                    themeToggle.querySelector('.bi').className = dark ? 'bi bi-moon-stars' : 'bi bi-sun';
                    document.getElementById('themeLabel').textContent = dark ? 'Dark' : 'Light';
                    themeToggle.setAttribute('aria-label', dark ? 'Switch to light theme' : 'Switch to dark theme');
                }

                themeToggle.onclick = function () {
                    var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                    document.documentElement.setAttribute('data-theme', next);
                    try { localStorage.setItem('meowletMemberTheme', next); } catch (e) { }
                    syncTheme();
                };

                syncTheme();

                // ---- course filters: All / In progress / Completed (+ text search on My Courses) ----
                function wireFilter(switchId, rowsId, noMatchId, searchId) {
                    var buttons = document.querySelectorAll('#' + switchId + ' button');
                    var rows = document.querySelectorAll('#' + rowsId + ' .md-row');
                    var noMatch = document.getElementById(noMatchId);
                    var search = searchId ? document.getElementById(searchId) : null;
                    var filter = '';

                    function apply() {
                        var q = search ? search.value.trim().toLowerCase() : '';
                        var shown = 0;
                        for (var i = 0; i < rows.length; i++) {
                            var match = (!filter || rows[i].getAttribute('data-state') === filter) &&
                                (!q || (rows[i].getAttribute('data-text') || '').toLowerCase().indexOf(q) !== -1);
                            rows[i].hidden = !match;
                            if (match) { shown++; }
                        }
                        for (var b = 0; b < buttons.length; b++) {
                            var on = buttons[b].getAttribute('data-filter') === filter;
                            buttons[b].className = on ? 'is-on' : '';
                            buttons[b].setAttribute('aria-pressed', on ? 'true' : 'false');
                        }
                        noMatch.hidden = !(rows.length > 0 && shown === 0);
                    }

                    for (var b = 0; b < buttons.length; b++) {
                        buttons[b].onclick = function () { filter = this.getAttribute('data-filter'); apply(); };
                    }
                    if (search) { search.oninput = apply; }
                }

                wireFilter('overviewFilter', 'overviewRows', 'overviewNoMatch');
                wireFilter('courseFilter', 'courseRows', 'courseNoMatch', 'courseSearch');

                // ---- catalog: search with Go, seven courses per page ----
                var PAGE_SIZE = 7;
                var cards = Array.prototype.slice.call(document.querySelectorAll('#catalogRows .md-course'));
                var catalogSearch = document.getElementById('catalogSearch');
                var catalogNoMatch = document.getElementById('catalogNoMatch');
                var pager = document.getElementById('catalogPager');
                var prev = document.getElementById('catalogPrev');
                var next = document.getElementById('catalogNext');
                var pageLabel = document.getElementById('catalogPage');
                var page = 1;

                function renderCatalog() {
                    var q = catalogSearch.value.trim().toLowerCase();
                    var matches = cards.filter(function (card) {
                        return !q || card.getAttribute('data-text').toLowerCase().indexOf(q) !== -1;
                    });
                    var pages = Math.max(1, Math.ceil(matches.length / PAGE_SIZE));
                    if (page > pages) { page = pages; }

                    for (var i = 0; i < cards.length; i++) { cards[i].hidden = true; }
                    for (var m = (page - 1) * PAGE_SIZE; m < Math.min(matches.length, page * PAGE_SIZE); m++) {
                        matches[m].hidden = false;
                    }

                    catalogNoMatch.hidden = !(cards.length > 0 && matches.length === 0);
                    pager.hidden = cards.length === 0;
                    pageLabel.textContent = 'Page ' + page + ' of ' + pages;
                    prev.disabled = page <= 1;
                    next.disabled = page >= pages;
                }

                function searchCatalog() { page = 1; renderCatalog(); }

                document.getElementById('catalogGo').onclick = searchCatalog;
                catalogSearch.oninput = searchCatalog;
                prev.onclick = function () { page--; renderCatalog(); };
                next.onclick = function () { page++; renderCatalog(); };
                renderCatalog();

                // Enter in a search box must not submit the form.
                var searchBoxes = document.querySelectorAll('.md-search input');
                for (var s = 0; s < searchBoxes.length; s++) {
                    searchBoxes[s].onkeydown = function (e) {
                        if (e.key === 'Enter') { e.preventDefault(); }
                    };
                }

                // ---- top search jumps to the catalog ----
                var globalSearch = document.getElementById('globalSearch');

                globalSearch.onkeydown = function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        catalogSearch.value = globalSearch.value;
                        show('pane-catalog');
                        searchCatalog();
                        catalogSearch.focus();
                    }
                };
            })();
        </script>
    </form>
</body>
</html>

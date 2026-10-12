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
        /* Member dashboard. Shares the admin panel's look: colours, type,
           buttons (.btn) and tags (.tag) come from style.css, and the dark
           theme swaps the same tokens. Everything page-specific is prefixed md-. */

        /* ---------- Themes ---------- */
        :root {
            --md-danger: #a3361f;
            --md-danger-bg: #fbeae4;
            --md-danger-line: #ecc4b8;
            --md-accent-text: #8d5122;
            color-scheme: light;
        }

        html[data-theme="dark"] {
            --paper: #1d1812;
            --cream: #15110c;
            --beige: #100c08;
            --beige-deep: #241d16;
            --sand: #4d4032;
            --ink: #f4ecdf;
            --ink-soft: #ddd1bf;
            --ink-mute: #ab9d89;
            --ink-faint: #928573;
            --accent: #d68a4e;
            --accent-soft: rgba(214, 138, 78, .18);
            --line: rgba(244, 236, 223, .09);
            --line-strong: rgba(244, 236, 223, .18);
            --shadow-sm: 0 1px 2px rgba(0, 0, 0, .45);
            --shadow: 0 12px 32px -16px rgba(0, 0, 0, .8);
            --md-danger: #f0a08c;
            --md-danger-bg: rgba(232, 120, 96, .12);
            --md-danger-line: rgba(232, 120, 96, .4);
            --md-accent-text: #eab087;
            color-scheme: dark;
        }

        html[data-theme="dark"] .btn--primary:hover { background: #ffffff; }
        html[data-theme="dark"] .md-side__logo--light,
        html[data-theme="light"] .md-side__logo--dark { display: none; }
        .tag--accent { color: var(--md-accent-text); }

        body {
            font-size: 14px;
            line-height: 1.5;
            color: var(--ink-soft);
            background: var(--cream);
            overflow-x: visible;
        }

        /* ---------- Shell ---------- */
        .md-shell { display: flex; min-height: 100vh; }

        .md-side {
            width: 228px;
            flex-shrink: 0;
            position: sticky;
            top: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 20px 14px 14px;
            background: var(--beige);
            border-right: 1px solid var(--line);
        }

        .md-side__brand {
            display: flex;
            align-items: center;
            height: 36px;
            padding: 0 8px;
            margin-bottom: 22px;
        }

        .md-side__logo { height: 40px; width: auto; }
        .md-side__mark { display: none; height: 32px; width: 32px; border-radius: 8px; }

        .md-side__group {
            margin: 18px 10px 6px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: var(--ink-faint);
        }

        .md-side__group:first-of-type { margin-top: 0; }

        .md-nav {
            display: flex;
            align-items: center;
            gap: 11px;
            width: 100%;
            padding: 8px 10px;
            margin-bottom: 2px;
            border: 0;
            border-radius: var(--radius-sm);
            background: transparent;
            font-size: .9rem;
            color: var(--ink-mute);
            text-align: left;
            white-space: nowrap;
            overflow: hidden;
            transition: background-color .15s ease-out, color .15s ease-out;
        }

        .md-nav .bi { font-size: 1rem; flex-shrink: 0; }
        .md-nav:hover { background: var(--beige-deep); color: var(--ink); }

        .md-nav.is-active {
            background: var(--paper);
            color: var(--ink);
            font-weight: 600;
            box-shadow: var(--shadow-sm);
        }

        .md-nav.is-active .bi { color: var(--accent); }

        .md-side__foot {
            margin-top: auto;
            padding-top: 12px;
            border-top: 1px solid var(--line);
        }

        .md-nav--danger { color: var(--md-danger); }
        .md-nav--danger:hover { background: var(--md-danger-bg); color: var(--md-danger); }

        @media (max-width: 760px) {
            .md-side { width: 68px; padding-inline: 10px; }
            .md-side__brand { justify-content: center; padding: 0; }
            .md-side__logo { display: none; }
            .md-side__mark { display: block; }
            .md-side__group { height: 1px; margin: 12px 6px; font-size: 0; background: var(--line); }
            .md-nav { justify-content: center; padding-inline: 0; }
            .md-nav > span { display: none; }
        }

        .md-main {
            flex: 1;
            min-width: 0;
            padding: 24px clamp(16px, 3vw, 36px) 88px;
        }

        /* ---------- Top bar ---------- */
        .md-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
            margin-bottom: 22px;
        }

        .md-title {
            margin: 0;
            font-size: 1.6rem;
            font-weight: 600;
            line-height: 1.2;
            letter-spacing: -.01em;
            color: var(--ink);
        }

        .md-sub { margin: 4px 0 0; color: var(--ink-mute); }

        .md-top__tools { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }

        .md-search { position: relative; display: block; }
        .md-search .bi {
            position: absolute;
            left: 11px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--ink-faint);
            pointer-events: none;
        }
        .md-search .md-input { padding-left: 32px; }

        .md-global { width: 300px; }

        @media (max-width: 1040px) { .md-global { display: none; } }

        .md-icon-btn {
            display: inline-grid;
            place-items: center;
            width: 38px;
            height: 38px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink);
        }

        .md-icon-btn:hover { border-color: var(--sand); }

        /* ---------- Profile menu ---------- */
        .md-menu { position: relative; }

        .md-menu__btn {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink);
            font-weight: 600;
            white-space: nowrap;
        }

        .md-menu__btn .bi-chevron-down { font-size: 11px; color: var(--ink-faint); }

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

        .md-menu__card {
            padding: 6px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            box-shadow: var(--shadow);
        }

        .md-menu__who { padding: 8px 10px 10px; margin-bottom: 4px; border-bottom: 1px solid var(--line); }
        .md-menu__who strong { display: block; color: var(--ink); }
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
        .md-menu__item--danger:hover { background: var(--md-danger-bg); }

        /* ---------- Quick actions & filter ---------- */
        .md-actions-bar {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }

        .md-actions-bar__left { display: flex; flex-wrap: wrap; gap: 10px; }

        .md-switch {
            display: inline-flex;
            padding: 2px;
            border: 1px solid var(--line);
            border-radius: var(--radius-btn);
            background: var(--paper);
        }

        .md-switch button {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border: 0;
            border-radius: var(--radius-btn);
            background: transparent;
            font-size: .82rem;
            color: var(--ink-mute);
        }

        .md-switch button:hover { color: var(--ink); }
        .md-switch button.is-on { background: var(--ink); color: var(--paper); font-weight: 600; }

        /* ---------- Feedback line ---------- */
        .md-flash {
            margin: 0 0 20px;
            padding: 10px 14px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            color: var(--ink);
        }

        .md-flash--error { border-color: var(--md-danger-line); background: var(--md-danger-bg); color: var(--md-danger); }

        /* ---------- Panes & panels ---------- */
        .md-pane { display: none; }
        .md-pane.is-active { display: block; }

        .md-panel {
            margin-bottom: 20px;
            border: 1px solid var(--line);
            border-radius: 10px;
            background: var(--paper);
        }

        .md-panel__head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            padding: 16px 18px 14px;
        }

        .md-panel__title { margin: 0; font-size: 1rem; font-weight: 600; color: var(--ink); }
        .md-panel__hint { margin: 2px 0 0; font-size: .85rem; color: var(--ink-mute); }
        .md-panel__body { padding: 0 18px 18px; }

        /* ---------- Stat cards ---------- */
        .md-stats {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .md-stat {
            padding: 16px 18px 18px;
            border: 1px solid var(--line);
            border-radius: 10px;
            background: var(--paper);
        }

        .md-stat__label { display: flex; align-items: center; gap: 8px; margin: 0; font-size: .8rem; color: var(--ink-mute); }
        .md-stat__label .bi { color: var(--accent); }

        .md-stat__value {
            margin: 10px 0 0;
            font-size: 2rem;
            font-weight: 600;
            line-height: 1.1;
            color: var(--ink);
            font-variant-numeric: tabular-nums;
        }

        @media (max-width: 720px) { .md-stats { grid-template-columns: minmax(0, 1fr); gap: 12px; } }

        /* ---------- Courses + profile pair ---------- */
        .md-pair {
            display: grid;
            grid-template-columns: minmax(0, 2.1fr) minmax(280px, 1fr);
            gap: 20px;
            align-items: start;
        }

        @media (max-width: 1000px) { .md-pair { grid-template-columns: minmax(0, 1fr); } }

        .md-rows { display: flex; flex-direction: column; gap: 10px; padding: 0 18px 18px; }

        .md-row {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 150px auto;
            align-items: center;
            gap: 18px;
            padding: 12px 14px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--cream);
        }

        .md-row[hidden] { display: none; }

        .md-row__title { display: block; font-weight: 600; color: var(--ink); line-height: 1.35; }
        .md-row__meta { font-size: .8rem; color: var(--ink-mute); }
        .md-row__meta .code { font-family: var(--mono); font-size: .76rem; }

        .md-row .btn { padding: 6px 12px; font-size: .8rem; box-shadow: none; }
        .md-row > .btn,
        .md-row__btns .btn { width: 100%; justify-content: center; }
        .md-row__btns { display: flex; gap: 6px; }
        .md-row__btns .btn { width: auto; }

        @media (max-width: 620px) {
            .md-row { grid-template-columns: minmax(0, 1fr) auto; }
            .md-row .md-progress { grid-column: 1 / -1; grid-row: 2; }
        }

        .md-progress { display: flex; flex-direction: column; gap: 5px; }
        .md-progress__text { display: flex; justify-content: space-between; font-size: .76rem; color: var(--ink-mute); font-variant-numeric: tabular-nums; }
        .md-progress__track { height: 6px; border-radius: var(--pill); background: var(--beige-deep); overflow: hidden; }
        .md-progress__fill { display: block; height: 100%; border-radius: inherit; background: var(--accent); }

        .md-empty-block { padding: 28px 18px; text-align: center; color: var(--ink-mute); }
        .md-empty-block strong { display: block; margin-bottom: 2px; color: var(--ink); }
        .md-empty-block[hidden] { display: none; }

        .btn.md-danger { color: var(--md-danger); }
        .btn.md-danger:hover { background: var(--md-danger-bg); border-color: var(--md-danger-line); }

        /* ---------- Profile card ---------- */
        .md-profile { display: flex; flex-direction: column; align-items: center; padding: 4px 18px 18px; }

        .md-avatar {
            display: grid;
            place-items: center;
            width: 96px;
            height: 96px;
            border-radius: 50%;
            background: var(--beige-deep);
            font-size: 2.2rem;
            font-weight: 600;
            color: var(--ink);
        }

        .md-profile__name { margin: 12px 0 2px; font-size: 1.02rem; font-weight: 600; color: var(--ink); text-align: center; }

        .md-facts { width: 100%; margin: 14px 0 16px; padding: 0; }

        .md-facts div {
            display: grid;
            grid-template-columns: 96px minmax(0, 1fr);
            gap: 10px;
            padding: 7px 0;
            font-size: .85rem;
        }

        .md-facts div + div { border-top: 1px solid var(--line); }
        .md-facts dt { color: var(--ink-faint); }
        .md-facts dd { margin: 0; color: var(--ink); overflow-wrap: anywhere; }

        .md-profile .btn { width: 100%; justify-content: center; }

        /* ---------- Course catalog ---------- */
        .md-tools {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
            padding: 0 18px 14px;
        }

        .md-tools .md-search { flex: 1; min-width: 200px; }
        .md-tools .md-select { width: auto; }
        .md-tools__meta { margin-left: auto; font-size: .82rem; color: var(--ink-faint); }

        .md-cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 12px;
            padding: 16px 18px 18px;
            border-top: 1px solid var(--line);
        }

        .md-course {
            display: flex;
            flex-direction: column;
            gap: 6px;
            padding: 14px 16px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--cream);
        }

        .md-course[hidden] { display: none; }
        .md-course__top { display: flex; justify-content: space-between; align-items: center; gap: 8px; }
        .md-course__top .code { font-family: var(--mono); font-size: .76rem; color: var(--ink-mute); }
        .md-course__title { margin: 2px 0 0; font-size: .98rem; font-weight: 600; line-height: 1.35; color: var(--ink); }
        .md-course__meta { margin: 0; font-size: .82rem; color: var(--ink-mute); }
        .md-course__desc { margin: 2px 0 0; font-size: .82rem; color: var(--ink-soft); }
        .md-course__foot { margin-top: auto; padding-top: 10px; }
        .md-course__foot .btn { padding: 6px 12px; font-size: .8rem; box-shadow: none; }

        /* ---------- Forms ---------- */
        .md-input,
        .md-select {
            width: 100%;
            padding: 8px 11px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink);
            font: inherit;
            transition: border-color .15s ease-out;
        }

        .md-input:hover,
        .md-select:hover { border-color: var(--sand); }

        .md-input:focus,
        .md-select:focus { border-color: var(--ink); outline: none; box-shadow: 0 0 0 3px var(--accent-soft); }

        /* ---------- Floating theme toggle ---------- */
        .md-theme {
            position: fixed;
            right: 24px;
            bottom: 24px;
            z-index: 30;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 5px 14px 5px 5px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-sm);
            background: var(--ink);
            color: var(--paper);
            font-size: .82rem;
            font-weight: 600;
            box-shadow: var(--shadow);
        }

        .md-theme__knob {
            display: grid;
            place-items: center;
            width: 32px;
            height: 30px;
            border-radius: 6px;
            background: var(--paper);
            color: var(--ink);
        }

        @media (prefers-reduced-motion: reduce) {
            .md-menu__pop,
            .md-nav { transition: none; }
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnPane" runat="server" Value="pane-overview" />

        <div class="md-shell">

            <!-- ================= SIDEBAR ================= -->
            <aside class="md-side">
                <a class="md-side__brand" href="Index.aspx" title="Open the public site">
                    <img class="md-side__logo md-side__logo--light" src="assets/img/meowlet-logo.png" alt="Meowlet Education" />
                    <img class="md-side__logo md-side__logo--dark" src="assets/img/meowlet-logo-dark.png" alt="Meowlet Education" />
                    <img class="md-side__mark" src="assets/img/meowlet-mark.png" alt="Meowlet Education" />
                </a>

                <nav aria-label="Member sections">
                    <p class="md-side__group">Learning</p>
                    <button type="button" class="md-nav is-active" data-pane="pane-overview">
                        <i class="bi bi-grid-1x2" aria-hidden="true"></i><span>Dashboard</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-courses">
                        <i class="bi bi-journal-bookmark" aria-hidden="true"></i><span>My Courses</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-catalog">
                        <i class="bi bi-book" aria-hidden="true"></i><span>Course Catalog</span>
                    </button>

                    <p class="md-side__group">Account</p>
                    <a class="md-nav" href="Profile.aspx">
                        <i class="bi bi-person" aria-hidden="true"></i><span>My Profile</span>
                    </a>
                    <a class="md-nav" href="Index.aspx">
                        <i class="bi bi-house" aria-hidden="true"></i><span>Public site</span>
                    </a>
                </nav>

                <div class="md-side__foot">
                    <asp:LinkButton ID="lnkSideSignOut" runat="server" CssClass="md-nav md-nav--danger"
                        OnClick="lnkLogout_Click"
                        OnClientClick="return confirm('Sign out of Meowlet?');">
                        <i class="bi bi-box-arrow-right" aria-hidden="true"></i><span>Sign Out</span>
                    </asp:LinkButton>
                </div>
            </aside>

            <!-- ================= MAIN ================= -->
            <main class="md-main">

                <header class="md-top">
                    <div>
                        <h1 class="md-title" id="pageTitle">Welcome back, <asp:Literal ID="litWelcomeName" runat="server">Member</asp:Literal></h1>
                        <p class="md-sub" id="pageSub">Pick up where you left off.</p>
                    </div>
                    <div class="md-top__tools">
                        <label class="md-search md-global">
                            <i class="bi bi-search" aria-hidden="true"></i>
                            <input type="search" id="globalSearch" class="md-input" placeholder="Search courses" aria-label="Search the course catalog" />
                        </label>
                        <a class="md-icon-btn" href="Index.aspx" title="Public site" aria-label="Public site">
                            <i class="bi bi-house" aria-hidden="true"></i>
                        </a>
                        <div class="md-menu">
                            <button type="button" class="md-menu__btn" aria-haspopup="true">
                                <i class="bi bi-person-circle" aria-hidden="true"></i>
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

                <asp:Literal ID="litFlash" runat="server" EnableViewState="false" />

                <!-- ---------- DASHBOARD ---------- -->
                <section id="pane-overview" class="md-pane is-active" aria-labelledby="pageTitle">

                    <div class="md-actions-bar">
                        <div class="md-actions-bar__left">
                            <button type="button" class="btn btn--ghost btn--sm" data-go="pane-catalog"><i class="bi bi-search" aria-hidden="true"></i>&nbsp;Browse courses</button>
                            <button type="button" class="btn btn--ghost btn--sm" data-go="pane-courses"><i class="bi bi-play-circle" aria-hidden="true"></i>&nbsp;Continue learning</button>
                        </div>
                        <div class="md-switch" role="group" aria-label="Show courses" id="overviewFilter">
                            <button type="button" class="is-on" data-filter="" aria-pressed="true">All</button>
                            <button type="button" data-filter="progress" aria-pressed="false">In progress</button>
                            <button type="button" data-filter="completed" aria-pressed="false">Completed</button>
                        </div>
                    </div>

                    <div class="md-stats">
                        <div class="md-stat">
                            <p class="md-stat__label"><i class="bi bi-journal-bookmark" aria-hidden="true"></i>Enrolled Courses</p>
                            <p class="md-stat__value"><asp:Literal ID="litStatEnrolled" runat="server">0</asp:Literal></p>
                        </div>
                        <div class="md-stat">
                            <p class="md-stat__label"><i class="bi bi-check2-circle" aria-hidden="true"></i>Completed</p>
                            <p class="md-stat__value"><asp:Literal ID="litStatCompleted" runat="server">0</asp:Literal></p>
                        </div>
                        <div class="md-stat">
                            <p class="md-stat__label"><i class="bi bi-hourglass-split" aria-hidden="true"></i>In Progress</p>
                            <p class="md-stat__value"><asp:Literal ID="litStatInProgress" runat="server">0</asp:Literal></p>
                        </div>
                    </div>

                    <div class="md-pair">
                        <div class="md-panel">
                            <div class="md-panel__head">
                                <div>
                                    <h2 class="md-panel__title">My Courses</h2>
                                    <p class="md-panel__hint">Your five most recent enrollments.</p>
                                </div>
                                <button type="button" class="btn btn--ghost btn--sm" data-go="pane-courses">View all</button>
                            </div>
                            <div class="md-rows" id="overviewRows">
                                <asp:Repeater ID="rptRecentCourses" runat="server">
                                    <ItemTemplate>
                                        <div class="md-row" data-state="<%# Eval("State") %>">
                                            <div>
                                                <span class="md-row__title"><%# Html(Eval("Title")) %></span>
                                                <span class="md-row__meta"><span class="code"><%# Html(Eval("CourseCode")) %></span> · <%# Html(Eval("Category")) %></span>
                                            </div>
                                            <div class="md-progress">
                                                <span class="md-progress__text"><span>Progress</span><span><%# Eval("Percent") %>%</span></span>
                                                <span class="md-progress__track"><span class="md-progress__fill" style="width:<%# Eval("Percent") %>%"></span></span>
                                            </div>
                                            <a class="btn btn--ghost btn--sm" href="course.aspx?id=<%# Eval("CourseId") %>">
                                                <%# (string)Eval("State") == "completed" ? "Review" : "Continue" %>
                                            </a>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <p class="md-empty-block" id="overviewNoMatch" hidden="hidden">No courses in this group yet.</p>
                            </div>
                            <asp:PlaceHolder ID="phNoRecent" runat="server" Visible="false">
                                <div class="md-empty-block">
                                    <strong>You haven't enrolled in a course yet</strong>
                                    Find one in the catalog to get started.
                                </div>
                            </asp:PlaceHolder>
                        </div>

                        <div class="md-panel">
                            <div class="md-panel__head">
                                <h2 class="md-panel__title">My Profile</h2>
                                <span class="tag tag--accent"><asp:Literal ID="litRole" runat="server">Student</asp:Literal></span>
                            </div>
                            <div class="md-profile">
                                <span class="md-avatar" aria-hidden="true"><asp:Literal ID="litAvatar" runat="server">?</asp:Literal></span>
                                <p class="md-profile__name"><asp:Literal ID="litProfileName" runat="server" /></p>
                                <dl class="md-facts">
                                    <div><dt>Email</dt><dd><asp:Literal ID="litProfileEmail" runat="server" /></dd></div>
                                    <div><dt>Age range</dt><dd><asp:Literal ID="litProfileAge" runat="server">Not set</asp:Literal></dd></div>
                                    <div><dt>Experience</dt><dd><asp:Literal ID="litProfileLevel" runat="server">Not set</asp:Literal></dd></div>
                                    <div><dt>Member since</dt><dd><asp:Literal ID="litProfileJoined" runat="server" /></dd></div>
                                </dl>
                                <a class="btn btn--primary btn--sm" href="Profile.aspx">Edit Profile</a>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ---------- MY COURSES ---------- -->
                <section id="pane-courses" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">All my courses</h2>
                                <p class="md-panel__hint">Dropping a course removes it from your list. You can enrol again later.</p>
                            </div>
                            <div class="md-switch" role="group" aria-label="Show courses" id="courseFilter">
                                <button type="button" class="is-on" data-filter="" aria-pressed="true">All</button>
                                <button type="button" data-filter="progress" aria-pressed="false">In progress</button>
                                <button type="button" data-filter="completed" aria-pressed="false">Completed</button>
                            </div>
                        </div>
                        <div class="md-rows" id="courseRows">
                            <asp:Repeater ID="rptMyCourses" runat="server" OnItemCommand="rptMyCourses_ItemCommand">
                                <ItemTemplate>
                                    <div class="md-row" data-state="<%# Eval("State") %>">
                                        <div>
                                            <span class="md-row__title"><%# Html(Eval("Title")) %></span>
                                            <span class="md-row__meta">
                                                <span class="code"><%# Html(Eval("CourseCode")) %></span> · <%# Html(Eval("Level")) %> ·
                                                <%# Eval("DoneLessons") %> of <%# Eval("TotalLessons") %> lessons · enrolled <%# FormatDate(Eval("EnrolledAt")) %>
                                            </span>
                                        </div>
                                        <div class="md-progress">
                                            <span class="md-progress__text"><span><%# (string)Eval("State") == "completed" ? "Completed" : "Progress" %></span><span><%# Eval("Percent") %>%</span></span>
                                            <span class="md-progress__track"><span class="md-progress__fill" style="width:<%# Eval("Percent") %>%"></span></span>
                                        </div>
                                        <span class="md-row__btns">
                                            <a class="btn btn--primary btn--sm" href="course.aspx?id=<%# Eval("CourseId") %>">
                                                <%# (string)Eval("State") == "completed" ? "Review" : "Open" %>
                                            </a>
                                            <asp:LinkButton runat="server" CommandName="Drop" CommandArgument='<%# Eval("CourseId") %>'
                                                CssClass="btn btn--ghost btn--sm md-danger" Text="Drop"
                                                OnClientClick="return confirm('Drop this course? Your lesson progress is kept if you enrol again.');" />
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <p class="md-empty-block" id="courseNoMatch" hidden="hidden">No courses in this group yet.</p>
                        </div>
                        <asp:PlaceHolder ID="phNoCourses" runat="server" Visible="false">
                            <div class="md-empty-block">
                                <strong>No courses yet</strong>
                                Courses you enrol in from the catalog show up here.
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </section>

                <!-- ---------- COURSE CATALOG ---------- -->
                <section id="pane-catalog" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">Course catalog</h2>
                                <p class="md-panel__hint">Published courses you haven't joined yet.</p>
                            </div>
                        </div>

                        <div class="md-tools">
                            <label class="md-search">
                                <i class="bi bi-search" aria-hidden="true"></i>
                                <input type="search" id="catalogSearch" class="md-input" placeholder="Search by title, tutor or code" aria-label="Search courses" />
                            </label>
                            <select id="catalogCategory" class="md-select" aria-label="Category">
                                <option value="">All categories</option>
                            </select>
                            <select id="catalogLevel" class="md-select" aria-label="Level">
                                <option value="">Any level</option>
                                <option value="Beginner">Beginner</option>
                                <option value="Intermediate">Intermediate</option>
                                <option value="Advanced">Advanced</option>
                            </select>
                            <span class="md-tools__meta" id="catalogShowing" aria-live="polite"></span>
                        </div>

                        <div class="md-cards" id="catalogCards">
                            <asp:Repeater ID="rptCatalog" runat="server" OnItemCommand="rptCatalog_ItemCommand">
                                <ItemTemplate>
                                    <article class="md-course"
                                        data-title="<%# Attr(Eval("Title")) %>"
                                        data-code="<%# Attr(Eval("CourseCode")) %>"
                                        data-tutor="<%# Attr(Eval("TutorName")) %>"
                                        data-category="<%# Attr(Eval("Category")) %>"
                                        data-level="<%# Attr(Eval("Level")) %>">
                                        <div class="md-course__top">
                                            <span class="code"><%# Html(Eval("CourseCode")) %></span>
                                            <span class="tag"><%# Html(Eval("Level")) %></span>
                                        </div>
                                        <h3 class="md-course__title"><%# Html(Eval("Title")) %></h3>
                                        <p class="md-course__meta"><%# Html(Eval("Category")) %> · <%# Html(Eval("TutorName")) %></p>
                                        <p class="md-course__meta"><%# Eval("Lessons") %> lessons · <%# Eval("LearnerCount") %> learners</p>
                                        <%# string.IsNullOrEmpty(Convert.ToString(Eval("Description"))) ? "" : "<p class=\"md-course__desc\">" + Html(Eval("Description")) + "</p>" %>
                                        <div class="md-course__foot">
                                            <asp:LinkButton runat="server" CommandName="Enrol" CommandArgument='<%# Eval("CourseId") %>'
                                                CssClass="btn btn--primary btn--sm" Text="Enrol" />
                                        </div>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                            <p class="md-empty-block" id="catalogNoMatch" hidden="hidden"><strong>No matches</strong>Try another search or clear the filters.</p>
                        </div>
                        <asp:PlaceHolder ID="phNoCatalog" runat="server" Visible="false">
                            <div class="md-empty-block">
                                <strong>You're enrolled in every course</strong>
                                New courses appear here once they're published.
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </section>
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

                var meta = {
                    'pane-overview': ['Welcome back, ' + memberData.name, 'Pick up where you left off.'],
                    'pane-courses': ['My Courses', 'Everything you are enrolled in, with your progress.'],
                    'pane-catalog': ['Course Catalog', 'Find your next course and enrol in one click.']
                };

                var hdnPane = document.getElementById('<%= hdnPane.ClientID %>');
                var navItems = document.querySelectorAll('.md-nav[data-pane]');
                var panes = document.querySelectorAll('.md-pane');
                var title = document.getElementById('pageTitle');
                var sub = document.getElementById('pageSub');

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
                    title.textContent = meta[paneId][0];
                    sub.textContent = meta[paneId][1];
                    var flash = document.querySelector('.md-main > .md-flash');
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

                // ---- course filters: All / In progress / Completed ----
                function wireFilter(switchId, rowsId, noMatchId) {
                    var buttons = document.querySelectorAll('#' + switchId + ' button');
                    var rows = document.querySelectorAll('#' + rowsId + ' .md-row');
                    var noMatch = document.getElementById(noMatchId);

                    function apply(filter) {
                        var shown = 0;
                        for (var i = 0; i < rows.length; i++) {
                            var match = !filter || rows[i].getAttribute('data-state') === filter;
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
                        buttons[b].onclick = function () { apply(this.getAttribute('data-filter')); };
                    }
                }

                wireFilter('overviewFilter', 'overviewRows', 'overviewNoMatch');
                wireFilter('courseFilter', 'courseRows', 'courseNoMatch');

                // ---- catalog search ----
                var cards = Array.prototype.slice.call(document.querySelectorAll('#catalogCards .md-course'));
                var catalogSearch = document.getElementById('catalogSearch');
                var catalogCategory = document.getElementById('catalogCategory');
                var catalogLevel = document.getElementById('catalogLevel');
                var catalogNoMatch = document.getElementById('catalogNoMatch');

                var seen = {};
                for (var c = 0; c < cards.length; c++) {
                    var cat = cards[c].getAttribute('data-category');
                    if (cat && !seen[cat]) { seen[cat] = true; catalogCategory.add(new Option(cat, cat)); }
                }

                function filterCatalog() {
                    var q = catalogSearch.value.trim().toLowerCase();
                    var cat = catalogCategory.value;
                    var level = catalogLevel.value;
                    var shown = 0;

                    for (var i = 0; i < cards.length; i++) {
                        var card = cards[i];
                        var text = (card.getAttribute('data-title') + ' ' + card.getAttribute('data-code') + ' ' +
                            card.getAttribute('data-tutor')).toLowerCase();
                        var match = (!cat || card.getAttribute('data-category') === cat) &&
                            (!level || card.getAttribute('data-level') === level) &&
                            (!q || text.indexOf(q) !== -1);
                        card.hidden = !match;
                        if (match) { shown++; }
                    }

                    catalogNoMatch.hidden = !(cards.length > 0 && shown === 0);
                    document.getElementById('catalogShowing').textContent =
                        cards.length ? shown + ' of ' + cards.length : '';
                }

                catalogSearch.oninput = filterCatalog;
                catalogCategory.onchange = filterCatalog;
                catalogLevel.onchange = filterCatalog;
                filterCatalog();

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
                        catalogCategory.value = '';
                        catalogLevel.value = '';
                        show('pane-catalog');
                        filterCatalog();
                        catalogSearch.focus();
                    }
                };
            })();
        </script>
    </form>
</body>
</html>

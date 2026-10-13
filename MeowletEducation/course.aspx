<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="course.aspx.cs" Inherits="MeowletEducation.CoursePlayer" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Course - Meowlet Education</title>
    <link rel="icon" href="favicon.ico" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="assets/css/style.css" />
    <link rel="stylesheet" href="assets/css/ar-lesson.css" />
    <%-- AR lessons load three.js as ES modules from a local copy (works offline for demos) --%>
    <script type="importmap">{"imports":{"three":"./assets/js/vendor/three/three.module.min.js","three/addons/":"./assets/js/vendor/three/"}}</script>
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
        /* Course player. Same base styles as memberdashboard.aspx, which shares the admin panel's look: colours, type,
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
            grid-template-columns: minmax(0, 1fr) 150px 88px;
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
        .md-row__btns { display: flex; }

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
        /* ---------- Course player (cp-) ---------- */
        .cp-wrap { max-width: 1180px; margin: 0 auto; padding: 24px clamp(16px, 3vw, 36px) 88px; }
        .cp-back { display: inline-flex; align-items: center; gap: 6px; margin-bottom: 10px; font-size: .85rem; color: var(--ink-mute); text-decoration: none; }
        .cp-back:hover { color: var(--ink); }
        .cp-progress { min-width: 220px; }
        .cp-grid { display: grid; grid-template-columns: 300px minmax(0, 1fr); gap: 20px; align-items: start; }
        @media (max-width: 900px) { .cp-grid { grid-template-columns: minmax(0, 1fr); } }
        .cp-list { position: sticky; top: 16px; }
        @media (max-width: 900px) { .cp-list { position: static; } }
        .cp-lessons { list-style: none; margin: 0; padding: 0 10px 12px; }
        .cp-lesson-link {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 9px 8px; border-radius: var(--radius-sm);
            color: var(--ink-soft); text-decoration: none;
        }
        .cp-lesson-link:hover { background: var(--cream); color: var(--ink); }
        .cp-lesson-link.is-current { background: var(--beige-deep); color: var(--ink); }
        .cp-mark {
            display: inline-grid; place-items: center; flex-shrink: 0;
            width: 24px; height: 24px; border-radius: 50%;
            border: 1px solid var(--line-strong); font-size: .75rem; font-weight: 700;
        }
        .cp-lesson-link.is-done .cp-mark { background: var(--accent); border-color: var(--accent); color: #fff; }
        .cp-lesson-text { display: flex; flex-direction: column; min-width: 0; }
        .cp-lesson-title { font-weight: 600; line-height: 1.3; }
        .cp-lesson-meta { font-size: .76rem; color: var(--ink-faint); }
        .cp-kicker { margin: 0 0 4px; font-size: .74rem; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: var(--ink-faint); }
        .cp-title { margin: 0; font-size: 1.3rem; font-weight: 600; color: var(--ink); line-height: 1.3; }
        .cp-body { padding: 4px 18px 18px; color: var(--ink-soft); font-size: .95rem; line-height: 1.65; }
        .cp-text { white-space: pre-wrap; margin: 0 0 14px; }
        .cp-video { position: relative; width: 100%; aspect-ratio: 16 / 9; margin-bottom: 14px; border-radius: var(--radius-sm); overflow: hidden; background: #000; }
        .cp-video iframe { position: absolute; inset: 0; width: 100%; height: 100%; border: 0; }
        .cp-text a, .cp-caption a { color: var(--accent); overflow-wrap: anywhere; }
        .cp-figure { margin: 0 0 18px; }
        .cp-figure .cp-video { margin-bottom: 6px; }
        .cp-figure img, .cp-media { display: block; max-width: 100%; border-radius: var(--radius-sm); }
        .cp-caption { font-size: .82rem; color: var(--ink-faint); }
        .cp-quiz { margin: 0 0 14px; padding-left: 1.4em; }
        .cp-quiz__item { margin-bottom: 14px; }
        .cp-quiz__q { margin: 0 0 4px; font-weight: 600; color: var(--ink); }
        .cp-quiz__options { margin: 0 0 6px; padding-left: 1.4em; }
        .cp-quiz__answer summary { cursor: pointer; color: var(--accent); font-size: .88rem; }
        .cp-quiz__answer p { margin: 4px 0 0; }
        .cp-note {
            display: flex; gap: 10px; margin: 0 0 14px; padding: 12px 14px;
            border: 1px solid var(--line); border-radius: var(--radius-sm); background: var(--cream);
            font-size: .88rem; color: var(--ink-soft);
        }
        .cp-note .bi { color: var(--accent); font-size: 1.05rem; }
        .cp-foot { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; padding: 14px 18px 18px; border-top: 1px solid var(--line); }
        .cp-foot__gap { flex: 1; }
        .cp-actions { margin-top: 14px; }
        .tag--ok { color: #2f7a3b; border-color: rgba(47, 122, 59, .3); }
        html[data-theme="dark"] .tag--ok { color: #8fd19b; }
        .cp-banner {
            margin: 0 0 20px; padding: 10px 14px; border: 1px dashed var(--line-strong);
            border-radius: var(--radius-sm); color: var(--ink-soft);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnLessonId" runat="server" />

        <div class="cp-wrap">
            <header class="md-top">
                <div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="cp-back" NavigateUrl="memberdashboard.aspx"><i class="bi bi-arrow-left" aria-hidden="true"></i> Back to my courses</asp:HyperLink>
                    <h1 class="md-title"><asp:Literal ID="litTitle" runat="server">Course</asp:Literal></h1>
                    <p class="md-sub"><asp:Literal ID="litMeta" runat="server" /></p>
                </div>
                <div class="md-top__tools">
                    <asp:Literal ID="litProgress" runat="server" />
                </div>
            </header>

            <asp:Literal ID="litFlash" runat="server" EnableViewState="false" />

            <asp:PlaceHolder ID="phMessage" runat="server" Visible="false">
                <div class="md-panel">
                    <div class="md-empty-block">
                        <asp:Literal ID="litMessage" runat="server" />
                        <div class="cp-actions">
                            <asp:Button ID="btnEnrol" runat="server" Text="Enrol in this course" CssClass="btn btn--primary btn--sm" OnClick="btnEnrol_Click" Visible="false" />
                        </div>
                    </div>
                </div>
            </asp:PlaceHolder>

            <asp:PlaceHolder ID="phPlayer" runat="server" Visible="false">
                <asp:Literal ID="litBanner" runat="server" />
                <div class="cp-grid">
                    <aside class="md-panel cp-list" aria-label="Lessons">
                        <div class="md-panel__head">
                            <h2 class="md-panel__title">Lessons</h2>
                        </div>
                        <ol class="cp-lessons">
                            <asp:Repeater ID="rptLessons" runat="server">
                                <ItemTemplate>
                                    <li>
                                        <a class='<%# LessonCss(Eval("LessonId"), Eval("IsDone")) %>' href='<%# LessonUrl(Eval("LessonId")) %>'>
                                            <span class="cp-mark"><%# (int)Eval("IsDone") == 1 ? "<i class=\"bi bi-check-lg\" aria-label=\"Done\"></i>" : Convert.ToString(Eval("Position")) %></span>
                                            <span class="cp-lesson-text">
                                                <span class="cp-lesson-title"><%# Html(Eval("Title")) %></span>
                                                <span class="cp-lesson-meta"><%# TypeLabel(Eval("ContentType")) %> · <%# Eval("DurationMinutes") %> min</span>
                                            </span>
                                        </a>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ol>
                        <asp:PlaceHolder ID="phNoLessons" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No lessons yet</strong>The tutor is still preparing this course.</div>
                        </asp:PlaceHolder>
                    </aside>

                    <section class="md-panel" aria-live="polite">
                        <asp:PlaceHolder ID="phLesson" runat="server">
                            <div class="md-panel__head">
                                <div>
                                    <p class="cp-kicker"><asp:Literal ID="litLessonKicker" runat="server" /></p>
                                    <h2 class="cp-title"><asp:Literal ID="litLessonTitle" runat="server" /></h2>
                                </div>
                                <asp:Literal ID="litLessonState" runat="server" />
                            </div>
                            <div class="cp-body">
                                <asp:Literal ID="litLessonBody" runat="server" />
                            </div>
                            <div class="cp-foot">
                                <asp:HyperLink ID="lnkPrev" runat="server" CssClass="btn btn--ghost btn--sm" Text="Previous" />
                                <span class="cp-foot__gap"></span>
                                <asp:Button ID="btnComplete" runat="server" CssClass="btn btn--primary btn--sm" Text="Mark as complete" OnClick="btnComplete_Click" />
                                <asp:HyperLink ID="lnkNext" runat="server" CssClass="btn btn--ghost btn--sm" Text="Next lesson" />
                            </div>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder ID="phNoLesson" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>Nothing to show yet</strong>Lessons appear here once the tutor adds them.</div>
                        </asp:PlaceHolder>
                    </section>
                </div>
            </asp:PlaceHolder>
        </div>

        <button type="button" class="md-theme" id="themeToggle" aria-label="Switch theme">
            <span class="md-theme__knob"><i class="bi bi-moon-stars" aria-hidden="true"></i></span>
            <span id="themeLabel">Dark</span>
        </button>

        <script type="text/javascript">
            // @ts-nocheck
            (function () {
                // Same theme switch (and saved choice) as the dashboards.
                var themeToggle = document.getElementById('themeToggle');
                function syncTheme() {
                    var dark = document.documentElement.getAttribute('data-theme') === 'dark';
                    themeToggle.querySelector('.bi').className = dark ? 'bi bi-moon-stars' : 'bi bi-sun';
                    document.getElementById('themeLabel').textContent = dark ? 'Dark' : 'Light';
                }
                themeToggle.onclick = function () {
                    var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                    document.documentElement.setAttribute('data-theme', next);
                    try { localStorage.setItem('meowletMemberTheme', next); } catch (e) { }
                    syncTheme();
                };
                syncTheme();
            })();
        </script>
    </form>
</body>
</html>

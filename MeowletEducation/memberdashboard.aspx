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
        // Light unless this browser chose dark.
        (function () {
            var theme = 'light';
            try { theme = localStorage.getItem('meowletMemberTheme') || 'light'; } catch (e) { }
            document.documentElement.setAttribute('data-theme', theme === 'dark' ? 'dark' : 'light');
        })();
    </script>
    <style>
        /* Member dashboard. Layout follows the learner dashboard mock-up:
           white sidebar, continue-learning hero beside the live-quiz box, four
           stat cards, then the course list beside "Due soon" and the profile.
           Browsing and enrolling happen on Courses.aspx. Page classes use md-. */

        @font-face { font-family: "General Sans"; font-weight: 500; font-display: swap; src: url("assets/fonts/GeneralSans-Medium.woff2") format("woff2"); }
        @font-face { font-family: "General Sans"; font-weight: 600; font-display: swap; src: url("assets/fonts/GeneralSans-Semibold.woff2") format("woff2"); }

        /* ---------- Themes ---------- */
        :root {
            --paper: #ffffff;
            --cream: #f4f3ef;
            --ink: #141413;
            --ink-soft: #2b2b29;
            --ink-mute: #6b6a65;
            --ink-faint: #8f8e88;
            --accent: #f5c518;
            --accent-soft: #fdf3c4;
            --line: #e7e5df;
            --line-strong: #d6d4cd;
            --md-display: "General Sans", var(--font);
            --md-canvas: #f4f3ef;
            --md-side: #ffffff;
            --md-pill: #efeeea;
            --md-hero: #141413;
            --md-good: #237a46;
            --md-good-bg: #e2f2e7;
            --md-warn: #b42318;
            --md-warn-bg: #fde8e6;
            --md-stripe: #ebe9e3;
            --md-shadow: 0 1px 2px rgba(40, 32, 0, .05);
            --md-shadow-lift: 0 10px 24px -14px rgba(40, 32, 0, .35);
            color-scheme: light;
        }

        html[data-theme="dark"] {
            --paper: #171716;
            --cream: #1f1f1d;
            --ink: #f3f3f0;
            --ink-soft: #d4d4cf;
            --ink-mute: #a3a39d;
            --ink-faint: #85857f;
            --accent-soft: rgba(245, 197, 24, .14);
            --line: rgba(255, 255, 255, .08);
            --line-strong: rgba(255, 255, 255, .16);
            --md-canvas: #0e0e0d;
            --md-side: #121211;
            --md-pill: #262624;
            --md-hero: #000000;
            --md-good: #6fcf97;
            --md-good-bg: rgba(111, 207, 151, .14);
            --md-warn: #f59a8f;
            --md-warn-bg: rgba(240, 82, 64, .14);
            --md-stripe: #222220;
            --md-shadow: 0 1px 2px rgba(0, 0, 0, .5);
            --md-shadow-lift: 0 10px 24px -14px rgba(0, 0, 0, .9);
            color-scheme: dark;
        }

        body {
            font-size: 14px;
            line-height: 1.5;
            color: var(--ink-soft);
            background: var(--md-canvas);
            overflow-x: visible;
        }

        /* ---------- Buttons ---------- */
        .md-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            height: 36px;
            padding: 0 16px;
            border: 1px solid var(--line-strong);
            border-radius: 7px;
            background: var(--paper);
            font-family: var(--md-display);
            font-size: .82rem;
            font-weight: 500;
            color: var(--ink);
            white-space: nowrap;
            transition: background-color .2s ease-out, border-color .2s ease-out, color .2s ease-out, transform .15s ease-out;
        }

        .md-btn:hover { border-color: var(--ink); color: var(--ink); }
        .md-btn:active { transform: translateY(1px); }
        .md-btn--sm { height: 30px; padding: 0 12px; font-size: .76rem; }

        .md-btn--ink { border-color: var(--ink); background: var(--ink); color: var(--paper); }
        .md-btn--ink:hover { background: #000000; color: var(--paper); }
        html[data-theme="dark"] .md-btn--ink:hover { background: #ffffff; }

        .md-btn--accent { border-color: #e0b30f; background: var(--accent); color: #141413; }
        .md-btn--accent:hover { border-color: #c99d00; background: #ffd43b; color: #141413; }

        .md-btn--danger { color: var(--md-warn); }
        .md-btn--danger:hover { border-color: var(--md-warn); background: var(--md-warn-bg); color: var(--md-warn); }

        /* ---------- Shell ---------- */
        .md-shell { display: flex; min-height: 100vh; min-height: 100dvh; }

        .md-side {
            width: 196px;
            flex-shrink: 0;
            position: sticky;
            top: 0;
            height: 100vh;
            height: 100dvh;
            display: flex;
            flex-direction: column;
            padding: 20px 12px 16px;
            border-right: 1px solid var(--line);
            background: var(--md-side);
        }

        .md-side__brand { display: block; padding: 0 6px; }
        .md-side__logo { height: 32px; width: auto; }
        .md-side__logo--dark,
        html[data-theme="dark"] .md-side__logo--light { display: none; }
        html[data-theme="dark"] .md-side__logo--dark { display: inline; }
        .md-side__mark { display: none; height: 32px; width: 32px; border-radius: 8px; }

        .md-ws {
            align-self: flex-start;
            margin: 12px 6px 20px;
            padding: 2px 10px;
            border: 1px solid var(--line-strong);
            border-radius: 999px;
            font-size: .68rem;
            color: var(--ink-mute);
        }

        .md-side nav { display: flex; flex-direction: column; gap: 3px; }

        .md-nav {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            height: 34px;
            padding: 0 10px;
            border: 0;
            border-radius: 7px;
            background: transparent;
            font-size: .82rem;
            color: var(--ink-soft);
            text-align: left;
            white-space: nowrap;
            overflow: hidden;
            transition: background-color .15s ease-out, color .15s ease-out;
        }

        .md-nav .bi { font-size: .95rem; flex-shrink: 0; color: var(--ink-mute); }
        .md-nav:hover { background: var(--cream); color: var(--ink); }

        .md-nav.is-active { background: var(--ink); color: var(--paper); font-family: var(--md-display); font-weight: 500; }
        .md-nav.is-active .bi { color: var(--accent); }

        .md-side__out {
            display: flex;
            align-items: center;
            gap: 10px;
            height: 34px;
            margin-top: auto;
            padding: 0 10px;
            border-top: 1px solid var(--line);
            border-radius: 0;
            padding-top: 14px;
            box-sizing: content-box;
            font-size: .82rem;
            color: var(--ink-mute);
        }

        .md-side__out:hover { color: var(--md-warn); }

        @media (max-width: 760px) {
            .md-side { width: 60px; padding-inline: 8px; }
            .md-side__logo, .md-ws { display: none !important; }
            .md-side__mark { display: block; margin: 0 auto 18px; }
            .md-nav, .md-side__out { justify-content: center; padding-inline: 0; }
            .md-nav > span, .md-side__out > span { display: none; }
        }

        .md-main { flex: 1; min-width: 0; }

        /* ---------- Top bar ---------- */
        .md-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            padding: 18px clamp(16px, 2.6vw, 30px) 16px;
            border-bottom: 1px solid var(--line);
        }

        .md-title {
            margin: 0;
            font-family: var(--md-display);
            font-size: 1.4rem;
            font-weight: 600;
            letter-spacing: -.02em;
            line-height: 1.2;
            color: var(--ink);
        }

        .md-sub { margin: 3px 0 0; font-size: .78rem; color: var(--ink-mute); }

        .md-top__tools { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }

        .md-search { position: relative; display: block; }
        .md-search .bi { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); font-size: .82rem; color: var(--ink-faint); pointer-events: none; }
        .md-search .md-input { padding-left: 32px; }

        .md-global { width: 240px; }
        @media (max-width: 900px) { .md-global { display: none; } }

        .md-icon-btn {
            display: inline-grid;
            place-items: center;
            width: 36px;
            height: 36px;
            border: 1px solid var(--line-strong);
            border-radius: 50%;
            background: var(--paper);
            color: var(--ink-mute);
        }

        .md-icon-btn:hover { border-color: var(--ink); color: var(--ink); }

        /* ---------- Profile menu (the avatar) ---------- */
        .md-menu { position: relative; }

        .md-mono {
            display: inline-grid;
            place-items: center;
            width: 36px;
            height: 36px;
            border: 0;
            border-radius: 50%;
            background: var(--accent);
            font-family: var(--md-display);
            font-size: .85rem;
            font-weight: 600;
            color: #141413;
        }

        .md-menu__pop {
            position: absolute;
            top: 100%;
            right: 0;
            z-index: 20;
            min-width: 220px;
            padding-top: 6px;
            visibility: hidden;
            opacity: 0;
            transition: opacity .15s ease-out, visibility .15s;
        }

        .md-menu:hover .md-menu__pop,
        .md-menu:focus-within .md-menu__pop { visibility: visible; opacity: 1; }

        .md-menu__card { padding: 6px; border: 1px solid var(--line); border-radius: 9px; background: var(--paper); box-shadow: var(--md-shadow-lift); }
        .md-menu__who { padding: 8px 10px 10px; margin-bottom: 4px; border-bottom: 1px solid var(--line); }
        .md-menu__who strong { display: block; font-family: var(--md-display); font-weight: 500; color: var(--ink); }
        .md-menu__who span { font-size: .78rem; color: var(--ink-faint); }

        .md-menu__item {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            padding: 8px 10px;
            border: 0;
            border-radius: 6px;
            background: transparent;
            font-size: .84rem;
            color: var(--ink-soft);
            text-align: left;
        }

        .md-menu__item:hover { background: var(--cream); color: var(--ink); }
        .md-menu__item--danger { color: var(--md-warn); }
        .md-menu__item--danger:hover { background: var(--md-warn-bg); color: var(--md-warn); }

        /* ---------- Content ---------- */
        .md-body { padding: 22px clamp(16px, 2.6vw, 30px) 64px; }

        .md-flash { margin: 0 0 16px; padding: 10px 14px; border: 1px solid var(--line); border-radius: 8px; background: var(--paper); color: var(--ink); }
        .md-flash--error { border-color: var(--md-warn); background: var(--md-warn-bg); color: var(--md-warn); }

        .md-pane { display: none; }
        .md-pane.is-active { display: block; }

        .md-card {
            border: 1px solid var(--line);
            border-radius: 12px;
            background: var(--paper);
            box-shadow: var(--md-shadow);
        }

        .md-card__head { display: flex; justify-content: space-between; align-items: baseline; gap: 12px; margin-bottom: 12px; }
        .md-card__title { margin: 0; font-family: var(--md-display); font-size: .98rem; font-weight: 600; color: var(--ink); }
        .md-card__link { font-family: var(--md-display); font-size: .74rem; font-weight: 500; color: var(--ink); white-space: nowrap; }
        .md-card__link:hover { color: var(--ink); text-decoration: underline; }

        .md-grid { display: grid; grid-template-columns: minmax(0, 1fr) 300px; gap: 16px; margin-bottom: 16px; align-items: start; }
        .md-grid--top { align-items: stretch; }
        .md-col { display: flex; flex-direction: column; gap: 16px; min-width: 0; }
        @media (max-width: 1080px) { .md-grid { grid-template-columns: minmax(0, 1fr); } }

        /* ---------- Continue-learning hero ---------- */
        .md-hero {
            display: flex;
            align-items: center;
            gap: 24px;
            padding: 22px;
            border-radius: 12px;
            background: var(--md-hero);
            color: #d4d4cf;
        }

        html[data-theme="dark"] .md-hero { border: 1px solid var(--line-strong); }

        .md-cover {
            flex: 0 0 200px;
            aspect-ratio: 16 / 10;
            display: grid;
            place-items: center;
            overflow: hidden;
            border-radius: 8px;
            background: #262624;
            font-size: .72rem;
            color: #85857f;
        }

        .md-cover img { width: 100%; height: 100%; object-fit: cover; }
        .md-cover .bi { margin-right: 5px; }

        .md-hero__body { flex: 1; min-width: 0; }

        .md-kicker {
            margin: 0;
            font-family: var(--mono);
            font-size: .64rem;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: #a3a39d;
        }

        .md-hero__title {
            margin: 6px 0 4px;
            font-family: var(--md-display);
            font-size: 1.32rem;
            font-weight: 600;
            letter-spacing: -.015em;
            line-height: 1.2;
            color: #ffffff;
        }

        .md-hero__lesson { margin: 0; font-size: .78rem; color: #a3a39d; }

        .md-hero__progress { display: flex; align-items: center; gap: 12px; margin: 14px 0 16px; }
        .md-hero__progress .md-track { flex: 1; max-width: 300px; background: #3a3a37; }
        .md-hero__progress .md-track > span { background: var(--accent); }
        .md-hero__progress b { font-size: .72rem; font-weight: 400; color: #d4d4cf; font-variant-numeric: tabular-nums; }

        .md-hero__btns { display: flex; flex-wrap: wrap; gap: 10px; }
        .md-btn--ghost-dark { border-color: rgba(255, 255, 255, .28); background: transparent; color: #ffffff; }
        .md-btn--ghost-dark:hover { border-color: #ffffff; color: #ffffff; }

        @media (max-width: 640px) {
            .md-hero { flex-direction: column; align-items: stretch; }
            .md-cover { flex-basis: auto; aspect-ratio: auto; height: 120px; }
        }

        /* ---------- Live quiz ---------- */
        .md-quiz { padding: 18px; }
        .md-quiz .md-card__title { display: flex; align-items: center; gap: 8px; }
        .md-quiz__hint { margin: 6px 0 14px; font-size: .78rem; color: var(--ink-mute); }
        .md-quiz__label { display: block; margin-bottom: 5px; font-family: var(--md-display); font-size: .76rem; font-weight: 500; color: var(--ink); }
        .md-quiz__code { font-family: var(--mono); letter-spacing: .2em; font-variant-numeric: tabular-nums; }
        .md-quiz__code::placeholder { font-family: var(--font); letter-spacing: 0; }
        .md-quiz .md-btn { width: 100%; height: 38px; margin-top: 12px; }
        .md-quiz__error { margin: 6px 0 0; font-size: .76rem; color: var(--md-warn); }
        .md-quiz__error[hidden] { display: none; }

        /* ---------- Stat cards ---------- */
        .md-stats { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 16px; margin-bottom: 16px; }
        @media (max-width: 1080px) { .md-stats { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
        @media (max-width: 520px) { .md-stats { grid-template-columns: minmax(0, 1fr); } }

        .md-stat { padding: 14px 16px 15px; }
        .md-stat__head { display: flex; justify-content: space-between; gap: 8px; }
        .md-stat__head .bi { font-size: .85rem; color: var(--ink-faint); }

        .md-stat__label {
            margin: 0;
            font-family: var(--mono);
            font-size: .62rem;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--ink-mute);
        }

        .md-stat__value {
            margin: 10px 0 4px;
            font-family: var(--md-display);
            font-size: 1.6rem;
            font-weight: 600;
            line-height: 1;
            letter-spacing: -.02em;
            color: var(--ink);
            font-variant-numeric: tabular-nums;
        }

        .md-stat__sub { margin: 0; font-size: .72rem; color: var(--ink-mute); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .md-stat__sub--warn { color: var(--md-warn); }
        .md-stat__sub--good { color: var(--md-good); }

        /* ---------- Course rows ---------- */
        .md-courses { padding: 18px 20px 8px; }

        .md-row {
            display: grid;
            grid-template-columns: 52px minmax(0, 1fr) 150px auto;
            align-items: center;
            gap: 16px;
            padding: 12px 0;
            border-bottom: 1px solid var(--line);
        }

        .md-row:last-of-type { border-bottom: 0; }
        .md-row[hidden] { display: none; }

        .md-thumb {
            width: 52px;
            height: 38px;
            overflow: hidden;
            border-radius: 6px;
            background: repeating-linear-gradient(135deg, var(--md-stripe) 0 6px, var(--cream) 6px 12px);
        }

        .md-thumb img { width: 100%; height: 100%; object-fit: cover; }

        .md-row__title { display: block; font-family: var(--md-display); font-size: .86rem; font-weight: 500; color: var(--ink); line-height: 1.3; }
        .md-row__meta { display: block; margin-top: 2px; font-size: .72rem; color: var(--ink-mute); }

        .md-status__line { display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 6px; }
        .md-status__line b { font-size: .7rem; font-weight: 400; color: var(--ink); font-variant-numeric: tabular-nums; }

        .md-pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 1px 8px;
            border-radius: 5px;
            background: var(--md-pill);
            font-size: .66rem;
            color: var(--ink-soft);
            white-space: nowrap;
        }

        .md-pill--done { background: var(--md-good-bg); color: var(--md-good); }
        .md-pill--warn { background: var(--md-warn-bg); color: var(--md-warn); }

        .md-track { display: block; height: 4px; overflow: hidden; border-radius: 3px; background: var(--md-pill); }
        .md-track > span { display: block; height: 100%; border-radius: inherit; background: var(--ink); }
        [data-state="completed"] .md-track > span { background: var(--md-good); }

        .md-row__btns { display: flex; justify-content: flex-end; gap: 8px; min-width: 96px; }
        .md-row__btns .md-btn { min-width: 84px; }

        @media (max-width: 680px) {
            .md-row { grid-template-columns: 52px minmax(0, 1fr); }
            .md-status, .md-row__btns { grid-column: 1 / -1; }
            .md-row__btns .md-btn { flex: 1; }
        }

        .md-empty { padding: 26px 12px; text-align: center; font-size: .82rem; color: var(--ink-mute); }
        .md-empty strong { display: block; margin-bottom: 2px; font-family: var(--md-display); font-weight: 500; color: var(--ink); }
        .md-empty[hidden] { display: none; }
        .md-empty img { display: block; width: 84px; height: auto; margin: 0 auto 8px; }
        .md-empty a { color: var(--ink); text-decoration: underline; }

        /* ---------- Due soon ---------- */
        .md-due { padding: 18px; }
        .md-due__list { display: flex; flex-direction: column; gap: 10px; }

        .md-due__item { padding: 11px 12px; border: 1px solid var(--line); border-radius: 9px; }
        .md-due__item strong { display: block; margin-top: 7px; font-family: var(--md-display); font-size: .82rem; font-weight: 500; color: var(--ink); }
        .md-due__item span.md-due__meta { display: block; font-size: .7rem; color: var(--ink-mute); }

        /* ---------- Profile ---------- */
        .md-profile { padding: 18px; }
        .md-profile__who { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
        .md-profile__who .md-mono { width: 40px; height: 40px; border-radius: 9px; font-size: .95rem; }
        .md-profile__name { display: block; font-family: var(--md-display); font-weight: 500; color: var(--ink); line-height: 1.3; }
        .md-profile__role { display: block; font-size: .72rem; color: var(--ink-mute); }

        .md-facts { margin: 0 0 12px; padding: 0; }
        .md-facts div { display: grid; grid-template-columns: 92px minmax(0, 1fr); gap: 10px; padding: 6px 0; border-top: 1px solid var(--line); font-size: .76rem; }
        .md-facts dt { color: var(--ink-mute); }
        .md-facts dd { margin: 0; color: var(--ink); overflow-wrap: anywhere; }

        /* ---------- My courses pane ---------- */
        .md-bar { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 12px; margin-bottom: 16px; }
        .md-bar__group { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; }
        .md-bar .md-search { width: 240px; }
        @media (max-width: 680px) { .md-bar .md-search, .md-bar__group { width: 100%; } }

        .md-switch { display: inline-flex; height: 36px; padding: 3px; border: 1px solid var(--line-strong); border-radius: 8px; background: var(--paper); }
        .md-switch button { padding: 0 14px; border: 0; border-radius: 5px; background: transparent; font-size: .78rem; color: var(--ink-mute); white-space: nowrap; }
        .md-switch button:hover { color: var(--ink); }
        .md-switch button.is-on { background: var(--ink); color: var(--paper); font-family: var(--md-display); font-weight: 500; }

        /* ---------- Forms ---------- */
        .md-input {
            width: 100%;
            height: 36px;
            padding: 0 12px;
            border: 1px solid var(--line-strong);
            border-radius: 7px;
            background: var(--paper);
            color: var(--ink);
            font: inherit;
            font-size: .82rem;
            transition: border-color .15s ease-out, box-shadow .15s ease-out;
        }

        .md-input::placeholder { color: var(--ink-faint); }
        .md-input:focus { border-color: var(--ink); outline: none; box-shadow: 0 0 0 3px var(--accent-soft); }

        :focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }

        @media (prefers-reduced-motion: reduce) {
            .md-menu__pop, .md-nav, .md-btn, .md-input { transition: none; }
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnPane" runat="server" Value="pane-overview" />

        <div class="md-shell">

            <!-- ================= SIDEBAR ================= -->
            <aside class="md-side">
                <a class="md-side__brand" href="index.aspx" title="Open the public site">
                    <img class="md-side__logo md-side__logo--light" src="assets/img/meowlet-logo.png" alt="Meowlet Education" />
                    <img class="md-side__logo md-side__logo--dark" src="assets/img/meowlet-logo-dark.png" alt="Meowlet Education" />
                    <img class="md-side__mark" src="assets/img/meowlet-mark.png" alt="Meowlet Education" />
                </a>
                <span class="md-ws">Learner workspace</span>

                <nav aria-label="Member sections">
                    <button type="button" class="md-nav is-active" data-pane="pane-overview">
                        <i class="bi bi-grid-1x2" aria-hidden="true"></i><span>Dashboard</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-courses">
                        <i class="bi bi-journal-bookmark" aria-hidden="true"></i><span>My courses</span>
                    </button>
                    <a class="md-nav" href="Courses.aspx">
                        <i class="bi bi-book" aria-hidden="true"></i><span>Browse courses</span>
                    </a>
                    <button type="button" class="md-nav" data-quiz="1">
                        <i class="bi bi-lightning-charge" aria-hidden="true"></i><span>Live quiz</span>
                    </button>
                    <a class="md-nav" href="Profile.aspx">
                        <i class="bi bi-person" aria-hidden="true"></i><span>My profile</span>
                    </a>
                    <a class="md-nav" href="index.aspx">
                        <i class="bi bi-house" aria-hidden="true"></i><span>Public site</span>
                    </a>
                </nav>

                <asp:LinkButton ID="lnkSideSignOut" runat="server" CssClass="md-side__out"
                    OnClick="lnkLogout_Click"
                    OnClientClick="return confirm('Sign out of Meowlet?');">
                    <i class="bi bi-box-arrow-right" aria-hidden="true"></i><span>Sign out</span>
                </asp:LinkButton>
            </aside>

            <!-- ================= MAIN ================= -->
            <main class="md-main" id="main">

                <header class="md-top">
                    <div>
                        <h1 class="md-title" id="pageTitle"><asp:Literal ID="litGreeting" runat="server">Welcome back</asp:Literal>, <asp:Literal ID="litWelcomeName" runat="server">Member</asp:Literal></h1>
                        <p class="md-sub" id="pageSub">Here's where you left off.</p>
                    </div>
                    <div class="md-top__tools">
                        <label class="md-search md-global">
                            <i class="bi bi-search" aria-hidden="true"></i>
                            <input type="search" id="globalSearch" class="md-input" placeholder="Search my courses..." aria-label="Search my courses" />
                        </label>
                        <button type="button" class="md-icon-btn" id="themeToggle" aria-label="Switch theme">
                            <i class="bi bi-moon" aria-hidden="true"></i>
                        </button>
                        <div class="md-menu">
                            <button type="button" class="md-mono" aria-haspopup="true" aria-label="Account menu">
                                <asp:Literal ID="litMenuAvatar" runat="server">?</asp:Literal>
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

                    <!-- ---------- DASHBOARD ---------- -->
                    <section id="pane-overview" class="md-pane is-active" aria-labelledby="pageTitle">

                        <div class="md-grid md-grid--top">
                            <%-- newest course that isn't finished --%>
                            <asp:PlaceHolder ID="phHero" runat="server">
                                <div class="md-hero">
                                    <div class="md-cover"><asp:Literal ID="litHeroCover" runat="server" /></div>
                                    <div class="md-hero__body">
                                        <p class="md-kicker">Continue learning</p>
                                        <h2 class="md-hero__title"><asp:Literal ID="litHeroTitle" runat="server" /></h2>
                                        <p class="md-hero__lesson"><asp:Literal ID="litHeroLesson" runat="server" /></p>
                                        <div class="md-hero__progress">
                                            <span class="md-track"><span style="width: <%= HeroPercent %>%"></span></span>
                                            <b><%= HeroPercent %>%</b>
                                        </div>
                                        <div class="md-hero__btns">
                                            <a class="md-btn md-btn--accent" href="<%= HeroHref %>"><i class="bi bi-play-fill" aria-hidden="true"></i>Resume lesson</a>
                                            <button type="button" class="md-btn md-btn--ghost-dark" data-go="pane-courses"><i class="bi bi-journal-bookmark" aria-hidden="true"></i>All my courses</button>
                                        </div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phHeroEmpty" runat="server" Visible="false">
                                <div class="md-hero">
                                    <div class="md-cover"><img src="assets/img/cat-reach.webp" alt="" /></div>
                                    <div class="md-hero__body">
                                        <p class="md-kicker">Up next</p>
                                        <h2 class="md-hero__title"><asp:Literal ID="litHeroEmpty" runat="server">Pick your first course</asp:Literal></h2>
                                        <p class="md-hero__lesson">Enrol in a course and it shows up here, ready to resume.</p>
                                        <div class="md-hero__btns" style="margin-top: 16px;">
                                            <a class="md-btn md-btn--accent" href="Courses.aspx"><i class="bi bi-search" aria-hidden="true"></i>Browse courses</a>
                                        </div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>

                            <div class="md-card md-quiz" id="quizBox">
                                <h2 class="md-card__title"><i class="bi bi-lightning-charge" aria-hidden="true"></i>Join a live quiz</h2>
                                <p class="md-quiz__hint">Your tutor will share a game PIN on screen.</p>
                                <label class="md-quiz__label" for="<%= txtQuizCode.ClientID %>">Game PIN</label>
                                <asp:TextBox ID="txtQuizCode" runat="server" CssClass="md-input md-quiz__code"
                                    MaxLength="7" placeholder="e.g. 482 915" autocomplete="off"
                                    inputmode="numeric" aria-describedby="quizError" />
                                <p class="md-quiz__error" id="quizError" role="alert" hidden="hidden">Enter all 6 digits.</p>
                                <asp:Button ID="btnJoinQuiz" runat="server" Text="Join game" CssClass="md-btn md-btn--accent"
                                    OnClick="btnJoinQuiz_Click" UseSubmitBehavior="false"
                                    OnClientClick="if (!window.mdCheckQuiz()) return false;" />
                            </div>
                        </div>

                        <div class="md-stats">
                            <div class="md-card md-stat">
                                <div class="md-stat__head"><p class="md-stat__label">Courses in progress</p><i class="bi bi-journal-bookmark" aria-hidden="true"></i></div>
                                <p class="md-stat__value"><asp:Literal ID="litStatInProgress" runat="server">0</asp:Literal></p>
                                <p class="md-stat__sub"><asp:Literal ID="litStatCompleted" runat="server">0</asp:Literal> completed</p>
                            </div>
                            <div class="md-card md-stat">
                                <div class="md-stat__head"><p class="md-stat__label">Courses enrolled</p><i class="bi bi-collection" aria-hidden="true"></i></div>
                                <p class="md-stat__value"><asp:Literal ID="litStatEnrolled" runat="server">0</asp:Literal></p>
                                <p class="md-stat__sub"><asp:Literal ID="litStatNext" runat="server">Nothing in progress</asp:Literal></p>
                            </div>
                            <div class="md-card md-stat">
                                <div class="md-stat__head"><p class="md-stat__label">Tutor sessions</p><i class="bi bi-calendar-event" aria-hidden="true"></i></div>
                                <p class="md-stat__value"><asp:Literal ID="litStatSessions" runat="server">0</asp:Literal></p>
                                <asp:Literal ID="litStatSessionSub" runat="server" />
                            </div>
                            <div class="md-card md-stat">
                                <div class="md-stat__head"><p class="md-stat__label">Lessons done</p><i class="bi bi-check2-square" aria-hidden="true"></i></div>
                                <p class="md-stat__value"><asp:Literal ID="litStatLessons" runat="server">0</asp:Literal></p>
                                <asp:Literal ID="litStatLessonsSub" runat="server" />
                            </div>
                        </div>

                        <div class="md-grid">
                            <div class="md-card md-courses">
                                <div class="md-card__head">
                                    <h2 class="md-card__title">My courses</h2>
                                    <a class="md-card__link" href="Courses.aspx">Browse all <i class="bi bi-arrow-right" aria-hidden="true"></i></a>
                                </div>
                                <asp:Repeater ID="rptRecentCourses" runat="server">
                                    <ItemTemplate>
                                        <div class="md-row" data-state="<%# Eval("State") %>">
                                            <span class="md-thumb"><%# Thumb(Eval("ImageUrl")) %></span>
                                            <div>
                                                <span class="md-row__title"><%# Html(Eval("Title")) %></span>
                                                <span class="md-row__meta"><%# Eval("TotalLessons") %> lessons · <%# Html(Eval("TutorName")) %></span>
                                            </div>
                                            <div class="md-status">
                                                <span class="md-status__line"><%# StatusPill(Eval("State")) %><b><%# Eval("Percent") %>%</b></span>
                                                <span class="md-track"><span style="width: <%# Eval("Percent") %>%"></span></span>
                                            </div>
                                            <span class="md-row__btns">
                                                <%# (string)Eval("State") == "completed"
                                                    ? "<a class=\"md-btn md-btn--sm\" href=\"course.aspx?id=" + Eval("CourseId") + "\"><i class=\"bi bi-arrow-counterclockwise\" aria-hidden=\"true\"></i>Review</a>"
                                                    : "<a class=\"md-btn md-btn--sm md-btn--ink\" href=\"course.aspx?id=" + Eval("CourseId") + "\">Continue</a>" %>
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <asp:PlaceHolder ID="phNoRecent" runat="server" Visible="false">
                                    <div class="md-empty">
                                        <img src="assets/img/cat-reading.webp" alt="" />
                                        <strong>You haven't enrolled in a course yet</strong>
                                        <a href="Courses.aspx">Browse courses</a> to find one.
                                    </div>
                                </asp:PlaceHolder>
                            </div>

                            <div class="md-col">
                                <div class="md-card md-due">
                                    <div class="md-card__head">
                                        <h2 class="md-card__title">Due soon</h2>
                                    </div>
                                    <div class="md-due__list">
                                        <asp:Repeater ID="rptSessions" runat="server">
                                            <ItemTemplate>
                                                <div class="md-due__item">
                                                    <%# DuePill(Eval("StartsAt")) %>
                                                    <strong>Session with <%# Html(Eval("TutorName")) %></strong>
                                                    <span class="md-due__meta"><%# Html(Eval("Topic")) %> · <%# Html(Eval("Status")) %></span>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                    <asp:PlaceHolder ID="phNoSessions" runat="server" Visible="false">
                                        <p class="md-empty"><strong>Nothing due</strong>Booked tutor sessions show up here.</p>
                                    </asp:PlaceHolder>
                                </div>

                                <div class="md-card md-profile">
                                    <div class="md-card__head">
                                        <h2 class="md-card__title">Your account</h2>
                                        <a class="md-card__link" href="Profile.aspx">Edit <i class="bi bi-arrow-right" aria-hidden="true"></i></a>
                                    </div>
                                    <div class="md-profile__who">
                                        <span class="md-mono" aria-hidden="true"><asp:Literal ID="litAvatar" runat="server">?</asp:Literal></span>
                                        <span>
                                            <span class="md-profile__name"><asp:Literal ID="litProfileName" runat="server" /></span>
                                            <span class="md-profile__role"><asp:Literal ID="litRole" runat="server">Student</asp:Literal></span>
                                        </span>
                                    </div>
                                    <dl class="md-facts">
                                        <div><dt>Email</dt><dd><asp:Literal ID="litProfileEmail" runat="server" /></dd></div>
                                        <div><dt>Age range</dt><dd><asp:Literal ID="litProfileAge" runat="server">Not set</asp:Literal></dd></div>
                                        <div><dt>Experience</dt><dd><asp:Literal ID="litProfileLevel" runat="server">Not set</asp:Literal></dd></div>
                                        <div><dt>Member since</dt><dd><asp:Literal ID="litProfileJoined" runat="server" /></dd></div>
                                    </dl>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- ---------- MY COURSES ---------- -->
                    <section id="pane-courses" class="md-pane" aria-labelledby="pageTitle">
                        <div class="md-bar">
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
                                <a class="md-btn md-btn--ink" href="Courses.aspx">Browse courses</a>
                            </div>
                        </div>

                        <div class="md-card md-courses">
                            <div id="courseRows">
                                <asp:Repeater ID="rptMyCourses" runat="server" OnItemCommand="rptMyCourses_ItemCommand">
                                    <ItemTemplate>
                                        <div class="md-row" data-state="<%# Eval("State") %>" data-text="<%# Attr(Eval("Title")) %> <%# Attr(Eval("CourseCode")) %> <%# Attr(Eval("TutorName")) %>">
                                            <span class="md-thumb"><%# Thumb(Eval("ImageUrl")) %></span>
                                            <div>
                                                <span class="md-row__title"><%# Html(Eval("Title")) %></span>
                                                <span class="md-row__meta"><%# Eval("DoneLessons") %> of <%# Eval("TotalLessons") %> lessons · <%# Html(Eval("TutorName")) %></span>
                                            </div>
                                            <div class="md-status">
                                                <span class="md-status__line"><%# StatusPill(Eval("State")) %><b><%# Eval("Percent") %>%</b></span>
                                                <span class="md-track"><span style="width: <%# Eval("Percent") %>%"></span></span>
                                            </div>
                                            <span class="md-row__btns">
                                                <a class="md-btn md-btn--sm <%# (string)Eval("State") == "completed" ? "" : "md-btn--ink" %>" href="course.aspx?id=<%# Eval("CourseId") %>">
                                                    <%# (string)Eval("State") == "completed" ? "Review" : "Continue" %>
                                                </a>
                                                <asp:LinkButton runat="server" CommandName="Drop" CommandArgument='<%# Eval("CourseId") %>'
                                                    CssClass="md-btn md-btn--sm md-btn--danger" Text="Drop"
                                                    OnClientClick="return confirm('Drop this course? Your lesson progress is kept if you enrol again.');" />
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <p class="md-empty" id="courseNoMatch" hidden="hidden">No courses match.</p>
                            </div>
                            <asp:PlaceHolder ID="phNoCourses" runat="server" Visible="false">
                                <div class="md-empty">
                                    <img src="assets/img/cat-reach.webp" alt="" />
                                    <strong>No courses yet</strong>
                                    Courses you enrol in from <a href="Courses.aspx">Browse courses</a> show up here.
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </section>
                </div>
            </main>
        </div>

        <script type="text/javascript">
            // @ts-nocheck
            (function () {
                var hdnPane = document.getElementById('<%= hdnPane.ClientID %>');
                var navItems = document.querySelectorAll('.md-nav[data-pane]');
                var panes = document.querySelectorAll('.md-pane');
                var title = document.getElementById('pageTitle');
                var sub = document.getElementById('pageSub');
                var greeting = title.textContent;
                var greetingSub = sub.textContent;

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
                    if (paneId === 'pane-courses') {
                        title.textContent = 'My courses';
                        sub.textContent = 'Everything you are enrolled in.';
                    } else {
                        title.textContent = greeting;
                        sub.textContent = greetingSub;
                    }
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

                show(hdnPane.value || 'pane-overview', true);

                // ---- theme ----
                var themeToggle = document.getElementById('themeToggle');

                function syncTheme() {
                    var dark = document.documentElement.getAttribute('data-theme') === 'dark';
                    themeToggle.querySelector('.bi').className = dark ? 'bi bi-sun' : 'bi bi-moon';
                    themeToggle.setAttribute('aria-label', dark ? 'Switch to light theme' : 'Switch to dark theme');
                }

                themeToggle.onclick = function () {
                    var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                    document.documentElement.setAttribute('data-theme', next);
                    try { localStorage.setItem('meowletMemberTheme', next); } catch (e) { }
                    syncTheme();
                };

                syncTheme();

                // ---- My courses: All / In progress / Completed + text search ----
                var filterButtons = document.querySelectorAll('#courseFilter button');
                var rows = document.querySelectorAll('#courseRows .md-row');
                var noMatch = document.getElementById('courseNoMatch');
                var courseSearch = document.getElementById('courseSearch');
                var filter = '';

                function applyFilter() {
                    var q = courseSearch.value.trim().toLowerCase();
                    var shown = 0;
                    for (var i = 0; i < rows.length; i++) {
                        var match = (!filter || rows[i].getAttribute('data-state') === filter) &&
                            (!q || (rows[i].getAttribute('data-text') || '').toLowerCase().indexOf(q) !== -1);
                        rows[i].hidden = !match;
                        if (match) { shown++; }
                    }
                    for (var b = 0; b < filterButtons.length; b++) {
                        var on = filterButtons[b].getAttribute('data-filter') === filter;
                        filterButtons[b].className = on ? 'is-on' : '';
                        filterButtons[b].setAttribute('aria-pressed', on ? 'true' : 'false');
                    }
                    noMatch.hidden = !(rows.length > 0 && shown === 0);
                }

                for (var f = 0; f < filterButtons.length; f++) {
                    filterButtons[f].onclick = function () { filter = this.getAttribute('data-filter'); applyFilter(); };
                }
                courseSearch.oninput = applyFilter;

                // Enter in a search box must not submit the form.
                var searchBoxes = document.querySelectorAll('.md-search input');
                for (var s = 0; s < searchBoxes.length; s++) {
                    searchBoxes[s].onkeydown = function (e) {
                        if (e.key === 'Enter') { e.preventDefault(); }
                    };
                }

                // ---- top search filters My courses ----
                var globalSearch = document.getElementById('globalSearch');

                globalSearch.onkeydown = function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        courseSearch.value = globalSearch.value;
                        show('pane-courses');
                        applyFilter();
                        courseSearch.focus();
                    }
                };

                // ---- live quiz: 6 digits (a space in the middle is fine), Enter joins ----
                var quizCode = document.getElementById('<%= txtQuizCode.ClientID %>');
                var quizJoin = document.getElementById('<%= btnJoinQuiz.ClientID %>');
                var quizError = document.getElementById('quizError');

                window.mdCheckQuiz = function () {
                    var ok = /^\d{6}$/.test(quizCode.value.replace(/\s/g, ''));
                    quizError.hidden = ok;
                    if (!ok) { quizCode.focus(); }
                    return ok;
                };

                quizCode.oninput = function () {
                    var digits = quizCode.value.replace(/\D/g, '').slice(0, 6);
                    quizCode.value = digits.length > 3 ? digits.slice(0, 3) + ' ' + digits.slice(3) : digits;
                    quizError.hidden = true;
                };

                quizCode.onkeydown = function (e) {
                    if (e.key === 'Enter') { e.preventDefault(); quizJoin.click(); }
                };

                // "Live quiz" in the sidebar jumps to the PIN box.
                var quizLinks = document.querySelectorAll('[data-quiz]');
                for (var qz = 0; qz < quizLinks.length; qz++) {
                    quizLinks[qz].onclick = function () {
                        show('pane-overview', true);
                        document.getElementById('quizBox').scrollIntoView({ block: 'center' });
                        quizCode.focus();
                    };
                }
            })();
        </script>
    </form>
</body>
</html>

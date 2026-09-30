<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="admindashboard.aspx.cs" Inherits="MeowletEducation.AdminDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin - Meowlet Education</title>
    <link rel="icon" href="favicon.ico" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="assets/css/style.css" />
    <script type="text/javascript">
        // Admin theme: dark unless this browser chose light in Settings.
        (function () {
            var theme = 'dark';
            try { theme = localStorage.getItem('meowletAdminTheme') || 'dark'; } catch (e) { }
            document.documentElement.setAttribute('data-theme', theme === 'light' ? 'light' : 'dark');
        })();
    </script>
    <style>
        /* Admin panel. Colours, type, buttons (.btn), tags (.tag) and chips
           (.chip) come from style.css so the panel reads as the same product
           as the public site. Everything page-specific is prefixed ad-. */

        /* ---------- Themes ----------
           Light uses style.css tokens as they are. Dark swaps the same
           tokens, so every rule below works in both. */
        :root {
            --ad-pie-1: #6d6053;
            --ad-pie-2: #b9703c;
            --ad-pie-3: #241d15;
            --ad-danger: #a3361f;
            --ad-danger-bg: #fbeae4;
            --ad-danger-line: #ecc4b8;
            --ad-accent-text: #8d5122;
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
            --ad-pie-1: #8f8270;
            --ad-pie-2: #d68a4e;
            --ad-pie-3: #efe3cf;
            --ad-danger: #f0a08c;
            --ad-danger-bg: rgba(232, 120, 96, .12);
            --ad-danger-line: rgba(232, 120, 96, .4);
            --ad-accent-text: #eab087;
            color-scheme: dark;
        }

        html[data-theme="dark"] .btn--primary:hover { background: #ffffff; }
        html[data-theme="dark"] .ad-side__logo--light,
        html[data-theme="light"] .ad-side__logo--dark { display: none; }
        .tag--accent { color: var(--ad-accent-text); }

        body {
            font-size: 14px;
            line-height: 1.5;
            color: var(--ink-soft);
            background: var(--cream);
            overflow-x: visible;
        }

        /* ---------- Shell ---------- */
        .ad-shell {
            display: flex;
            min-height: 100vh;
        }

        .ad-side {
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

        .ad-side__brand {
            display: flex;
            align-items: center;
            height: 36px;
            padding: 0 8px;
            margin-bottom: 22px;
        }

        .ad-side__logo { height: 40px; width: auto; }
        .ad-side__mark { display: none; height: 32px; width: 32px; border-radius: 8px; }

        .ad-side__group {
            margin: 18px 10px 6px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: var(--ink-faint);
        }

        .ad-side__group:first-of-type { margin-top: 0; }

        .ad-nav {
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

        .ad-nav .bi { font-size: 1rem; flex-shrink: 0; }
        .ad-nav:hover { background: var(--beige-deep); color: var(--ink); }

        .ad-nav.is-active {
            background: var(--paper);
            color: var(--ink);
            font-weight: 600;
            box-shadow: var(--shadow-sm);
        }

        .ad-nav.is-active .bi { color: var(--accent); }

        .ad-side__foot {
            margin-top: auto;
            padding-top: 12px;
            border-top: 1px solid var(--line);
        }

        .ad-collapse .bi { transition: transform .2s ease-out; }

        /* icons-only sidebar: toggled, and always on narrow screens */
        .ad-shell.is-collapsed .ad-side { width: 68px; padding-inline: 10px; }
        .ad-shell.is-collapsed .ad-side__brand { justify-content: center; padding: 0; }
        .ad-shell.is-collapsed .ad-side__logo { display: none; }
        .ad-shell.is-collapsed .ad-side__mark { display: block; }
        .ad-shell.is-collapsed .ad-side__group { height: 1px; margin: 12px 6px; font-size: 0; background: var(--line); }
        .ad-shell.is-collapsed .ad-nav { justify-content: center; padding-inline: 0; }
        .ad-shell.is-collapsed .ad-nav > span { display: none; }
        .ad-shell.is-collapsed .ad-collapse .bi { transform: rotate(180deg); }

        @media (max-width: 760px) {
            .ad-side { width: 68px; padding-inline: 10px; }
            .ad-side__brand { justify-content: center; padding: 0; }
            .ad-side__logo { display: none; }
            .ad-side__mark { display: block; }
            .ad-side__group { height: 1px; margin: 12px 6px; font-size: 0; background: var(--line); }
            .ad-nav { justify-content: center; padding-inline: 0; }
            .ad-nav > span { display: none; }
            .ad-collapse { display: none; }
        }

        .ad-main {
            flex: 1;
            min-width: 0;
            padding: 24px clamp(16px, 3vw, 36px) 56px;
        }

        /* ---------- Top bar ---------- */
        .ad-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
            margin-bottom: 26px;
        }

        .ad-title {
            margin: 0;
            font-size: 1.6rem;
            font-weight: 600;
            line-height: 1.2;
            letter-spacing: -.01em;
            color: var(--ink);
        }

        .ad-sub { margin: 4px 0 0; color: var(--ink-mute); }

        .ad-top__tools { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }

        .ad-search { position: relative; display: block; }
        .ad-search .bi {
            position: absolute;
            left: 11px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--ink-faint);
            pointer-events: none;
        }
        .ad-search .ad-input { padding-left: 32px; }

        .ad-global { width: 280px; }
        .ad-global .ad-input { padding-right: 58px; }

        .ad-kbd {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            padding: 1px 6px;
            border: 1px solid var(--line);
            border-radius: 4px;
            font-family: var(--mono);
            font-size: 11px;
            color: var(--ink-faint);
            pointer-events: none;
        }

        @media (max-width: 1040px) { .ad-global { display: none; } }

        /* ---------- Profile menu ---------- */
        .ad-menu { position: relative; }

        .ad-menu__btn {
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

        .ad-menu__btn .bi-chevron-down { font-size: 11px; color: var(--ink-faint); }

        .ad-menu__pop {
            position: absolute;
            top: 100%;
            right: 0;
            z-index: 20;
            min-width: 200px;
            padding-top: 6px;
            visibility: hidden;
            opacity: 0;
            transition: opacity .15s ease-out, visibility .15s;
        }

        .ad-menu:hover .ad-menu__pop,
        .ad-menu:focus-within .ad-menu__pop { visibility: visible; opacity: 1; }

        .ad-menu__card {
            padding: 6px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            box-shadow: var(--shadow);
        }

        .ad-menu__who { padding: 8px 10px 10px; margin-bottom: 4px; border-bottom: 1px solid var(--line); }
        .ad-menu__who strong { display: block; color: var(--ink); }
        .ad-menu__who span { font-size: .8rem; color: var(--ink-faint); }

        .ad-menu__item {
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

        .ad-menu__item:hover { background: var(--cream); color: var(--ink); }
        .ad-menu__item--danger { color: var(--ad-danger); }
        .ad-menu__item--danger:hover { background: var(--ad-danger-bg); }

        /* ---------- Feedback line after an action ---------- */
        .ad-flash {
            margin: 0 0 20px;
            padding: 10px 14px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            color: var(--ink);
        }

        .ad-flash--error { border-color: var(--ad-danger-line); background: var(--ad-danger-bg); color: var(--ad-danger); }

        /* ---------- Panels ---------- */
        .ad-pane { display: none; }
        .ad-pane.is-active { display: block; }

        .ad-panel {
            margin-bottom: 20px;
            border: 1px solid var(--line);
            border-radius: 10px;
            background: var(--paper);
        }

        .ad-panel__head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            padding: 16px 18px 14px;
        }

        .ad-panel__title {
            margin: 0;
            font-size: 1rem;
            font-weight: 600;
            color: var(--ink);
        }

        .ad-panel__hint { margin: 2px 0 0; font-size: .85rem; color: var(--ink-mute); }

        .ad-panel__body { padding: 0 18px 18px; }

        .ad-sample {
            display: inline-block;
            margin-left: 8px;
            padding: 1px 8px;
            border: 1px dashed var(--sand);
            border-radius: var(--pill);
            font-size: .72rem;
            font-weight: 600;
            color: var(--ink-faint);
            vertical-align: 2px;
        }

        /* ---------- Overview ---------- */
        .ad-stats {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            margin-bottom: 20px;
            border: 1px solid var(--line);
            border-radius: 10px;
            background: var(--paper);
        }

        .ad-stat { padding: 16px 18px; }
        .ad-stat + .ad-stat { border-left: 1px solid var(--line); }

        .ad-stat dt { font-size: .8rem; color: var(--ink-mute); }

        .ad-stat dd {
            margin: 4px 0 0;
            font-size: 1.5rem;
            font-weight: 600;
            line-height: 1.2;
            color: var(--ink);
            font-variant-numeric: tabular-nums;
        }

        .ad-stat small { display: block; margin-top: 2px; font-size: .78rem; color: var(--ink-faint); }

        @media (max-width: 1100px) {
            .ad-stats { grid-template-columns: repeat(3, minmax(0, 1fr)); }
            .ad-stat:nth-child(4) { border-left: 0; }
            .ad-stat:nth-child(n+4) { border-top: 1px solid var(--line); }
        }

        @media (max-width: 620px) {
            .ad-stats { grid-template-columns: repeat(2, minmax(0, 1fr)); }
            .ad-stat:nth-child(odd) { border-left: 0; }
            .ad-stat:nth-child(4) { border-left: 1px solid var(--line); }
            .ad-stat:nth-child(n+3) { border-top: 1px solid var(--line); }
        }

        .ad-pair {
            display: grid;
            grid-template-columns: minmax(0, 1.65fr) minmax(0, 1fr);
            gap: 20px;
            align-items: stretch;
        }

        .ad-pair > .ad-panel { display: flex; flex-direction: column; }
        .ad-pair .ad-panel__body { flex: 1; display: flex; align-items: center; justify-content: center; }

        @media (max-width: 1100px) { .ad-pair { grid-template-columns: minmax(0, 1fr); } }

        /* line chart, drawn by script from the server's monthly counts */
        .ad-line { width: 100%; height: auto; overflow: visible; }
        .ad-line .grid { stroke: var(--line); stroke-width: 1; }
        .ad-line .axis { font-size: 11px; fill: var(--ink-faint); }
        .ad-line .val { font-size: 11px; font-weight: 600; fill: var(--ink-mute); }
        .ad-line .area { fill: var(--accent-soft); opacity: .7; }
        .ad-line .stroke { fill: none; stroke: var(--accent); stroke-width: 2.25; stroke-linejoin: round; stroke-linecap: round; }
        .ad-line .dot { fill: var(--paper); stroke: var(--accent); stroke-width: 2; }
        .ad-line .dot.now { fill: var(--accent); }

        /* pie */
        .ad-pie {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: center;
            gap: 24px;
            width: 100%;
        }

        .ad-pie__disc {
            display: grid;
            place-items: center;
            width: 152px;
            height: 152px;
            flex-shrink: 0;
            border-radius: 50%;
        }

        .ad-pie__hole {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 96px;
            height: 96px;
            border-radius: 50%;
            background: var(--paper);
            font-size: .75rem;
            color: var(--ink-faint);
        }

        .ad-pie__hole strong { font-size: 1.35rem; line-height: 1.1; color: var(--ink); }

        .ad-pie__legend { min-width: 160px; margin: 0; padding: 0; list-style: none; }

        .ad-pie__legend li {
            display: flex;
            align-items: center;
            gap: 9px;
            padding: 7px 0;
        }

        .ad-pie__legend li + li { border-top: 1px solid var(--line); }
        .ad-pie__swatch { width: 10px; height: 10px; flex-shrink: 0; border-radius: 3px; }
        .ad-pie__label { flex: 1; }
        .ad-pie__value { font-weight: 600; color: var(--ink); font-variant-numeric: tabular-nums; }
        .ad-pie__share { width: 3.2em; text-align: right; color: var(--ink-faint); font-variant-numeric: tabular-nums; }

        /* ---------- Tables ---------- */
        .ad-tools {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
            padding: 0 18px 12px;
        }

        .ad-tools .ad-search { flex: 1; min-width: 200px; }
        .ad-tools .ad-select { width: auto; }
        .ad-tools__meta { margin-left: auto; font-size: .82rem; color: var(--ink-faint); }

        .ad-chips { display: flex; flex-wrap: wrap; gap: 6px; padding: 0 18px 14px; }
        .ad-chips .chip { padding: 5px 11px; font-size: .78rem; }
        .ad-chips .chip b { margin-left: 4px; font-weight: 600; opacity: .75; }

        .ad-table-wrap { overflow-x: auto; border-top: 1px solid var(--line); }
        .ad-table-wrap[hidden] { display: none; }

        .ad-table {
            width: 100%;
            min-width: 680px;
            border-collapse: collapse;
            font-size: .88rem;
        }

        .ad-table th {
            padding: 10px 18px;
            border-bottom: 1px solid var(--line);
            font-size: .78rem;
            font-weight: 600;
            text-align: left;
            color: var(--ink-mute);
            white-space: nowrap;
        }

        .ad-table td {
            padding: 11px 18px;
            border-bottom: 1px solid var(--line);
            vertical-align: middle;
        }

        .ad-table tbody tr:last-child td { border-bottom: 0; }
        .ad-table tbody tr:hover td { background: var(--cream); }
        .ad-table .num { text-align: right; font-variant-numeric: tabular-nums; }
        .ad-table .end { text-align: right; white-space: nowrap; }
        .ad-table strong { font-weight: 600; color: var(--ink); }
        .ad-table .quiet { color: var(--ink-mute); }
        .ad-table .code { font-family: var(--mono); font-size: .8rem; color: var(--ink-mute); }

        .ad-empty td,
        .ad-empty-block {
            padding: 32px 18px;
            text-align: center;
            color: var(--ink-mute);
        }

        .ad-empty td:hover { background: transparent; }
        .ad-empty strong { display: block; margin-bottom: 2px; color: var(--ink); }

        .ad-actions { display: inline-flex; gap: 6px; }
        .ad-actions .btn { padding: 6px 12px; font-size: .8rem; box-shadow: none; }
        .btn.ad-danger { color: var(--ad-danger); }
        .btn.ad-danger:hover { background: var(--ad-danger-bg); border-color: var(--ad-danger-line); }

        .ad-tag--ink { background: var(--ink); border-color: var(--ink); color: var(--paper); }

        /* newest accounts list on the overview */
        .ad-list { margin: 0; padding: 0; list-style: none; border-top: 1px solid var(--line); }

        .ad-list li {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto auto;
            align-items: center;
            gap: 16px;
            padding: 11px 18px;
        }

        .ad-list li + li { border-top: 1px solid var(--line); }
        .ad-list__who strong { display: block; font-weight: 600; color: var(--ink); }
        .ad-list__who span { font-size: .82rem; color: var(--ink-mute); }
        .ad-list time { font-size: .82rem; color: var(--ink-faint); font-variant-numeric: tabular-nums; }

        /* ---------- Tabs & view switch ---------- */
        .ad-tabs {
            display: flex;
            gap: 4px;
            margin-bottom: 18px;
            border-bottom: 1px solid var(--line);
        }

        .ad-tab {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: -1px;
            padding: 9px 12px;
            border: 0;
            border-bottom: 2px solid transparent;
            background: transparent;
            color: var(--ink-mute);
            font-weight: 500;
        }

        .ad-tab:hover { color: var(--ink); }
        .ad-tab.is-active { border-bottom-color: var(--ink); color: var(--ink); font-weight: 600; }

        .ad-tab__count {
            padding: 0 7px;
            border-radius: var(--pill);
            background: var(--beige);
            font-size: .75rem;
            font-variant-numeric: tabular-nums;
        }

        .ad-sub-pane { display: none; }
        .ad-sub-pane.is-active { display: block; }

        .ad-switch {
            display: inline-flex;
            padding: 2px;
            border: 1px solid var(--line);
            border-radius: var(--radius-btn);
            background: var(--cream);
        }

        .ad-switch button {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 10px;
            border: 0;
            border-radius: var(--radius-btn);
            background: transparent;
            font-size: .8rem;
            color: var(--ink-mute);
        }

        .ad-switch button:hover { color: var(--ink); }
        .ad-switch button.is-on { background: var(--paper); color: var(--ink); font-weight: 600; box-shadow: var(--shadow-sm); }

        .ad-cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 12px;
            padding: 16px 18px 18px;
            border-top: 1px solid var(--line);
        }

        .ad-cards[hidden] { display: none; }

        .ad-course {
            display: flex;
            flex-direction: column;
            gap: 6px;
            padding: 14px 16px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--cream);
        }

        .ad-course__top { display: flex; justify-content: space-between; align-items: center; gap: 8px; }
        .ad-course__title { margin: 2px 0 0; font-size: .98rem; font-weight: 600; line-height: 1.35; color: var(--ink); }
        .ad-course__meta { margin: 0; font-size: .82rem; color: var(--ink-mute); }
        .ad-course .ad-actions { margin-top: auto; padding-top: 10px; }

        /* ---------- Forms ---------- */
        .ad-form {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 16px;
            max-width: 900px;
        }

        .ad-form .wide { grid-column: span 2; }
        .ad-form .full { grid-column: 1 / -1; }

        @media (max-width: 900px) {
            .ad-form { grid-template-columns: minmax(0, 1fr); }
            .ad-form .wide { grid-column: auto; }
        }

        .ad-field label,
        .ad-label {
            display: block;
            margin-bottom: 6px;
            font-size: .85rem;
            font-weight: 600;
            color: var(--ink);
        }

        .ad-field p { margin: 5px 0 0; font-size: .8rem; color: var(--ink-faint); }

        .ad-input,
        .ad-select {
            width: 100%;
            padding: 8px 11px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink);
            font: inherit;
            transition: border-color .15s ease-out;
        }

        .ad-input:hover,
        .ad-select:hover { border-color: var(--sand); }

        .ad-input:focus,
        .ad-select:focus { border-color: var(--ink); outline: none; box-shadow: 0 0 0 3px var(--accent-soft); }

        .ad-check { display: flex; align-items: center; gap: 9px; }
        .ad-check label { margin: 0; font-weight: 500; }
        .ad-check input { width: 16px; height: 16px; accent-color: var(--ink); }

        .ad-form-actions { display: flex; flex-wrap: wrap; gap: 10px; }

        .btn[disabled] { opacity: .45; cursor: not-allowed; }

        .ad-setting {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            padding: 16px 18px;
            border-top: 1px solid var(--line);
        }

        .ad-setting strong { display: block; color: var(--ink); font-weight: 600; }
        .ad-setting span { font-size: .85rem; color: var(--ink-mute); }

        .ad-profile-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 20px;
            align-items: start;
        }

        @media (max-width: 1000px) { .ad-profile-grid { grid-template-columns: minmax(0, 1fr); } }

        .ad-profile-grid .ad-form { grid-template-columns: minmax(0, 1fr); max-width: none; }
        .ad-profile-grid .ad-form .full { grid-column: auto; }

        /* arriving from the admin log in: start on its dark colour and fade in */
        .ad-veil {
            position: fixed;
            inset: 0;
            z-index: 100;
            background: #140f0a;
            pointer-events: none;
            animation: ad-veil-out .6s ease-out .05s forwards;
        }

        @keyframes ad-veil-out { to { opacity: 0; } }

        @media (prefers-reduced-motion: reduce) {
            .ad-veil { animation-duration: .2s; }

            .ad-collapse .bi,
            .ad-menu__pop,
            .ad-nav { transition: none; }
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnPane" runat="server" Value="pane-overview" />

        <div class="ad-shell" id="adminShell">
            <script type="text/javascript">
                // apply the saved sidebar state before first paint
                try {
                    if (localStorage.getItem('meowletAdminSidebar') === 'collapsed') {
                        document.getElementById('adminShell').className += ' is-collapsed';
                    }
                } catch (e) { }

                // fade in after the admin log in greeting
                try {
                    if (sessionStorage.getItem('meowletAdminArrive') === '1') {
                        sessionStorage.removeItem('meowletAdminArrive');
                        var veil = document.createElement('div');
                        veil.className = 'ad-veil';
                        veil.addEventListener('animationend', function () { veil.parentNode.removeChild(veil); });
                        document.body.appendChild(veil);
                    }
                } catch (e) { }
            </script>

            <!-- ================= SIDEBAR ================= -->
            <aside class="ad-side">
                <a class="ad-side__brand" href="index.html" title="Open the public site">
                    <img class="ad-side__logo ad-side__logo--light" src="assets/img/meowlet-logo.png" alt="Meowlet Education" />
                    <img class="ad-side__logo ad-side__logo--dark" src="assets/img/meowlet-logo-dark.png" alt="Meowlet Education" />
                    <img class="ad-side__mark" src="assets/img/meowlet-mark.png" alt="Meowlet Education" />
                </a>

                <nav aria-label="Admin sections">
                    <p class="ad-side__group">Overview</p>
                    <button type="button" class="ad-nav is-active" data-pane="pane-overview">
                        <i class="bi bi-grid-1x2" aria-hidden="true"></i><span>Dashboard</span>
                    </button>

                    <p class="ad-side__group">Manage</p>
                    <button type="button" class="ad-nav" data-pane="pane-users">
                        <i class="bi bi-people" aria-hidden="true"></i><span>Users</span>
                    </button>
                    <button type="button" class="ad-nav" data-pane="pane-courses">
                        <i class="bi bi-book" aria-hidden="true"></i><span>Courses</span>
                    </button>
                    <button type="button" class="ad-nav" data-pane="pane-enrollments">
                        <i class="bi bi-journal-check" aria-hidden="true"></i><span>Enrollments</span>
                    </button>
                    <button type="button" class="ad-nav" data-pane="pane-feedback">
                        <i class="bi bi-chat-square-text" aria-hidden="true"></i><span>Reviews</span>
                    </button>

                    <p class="ad-side__group">System</p>
                    <button type="button" class="ad-nav" data-pane="pane-settings">
                        <i class="bi bi-gear" aria-hidden="true"></i><span>Settings</span>
                    </button>
                </nav>

                <div class="ad-side__foot">
                    <button type="button" class="ad-nav ad-collapse" id="sidebarToggle" aria-pressed="false">
                        <i class="bi bi-chevron-double-left" aria-hidden="true"></i><span>Collapse</span>
                    </button>
                </div>
            </aside>

            <!-- ================= MAIN ================= -->
            <main class="ad-main">

                <header class="ad-top">
                    <div>
                        <h1 class="ad-title" id="pageTitle">Welcome back, <asp:Literal ID="litWelcomeName" runat="server">Admin</asp:Literal></h1>
                        <p class="ad-sub" id="pageSub">Accounts, courses and enrollments across Meowlet.</p>
                    </div>
                    <div class="ad-top__tools">
                        <label class="ad-search ad-global">
                            <i class="bi bi-search" aria-hidden="true"></i>
                            <input type="search" id="globalSearch" class="ad-input" placeholder="Find a user" aria-label="Find a user by name or email" />
                            <span class="ad-kbd">Ctrl K</span>
                        </label>
                        <div class="ad-menu">
                            <button type="button" class="ad-menu__btn" aria-haspopup="true">
                                <i class="bi bi-person-circle" aria-hidden="true"></i>
                                <asp:Literal ID="litAdminName" runat="server">Administrator</asp:Literal>
                                <i class="bi bi-chevron-down" aria-hidden="true"></i>
                            </button>
                            <div class="ad-menu__pop">
                                <div class="ad-menu__card">
                                    <div class="ad-menu__who">
                                        <strong><asp:Literal ID="litMenuName" runat="server">Administrator</asp:Literal></strong>
                                        <span>Administrator</span>
                                    </div>
                                    <button type="button" class="ad-menu__item" data-go="pane-profile"><i class="bi bi-person" aria-hidden="true"></i>My profile</button>
                                    <button type="button" class="ad-menu__item" data-go="pane-settings"><i class="bi bi-circle-half" aria-hidden="true"></i>Settings</button>
                                    <a class="ad-menu__item" href="index.html"><i class="bi bi-box-arrow-up-right" aria-hidden="true"></i>Public site</a>
                                    <asp:LinkButton ID="lnkLogout" runat="server" CssClass="ad-menu__item ad-menu__item--danger"
                                        OnClick="lnkLogout_Click"
                                        OnClientClick="return confirm('Log out of the admin panel?');">
                                        <i class="bi bi-box-arrow-right" aria-hidden="true"></i>Log out
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </header>

                <asp:Literal ID="litFlash" runat="server" EnableViewState="false" />

                <!-- ---------- OVERVIEW ---------- -->
                <section id="pane-overview" class="ad-pane is-active" aria-labelledby="pageTitle">

                    <dl class="ad-stats">
                        <div class="ad-stat">
                            <dt>Accounts</dt>
                            <dd><asp:Literal ID="litStatUsers" runat="server">0</asp:Literal></dd>
                        </div>
                        <div class="ad-stat">
                            <dt>Learners</dt>
                            <dd><asp:Literal ID="litStatStudents" runat="server">0</asp:Literal></dd>
                        </div>
                        <div class="ad-stat">
                            <dt>Tutors</dt>
                            <dd><asp:Literal ID="litStatTutors" runat="server">0</asp:Literal></dd>
                        </div>
                        <div class="ad-stat">
                            <dt>Courses</dt>
                            <dd><asp:Literal ID="litStatCourses" runat="server">0</asp:Literal></dd>
                            <small><asp:Literal ID="litStatCoursesNote" runat="server" /></small>
                        </div>
                        <div class="ad-stat">
                            <dt>Enrollments</dt>
                            <dd><asp:Literal ID="litStatEnrollments" runat="server">0</asp:Literal></dd>
                            <small><asp:Literal ID="litStatEnrollmentsNote" runat="server" /></small>
                        </div>
                    </dl>

                    <div class="ad-pair">
                        <div class="ad-panel">
                            <div class="ad-panel__head">
                                <div>
                                    <h2 class="ad-panel__title">Enrollments by month
                                        <asp:PlaceHolder ID="phChartSample" runat="server"><span class="ad-sample" title="No enrollments recorded yet, so these figures are placeholders">Sample data</span></asp:PlaceHolder>
                                    </h2>
                                    <p class="ad-panel__hint">New course enrollments over the last eight months.</p>
                                </div>
                            </div>
                            <div class="ad-panel__body">
                                <svg class="ad-line" id="enrollChart" viewBox="0 0 600 210" role="img" aria-label="Enrollments by month"></svg>
                            </div>
                        </div>

                        <div class="ad-panel">
                            <div class="ad-panel__head">
                                <div>
                                    <h2 class="ad-panel__title">Accounts by role</h2>
                                    <p class="ad-panel__hint">Everyone who has signed up.</p>
                                </div>
                            </div>
                            <div class="ad-panel__body">
                                <div class="ad-pie">
                                    <asp:Literal ID="litRolePie" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">Newest accounts</h2>
                                <p class="ad-panel__hint">The last five people to sign up.</p>
                            </div>
                            <button type="button" class="btn btn--ghost btn--sm" data-go="pane-users">All users</button>
                        </div>
                        <ul class="ad-list">
                            <asp:Repeater ID="rptNewUsers" runat="server">
                                <ItemTemplate>
                                    <li>
                                        <span class="ad-list__who">
                                            <strong><%# Html(Eval("FullName")) %></strong>
                                            <span><%# Html(Eval("Email")) %></span>
                                        </span>
                                        <span class="<%# RoleTagClass(Eval("Role")) %>"><%# Html(Eval("Role")) %></span>
                                        <time><%# FormatDate(Eval("CreatedAt")) %></time>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                        <asp:PlaceHolder ID="phNoNewUsers" runat="server" Visible="false">
                            <p class="ad-empty-block">No one has signed up yet. New accounts from the sign-up page appear here.</p>
                        </asp:PlaceHolder>
                    </div>
                </section>

                <!-- ---------- USERS ---------- -->
                <section id="pane-users" class="ad-pane" aria-labelledby="pageTitle">
                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">All users</h2>
                                <p class="ad-panel__hint">Disabled accounts can't sign in until you enable them again.</p>
                            </div>
                        </div>

                        <div class="ad-tools">
                            <label class="ad-search">
                                <i class="bi bi-search" aria-hidden="true"></i>
                                <input type="search" id="userSearch" class="ad-input" placeholder="Search by name or email" aria-label="Search users" />
                            </label>
                            <select id="userRole" class="ad-select" aria-label="Role">
                                <option value="">All roles</option>
                                <option value="student">Students</option>
                                <option value="tutor">Tutors</option>
                                <option value="admin">Admins</option>
                            </select>
                            <select id="userSort" class="ad-select" aria-label="Sort">
                                <option value="newest">Newest first</option>
                                <option value="oldest">Oldest first</option>
                                <option value="name">Name A to Z</option>
                                <option value="enrolled">Most enrolled</option>
                            </select>
                            <span class="ad-tools__meta" id="userShowing" aria-live="polite"></span>
                        </div>

                        <div class="ad-chips" id="userChips">
                            <button type="button" class="chip is-active" data-role="">All<b><asp:Literal ID="litCountAll" runat="server">0</asp:Literal></b></button>
                            <button type="button" class="chip" data-role="student">Students<b><asp:Literal ID="litCountStudent" runat="server">0</asp:Literal></b></button>
                            <button type="button" class="chip" data-role="tutor">Tutors<b><asp:Literal ID="litCountTutor" runat="server">0</asp:Literal></b></button>
                            <button type="button" class="chip" data-role="admin">Admins<b><asp:Literal ID="litCountAdmin" runat="server">0</asp:Literal></b></button>
                        </div>

                        <div class="ad-table-wrap">
                            <table class="ad-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Name</th>
                                        <th scope="col">Email</th>
                                        <th scope="col">Role</th>
                                        <th scope="col" class="num">Enrolled courses</th>
                                        <th scope="col" class="end"><span class="sr-only">Actions</span></th>
                                    </tr>
                                </thead>
                                <tbody id="userRows">
                                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                                        <ItemTemplate>
                                            <tr class="user-row"
                                                data-order="<%# Container.ItemIndex %>"
                                                data-role="<%# Attr(Convert.ToString(Eval("Role")).ToLowerInvariant()) %>"
                                                data-name="<%# Attr(Eval("FullName")) %>"
                                                data-email="<%# Attr(Eval("Email")) %>"
                                                data-enrolled="<%# Eval("EnrolledCount") %>">
                                                <td>
                                                    <strong><%# Html(Eval("FullName")) %></strong>
                                                    <%# (bool)Eval("IsActive") ? "" : "<span class=\"tag\">Disabled</span>" %>
                                                </td>
                                                <td class="quiet"><%# Html(Eval("Email")) %></td>
                                                <td><span class="<%# RoleTagClass(Eval("Role")) %>"><%# Html(Eval("Role")) %></span></td>
                                                <td class="num"><%# Eval("EnrolledCount") %></td>
                                                <td class="end">
                                                    <asp:LinkButton runat="server" CommandName="ToggleActive" CommandArgument='<%# Eval("UserId") %>'
                                                        CssClass='<%# (bool)Eval("IsActive") ? "btn btn--ghost btn--sm ad-danger" : "btn btn--ghost btn--sm" %>'
                                                        Text='<%# (bool)Eval("IsActive") ? "Disable" : "Enable" %>' />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="phNoUsers" runat="server" Visible="false">
                                        <tr class="ad-empty"><td colspan="5"><strong>No users yet</strong>Accounts created on the sign-up page show up here.</td></tr>
                                    </asp:PlaceHolder>
                                    <tr class="ad-empty" id="userNoMatch" hidden="hidden"><td colspan="5"><strong>No matches</strong>Try another name, or clear the role filter.</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ---------- COURSES ---------- -->
                <section id="pane-courses" class="ad-pane" aria-labelledby="pageTitle">

                    <div class="ad-tabs" role="tablist">
                        <button type="button" class="ad-tab is-active" role="tab" data-sub="sub-course-list">
                            All courses <span class="ad-tab__count"><asp:Literal ID="litCourseTabCount" runat="server">0</asp:Literal></span>
                        </button>
                        <button type="button" class="ad-tab" role="tab" data-sub="sub-course-create">
                            <i class="bi bi-plus-lg" aria-hidden="true"></i>New course
                        </button>
                    </div>

                    <div id="sub-course-list" class="ad-sub-pane is-active">
                        <div class="ad-panel">
                            <div class="ad-panel__head">
                                <div>
                                    <h2 class="ad-panel__title">All courses</h2>
                                    <p class="ad-panel__hint">Drafts stay hidden from learners until you publish them.</p>
                                </div>
                                <div class="ad-switch" role="group" aria-label="Course layout" id="courseViewSwitch">
                                    <button type="button" class="is-on" data-view="table" aria-pressed="true"><i class="bi bi-list-ul" aria-hidden="true"></i>Table</button>
                                    <button type="button" data-view="cards" aria-pressed="false"><i class="bi bi-grid" aria-hidden="true"></i>Cards</button>
                                </div>
                            </div>

                            <div class="ad-tools">
                                <label class="ad-search">
                                    <i class="bi bi-search" aria-hidden="true"></i>
                                    <input type="search" id="courseSearch" class="ad-input" placeholder="Search by title or code" aria-label="Search courses" />
                                </label>
                                <select id="courseCategory" class="ad-select" aria-label="Category">
                                    <option value="">All categories</option>
                                </select>
                                <select id="courseStatus" class="ad-select" aria-label="Status">
                                    <option value="">Any status</option>
                                    <option value="published">Published</option>
                                    <option value="draft">Draft</option>
                                </select>
                                <span class="ad-tools__meta" id="courseShowing" aria-live="polite"></span>
                            </div>

                            <div class="ad-table-wrap" id="courseTableView">
                                <table class="ad-table">
                                    <thead>
                                        <tr>
                                            <th scope="col">Code</th>
                                            <th scope="col">Title</th>
                                            <th scope="col">Category</th>
                                            <th scope="col">Level</th>
                                            <th scope="col" class="num">Lessons</th>
                                            <th scope="col" class="num">Learners</th>
                                            <th scope="col">Status</th>
                                            <th scope="col" class="end"><span class="sr-only">Actions</span></th>
                                        </tr>
                                    </thead>
                                    <tbody id="courseRows">
                                        <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                                            <ItemTemplate>
                                                <tr class="course-row"
                                                    data-code="<%# Attr(Eval("CourseCode")) %>"
                                                    data-title="<%# Attr(Eval("Title")) %>"
                                                    data-category="<%# Attr(Eval("Category")) %>"
                                                    data-level="<%# Attr(Eval("Level")) %>"
                                                    data-lessons="<%# Eval("Lessons") %>"
                                                    data-learners="<%# Eval("LearnerCount") %>"
                                                    data-status="<%# (bool)Eval("IsPublished") ? "published" : "draft" %>">
                                                    <td class="code"><%# Html(Eval("CourseCode")) %></td>
                                                    <td><strong><%# Html(Eval("Title")) %></strong></td>
                                                    <td class="quiet"><%# Html(Eval("Category")) %></td>
                                                    <td class="quiet"><%# Html(Eval("Level")) %></td>
                                                    <td class="num"><%# Eval("Lessons") %></td>
                                                    <td class="num"><%# Eval("LearnerCount") %></td>
                                                    <td><%# (bool)Eval("IsPublished") ? "<span class=\"tag tag--live\">Published</span>" : "<span class=\"tag\">Draft</span>" %></td>
                                                    <td class="end">
                                                        <span class="ad-actions">
                                                            <asp:LinkButton runat="server" CommandName="TogglePublish" CommandArgument='<%# Eval("CourseId") %>'
                                                                CssClass="btn btn--ghost btn--sm"
                                                                Text='<%# (bool)Eval("IsPublished") ? "Unpublish" : "Publish" %>' />
                                                            <asp:LinkButton runat="server" CommandName="Delete" CommandArgument='<%# Eval("CourseId") %>'
                                                                CssClass="btn btn--ghost btn--sm ad-danger" Text="Delete"
                                                                OnClientClick="return confirm('Delete this course? Its enrollments are removed too.');" />
                                                        </span>
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                        <asp:PlaceHolder ID="phNoCourses" runat="server" Visible="false">
                                            <tr class="ad-empty"><td colspan="8"><strong>No courses yet</strong>Add the first one from the New course tab.</td></tr>
                                        </asp:PlaceHolder>
                                        <tr class="ad-empty" id="courseNoMatch" hidden="hidden"><td colspan="8"><strong>No matches</strong>Try another search or clear the filters.</td></tr>
                                    </tbody>
                                </table>
                            </div>

                            <!-- built from the table rows by script, so both layouts show the same data -->
                            <div class="ad-cards" id="courseCardView" hidden="hidden"></div>
                        </div>
                    </div>

                    <div id="sub-course-create" class="ad-sub-pane">
                        <div class="ad-panel">
                            <div class="ad-panel__head">
                                <div>
                                    <h2 class="ad-panel__title">New course</h2>
                                    <p class="ad-panel__hint">Saved as a draft unless you publish it now.</p>
                                </div>
                            </div>
                            <div class="ad-panel__body">
                                <asp:Literal ID="litCourseMsg" runat="server" EnableViewState="false" />
                                <div class="ad-form">
                                    <div class="ad-field wide">
                                        <asp:Label runat="server" AssociatedControlID="txtCourseTitle">Title</asp:Label>
                                        <asp:TextBox ID="txtCourseTitle" runat="server" CssClass="ad-input" MaxLength="200" placeholder="Smart Budgeting and Cash Flow" />
                                    </div>
                                    <div class="ad-field">
                                        <asp:Label runat="server" AssociatedControlID="txtCourseCode">Code</asp:Label>
                                        <asp:TextBox ID="txtCourseCode" runat="server" CssClass="ad-input" MaxLength="20" placeholder="FIN-101" />
                                        <p>Unique. Printed on certificates.</p>
                                    </div>
                                    <div class="ad-field">
                                        <asp:Label runat="server" AssociatedControlID="ddlCategory">Category</asp:Label>
                                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="ad-select" ClientIDMode="Static" />
                                    </div>
                                    <div class="ad-field">
                                        <asp:Label runat="server" AssociatedControlID="ddlLevel">Level</asp:Label>
                                        <asp:DropDownList ID="ddlLevel" runat="server" CssClass="ad-select" />
                                    </div>
                                    <div class="ad-field">
                                        <asp:Label runat="server" AssociatedControlID="txtLessons">Lessons</asp:Label>
                                        <asp:TextBox ID="txtLessons" runat="server" CssClass="ad-input" TextMode="Number" min="0" placeholder="12" />
                                    </div>
                                    <div class="ad-check full">
                                        <asp:CheckBox ID="chkPublish" runat="server" />
                                        <asp:Label runat="server" AssociatedControlID="chkPublish">Publish now</asp:Label>
                                    </div>
                                    <div class="ad-form-actions full">
                                        <asp:Button ID="btnCreateCourse" runat="server" CssClass="btn btn--primary btn--sm" Text="Save course" OnClick="btnCreateCourse_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ---------- ENROLLMENTS ---------- -->
                <section id="pane-enrollments" class="ad-pane" aria-labelledby="pageTitle">
                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">Recent enrollments</h2>
                                <p class="ad-panel__hint">
                                    <asp:Literal ID="litEnrollTotal" runat="server">0</asp:Literal> in total,
                                    <asp:Literal ID="litEnrollMonth" runat="server">0</asp:Literal> this month. Showing the latest 100.
                                </p>
                            </div>
                        </div>
                        <div class="ad-table-wrap">
                            <table class="ad-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Learner</th>
                                        <th scope="col">Email</th>
                                        <th scope="col">Course</th>
                                        <th scope="col">Enrolled</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptEnrollments" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><strong><%# Html(Eval("FullName")) %></strong></td>
                                                <td class="quiet"><%# Html(Eval("Email")) %></td>
                                                <td><%# Html(Eval("Title")) %> <span class="code"><%# Html(Eval("CourseCode")) %></span></td>
                                                <td class="quiet"><%# FormatDate(Eval("EnrolledAt")) %></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="phNoEnrollments" runat="server" Visible="false">
                                        <tr class="ad-empty"><td colspan="4"><strong>No enrollments yet</strong>Each row here is a learner joining a course.</td></tr>
                                    </asp:PlaceHolder>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ---------- REVIEWS (not stored yet) ---------- -->
                <section id="pane-feedback" class="ad-pane" aria-labelledby="pageTitle">
                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">Course reviews <span class="ad-sample">Sample data</span></h2>
                                <p class="ad-panel__hint">Reviews aren't saved to the database yet. These rows show the layout.</p>
                            </div>
                        </div>
                        <div class="ad-table-wrap">
                            <table class="ad-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Learner</th>
                                        <th scope="col">Course</th>
                                        <th scope="col" class="num">Rating</th>
                                        <th scope="col">Comment</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><strong>Nur Aisyah</strong></td>
                                        <td class="quiet">Investment and Portfolio Analysis</td>
                                        <td class="num">5</td>
                                        <td>Clear examples, and the portfolio lab finally made diversification click.</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Daniel Tan</strong></td>
                                        <td class="quiet">Smart Budgeting and Cash Flow</td>
                                        <td class="num">4</td>
                                        <td>Good pace. More local examples for Malaysian bills would help.</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Chong Mei Ling</strong></td>
                                        <td class="quiet">Debt Management and Credit Health</td>
                                        <td class="num">3</td>
                                        <td>The quiz questions in lesson 4 don't match the video.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ---------- MY PROFILE ---------- -->
                <section id="pane-profile" class="ad-pane" aria-labelledby="pageTitle">
                    <asp:PlaceHolder ID="phProfileSignedOut" runat="server" Visible="false">
                        <div class="ad-panel">
                            <p class="ad-empty-block">
                                You're viewing the dashboard without logging in.
                                <a href="AdminSignin.aspx"><strong>Log in as an admin</strong></a> to edit your profile.
                            </p>
                        </div>
                    </asp:PlaceHolder>

                    <asp:PlaceHolder ID="phProfile" runat="server">
                        <div class="ad-profile-grid">
                            <div class="ad-panel">
                                <div class="ad-panel__head">
                                    <div>
                                        <h2 class="ad-panel__title">Profile</h2>
                                        <p class="ad-panel__hint">Your name appears in the greeting and on the account menu.</p>
                                    </div>
                                    <span class="tag ad-tag--ink">Admin</span>
                                </div>
                                <div class="ad-panel__body">
                                    <asp:Literal ID="litProfileMsg" runat="server" EnableViewState="false" />
                                    <div class="ad-form">
                                        <div class="ad-field">
                                            <asp:Label runat="server" AssociatedControlID="txtProfileName">Full name</asp:Label>
                                            <asp:TextBox ID="txtProfileName" runat="server" CssClass="ad-input" MaxLength="100" autocomplete="name" />
                                        </div>
                                        <div class="ad-field">
                                            <asp:Label runat="server" AssociatedControlID="txtProfileEmail">Email</asp:Label>
                                            <asp:TextBox ID="txtProfileEmail" runat="server" CssClass="ad-input" TextMode="Email" MaxLength="256" autocomplete="email" />
                                            <p>You log in with this address.</p>
                                        </div>
                                        <div class="ad-form-actions">
                                            <asp:Button ID="btnSaveProfile" runat="server" CssClass="btn btn--primary btn--sm" Text="Save changes" OnClick="btnSaveProfile_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="ad-panel">
                                <div class="ad-panel__head">
                                    <div>
                                        <h2 class="ad-panel__title">Password</h2>
                                        <p class="ad-panel__hint">Enter your current password to set a new one.</p>
                                    </div>
                                </div>
                                <div class="ad-panel__body">
                                    <asp:Literal ID="litPasswordMsg" runat="server" EnableViewState="false" />
                                    <div class="ad-form">
                                        <div class="ad-field">
                                            <asp:Label runat="server" AssociatedControlID="txtCurrentPassword">Current password</asp:Label>
                                            <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="ad-input" TextMode="Password" autocomplete="current-password" />
                                        </div>
                                        <div class="ad-field">
                                            <asp:Label runat="server" AssociatedControlID="txtNewPassword">New password</asp:Label>
                                            <asp:TextBox ID="txtNewPassword" runat="server" CssClass="ad-input" TextMode="Password" autocomplete="new-password" />
                                            <p>At least 8 characters.</p>
                                        </div>
                                        <div class="ad-field">
                                            <asp:Label runat="server" AssociatedControlID="txtConfirmPassword">Confirm new password</asp:Label>
                                            <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="ad-input" TextMode="Password" autocomplete="new-password" />
                                        </div>
                                        <div class="ad-form-actions">
                                            <asp:Button ID="btnChangePassword" runat="server" CssClass="btn btn--ghost btn--sm" Text="Change password" OnClick="btnChangePassword_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:PlaceHolder>
                </section>

                <!-- ---------- SETTINGS ---------- -->
                <section id="pane-settings" class="ad-pane" aria-labelledby="pageTitle">
                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">Appearance</h2>
                                <p class="ad-panel__hint">Saved in this browser.</p>
                            </div>
                        </div>
                        <div class="ad-setting">
                            <div>
                                <strong>Theme</strong>
                                <span>The admin panel starts in dark mode.</span>
                            </div>
                            <div class="ad-switch" role="group" aria-label="Theme" id="themeSwitch">
                                <button type="button" data-theme-choice="light" aria-pressed="false"><i class="bi bi-sun" aria-hidden="true"></i>Light</button>
                                <button type="button" data-theme-choice="dark" aria-pressed="false"><i class="bi bi-moon-stars" aria-hidden="true"></i>Dark</button>
                            </div>
                        </div>
                    </div>
                </section>
            </main>
        </div>

        <script type="text/javascript">
            (function () {
                var adminFirstName = '<asp:Literal ID="litAdminNameJs" runat="server">Admin</asp:Literal>';
                var chartData = <asp:Literal ID="litChartJson" runat="server" Text="[]" />;

                var meta = {
                    'pane-overview': ['Welcome back, ' + adminFirstName, 'Accounts, courses and enrollments across Meowlet.'],
                    'pane-users': ['Users', 'Find an account and change who can sign in.'],
                    'pane-courses': ['Courses', 'Add courses and choose which ones learners can see.'],
                    'pane-enrollments': ['Enrollments', 'Who joined which course, newest first.'],
                    'pane-feedback': ['Reviews', 'What learners say about each course.'],
                    'pane-profile': ['My profile', 'Your name, email and password.'],
                    'pane-settings': ['Settings', 'How the admin panel looks.']
                };

                var shell = document.getElementById('adminShell');
                var hdnPane = document.getElementById('<%= hdnPane.ClientID %>');
                var navItems = document.querySelectorAll('.ad-nav[data-pane]');
                var panes = document.querySelectorAll('.ad-pane');
                var title = document.getElementById('pageTitle');
                var sub = document.getElementById('pageSub');

                // ---- panes (the choice survives postbacks via hdnPane) ----
                function show(paneId, subId, keepScroll) {
                    if (!document.getElementById(paneId)) { paneId = 'pane-overview'; }
                    for (var i = 0; i < panes.length; i++) {
                        panes[i].className = panes[i].id === paneId ? 'ad-pane is-active' : 'ad-pane';
                    }
                    for (var j = 0; j < navItems.length; j++) {
                        var on = navItems[j].getAttribute('data-pane') === paneId;
                        navItems[j].className = on ? 'ad-nav is-active' : 'ad-nav';
                        if (on) { navItems[j].setAttribute('aria-current', 'page'); } else { navItems[j].removeAttribute('aria-current'); }
                    }
                    title.textContent = meta[paneId][0];
                    sub.textContent = meta[paneId][1];
                    if (subId) { showSub(subId); }
                    // a result message belongs to the pane it came from
                    var flash = document.querySelector('.ad-main > .ad-flash');
                    if (flash && !keepScroll) { flash.parentNode.removeChild(flash); }
                    hdnPane.value = paneId + (paneId === 'pane-courses' ? '/' + currentSub() : '');
                    if (!keepScroll) { window.scrollTo(0, 0); }
                }

                var tabs = document.querySelectorAll('.ad-tab[data-sub]');

                function currentSub() {
                    var active = document.querySelector('.ad-tab.is-active');
                    return active ? active.getAttribute('data-sub') : 'sub-course-list';
                }

                function showSub(subId) {
                    for (var i = 0; i < tabs.length; i++) {
                        var id = tabs[i].getAttribute('data-sub');
                        var on = id === subId;
                        tabs[i].className = on ? 'ad-tab is-active' : 'ad-tab';
                        tabs[i].setAttribute('aria-selected', on ? 'true' : 'false');
                        document.getElementById(id).className = on ? 'ad-sub-pane is-active' : 'ad-sub-pane';
                    }
                }

                for (var k = 0; k < navItems.length; k++) {
                    navItems[k].onclick = function () { show(this.getAttribute('data-pane')); };
                }

                var jumps = document.querySelectorAll('[data-go]');
                for (var g = 0; g < jumps.length; g++) {
                    jumps[g].onclick = function () {
                        show(this.getAttribute('data-go'));
                        // close the account menu, which stays open while it has focus
                        if (document.activeElement && document.activeElement.blur) { document.activeElement.blur(); }
                    };
                }

                // ---- theme ----
                var themeButtons = document.querySelectorAll('[data-theme-choice]');

                function syncTheme() {
                    var current = document.documentElement.getAttribute('data-theme');
                    for (var i = 0; i < themeButtons.length; i++) {
                        var on = themeButtons[i].getAttribute('data-theme-choice') === current;
                        themeButtons[i].className = on ? 'is-on' : '';
                        themeButtons[i].setAttribute('aria-pressed', on ? 'true' : 'false');
                    }
                }

                for (var tb = 0; tb < themeButtons.length; tb++) {
                    themeButtons[tb].onclick = function () {
                        var theme = this.getAttribute('data-theme-choice');
                        document.documentElement.setAttribute('data-theme', theme);
                        try { localStorage.setItem('meowletAdminTheme', theme); } catch (e) { }
                        syncTheme();
                    };
                }

                syncTheme();

                for (var t = 0; t < tabs.length; t++) {
                    tabs[t].onclick = function () {
                        showSub(this.getAttribute('data-sub'));
                        hdnPane.value = 'pane-courses/' + this.getAttribute('data-sub');
                    };
                }

                var saved = (hdnPane.value || 'pane-overview').split('/');
                show(saved[0], saved[1], true);

                // ---- sidebar collapse ----
                var toggle = document.getElementById('sidebarToggle');
                var sideItems = document.querySelectorAll('.ad-side .ad-nav');

                function syncSidebar() {
                    var collapsed = /\bis-collapsed\b/.test(shell.className);
                    toggle.setAttribute('aria-pressed', collapsed ? 'true' : 'false');
                    toggle.querySelector('span').textContent = collapsed ? 'Expand' : 'Collapse';
                    toggle.setAttribute('aria-label', collapsed ? 'Expand sidebar' : 'Collapse sidebar');
                    for (var i = 0; i < sideItems.length; i++) {
                        var label = sideItems[i].getAttribute('aria-label') || sideItems[i].querySelector('span').textContent;
                        if (collapsed) { sideItems[i].title = label; } else { sideItems[i].removeAttribute('title'); }
                    }
                }

                toggle.onclick = function () {
                    var collapsed = !/\bis-collapsed\b/.test(shell.className);
                    shell.className = collapsed ? 'ad-shell is-collapsed' : 'ad-shell';
                    try { localStorage.setItem('meowletAdminSidebar', collapsed ? 'collapsed' : 'expanded'); } catch (e) { }
                    syncSidebar();
                };

                syncSidebar();

                // Enter in a filter box must not submit the form (it would
                // press the first submit button on the page, "Save course").
                var filterBoxes = document.querySelectorAll('.ad-search input');
                for (var f = 0; f < filterBoxes.length; f++) {
                    filterBoxes[f].onkeydown = function (e) {
                        if (e.key === 'Enter') { e.preventDefault(); }
                    };
                }

                // ---- users: search, role, sort ----
                var userRows = document.getElementById('userRows');
                var userSearch = document.getElementById('userSearch');
                var userRole = document.getElementById('userRole');
                var userSort = document.getElementById('userSort');
                var userChips = document.querySelectorAll('#userChips .chip');
                var userNoMatch = document.getElementById('userNoMatch');
                var users = Array.prototype.slice.call(userRows.querySelectorAll('tr.user-row'));

                function filterUsers() {
                    var q = userSearch.value.trim().toLowerCase();
                    var role = userRole.value;
                    var sort = userSort.value;

                    users.sort(function (a, b) {
                        if (sort === 'name') { return a.getAttribute('data-name').localeCompare(b.getAttribute('data-name')); }
                        if (sort === 'enrolled') { return b.getAttribute('data-enrolled') - a.getAttribute('data-enrolled'); }
                        var diff = a.getAttribute('data-order') - b.getAttribute('data-order');
                        return sort === 'oldest' ? -diff : diff;
                    });

                    var shown = 0;
                    for (var i = 0; i < users.length; i++) {
                        var r = users[i];
                        var text = (r.getAttribute('data-name') + ' ' + r.getAttribute('data-email')).toLowerCase();
                        var match = (!role || r.getAttribute('data-role') === role) && (!q || text.indexOf(q) !== -1);
                        r.hidden = !match;
                        if (match) { shown++; }
                        userRows.insertBefore(r, userNoMatch);
                    }

                    for (var c = 0; c < userChips.length; c++) {
                        userChips[c].className = userChips[c].getAttribute('data-role') === role ? 'chip is-active' : 'chip';
                    }

                    userNoMatch.hidden = !(users.length > 0 && shown === 0);
                    document.getElementById('userShowing').textContent =
                        users.length ? shown + ' of ' + users.length : '';
                }

                userSearch.oninput = filterUsers;
                userRole.onchange = filterUsers;
                userSort.onchange = filterUsers;

                for (var uc = 0; uc < userChips.length; uc++) {
                    userChips[uc].onclick = function () {
                        userRole.value = this.getAttribute('data-role');
                        filterUsers();
                    };
                }

                filterUsers();

                // ---- global search jumps to the user list ----
                var globalSearch = document.getElementById('globalSearch');

                globalSearch.onkeydown = function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        userSearch.value = globalSearch.value;
                        userRole.value = '';
                        show('pane-users');
                        filterUsers();
                        userSearch.focus();
                    }
                };

                document.addEventListener('keydown', function (e) {
                    if ((e.ctrlKey || e.metaKey) && (e.key === 'k' || e.key === 'K')) {
                        e.preventDefault();
                        var target = globalSearch.offsetParent ? globalSearch : userSearch;
                        if (target === userSearch) { show('pane-users'); }
                        target.focus();
                        target.select();
                    }
                });

                // ---- courses: filters and table / card layout ----
                var courseRows = Array.prototype.slice.call(document.querySelectorAll('#courseRows tr.course-row'));
                var courseSearch = document.getElementById('courseSearch');
                var courseCategory = document.getElementById('courseCategory');
                var courseStatus = document.getElementById('courseStatus');
                var courseNoMatch = document.getElementById('courseNoMatch');
                var courseTable = document.getElementById('courseTableView');
                var courseCards = document.getElementById('courseCardView');
                var viewButtons = document.querySelectorAll('#courseViewSwitch button');

                // category filter uses the same list as the New course form
                var formCategories = document.getElementById('ddlCategory').options;
                for (var oc = 0; oc < formCategories.length; oc++) {
                    courseCategory.add(new Option(formCategories[oc].text, formCategories[oc].value));
                }

                function el(tag, className, text) {
                    var node = document.createElement(tag);
                    if (className) { node.className = className; }
                    if (text !== undefined) { node.textContent = text; }
                    return node;
                }

                function buildCards() {
                    courseCards.innerHTML = '';
                    for (var i = 0; i < courseRows.length; i++) {
                        var r = courseRows[i];
                        if (r.hidden) { continue; }

                        var card = el('article', 'ad-course');
                        var top = el('div', 'ad-course__top');
                        top.appendChild(el('span', 'code', r.getAttribute('data-code')));
                        top.appendChild(r.children[6].firstElementChild.cloneNode(true));

                        card.appendChild(top);
                        card.appendChild(el('h3', 'ad-course__title', r.getAttribute('data-title')));
                        card.appendChild(el('p', 'ad-course__meta',
                            r.getAttribute('data-category') + ', ' + r.getAttribute('data-level').toLowerCase()));
                        card.appendChild(el('p', 'ad-course__meta',
                            r.getAttribute('data-lessons') + ' lessons, ' + r.getAttribute('data-learners') + ' learners'));
                        // the cloned buttons keep their __doPostBack hrefs, so they work here too
                        card.appendChild(r.querySelector('.ad-actions').cloneNode(true));
                        courseCards.appendChild(card);
                    }
                }

                function filterCourses() {
                    var q = courseSearch.value.trim().toLowerCase();
                    var cat = courseCategory.value;
                    var status = courseStatus.value;
                    var shown = 0;

                    for (var i = 0; i < courseRows.length; i++) {
                        var r = courseRows[i];
                        var text = (r.getAttribute('data-title') + ' ' + r.getAttribute('data-code')).toLowerCase();
                        var match = (!cat || r.getAttribute('data-category') === cat) &&
                            (!status || r.getAttribute('data-status') === status) &&
                            (!q || text.indexOf(q) !== -1);
                        r.hidden = !match;
                        if (match) { shown++; }
                    }

                    courseNoMatch.hidden = !(courseRows.length > 0 && shown === 0);
                    document.getElementById('courseShowing').textContent =
                        courseRows.length ? shown + ' of ' + courseRows.length : '';
                    if (!courseCards.hidden) { buildCards(); }
                }

                function setCourseView(view) {
                    var cards = view === 'cards';
                    courseTable.hidden = cards;
                    courseCards.hidden = !cards;
                    if (cards) { buildCards(); }
                    for (var i = 0; i < viewButtons.length; i++) {
                        var on = viewButtons[i].getAttribute('data-view') === view;
                        viewButtons[i].className = on ? 'is-on' : '';
                        viewButtons[i].setAttribute('aria-pressed', on ? 'true' : 'false');
                    }
                    try { localStorage.setItem('meowletAdminCourseView', view); } catch (e) { }
                }

                courseSearch.oninput = filterCourses;
                courseCategory.onchange = filterCourses;
                courseStatus.onchange = filterCourses;

                for (var vb = 0; vb < viewButtons.length; vb++) {
                    viewButtons[vb].onclick = function () { setCourseView(this.getAttribute('data-view')); };
                }

                filterCourses();

                try {
                    if (localStorage.getItem('meowletAdminCourseView') === 'cards' && courseRows.length) { setCourseView('cards'); }
                } catch (e) { }

                // ---- enrollments line chart ----
                (function drawChart() {
                    var svg = document.getElementById('enrollChart');
                    if (!chartData.length) { return; }

                    var NS = 'http://www.w3.org/2000/svg';
                    var L = 40, R = 584, T = 22, B = 172;
                    var max = 0;
                    for (var i = 0; i < chartData.length; i++) { max = Math.max(max, chartData[i].value); }

                    // round the top of the scale up to a multiple of 4 "nice" steps
                    var step = Math.max(1, Math.ceil(max / 4));
                    var mag = Math.pow(10, Math.floor(Math.log(step) / Math.LN10));
                    step = Math.ceil(step / mag) * mag;
                    var top = step * 4;

                    function x(i) { return L + i * (R - L) / (chartData.length - 1); }
                    function y(v) { return B - v / top * (B - T); }

                    function add(tag, attrs, text) {
                        var node = document.createElementNS(NS, tag);
                        for (var a in attrs) { node.setAttribute(a, attrs[a]); }
                        if (text !== undefined) { node.textContent = text; }
                        svg.appendChild(node);
                        return node;
                    }

                    for (var s = 0; s <= 4; s++) {
                        var gv = step * s;
                        add('line', { 'class': 'grid', x1: L, x2: R, y1: y(gv), y2: y(gv) });
                        add('text', { 'class': 'axis', x: L - 10, y: y(gv) + 4, 'text-anchor': 'end' }, gv);
                    }

                    var pts = [];
                    for (var p = 0; p < chartData.length; p++) { pts.push(x(p) + ',' + y(chartData[p].value)); }

                    add('polygon', { 'class': 'area', points: x(0) + ',' + B + ' ' + pts.join(' ') + ' ' + x(chartData.length - 1) + ',' + B });
                    add('polyline', { 'class': 'stroke', points: pts.join(' ') });

                    var summary = [];
                    for (var d = 0; d < chartData.length; d++) {
                        var last = d === chartData.length - 1;
                        var dot = add('circle', { 'class': last ? 'dot now' : 'dot', cx: x(d), cy: y(chartData[d].value), r: last ? 5 : 3.5 });
                        var tip = document.createElementNS(NS, 'title');
                        tip.textContent = chartData[d].label + ': ' + chartData[d].value;
                        dot.appendChild(tip);
                        add('text', { 'class': 'val', x: x(d), y: y(chartData[d].value) - 11, 'text-anchor': 'middle' }, chartData[d].value);
                        add('text', { 'class': 'axis', x: x(d), y: 200, 'text-anchor': 'middle' }, chartData[d].label);
                        summary.push(chartData[d].label + ' ' + chartData[d].value);
                    }

                    svg.setAttribute('aria-label', 'Enrollments by month: ' + summary.join(', '));
                })();
            })();
        </script>
    </form>
</body>
</html>

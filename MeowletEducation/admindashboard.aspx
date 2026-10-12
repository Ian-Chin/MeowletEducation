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
    <link rel="stylesheet" href="assets/css/admin-theme.css" />
    <link rel="stylesheet" href="assets/css/admin-shell.css" />
    <script type="text/javascript">
        // @ts-nocheck
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

        .tag--accent { color: var(--ad-accent-text); }

        body {
            font-size: 14px;
            line-height: 1.5;
            color: var(--ink-soft);
            background: var(--cream);
            overflow-x: visible;
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

        /* ---------- Notifications (new admin sign ups) ---------- */
        .ad-bell { position: relative; }

        .ad-bell__btn {
            position: relative;
            display: grid;
            place-items: center;
            width: 40px;
            height: 40px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink);
            font-size: 1.05rem;
        }

        .ad-bell__btn:hover { border-color: var(--ink); }

        .ad-bell__count {
            position: absolute;
            top: -7px;
            right: -7px;
            min-width: 19px;
            height: 19px;
            padding: 0 5px;
            border: 2px solid var(--cream);
            border-radius: 999px;
            background: var(--accent);
            color: #111111;
            font-size: 10.5px;
            font-weight: 700;
            line-height: 15px;
            text-align: center;
        }

        .ad-bell__count[hidden] { display: none; }
        .ad-bell.is-new .ad-bell__count { animation: ad-bell-pop .5s ease-out; }
        @keyframes ad-bell-pop { 40% { transform: scale(1.35); } }

        .ad-bell__pop {
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            z-index: 30;
            width: min(380px, calc(100vw - 32px));
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            box-shadow: var(--shadow);
        }

        .ad-bell__pop[hidden] { display: none; }

        .ad-bell__head {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            padding: 12px 14px;
            border-bottom: 1px solid var(--line);
        }

        .ad-bell__head strong { color: var(--ink); }
        .ad-bell__head span { font-size: .8rem; color: var(--ink-faint); }

        .ad-bell__list { max-height: 420px; margin: 0; padding: 0; overflow-y: auto; list-style: none; }

        .ad-note { padding: 12px 14px; border-bottom: 1px solid var(--line); }
        .ad-note:last-child { border-bottom: 0; }
        .ad-note__top { display: flex; gap: 10px; align-items: flex-start; }

        .ad-note__icon {
            display: grid;
            place-items: center;
            width: 30px;
            height: 30px;
            flex-shrink: 0;
            border-radius: 50%;
            background: var(--accent-soft);
            color: var(--ad-accent-text);
        }

        .ad-note__text { flex: 1; min-width: 0; font-size: .86rem; color: var(--ink-mute); }
        .ad-note__text strong { color: var(--ink); font-weight: 600; }
        .ad-note__email { display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .ad-note__meta { display: block; margin-top: 2px; font-size: .78rem; color: var(--ink-faint); }
        .ad-note__actions { display: flex; gap: 8px; margin: 10px 0 0 40px; }

        .ad-note__code {
            margin: 10px 0 0 40px;
            padding: 10px 12px;
            border: 1px dashed var(--ink);
            border-radius: var(--radius-sm);
            background: var(--cream);
        }

        .ad-note__code b {
            display: block;
            font-family: var(--mono);
            font-size: 1.3rem;
            letter-spacing: .24em;
            color: var(--ink);
        }

        .ad-note__code p { margin: 4px 0 8px; font-size: .78rem; color: var(--ink-mute); }
        .ad-note__code div { display: flex; gap: 8px; }
        .ad-note__err { margin: 8px 0 0 40px; font-size: .8rem; color: var(--ad-danger); }
        .ad-note__err:empty { display: none; }

        .ad-bell__empty { padding: 26px 14px; text-align: center; font-size: .86rem; color: var(--ink-faint); }

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

        .ad-stat__label { margin: 0; font-size: .8rem; color: var(--ink-mute); }

        .ad-stat__value {
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
        .ad-line .stroke { fill: none; stroke: var(--ink); stroke-width: 2.25px; stroke-linejoin: round; stroke-linecap: round; }
        .ad-line .dot { fill: var(--paper); stroke: var(--ink); stroke-width: 2; }
        .ad-line .dot.now { fill: var(--accent); stroke: var(--ink); }

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

        /* ---------- Tutor verification ---------- */
        .tag--ok { color: #2f7a3b; border-color: rgba(47, 122, 59, .3); }
        html[data-theme="dark"] .tag--ok { color: #8fd19b; }
        .tag--warn { color: var(--ad-danger); border-color: var(--ad-danger-line); }
        .ad-nav__count {
            margin-left: auto;
            min-width: 20px;
            padding: 1px 7px;
            border-radius: var(--pill);
            background: var(--accent);
            color: #fff;
            font-size: .72rem;
            font-weight: 700;
            text-align: center;
        }
        .ad-shell.is-collapsed .ad-nav__count { display: none; }
        .ad-table .ad-note { min-width: 190px; padding: 6px 10px; font-size: .82rem; }
        .ad-table .ad-reason { max-width: 320px; white-space: normal; }

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

        /* the whole card opens the course builder; the menu sits on the picture */
        .ad-course { position: relative; overflow: visible; cursor: pointer; transition: border-color .15s ease-out, box-shadow .15s ease-out; }
        .ad-course:hover { border-color: var(--line-strong); box-shadow: var(--shadow); }
        .ad-course:focus-visible { outline: 2px solid var(--ink); outline-offset: 2px; }

        .ad-kebab { position: absolute; top: 8px; right: 8px; z-index: 2; }

        .ad-kebab__btn {
            display: grid;
            place-items: center;
            width: 32px;
            height: 32px;
            border: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, .92);
            color: #111111;
            font-size: 1rem;
            box-shadow: 0 1px 4px rgba(0, 0, 0, .25);
            cursor: pointer;
        }

        .ad-kebab__btn:hover,
        .ad-kebab__btn[aria-expanded="true"] { background: #ffffff; }

        .ad-kebab__menu {
            position: absolute;
            top: calc(100% + 6px);
            right: 0;
            min-width: 220px;
            padding: 6px;
            white-space: nowrap;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            box-shadow: var(--shadow);
            cursor: default;
        }

        .ad-kebab__menu[hidden] { display: none; }

        .ad-kebab__menu button {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            padding: 8px 10px;
            border: 0;
            border-radius: 6px;
            background: transparent;
            font: inherit;
            font-size: .88rem;
            color: var(--ink-soft);
            text-align: left;
            cursor: pointer;
        }

        .ad-kebab__menu button:hover { background: var(--cream); color: var(--ink); }
        .ad-kebab__menu .is-danger { color: var(--ad-danger); }
        .ad-kebab__menu .is-danger:hover { background: var(--ad-danger-bg); color: var(--ad-danger); }

        .ad-table .ad-open { color: var(--ink); font-weight: 600; text-decoration: underline; text-decoration-color: transparent; text-underline-offset: 3px; }
        .ad-table .ad-open:hover { text-decoration-color: var(--accent); }

        /* cover picture, chosen by category (CourseImages.cs) */
        .ad-course { overflow: hidden; }
        .ad-course__img {
            display: block;
            width: calc(100% + 32px);
            max-width: none;
            aspect-ratio: 16 / 9;
            margin: -14px -16px 6px;
            object-fit: cover;
            background: var(--beige-deep);
        }

        .ad-course > .ad-course__img { border-radius: var(--radius-sm) var(--radius-sm) 0 0; }

        .ad-course__img--empty {
            display: grid;
            place-items: center;
            color: var(--ink-faint);
            font-size: 1.6rem;
        }

        /* ---------- Create / edit user popup ---------- */
        .ad-modal {
            width: min(520px, calc(100vw - 32px));
            padding: 0;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            color: var(--ink-soft);
            box-shadow: var(--shadow);
        }

        .ad-modal::backdrop { background: rgba(0, 0, 0, .55); }

        .ad-modal__head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 18px;
            border-bottom: 1px solid var(--line);
        }

        .ad-modal__head h2 { margin: 0; font-size: 1.05rem; font-weight: 600; color: var(--ink); }

        .ad-modal__x {
            display: grid;
            place-items: center;
            width: 32px;
            height: 32px;
            border: 0;
            border-radius: var(--radius-btn);
            background: transparent;
            color: var(--ink-mute);
            cursor: pointer;
        }

        .ad-modal__x:hover { background: var(--beige-deep); color: var(--ink); }

        .ad-modal .ad-form {
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 16px 14px;
            max-width: none;
            padding: 20px;
            border-top: 0;
        }

        .ad-modal--wide { width: min(900px, calc(100vw - 32px)); }
        .ad-modal .ad-form > .ad-flash { grid-column: 1 / -1; margin: 0; }
        .ad-modal .ad-field p { margin-top: 6px; }
        .ad-modal .ad-check { padding-top: 2px; }
        .ad-modal__body { max-height: calc(100vh - 190px); overflow-y: auto; }

        textarea.ad-input { min-height: 92px; resize: vertical; line-height: 1.5; }
        input[type="file"].ad-input { padding: 6px 8px; }

        /* ---------- Course form (New course tab, and moved into the popup to edit) ---------- */
        .ad-course-form__grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 300px;
            gap: 24px;
            align-items: start;
        }

        .ad-course-form .ad-form {
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 16px 14px;
            max-width: none;
            padding: 0;
            border-top: 0;
        }

        .ad-course-form .ad-form > .ad-flash { grid-column: 1 / -1; margin: 0; }
        .ad-course-form__media { display: grid; gap: 10px; }

        .ad-course-form__actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 22px;
            padding-top: 16px;
            border-top: 1px solid var(--line);
        }

        #courseFormHome .ad-course-form__cancel { display: none; }
        #courseFormHome { padding: 4px 18px 18px; }
        #courseFormModalSlot { padding: 20px; }

        .ad-modal .ad-course-form__actions {
            position: sticky;
            bottom: -20px;
            margin: 22px -20px -20px;
            padding: 14px 20px;
            background: var(--paper);
        }

        /* click-to-pick image placeholder; the file input sits inside the label */
        .ad-picker {
            position: relative;
            display: grid;
            place-items: center;
            aspect-ratio: 16 / 9;
            overflow: hidden;
            border: 1.5px dashed var(--line-strong);
            border-radius: var(--radius-sm);
            background: var(--cream);
            color: var(--ink-mute);
            text-align: center;
            cursor: pointer;
            transition: border-color .15s ease-out, background-color .15s ease-out;
        }

        .ad-picker:hover,
        .ad-picker:focus-within { border-color: var(--ink); background: var(--beige-deep); }
        .ad-picker:focus-within { outline: 2px solid var(--ink); outline-offset: 2px; }

        .ad-picker__empty { display: grid; justify-items: center; gap: 4px; padding: 16px; font-size: .8rem; }
        .ad-picker__empty .bi { font-size: 1.9rem; color: var(--ink-faint); }
        .ad-picker__empty strong { font-size: .88rem; font-weight: 600; color: var(--ink); }

        .ad-picker__img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; }

        .ad-picker__change {
            position: absolute;
            right: 8px;
            bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 999px;
            background: rgba(0, 0, 0, .72);
            color: #ffffff;
            font-size: .75rem;
            font-weight: 600;
        }

        .ad-picker [hidden] { display: none; }
        .ad-picker__input { position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none; }
        .ad-course-form__media p { margin: 0; font-size: .8rem; color: var(--ink-faint); }

        @media (max-width: 900px) {
            .ad-course-form__grid { grid-template-columns: minmax(0, 1fr); }
            .ad-course-form .ad-form { grid-template-columns: minmax(0, 1fr); }
            .ad-course-form .ad-form .full { grid-column: auto; }
        }

        /* icon-only row actions */
        .ad-icon-btn {
            display: inline-grid;
            place-items: center;
            width: 32px;
            height: 32px;
            padding: 0;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink-mute);
            font-size: .92rem;
            line-height: 1;
            cursor: pointer;
            transition: border-color .15s ease-out, color .15s ease-out, background-color .15s ease-out;
        }

        .ad-icon-btn:hover { border-color: var(--ink); color: var(--ink); }
        .ad-icon-btn.ad-danger { color: var(--ad-danger); }
        .ad-icon-btn.ad-danger:hover { border-color: var(--ad-danger-line); background: var(--ad-danger-bg); }

        .ad-modal__foot {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            padding: 14px 18px;
            border-top: 1px solid var(--line);
        }

        @media (max-width: 560px) {
            .ad-modal .ad-form { grid-template-columns: minmax(0, 1fr); }
        }

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
        .ad-check[hidden] { display: none; }
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
            background: #0a0a0a;
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
                // @ts-nocheck
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
                    <button type="button" class="ad-nav" data-pane="pane-verify">
                        <i class="bi bi-patch-check" aria-hidden="true"></i><span>Tutor verification</span>
                        <asp:Literal ID="litVerifyBadge" runat="server" />
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
                        <div class="ad-bell" id="bell">
                            <button type="button" class="ad-bell__btn" id="bellBtn" aria-haspopup="true" aria-expanded="false" aria-controls="bellPop" aria-label="Notifications">
                                <i class="bi bi-bell" aria-hidden="true"></i>
                                <span class="ad-bell__count" id="bellCount" hidden="hidden">0</span>
                            </button>
                            <div class="ad-bell__pop" id="bellPop" hidden="hidden">
                                <div class="ad-bell__head">
                                    <strong>Notifications</strong>
                                    <span>New admin sign ups</span>
                                </div>
                                <ul class="ad-bell__list" id="bellList" aria-live="polite"></ul>
                            </div>
                        </div>
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

                    <div class="ad-stats">
                        <div class="ad-stat">
                            <p class="ad-stat__label">Accounts</p>
                            <p class="ad-stat__value"><asp:Literal ID="litStatUsers" runat="server">0</asp:Literal></p>
                        </div>
                        <div class="ad-stat">
                            <p class="ad-stat__label">Learners</p>
                            <p class="ad-stat__value"><asp:Literal ID="litStatStudents" runat="server">0</asp:Literal></p>
                        </div>
                        <div class="ad-stat">
                            <p class="ad-stat__label">Tutors</p>
                            <p class="ad-stat__value"><asp:Literal ID="litStatTutors" runat="server">0</asp:Literal></p>
                        </div>
                        <div class="ad-stat">
                            <p class="ad-stat__label">Courses</p>
                            <p class="ad-stat__value"><asp:Literal ID="litStatCourses" runat="server">0</asp:Literal></p>
                            <small><asp:Literal ID="litStatCoursesNote" runat="server" /></small>
                        </div>
                        <div class="ad-stat">
                            <p class="ad-stat__label">Enrollments</p>
                            <p class="ad-stat__value"><asp:Literal ID="litStatEnrollments" runat="server">0</asp:Literal></p>
                            <small><asp:Literal ID="litStatEnrollmentsNote" runat="server" /></small>
                        </div>
                    </div>

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
                            <button type="button" class="btn btn--primary btn--sm" id="btnNewUser">
                                <i class="bi bi-person-plus" aria-hidden="true"></i>Create user
                            </button>
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
                                                data-id="<%# Eval("UserId") %>"
                                                data-active="<%# (bool)Eval("IsActive") ? "1" : "0" %>"
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
                                                <td><span class="<%# RoleTagClass(Eval("Role")) %>"><%# Html(Eval("Role")) %></span><%# string.Equals(Convert.ToString(Eval("Role")), "Tutor", StringComparison.OrdinalIgnoreCase) && !(bool)Eval("IsVerified") ? " <span class=\"tag tag--warn\">Unverified</span>" : "" %></td>
                                                <td class="num"><%# Eval("EnrolledCount") %></td>
                                                <td class="end">
                                                    <span class="ad-actions">
                                                        <button type="button" class="ad-icon-btn" data-edit-user title="Edit user">
                                                            <i class="bi bi-pencil" aria-hidden="true"></i><span class="sr-only">Edit</span>
                                                        </button>
                                                        <asp:LinkButton runat="server" CommandName="ToggleActive" CommandArgument='<%# Eval("UserId") %>'
                                                            CssClass="ad-icon-btn"
                                                            ToolTip='<%# (bool)Eval("IsActive") ? "Disable (can no longer sign in)" : "Enable (can sign in again)" %>'
                                                            Text='<%# (bool)Eval("IsActive") ? "<i class=\"bi bi-slash-circle\"></i><span class=\"sr-only\">Disable</span>" : "<i class=\"bi bi-check-circle\"></i><span class=\"sr-only\">Enable</span>" %>' />
                                                        <asp:LinkButton runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("UserId") %>'
                                                            CssClass="ad-icon-btn ad-danger" ToolTip="Delete user"
                                                            Text='<%# "<i class=\"bi bi-trash\"></i><span class=\"sr-only\">Delete</span>" %>'
                                                            OnClientClick="return confirm('Delete this user? Their enrollments, progress, reviews and messages are deleted too. This cannot be undone.');" />
                                                    </span>
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

                <!-- ---------- TUTOR VERIFICATION ---------- -->
                <section id="pane-verify" class="ad-pane" aria-labelledby="pageTitle">
                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">Waiting for review</h2>
                                <p class="ad-panel__hint">Open the certificate and check the name and institution match the account. Students can only find and book verified tutors. A rejected tutor sees your reason and can upload again.</p>
                            </div>
                        </div>
                        <div class="ad-table-wrap">
                            <table class="ad-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Tutor</th>
                                        <th scope="col">Institution</th>
                                        <th scope="col">Subjects</th>
                                        <th scope="col">Submitted</th>
                                        <th scope="col">Certificate</th>
                                        <th scope="col">Note to tutor</th>
                                        <th scope="col" class="end"><span class="sr-only">Actions</span></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptVerifyPending" runat="server" OnItemCommand="rptVerifyPending_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <strong><%# Html(Eval("FullName")) %></strong>
                                                    <%# Convert.ToInt32(Eval("RejectedBefore")) > 0 ? "<span class=\"tag\">Re-submitted</span>" : "" %>
                                                    <br /><span class="quiet"><%# Html(Eval("Email")) %></span>
                                                </td>
                                                <td><%# NotSet(Eval("Institution")) %></td>
                                                <td class="quiet"><%# NotSet(Eval("Subjects")) %></td>
                                                <td class="quiet"><%# FormatDate(Eval("SubmittedAt")) %></td>
                                                <td>
                                                    <a class="btn btn--ghost btn--sm" href="Certificate.ashx?user=<%# Eval("UserId") %>" target="_blank" rel="noopener">
                                                        <i class="bi bi-file-earmark-text" aria-hidden="true"></i>&nbsp;View <%# FileKind(Eval("CertificatePath")) %>
                                                    </a>
                                                </td>
                                                <td><asp:TextBox ID="txtVerifyNote" runat="server" CssClass="ad-input ad-note" MaxLength="500" placeholder="Required to reject" /></td>
                                                <td class="end">
                                                    <span class="ad-actions">
                                                        <asp:LinkButton runat="server" CommandName="Approve" CommandArgument='<%# Eval("UserId") %>'
                                                            CssClass="btn btn--primary btn--sm" Text="Approve"
                                                            OnClientClick="return confirm('Approve this tutor? Students will be able to find and book them.');" />
                                                        <asp:LinkButton runat="server" CommandName="Reject" CommandArgument='<%# Eval("UserId") %>'
                                                            CssClass="btn btn--ghost btn--sm ad-danger" Text="Reject"
                                                            OnClientClick="return confirm('Reject this certificate? The tutor will be asked to upload a new one.');" />
                                                    </span>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="phNoVerifyPending" runat="server" Visible="false">
                                        <tr class="ad-empty"><td colspan="7"><strong>Nothing to review</strong>Certificates that tutors upload show up here.</td></tr>
                                    </asp:PlaceHolder>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">Verified tutors</h2>
                                <p class="ad-panel__hint">Revoking removes the verified badge and asks the tutor for a new certificate. Their courses and booked sessions stay as they are.</p>
                            </div>
                        </div>
                        <div class="ad-table-wrap">
                            <table class="ad-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Tutor</th>
                                        <th scope="col">Institution</th>
                                        <th scope="col">Verified</th>
                                        <th scope="col">Certificate</th>
                                        <th scope="col">Reason to revoke</th>
                                        <th scope="col" class="end"><span class="sr-only">Actions</span></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptVerified" runat="server" OnItemCommand="rptVerified_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <strong><%# Html(Eval("FullName")) %></strong>
                                                    <%# (bool)Eval("IsActive") ? "" : "<span class=\"tag\">Disabled</span>" %>
                                                    <br /><span class="quiet"><%# Html(Eval("Email")) %></span>
                                                </td>
                                                <td><%# NotSet(Eval("Institution")) %></td>
                                                <td class="quiet"><%# Eval("VerifiedAt") == DBNull.Value ? "Before review history" : FormatDate(Eval("VerifiedAt")) %></td>
                                                <td>
                                                    <%# Eval("CertificatePath") == DBNull.Value ? "<span class=\"quiet\">No file</span>" :
                                                        "<a class=\"btn btn--ghost btn--sm\" href=\"Certificate.ashx?user=" + Eval("UserId") + "\" target=\"_blank\" rel=\"noopener\">View " + FileKind(Eval("CertificatePath")) + "</a>" %>
                                                </td>
                                                <td><asp:TextBox ID="txtRevokeNote" runat="server" CssClass="ad-input ad-note" MaxLength="480" placeholder="Required to revoke" /></td>
                                                <td class="end">
                                                    <asp:LinkButton runat="server" CommandName="Revoke" CommandArgument='<%# Eval("UserId") %>'
                                                        CssClass="btn btn--ghost btn--sm ad-danger" Text="Revoke"
                                                        OnClientClick="return confirm('Revoke this tutor\'s verification?');" />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="phNoVerified" runat="server" Visible="false">
                                        <tr class="ad-empty"><td colspan="6"><strong>No verified tutors yet</strong>Approve a certificate above to verify a tutor.</td></tr>
                                    </asp:PlaceHolder>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">No certificate yet</h2>
                                <p class="ad-panel__hint">Unverified tutors with nothing to review: they haven't uploaded, or their last certificate was rejected or revoked.</p>
                            </div>
                        </div>
                        <div class="ad-table-wrap">
                            <table class="ad-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Tutor</th>
                                        <th scope="col">Email</th>
                                        <th scope="col">Joined</th>
                                        <th scope="col">Last decision</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptVerifyMissing" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><strong><%# Html(Eval("FullName")) %></strong></td>
                                                <td class="quiet"><%# Html(Eval("Email")) %></td>
                                                <td class="quiet"><%# FormatDate(Eval("CreatedAt")) %></td>
                                                <td class="ad-reason"><%# Eval("LastStatus") == DBNull.Value ? "<span class=\"quiet\">Never uploaded</span>" : VerifyStatusTag(Eval("LastStatus")) + " <span class=\"quiet\">" + Html(Eval("LastNote")) + "</span>" %></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="phNoVerifyMissing" runat="server" Visible="false">
                                        <tr class="ad-empty"><td colspan="4"><strong>Every tutor has submitted a certificate</strong></td></tr>
                                    </asp:PlaceHolder>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="ad-panel">
                        <div class="ad-panel__head">
                            <div>
                                <h2 class="ad-panel__title">Decision history</h2>
                                <p class="ad-panel__hint">The last 30 approvals, rejections and revocations.</p>
                            </div>
                        </div>
                        <div class="ad-table-wrap">
                            <table class="ad-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Tutor</th>
                                        <th scope="col">Decision</th>
                                        <th scope="col">Submitted</th>
                                        <th scope="col">Decided</th>
                                        <th scope="col">By</th>
                                        <th scope="col">Note</th>
                                        <th scope="col" class="end">File</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptVerifyHistory" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><strong><%# Html(Eval("TutorName")) %></strong></td>
                                                <td><%# VerifyStatusTag(Eval("Status")) %></td>
                                                <td class="quiet"><%# FormatDate(Eval("SubmittedAt")) %></td>
                                                <td class="quiet"><%# FormatDate(Eval("ReviewedAt")) %></td>
                                                <td class="quiet"><%# Html(Eval("ReviewerName")) %></td>
                                                <td class="ad-reason"><%# Html(Eval("ReviewNote")) %></td>
                                                <td class="end"><a href="Certificate.ashx?verification=<%# Eval("VerificationId") %>" target="_blank" rel="noopener">Open</a></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="phNoVerifyHistory" runat="server" Visible="false">
                                        <tr class="ad-empty"><td colspan="7"><strong>No decisions yet</strong></td></tr>
                                    </asp:PlaceHolder>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
                <!-- Create / edit user popup. Opened by the Create user and Edit
                     buttons; saving posts back to btnSaveUser_Click. -->
                <dialog class="ad-modal" id="userModal" aria-labelledby="userModalTitle">
                    <div class="ad-modal__head">
                        <h2 id="userModalTitle">Edit user</h2>
                        <button type="button" class="ad-modal__x" data-close-modal aria-label="Close"><i class="bi bi-x-lg" aria-hidden="true"></i></button>
                    </div>
                    <asp:HiddenField ID="hdnUserId" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdnUserModal" runat="server" ClientIDMode="Static" />
                    <div class="ad-form ad-modal__body">
                        <asp:Literal ID="litUserModalMsg" runat="server" EnableViewState="false" />
                        <div class="ad-field full">
                            <asp:Label runat="server" AssociatedControlID="txtUserName">Full name</asp:Label>
                            <asp:TextBox ID="txtUserName" runat="server" CssClass="ad-input" MaxLength="100" ClientIDMode="Static" autocomplete="off" />
                        </div>
                        <div class="ad-field full">
                            <asp:Label runat="server" AssociatedControlID="txtUserEmail">Email</asp:Label>
                            <asp:TextBox ID="txtUserEmail" runat="server" CssClass="ad-input" TextMode="Email" MaxLength="256" ClientIDMode="Static" autocomplete="off" />
                        </div>
                        <div class="ad-field">
                            <asp:Label runat="server" AssociatedControlID="ddlUserRole">Role</asp:Label>
                            <asp:DropDownList ID="ddlUserRole" runat="server" CssClass="ad-select" ClientIDMode="Static">
                                <asp:ListItem Value="Student">Student</asp:ListItem>
                                <asp:ListItem Value="Tutor">Tutor</asp:ListItem>
                                <asp:ListItem Value="Admin">Admin</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="ad-field">
                            <asp:Label runat="server" AssociatedControlID="txtUserPassword">Password</asp:Label>
                            <asp:TextBox ID="txtUserPassword" runat="server" CssClass="ad-input" TextMode="Password" ClientIDMode="Static" autocomplete="new-password" />
                            <p id="userPasswordHint">At least 8 characters.</p>
                        </div>
                        <div class="ad-check full">
                            <asp:CheckBox ID="chkUserActive" runat="server" ClientIDMode="Static" Checked="true" />
                            <asp:Label runat="server" AssociatedControlID="chkUserActive">Can sign in</asp:Label>
                        </div>
                    </div>
                    <div class="ad-modal__foot">
                        <button type="button" class="btn btn--ghost btn--sm" data-close-modal>Cancel</button>
                        <asp:Button ID="btnSaveUser" runat="server" CssClass="btn btn--primary btn--sm" Text="Save" OnClick="btnSaveUser_Click" ClientIDMode="Static" />
                    </div>
                </dialog>

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
                                <div class="ad-form-actions">
                                    <div class="ad-switch" role="group" aria-label="Course layout" id="courseViewSwitch">
                                        <button type="button" class="is-on" data-view="table" aria-pressed="true"><i class="bi bi-list-ul" aria-hidden="true"></i>Table</button>
                                        <button type="button" data-view="cards" aria-pressed="false"><i class="bi bi-grid" aria-hidden="true"></i>Cards</button>
                                    </div>
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
                                            <th scope="col" class="num">Chapters</th>
                                            <th scope="col" class="num">Learners</th>
                                            <th scope="col">Status</th>
                                            <th scope="col" class="end"><span class="sr-only">Actions</span></th>
                                        </tr>
                                    </thead>
                                    <tbody id="courseRows">
                                        <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                                            <ItemTemplate>
                                                <tr class="course-row"
                                                    data-id="<%# Eval("CourseId") %>"
                                                    data-code="<%# Attr(Eval("CourseCode")) %>"
                                                    data-title="<%# Attr(Eval("Title")) %>"
                                                    data-category="<%# Attr(Eval("Category")) %>"
                                                    data-level="<%# Attr(Eval("Level")) %>"
                                                    data-lessons="<%# Eval("Lessons") %>"
                                                    data-learners="<%# Eval("LearnerCount") %>"
                                                    data-tutor-id="<%# Eval("TutorId") %>"
                                                    data-tutor="<%# Attr(Eval("TutorName")) %>"
                                                    data-description="<%# Attr(Eval("Description")) %>"
                                                    data-image="<%# Attr(Eval("ImageUrl")) %>"
                                                    data-status="<%# (bool)Eval("IsPublished") ? "published" : "draft" %>">
                                                    <td class="code"><%# Html(Eval("CourseCode")) %></td>
                                                    <td><a class="ad-open" href="AdminCourse.aspx?id=<%# Eval("CourseId") %>"><%# Html(Eval("Title")) %></a></td>
                                                    <td class="quiet"><%# Html(Eval("Category")) %></td>
                                                    <td class="quiet"><%# Html(Eval("Level")) %></td>
                                                    <td class="num"><%# Eval("Lessons") %></td>
                                                    <td class="num"><%# Eval("LearnerCount") %></td>
                                                    <td><%# (bool)Eval("IsPublished") ? "<span class=\"tag tag--live\">Published</span>" : (Eval("ReviewRequestedAt") != DBNull.Value ? "<span class=\"tag tag--accent\" title=\"The tutor submitted this draft for publishing\">Review requested</span>" : "<span class=\"tag\">Draft</span>") %></td>
                                                    <td class="end">
                                                        <span class="ad-actions">
                                                            <a class="ad-icon-btn" href="AdminCourse.aspx?id=<%# Eval("CourseId") %>" title="Open chapters and content">
                                                                <i class="bi bi-journal-text" aria-hidden="true"></i><span class="sr-only">Chapters and content</span>
                                                            </a>
                                                            <button type="button" class="ad-icon-btn" data-edit-course="<%# Eval("CourseId") %>" title="Edit details">
                                                                <i class="bi bi-pencil" aria-hidden="true"></i><span class="sr-only">Edit</span>
                                                            </button>
                                                            <asp:LinkButton runat="server" CommandName="TogglePublish" CommandArgument='<%# Eval("CourseId") %>'
                                                                CssClass="ad-icon-btn js-publish"
                                                                ToolTip='<%# (bool)Eval("IsPublished") ? "Unpublish (back to draft)" : "Publish" %>'
                                                                Text='<%# (bool)Eval("IsPublished") ? "<i class=\"bi bi-eye-slash\"></i><span class=\"sr-only\">Unpublish</span>" : "<i class=\"bi bi-eye\"></i><span class=\"sr-only\">Publish</span>" %>' />
                                                            <asp:LinkButton runat="server" CommandName="Delete" CommandArgument='<%# Eval("CourseId") %>'
                                                                CssClass="ad-icon-btn ad-danger js-delete" ToolTip="Delete course"
                                                                Text='<%# "<i class=\"bi bi-trash\"></i><span class=\"sr-only\">Delete</span>" %>'
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

                        <asp:PlaceHolder ID="phAssignTutor" runat="server">
                            <div class="ad-panel">
                                <div class="ad-panel__head">
                                    <div>
                                        <h2 class="ad-panel__title">Assign a tutor</h2>
                                        <p class="ad-panel__hint">A course's lessons are written by its tutor in Tutor Studio. Courses made here start without a tutor or lessons.</p>
                                    </div>
                                </div>
                                <div class="ad-panel__body">
                                    <div class="ad-form">
                                        <div class="ad-field wide">
                                            <asp:Label runat="server" AssociatedControlID="ddlAssignCourse">Course</asp:Label>
                                            <asp:DropDownList ID="ddlAssignCourse" runat="server" CssClass="ad-select" />
                                        </div>
                                        <div class="ad-field">
                                            <asp:Label runat="server" AssociatedControlID="ddlAssignTutor">Tutor</asp:Label>
                                            <asp:DropDownList ID="ddlAssignTutor" runat="server" CssClass="ad-select" />
                                        </div>
                                        <div class="ad-form-actions full">
                                            <asp:Button ID="btnAssignTutor" runat="server" CssClass="btn btn--primary btn--sm" Text="Assign tutor" OnClick="btnAssignTutor_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </asp:PlaceHolder>
                    </div>

                    <div id="sub-course-create" class="ad-sub-pane">
                        <div class="ad-panel">
                            <div class="ad-panel__head">
                                <div>
                                    <h2 class="ad-panel__title">New course</h2>
                                    <p class="ad-panel__hint">Saved as a draft unless you publish it now.</p>
                                </div>
                            </div>
                            <div class="ad-panel__body" id="courseFormHome">
                                <div class="ad-course-form" id="courseForm">
                                    <asp:HiddenField ID="hdnCourseId" runat="server" ClientIDMode="Static" />
                                    <asp:HiddenField ID="hdnCourseModal" runat="server" ClientIDMode="Static" />
                                    <div class="ad-course-form__grid">
                                        <div class="ad-form">
                                            <asp:Literal ID="litCourseMsg" runat="server" EnableViewState="false" />
                                            <div class="ad-field full">
                                                <asp:Label runat="server" AssociatedControlID="txtCourseTitle">Title</asp:Label>
                                                <asp:TextBox ID="txtCourseTitle" runat="server" CssClass="ad-input" MaxLength="200" ClientIDMode="Static" placeholder="Smart Budgeting and Cash Flow" />
                                            </div>
                                            <div class="ad-field">
                                                <asp:Label runat="server" AssociatedControlID="txtCourseCode">Code</asp:Label>
                                                <asp:TextBox ID="txtCourseCode" runat="server" CssClass="ad-input" MaxLength="20" ClientIDMode="Static" placeholder="FIN-101" />
                                                <p>Unique. Printed on certificates.</p>
                                            </div>
                                            <div class="ad-field">
                                                <asp:Label runat="server" AssociatedControlID="ddlCategory">Category</asp:Label>
                                                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="ad-select" ClientIDMode="Static" />
                                            </div>
                                            <div class="ad-field">
                                                <asp:Label runat="server" AssociatedControlID="ddlLevel">Level</asp:Label>
                                                <asp:DropDownList ID="ddlLevel" runat="server" CssClass="ad-select" ClientIDMode="Static" />
                                            </div>
                                            <div class="ad-field full">
                                                <asp:Label runat="server" AssociatedControlID="ddlTutor">Tutor</asp:Label>
                                                <asp:DropDownList ID="ddlTutor" runat="server" CssClass="ad-select" ClientIDMode="Static" />
                                                <p>Shown to learners as who leads the course.</p>
                                            </div>
                                            <div class="ad-field full">
                                                <asp:Label runat="server" AssociatedControlID="txtCourseDesc">Description</asp:Label>
                                                <asp:TextBox ID="txtCourseDesc" runat="server" CssClass="ad-input" TextMode="MultiLine" Rows="4" MaxLength="1000" ClientIDMode="Static"
                                                    placeholder="What learners will be able to do after this course." />
                                                <p>Shown on the course card. Up to 1,000 characters.</p>
                                            </div>
                                            <div class="ad-check full">
                                                <asp:CheckBox ID="chkPublish" runat="server" ClientIDMode="Static" />
                                                <asp:Label runat="server" AssociatedControlID="chkPublish">Published (learners can see and enrol)</asp:Label>
                                            </div>
                                        </div>

                                        <div class="ad-course-form__media">
                                            <span class="ad-label">Course image</span>
                                            <label class="ad-picker" for="fuCourseImage">
                                                <img class="ad-picker__img" id="coursePreview" alt="Course image preview" hidden="hidden" />
                                                <span class="ad-picker__empty" id="coursePickerEmpty">
                                                    <i class="bi bi-image" aria-hidden="true"></i>
                                                    <strong>Click to add a course image</strong>
                                                    <span>JPG, PNG or WebP, up to 5 MB</span>
                                                </span>
                                                <span class="ad-picker__change" id="coursePickerChange" hidden="hidden">
                                                    <i class="bi bi-arrow-repeat" aria-hidden="true"></i>Change image
                                                </span>
                                                <asp:FileUpload ID="fuCourseImage" runat="server" CssClass="ad-picker__input" ClientIDMode="Static" accept=".jpg,.jpeg,.png,.webp" />
                                            </label>
                                            <p>A 16:9 picture fits the course card best.</p>
                                            <div class="ad-check" id="courseRemoveImageWrap" hidden="hidden">
                                                <asp:CheckBox ID="chkRemoveImage" runat="server" ClientIDMode="Static" />
                                                <asp:Label runat="server" AssociatedControlID="chkRemoveImage">Remove the current image</asp:Label>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="ad-course-form__actions">
                                        <button type="button" class="btn btn--ghost btn--sm ad-course-form__cancel" data-close-modal>Cancel</button>
                                        <asp:Button ID="btnSaveCourse" runat="server" CssClass="btn btn--primary btn--sm" Text="Save course" OnClick="btnSaveCourse_Click" ClientIDMode="Static" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Edit course popup. The pencil buttons move the New course form
                     (#courseForm) in here, so create and edit share one set of fields. -->
                <dialog class="ad-modal ad-modal--wide" id="courseModal" aria-labelledby="courseModalTitle">
                    <div class="ad-modal__head">
                        <h2 id="courseModalTitle">Edit course</h2>
                        <button type="button" class="ad-modal__x" data-close-modal aria-label="Close"><i class="bi bi-x-lg" aria-hidden="true"></i></button>
                    </div>
                    <div class="ad-modal__body" id="courseFormModalSlot"></div>
                </dialog>

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

        <%-- server data for the script below; both values arrive JS-encoded, so < > & come through as \u escapes --%>
        <script type="application/json" id="adminData">{"name":"<asp:Literal ID="litAdminNameJs" runat="server">Admin</asp:Literal>","chart":<asp:Literal ID="litChartJson" runat="server" Text="[]" />}</script>

        <script type="text/javascript">
            // @ts-nocheck
            (function () {
                var adminData = JSON.parse(document.getElementById('adminData').textContent);
                var adminFirstName = adminData.name;
                var chartData = adminData.chart;

                var meta = {
                    'pane-overview': ['Welcome back, ' + adminFirstName, 'Accounts, courses and enrollments across Meowlet.'],
                    'pane-users': ['Users', 'Find an account and change who can sign in.'],
                    'pane-verify': ['Tutor verification', 'Check tutor certificates before students can book them.'],
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
                // admindashboard.aspx#users, #courses, ... (links from the course builder's sidebar)
                var hashPane = 'pane-' + location.hash.replace('#', '');
                if (location.hash.length > 1 && saved[0] === 'pane-overview' && meta[hashPane]) {
                    saved = [hashPane, hashPane === 'pane-courses' ? 'sub-course-list' : undefined];
                }
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

                // ---- users: create / edit popup ----
                var userModal = document.getElementById('userModal');
                var userFields = {
                    id: document.getElementById('hdnUserId'),
                    open: document.getElementById('hdnUserModal'),
                    name: document.getElementById('txtUserName'),
                    email: document.getElementById('txtUserEmail'),
                    role: document.getElementById('ddlUserRole'),
                    password: document.getElementById('txtUserPassword'),
                    active: document.getElementById('chkUserActive')
                };
                var roleNames = { student: 'Student', tutor: 'Tutor', admin: 'Admin' };

                function openUserModal(row, keepValues) {
                    var editing = row ? true : !!userFields.id.value;
                    if (!keepValues) {
                        userFields.id.value = row ? row.getAttribute('data-id') : '';
                        userFields.name.value = row ? row.getAttribute('data-name') : '';
                        userFields.email.value = row ? row.getAttribute('data-email') : '';
                        userFields.role.value = row ? roleNames[row.getAttribute('data-role')] || 'Student' : 'Student';
                        userFields.active.checked = row ? row.getAttribute('data-active') === '1' : true;
                        var msg = userModal.querySelector('.ad-flash');
                        if (msg) { msg.parentNode.removeChild(msg); }
                    }
                    userFields.password.value = '';
                    document.getElementById('userModalTitle').textContent = editing ? 'Edit user' : 'Create user';
                    document.getElementById('userPasswordHint').textContent = editing
                        ? 'Leave blank to keep the current password.' : 'At least 8 characters.';
                    document.getElementById('btnSaveUser').value = editing ? 'Save changes' : 'Create user';
                    userFields.open.value = 'open';
                    if (userModal.showModal) { userModal.showModal(); } else { userModal.setAttribute('open', 'open'); }
                    userFields.name.focus();
                }

                function closeUserModal() {
                    userFields.open.value = '';
                    if (userModal.close) { userModal.close(); } else { userModal.removeAttribute('open'); }
                }

                document.getElementById('btnNewUser').onclick = function () { openUserModal(null); };
                userModal.addEventListener('cancel', function () { userFields.open.value = ''; });
                var closers = userModal.querySelectorAll('[data-close-modal]');
                for (var uc = 0; uc < closers.length; uc++) { closers[uc].onclick = closeUserModal; }

                document.getElementById('userRows').addEventListener('click', function (e) {
                    var btn = e.target.closest ? e.target.closest('[data-edit-user]') : null;
                    if (btn) { openUserModal(btn.closest('tr')); }
                });

                // a failed save comes back with the popup still open and its values kept
                if (userFields.open.value === 'open') { openUserModal(null, true); }

                // ---- courses: New course tab and edit popup ----
                // One form (#courseForm). It lives in the New course tab; a pencil
                // button moves it into the popup, filled with that course, and
                // closing the popup moves it back, emptied.
                var courseModal = document.getElementById('courseModal');
                var courseForm = document.getElementById('courseForm');
                var courseHome = document.getElementById('courseFormHome');
                var courseSlot = document.getElementById('courseFormModalSlot');
                var cf = {
                    id: document.getElementById('hdnCourseId'),
                    open: document.getElementById('hdnCourseModal'),
                    title: document.getElementById('txtCourseTitle'),
                    code: document.getElementById('txtCourseCode'),
                    tutor: document.getElementById('ddlTutor'),
                    category: document.getElementById('ddlCategory'),
                    level: document.getElementById('ddlLevel'),
                    desc: document.getElementById('txtCourseDesc'),
                    file: document.getElementById('fuCourseImage'),
                    remove: document.getElementById('chkRemoveImage'),
                    removeWrap: document.getElementById('courseRemoveImageWrap'),
                    preview: document.getElementById('coursePreview'),
                    empty: document.getElementById('coursePickerEmpty'),
                    change: document.getElementById('coursePickerChange'),
                    publish: document.getElementById('chkPublish'),
                    save: document.getElementById('btnSaveCourse')
                };
                var currentImage = '';

                function showPicture(src) {
                    cf.preview.hidden = !src;
                    cf.empty.hidden = !!src;
                    cf.change.hidden = !src;
                    if (src) { cf.preview.src = src; } else { cf.preview.removeAttribute('src'); }
                }

                function setCurrentImage(src) {
                    currentImage = src || '';
                    cf.file.value = '';
                    cf.remove.checked = false;
                    cf.removeWrap.hidden = !currentImage;
                    showPicture(currentImage);
                }

                function fillCourse(row) {
                    cf.id.value = row ? row.getAttribute('data-id') : '';
                    cf.title.value = row ? row.getAttribute('data-title') : '';
                    cf.code.value = row ? row.getAttribute('data-code') : '';
                    cf.tutor.value = row ? row.getAttribute('data-tutor-id') : '';
                    if (cf.tutor.selectedIndex < 0) { cf.tutor.value = ''; }
                    if (row) { cf.category.value = row.getAttribute('data-category'); } else { cf.category.selectedIndex = 0; }
                    if (row) { cf.level.value = row.getAttribute('data-level'); } else { cf.level.selectedIndex = 0; }
                    cf.desc.value = row ? row.getAttribute('data-description') : '';
                    cf.publish.checked = row ? row.getAttribute('data-status') === 'published' : false;
                    setCurrentImage(row ? row.getAttribute('data-image') : '');
                    var msg = courseForm.querySelector('.ad-flash');
                    if (msg) { msg.parentNode.removeChild(msg); }
                }

                function courseRow(id) {
                    return document.querySelector('#courseRows tr[data-id="' + id + '"]');
                }

                function openCourseEdit(row, keepValues) {
                    if (keepValues) {
                        // a failed save: the server kept the typed values
                        var current = courseRow(cf.id.value);
                        setCurrentImage(current ? current.getAttribute('data-image') : '');
                    } else {
                        fillCourse(row);
                    }
                    courseSlot.appendChild(courseForm);
                    cf.save.value = 'Save changes';
                    cf.open.value = 'open';
                    if (courseModal.showModal) { courseModal.showModal(); } else { courseModal.setAttribute('open', 'open'); }
                    cf.title.focus();
                }

                // back to the tab as an empty New course form
                function returnCourseForm() {
                    if (courseForm.parentNode === courseHome) { return; }
                    courseHome.appendChild(courseForm);
                    fillCourse(null);
                    cf.save.value = 'Save course';
                    cf.open.value = '';
                }

                function closeCourseEdit() {
                    if (courseModal.close) { courseModal.close(); } else { courseModal.removeAttribute('open'); returnCourseForm(); }
                }

                courseModal.addEventListener('close', returnCourseForm);
                var courseClosers = document.querySelectorAll('#courseModal [data-close-modal], #courseForm [data-close-modal]');
                for (var cc = 0; cc < courseClosers.length; cc++) { courseClosers[cc].onclick = closeCourseEdit; }

                // picking a file previews it in the placeholder
                cf.file.onchange = function () {
                    if (cf.file.files && cf.file.files[0] && window.URL) {
                        cf.remove.checked = false;
                        showPicture(URL.createObjectURL(cf.file.files[0]));
                    }
                };

                cf.remove.onchange = function () {
                    if (cf.remove.checked) { cf.file.value = ''; showPicture(''); } else { showPicture(currentImage); }
                };

                // pencil buttons live in the table and in the cloned cards
                document.getElementById('pane-courses').addEventListener('click', function (e) {
                    var btn = e.target.closest ? e.target.closest('[data-edit-course]') : null;
                    if (btn) { openCourseEdit(courseRow(btn.getAttribute('data-edit-course'))); }
                });

                if (cf.open.value === 'open') { openCourseEdit(null, true); } else { setCurrentImage(''); }

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

                // Three-dots menu on a course card. Hide / Show and Delete press the
                // row's own postback links, so they behave exactly like the table.
                function courseMenu(r) {
                    var published = r.getAttribute('data-status') === 'published';
                    var wrap = el('div', 'ad-kebab');
                    var btn = el('button', 'ad-kebab__btn');
                    btn.type = 'button';
                    btn.setAttribute('aria-haspopup', 'true');
                    btn.setAttribute('aria-expanded', 'false');
                    btn.setAttribute('aria-label', 'Actions for ' + r.getAttribute('data-title'));
                    btn.appendChild(el('i', 'bi bi-three-dots-vertical'));

                    var menu = el('div', 'ad-kebab__menu');
                    menu.setAttribute('role', 'menu');
                    menu.hidden = true;

                    function item(iconName, text, cls, action) {
                        var b = el('button', cls || '');
                        b.type = 'button';
                        b.setAttribute('role', 'menuitem');
                        b.appendChild(el('i', 'bi ' + iconName));
                        b.appendChild(document.createTextNode(text));
                        b.onclick = function () { closeMenus(); action(); };
                        menu.appendChild(b);
                    }

                    item('bi-pencil', 'Edit details', '', function () { openCourseEdit(r); });
                    item('bi-journal-text', 'Chapters and content', '', function () { location.href = 'AdminCourse.aspx?id=' + r.getAttribute('data-id'); });
                    item(published ? 'bi-eye-slash' : 'bi-eye', published ? 'Hide from learners' : 'Show to learners', '',
                        function () { r.querySelector('.js-publish').click(); });
                    item('bi-trash', 'Delete', 'is-danger', function () { r.querySelector('.js-delete').click(); });

                    btn.onclick = function (e) {
                        e.stopPropagation();
                        var open = menu.hidden;
                        closeMenus();
                        menu.hidden = !open;
                        btn.setAttribute('aria-expanded', open ? 'true' : 'false');
                    };
                    wrap.onclick = function (e) { e.stopPropagation(); };

                    wrap.appendChild(btn);
                    wrap.appendChild(menu);
                    return wrap;
                }

                function closeMenus() {
                    var menus = document.querySelectorAll('.ad-kebab__menu');
                    for (var m = 0; m < menus.length; m++) {
                        menus[m].hidden = true;
                        menus[m].previousSibling.setAttribute('aria-expanded', 'false');
                    }
                }

                document.addEventListener('click', closeMenus);
                document.addEventListener('keydown', function (e) { if (e.key === 'Escape') { closeMenus(); } });

                // clicking a card (anywhere but its menu) opens the course builder
                courseCards.addEventListener('click', function (e) {
                    var card = e.target.closest ? e.target.closest('.ad-course') : null;
                    if (card) { location.href = 'AdminCourse.aspx?id=' + card.getAttribute('data-id'); }
                });
                courseCards.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter' && e.target.classList && e.target.classList.contains('ad-course')) {
                        location.href = 'AdminCourse.aspx?id=' + e.target.getAttribute('data-id');
                    }
                });

                function buildCards() {
                    courseCards.innerHTML = '';
                    for (var i = 0; i < courseRows.length; i++) {
                        var r = courseRows[i];
                        if (r.hidden) { continue; }

                        var card = el('article', 'ad-course');
                        if (r.getAttribute('data-image')) {
                            var img = el('img', 'ad-course__img');
                            img.src = r.getAttribute('data-image');
                            img.alt = '';
                            img.loading = 'lazy';
                            card.appendChild(img);
                        } else {
                            var blank = el('div', 'ad-course__img ad-course__img--empty');
                            blank.appendChild(el('i', 'bi bi-image'));
                            card.appendChild(blank);
                        }
                        var top = el('div', 'ad-course__top');
                        top.appendChild(el('span', 'code', r.getAttribute('data-code')));
                        top.appendChild(r.children[6].firstElementChild.cloneNode(true));

                        card.appendChild(top);
                        card.appendChild(el('h3', 'ad-course__title', r.getAttribute('data-title')));
                        card.appendChild(el('p', 'ad-course__meta',
                            r.getAttribute('data-category') + ', ' + r.getAttribute('data-level').toLowerCase()));
                        card.appendChild(el('p', 'ad-course__meta',
                            r.getAttribute('data-lessons') + (r.getAttribute('data-lessons') === '1' ? ' chapter, ' : ' chapters, ') +
                            r.getAttribute('data-learners') + ' learners' +
                            (r.getAttribute('data-tutor') ? ', with ' + r.getAttribute('data-tutor') : '')));
                        card.appendChild(courseMenu(r));
                        card.setAttribute('data-id', r.getAttribute('data-id'));
                        card.tabIndex = 0;
                        card.setAttribute('aria-label', 'Open ' + r.getAttribute('data-title'));
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

        <script type="text/javascript">
            // @ts-nocheck
            // Bell: pending admin sign ups from AdminNotifications.ashx, polled
            // every 30 seconds. "Generate code" makes a one-time access code the
            // admin copies or emails to the new admin, who enters it on
            // AdminAccessCode.aspx to activate their account.
            (function () {
                var bell = document.getElementById('bell');
                var btn = document.getElementById('bellBtn');
                var pop = document.getElementById('bellPop');
                var list = document.getElementById('bellList');
                var countEl = document.getElementById('bellCount');
                var url = 'AdminNotifications.ashx';
                var lastCount = -1;
                var shown = {};   // request id -> code just generated, kept while the request is pending

                function el(tag, cls, text) {
                    var n = document.createElement(tag);
                    if (cls) n.className = cls;
                    if (text != null) n.textContent = text;
                    return n;
                }

                function ago(iso) {
                    var mins = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 60000));
                    if (mins < 1) return 'just now';
                    if (mins < 60) return mins + ' min ago';
                    var h = Math.round(mins / 60);
                    if (h < 24) return h + (h === 1 ? ' hour ago' : ' hours ago');
                    var d = Math.round(h / 24);
                    return d + (d === 1 ? ' day ago' : ' days ago');
                }

                var statusText = {
                    waiting: 'Needs an access code',
                    sent: 'Code sent, waiting for them to enter it',
                    expired: 'Code expired',
                    locked: 'Too many wrong tries'
                };

                function post(action, id) {
                    return fetch(url, {
                        method: 'POST',
                        credentials: 'same-origin',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'fetch' },
                        body: 'action=' + encodeURIComponent(action) + '&id=' + encodeURIComponent(id)
                    }).then(function (res) {
                        return res.json().then(function (data) {
                            if (!res.ok) throw new Error(data.error || 'Something went wrong.');
                            return data;
                        });
                    });
                }

                function codeBox(result) {
                    var box = el('div', 'ad-note__code');
                    box.appendChild(el('b', null, result.code));
                    box.appendChild(el('p', null, 'Send this to ' + result.email + '. It works once, expires in 24 hours and won\'t be shown again after you leave this page.'));
                    var row = el('div');

                    var copy = el('button', 'btn btn--primary btn--sm', 'Copy code');
                    copy.type = 'button';
                    copy.addEventListener('click', function () {
                        if (!navigator.clipboard) return;
                        navigator.clipboard.writeText(result.code).then(function () {
                            copy.textContent = 'Copied';
                            setTimeout(function () { copy.textContent = 'Copy code'; }, 1600);
                        }, function () { });
                    });

                    var mail = el('a', 'btn btn--ghost btn--sm', 'Email it');
                    var base = location.href.split('#')[0].split('?')[0].replace(/[^\/]*$/, '');
                    mail.href = 'mailto:' + encodeURIComponent(result.email) +
                        '?subject=' + encodeURIComponent('Your Meowlet admin access code') +
                        '&body=' + encodeURIComponent('Hi ' + result.name.split(' ')[0] + ',\n\n' +
                            'Your admin access code is: ' + result.code + '\n\n' +
                            'Log in at ' + base + 'AdminSignin.aspx and enter it within 24 hours to open your dashboard.');

                    row.appendChild(copy);
                    row.appendChild(mail);
                    box.appendChild(row);
                    return box;
                }

                function render(items) {
                    list.innerHTML = '';
                    var waiting = 0;

                    if (!items.length) {
                        list.appendChild(el('li', 'ad-bell__empty', 'Nothing new. Admin sign ups show up here.'));
                    }

                    items.forEach(function (item) {
                        if (item.status !== 'sent') waiting++;

                        var li = el('li', 'ad-note');
                        var top = el('div', 'ad-note__top');
                        var icon = el('span', 'ad-note__icon');
                        icon.appendChild(el('i', 'bi bi-person-plus'));
                        top.appendChild(icon);

                        var text = el('div', 'ad-note__text');
                        text.appendChild(el('strong', null, item.name));
                        text.appendChild(document.createTextNode(' signed up as an admin'));
                        text.appendChild(el('span', 'ad-note__email', item.email));
                        var meta = statusText[item.status] + ' \u00b7 ' + ago(item.requestedAt);
                        if (item.status === 'sent' && item.generatedBy) meta += ' \u00b7 code by ' + item.generatedBy;
                        text.appendChild(el('span', 'ad-note__meta', meta));
                        top.appendChild(text);
                        li.appendChild(top);

                        if (shown[item.id]) {
                            li.appendChild(codeBox(shown[item.id]));
                        } else {
                            var actions = el('div', 'ad-note__actions');
                            var gen = el('button', 'btn btn--accent btn--sm', item.status === 'waiting' ? 'Generate code' : 'New code');
                            gen.type = 'button';
                            var decline = el('button', 'btn btn--quiet btn--sm', 'Decline');
                            decline.type = 'button';
                            var err = el('p', 'ad-note__err');

                            gen.addEventListener('click', function () {
                                gen.disabled = true;
                                post('generate', item.id).then(function (result) {
                                    shown[item.id] = result;
                                    load();
                                }, function (e) { err.textContent = e.message; gen.disabled = false; });
                            });

                            decline.addEventListener('click', function () {
                                if (!confirm("Decline " + item.name + "'s admin sign up?")) return;
                                decline.disabled = true;
                                post('decline', item.id).then(load, function (e) { err.textContent = e.message; decline.disabled = false; });
                            });

                            actions.appendChild(gen);
                            actions.appendChild(decline);
                            li.appendChild(actions);
                            li.appendChild(err);
                        }

                        list.appendChild(li);
                    });

                    countEl.textContent = waiting > 9 ? '9+' : waiting;
                    countEl.hidden = waiting === 0;
                    btn.setAttribute('aria-label', waiting ? 'Notifications, ' + waiting + ' need an access code' : 'Notifications');

                    if (lastCount >= 0 && waiting > lastCount) {
                        bell.classList.remove('is-new');
                        void bell.offsetWidth;
                        bell.classList.add('is-new');
                    }
                    lastCount = waiting;
                }

                function load() {
                    return fetch(url, { credentials: 'same-origin', cache: 'no-store' })
                        .then(function (res) { return res.ok ? res.json() : null; })
                        .then(function (data) {
                            if (!data) return;
                            var ids = {};
                            data.items.forEach(function (i) { ids[i.id] = true; });
                            Object.keys(shown).forEach(function (k) { if (!ids[k]) delete shown[k]; });
                            render(data.items);
                        })
                        .catch(function () { });
                }

                function setOpen(open) {
                    pop.hidden = !open;
                    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
                    if (open) load();
                }

                btn.addEventListener('click', function () { setOpen(pop.hidden); });
                document.addEventListener('click', function (e) { if (!bell.contains(e.target)) setOpen(false); });
                document.addEventListener('keydown', function (e) {
                    if (e.key === 'Escape' && !pop.hidden) { setOpen(false); btn.focus(); }
                });

                load();
                setInterval(function () { if (!document.hidden) load(); }, 30000);
                document.addEventListener('visibilitychange', function () { if (!document.hidden) load(); });
            })();
        </script>
    </form>
</body>
</html>

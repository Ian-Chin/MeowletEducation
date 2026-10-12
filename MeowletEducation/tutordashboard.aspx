<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="tutordashboard.aspx.cs" Inherits="MeowletEducation.TutorDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Tutor Studio - Meowlet Education</title>
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
        /* Tutor Studio. Same base styles as memberdashboard.aspx, which shares the admin panel's look: colours, type,
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
        /* ---------- Tutor Studio additions (td-) ----------
           Everything above is shared with memberdashboard.aspx so both
           dashboards look the same; tutor-only pieces are prefixed td-. */
        .md-stats.td-stats4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
        @media (max-width: 1100px) { .md-stats.td-stats4 { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
        @media (max-width: 560px) { .md-stats.td-stats4 { grid-template-columns: minmax(0, 1fr); } }

        .md-stat__note { margin: 4px 0 0; font-size: .78rem; color: var(--ink-faint); }

        .td-badge {
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
        @media (max-width: 760px) { .td-badge { display: none; } }

        .td-banner {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            margin: 0 0 20px;
            padding: 12px 16px;
            border: 1px solid var(--md-danger-line);
            border-radius: var(--radius-sm);
            background: var(--md-danger-bg);
            color: var(--ink);
        }
        .td-banner .bi { color: var(--md-danger); font-size: 1.1rem; margin-top: 1px; }
        .td-banner a { color: var(--md-accent-text); font-weight: 600; }

        .tag--ok { color: #2f7a3b; border-color: rgba(47, 122, 59, .3); }
        .tag--warn { color: var(--md-danger); border-color: var(--md-danger-line); }
        html[data-theme="dark"] .tag--ok { color: #8fd19b; }

        /* rows with a free-width action column */
        .md-row.td-row { grid-template-columns: minmax(0, 1fr) auto; align-items: start; }
        .td-row__side { display: flex; flex-direction: column; align-items: flex-end; gap: 8px; }
        .td-btns { display: flex; flex-wrap: wrap; gap: 6px; justify-content: flex-end; }
        .td-btns .btn { width: auto; }
        .td-when { font-weight: 600; color: var(--ink); font-variant-numeric: tabular-nums; }
        .td-quote { margin: 6px 0 0; padding-left: 10px; border-left: 2px solid var(--line-strong); font-size: .85rem; color: var(--ink-soft); }
        .td-quote--tutor { border-left-color: var(--accent); }
        .td-quote small { display: block; font-size: .74rem; color: var(--ink-faint); }

        .td-inline-form { display: flex; gap: 6px; margin-top: 8px; }
        .td-inline-form .md-input { flex: 1; min-width: 0; }

        .td-section-label {
            margin: 4px 18px 8px;
            font-size: .74rem;
            font-weight: 700;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--ink-faint);
        }

        /* forms */
        .td-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px 16px;
            padding: 0 18px 18px;
        }
        .td-grid .full { grid-column: 1 / -1; }
        @media (max-width: 640px) { .td-grid { grid-template-columns: minmax(0, 1fr); } }
        .td-field label,
        .td-field .td-label { display: block; margin-bottom: 5px; font-size: .8rem; font-weight: 600; color: var(--ink); }
        .td-field .td-hint { display: block; margin-top: 4px; font-size: .76rem; color: var(--ink-faint); }
        .td-field textarea.md-input { min-height: 96px; resize: vertical; }
        .td-field[hidden] { display: none; }
        .td-check { display: flex; align-items: center; gap: 8px; }
        .td-check label { margin: 0; font-weight: 500; }
        .td-actions { display: flex; flex-wrap: wrap; gap: 10px; }
        .md-input[readonly] { background: var(--cream); color: var(--ink-mute); }

        /* tables */
        .td-table-wrap { overflow-x: auto; padding: 0 18px 18px; }
        .td-table { width: 100%; border-collapse: collapse; font-size: .86rem; }
        .td-table th {
            padding: 8px 10px;
            border-bottom: 1px solid var(--line-strong);
            font-size: .74rem;
            font-weight: 700;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: var(--ink-faint);
            text-align: left;
            white-space: nowrap;
        }
        .td-table td { padding: 10px; border-bottom: 1px solid var(--line); color: var(--ink-soft); vertical-align: middle; }
        .td-table td.num { text-align: right; font-variant-numeric: tabular-nums; }
        .td-table td.end { text-align: right; white-space: nowrap; }
        .td-table strong { color: var(--ink); }
        .td-table .code { font-family: var(--mono); font-size: .76rem; }
        .td-table tr[hidden] { display: none; }
        .td-table .btn { padding: 5px 10px; font-size: .78rem; box-shadow: none; }
        .td-table .md-progress { min-width: 120px; }

        .td-pos {
            display: inline-grid;
            place-items: center;
            width: 26px;
            height: 26px;
            border-radius: 50%;
            background: var(--beige-deep);
            font-weight: 700;
            font-size: .8rem;
            color: var(--ink);
        }

        /* messages */
        .td-msg {
            padding: 12px 14px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--cream);
        }
        .td-msg--mine { background: var(--paper); border-style: dashed; }
        .td-msg--unread { border-color: var(--accent); box-shadow: inset 3px 0 0 var(--accent); }
        .td-msg__head { display: flex; justify-content: space-between; gap: 10px; font-size: .8rem; color: var(--ink-mute); }
        .td-msg__head strong { color: var(--ink); }
        .td-msg__body { margin: 6px 0 0; color: var(--ink-soft); white-space: pre-wrap; }

        .td-stars { color: var(--accent); letter-spacing: 1px; white-space: nowrap; }
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

                <nav aria-label="Tutor sections">
                    <p class="md-side__group">Teaching</p>
                    <button type="button" class="md-nav is-active" data-pane="pane-overview">
                        <i class="bi bi-grid-1x2" aria-hidden="true"></i><span>Dashboard</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-sessions">
                        <i class="bi bi-calendar-check" aria-hidden="true"></i><span>Sessions</span>
                        <asp:Literal ID="litReqBadge" runat="server" />
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-availability">
                        <i class="bi bi-clock" aria-hidden="true"></i><span>Availability</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-messages">
                        <i class="bi bi-chat-dots" aria-hidden="true"></i><span>Messages</span>
                        <asp:Literal ID="litMsgBadge" runat="server" />
                    </button>

                    <p class="md-side__group">Courses</p>
                    <button type="button" class="md-nav" data-pane="pane-courses">
                        <i class="bi bi-journal-bookmark" aria-hidden="true"></i><span>My Courses</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-lessons">
                        <i class="bi bi-list-ol" aria-hidden="true"></i><span>Lessons</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-learners">
                        <i class="bi bi-people" aria-hidden="true"></i><span>Learners</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-reviews">
                        <i class="bi bi-star" aria-hidden="true"></i><span>Reviews</span>
                    </button>

                    <p class="md-side__group">Account</p>
                    <button type="button" class="md-nav" data-pane="pane-profile">
                        <i class="bi bi-person-badge" aria-hidden="true"></i><span>Teaching Profile</span>
                    </button>
                    <a class="md-nav" href="Profile.aspx">
                        <i class="bi bi-person" aria-hidden="true"></i><span>Account &amp; Verification</span>
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
                        <h1 class="md-title" id="pageTitle">Welcome back, <asp:Literal ID="litWelcomeName" runat="server">Tutor</asp:Literal></h1>
                        <p class="md-sub" id="pageSub">Your sessions, courses and learners in one place.</p>
                    </div>
                    <div class="md-top__tools">
                        <a class="md-icon-btn" href="Index.aspx" title="Public site" aria-label="Public site">
                            <i class="bi bi-house" aria-hidden="true"></i>
                        </a>
                        <div class="md-menu">
                            <button type="button" class="md-menu__btn" aria-haspopup="true">
                                <i class="bi bi-person-circle" aria-hidden="true"></i>
                                <asp:Literal ID="litTutorName" runat="server">Tutor</asp:Literal>
                                <i class="bi bi-chevron-down" aria-hidden="true"></i>
                            </button>
                            <div class="md-menu__pop">
                                <div class="md-menu__card">
                                    <div class="md-menu__who">
                                        <strong><asp:Literal ID="litMenuName" runat="server">Tutor</asp:Literal></strong>
                                        <span><asp:Literal ID="litMenuEmail" runat="server" /></span>
                                    </div>
                                    <button type="button" class="md-menu__item" data-go="pane-profile"><i class="bi bi-person-badge" aria-hidden="true"></i>Teaching profile</button>
                                    <a class="md-menu__item" href="Profile.aspx"><i class="bi bi-person" aria-hidden="true"></i>Account settings</a>
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

                <asp:PlaceHolder ID="phUnverified" runat="server" Visible="false">
                    <div class="td-banner" role="note">
                        <i class="bi bi-shield-exclamation" aria-hidden="true"></i>
                        <div>
                            <strong>Your tutor account isn't verified yet.</strong>
                            <asp:Literal ID="litVerifyNote" runat="server" />
                            <a href="Profile.aspx">Upload or check your certificate</a>
                        </div>
                    </div>
                </asp:PlaceHolder>

                <!-- ---------- DASHBOARD ---------- -->
                <section id="pane-overview" class="md-pane is-active" aria-labelledby="pageTitle">

                    <div class="md-actions-bar">
                        <div class="md-actions-bar__left">
                            <button type="button" class="btn btn--ghost btn--sm" data-go="pane-sessions"><i class="bi bi-inbox" aria-hidden="true"></i>&nbsp;Booking requests</button>
                            <button type="button" class="btn btn--ghost btn--sm" data-go="pane-courses"><i class="bi bi-plus-lg" aria-hidden="true"></i>&nbsp;New course</button>
                            <button type="button" class="btn btn--ghost btn--sm" data-go="pane-availability"><i class="bi bi-clock" aria-hidden="true"></i>&nbsp;Set availability</button>
                        </div>
                    </div>

                    <div class="md-stats td-stats4">
                        <div class="md-stat">
                            <p class="md-stat__label"><i class="bi bi-calendar-event" aria-hidden="true"></i>Upcoming sessions</p>
                            <p class="md-stat__value"><asp:Literal ID="litStatUpcoming" runat="server">0</asp:Literal></p>
                            <p class="md-stat__note">Confirmed, still to come</p>
                        </div>
                        <div class="md-stat">
                            <p class="md-stat__label"><i class="bi bi-inbox" aria-hidden="true"></i>Booking requests</p>
                            <p class="md-stat__value"><asp:Literal ID="litStatRequests" runat="server">0</asp:Literal></p>
                            <p class="md-stat__note">Waiting for your answer</p>
                        </div>
                        <div class="md-stat">
                            <p class="md-stat__label"><i class="bi bi-people" aria-hidden="true"></i>Learners</p>
                            <p class="md-stat__value"><asp:Literal ID="litStatLearners" runat="server">0</asp:Literal></p>
                            <p class="md-stat__note">Enrolled in your courses</p>
                        </div>
                        <div class="md-stat">
                            <p class="md-stat__label"><i class="bi bi-star" aria-hidden="true"></i>Session rating</p>
                            <p class="md-stat__value"><asp:Literal ID="litStatRating" runat="server">-</asp:Literal></p>
                            <p class="md-stat__note"><asp:Literal ID="litStatRatingNote" runat="server">No reviews yet</asp:Literal></p>
                        </div>
                    </div>

                    <div class="md-pair">
                        <div class="md-panel">
                            <div class="md-panel__head">
                                <div>
                                    <h2 class="md-panel__title">Coming up</h2>
                                    <p class="md-panel__hint">Your next confirmed sessions and open requests. Times are Malaysia time.</p>
                                </div>
                                <button type="button" class="btn btn--ghost btn--sm" data-go="pane-sessions">All sessions</button>
                            </div>
                            <div class="md-rows">
                                <asp:Repeater ID="rptNextSessions" runat="server">
                                    <ItemTemplate>
                                        <div class="md-row td-row">
                                            <div>
                                                <span class="md-row__title"><%# Html(Eval("StudentName")) %></span>
                                                <span class="md-row__meta"><span class="td-when"><%# Myt(Eval("StartsAt")) %></span> · <%# Eval("DurationMinutes") %> min · <%# Html(Eval("Topic")) %></span>
                                                <%# Quote(Eval("StudentNote"), null, false) %>
                                            </div>
                                            <div class="td-row__side"><%# StatusTag(Eval("Status")) %></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                            <asp:PlaceHolder ID="phNoNext" runat="server" Visible="false">
                                <div class="md-empty-block">
                                    <strong>Nothing booked yet</strong>
                                    Keep your availability up to date so students can request a session.
                                </div>
                            </asp:PlaceHolder>
                        </div>

                        <div class="md-panel">
                            <div class="md-panel__head">
                                <h2 class="md-panel__title">Tutor profile</h2>
                                <asp:Literal ID="litVerifyTag" runat="server" />
                            </div>
                            <div class="md-profile">
                                <span class="md-avatar" aria-hidden="true"><asp:Literal ID="litAvatar" runat="server">?</asp:Literal></span>
                                <p class="md-profile__name"><asp:Literal ID="litProfileName" runat="server" /></p>
                                <p class="md-panel__hint" style="text-align:center;"><asp:Literal ID="litProfileHeadline" runat="server" /></p>
                                <dl class="md-facts">
                                    <div><dt>Email</dt><dd><asp:Literal ID="litProfileEmail" runat="server" /></dd></div>
                                    <div><dt>Subjects</dt><dd><asp:Literal ID="litProfileSubjects" runat="server">Not set</asp:Literal></dd></div>
                                    <div><dt>Bookings</dt><dd><asp:Literal ID="litProfileAccepting" runat="server" /></dd></div>
                                    <div><dt>Weekly slots</dt><dd><asp:Literal ID="litProfileSlots" runat="server">0</asp:Literal></dd></div>
                                </dl>
                                <button type="button" class="btn btn--primary btn--sm" data-go="pane-profile">Edit teaching profile</button>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ---------- SESSIONS ---------- -->
                <section id="pane-sessions" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">Booking requests</h2>
                                <p class="md-panel__hint">Accept to confirm the slot, or decline if it doesn't suit you.</p>
                            </div>
                        </div>
                        <div class="md-rows">
                            <asp:Repeater ID="rptRequests" runat="server" OnItemCommand="rptSessions_ItemCommand">
                                <ItemTemplate>
                                    <div class="md-row td-row">
                                        <div>
                                            <span class="md-row__title"><%# Html(Eval("StudentName")) %></span>
                                            <span class="md-row__meta"><span class="td-when"><%# Myt(Eval("StartsAt")) %></span> · <%# Eval("DurationMinutes") %> min · <%# Html(Eval("Topic")) %></span>
                                            <%# Quote(Eval("StudentNote"), null, false) %>
                                        </div>
                                        <div class="td-row__side">
                                            <span class="td-btns">
                                                <asp:LinkButton runat="server" CommandName="Accept" CommandArgument='<%# Eval("SessionId") %>'
                                                    CssClass="btn btn--primary btn--sm" Text="Accept" />
                                                <asp:LinkButton runat="server" CommandName="Decline" CommandArgument='<%# Eval("SessionId") %>'
                                                    CssClass="btn btn--ghost btn--sm md-danger" Text="Decline"
                                                    OnClientClick="return confirm('Decline this booking request?');" />
                                            </span>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:PlaceHolder ID="phNoRequests" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No open requests</strong>New booking requests from students appear here.</div>
                        </asp:PlaceHolder>
                    </div>

                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">Confirmed sessions</h2>
                                <p class="md-panel__hint">After a session, add a short summary or homework and mark it completed.</p>
                            </div>
                        </div>
                        <div class="md-rows">
                            <asp:Repeater ID="rptUpcoming" runat="server" OnItemCommand="rptSessions_ItemCommand">
                                <ItemTemplate>
                                    <div class="md-row td-row">
                                        <div>
                                            <span class="md-row__title"><%# Html(Eval("StudentName")) %></span>
                                            <span class="md-row__meta"><span class="td-when"><%# Myt(Eval("StartsAt")) %></span> · <%# Eval("DurationMinutes") %> min · <%# Html(Eval("Topic")) %>
                                                <%# LinkHtml(Eval("Link")) %></span>
                                            <%# Quote(Eval("StudentNote"), null, false) %>
                                            <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("HasStarted") %>'>
                                                <div class="td-inline-form">
                                                    <asp:TextBox ID="txtTutorNote" runat="server" CssClass="md-input" MaxLength="1000"
                                                        placeholder="Session summary or homework for the student" />
                                                </div>
                                            </asp:PlaceHolder>
                                        </div>
                                        <div class="td-row__side">
                                            <%# (bool)Eval("HasStarted") ? "<span class=\"tag tag--warn\">Awaiting wrap-up</span>" : StatusTag(Eval("Status")) %>
                                            <span class="td-btns">
                                                <asp:LinkButton runat="server" CommandName="Complete" CommandArgument='<%# Eval("SessionId") %>'
                                                    Visible='<%# (bool)Eval("HasStarted") %>'
                                                    CssClass="btn btn--primary btn--sm" Text="Mark completed" />
                                                <asp:LinkButton runat="server" CommandName="Cancel" CommandArgument='<%# Eval("SessionId") %>'
                                                    Visible='<%# !(bool)Eval("HasStarted") %>'
                                                    CssClass="btn btn--ghost btn--sm md-danger" Text="Cancel"
                                                    OnClientClick="return confirm('Cancel this session? The student will see it as cancelled by you.');" />
                                            </span>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:PlaceHolder ID="phNoUpcoming" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No confirmed sessions</strong>Accepted requests show up here.</div>
                        </asp:PlaceHolder>
                    </div>

                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">History</h2>
                                <p class="md-panel__hint">Completed, cancelled, declined and expired sessions.</p>
                            </div>
                        </div>
                        <div class="td-table-wrap">
                            <table class="td-table">
                                <thead>
                                    <tr><th>When</th><th>Student</th><th>Topic</th><th>Status</th><th>Your notes</th><th>Rating</th></tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptHistory" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><%# Myt(Eval("StartsAt")) %></td>
                                                <td><strong><%# Html(Eval("StudentName")) %></strong></td>
                                                <td><%# Html(Eval("Topic")) %></td>
                                                <td><%# StatusTag(Eval("DisplayStatus")) %></td>
                                                <td><%# Html(Eval("TutorNote")) %></td>
                                                <td><%# Stars(Eval("Rating")) %></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                        <asp:PlaceHolder ID="phNoHistory" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No past sessions</strong>Your finished sessions are kept here.</div>
                        </asp:PlaceHolder>
                    </div>
                </section>

                <!-- ---------- AVAILABILITY ---------- -->
                <section id="pane-availability" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-pair">
                        <div class="md-panel">
                            <div class="md-panel__head">
                                <div>
                                    <h2 class="md-panel__title">Weekly availability</h2>
                                    <p class="md-panel__hint">Students can request sessions inside these times (Malaysia time).</p>
                                </div>
                            </div>
                            <div class="td-table-wrap">
                                <table class="td-table">
                                    <thead><tr><th>Day</th><th>From</th><th>To</th><th></th></tr></thead>
                                    <tbody>
                                        <asp:Repeater ID="rptSlots" runat="server" OnItemCommand="rptSlots_ItemCommand">
                                            <ItemTemplate>
                                                <tr>
                                                    <td><strong><%# DayName(Eval("DayOfWeek")) %></strong></td>
                                                    <td><%# Clock(Eval("StartTime")) %></td>
                                                    <td><%# Clock(Eval("EndTime")) %></td>
                                                    <td class="end">
                                                        <asp:LinkButton runat="server" CommandName="DeleteSlot" CommandArgument='<%# Eval("AvailabilityId") %>'
                                                            CssClass="btn btn--ghost btn--sm md-danger" Text="Remove"
                                                            OnClientClick="return confirm('Remove this weekly slot?');" />
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </tbody>
                                </table>
                            </div>
                            <asp:PlaceHolder ID="phNoSlots" runat="server" Visible="false">
                                <div class="md-empty-block"><strong>No slots yet</strong>Add the times you can usually teach.</div>
                            </asp:PlaceHolder>
                        </div>

                        <div class="md-panel">
                            <div class="md-panel__head"><h2 class="md-panel__title">Add a slot</h2></div>
                            <div class="td-grid">
                                <div class="td-field full">
                                    <asp:Label runat="server" AssociatedControlID="ddlDay">Day</asp:Label>
                                    <asp:DropDownList ID="ddlDay" runat="server" CssClass="md-select">
                                        <asp:ListItem Value="1">Monday</asp:ListItem>
                                        <asp:ListItem Value="2">Tuesday</asp:ListItem>
                                        <asp:ListItem Value="3">Wednesday</asp:ListItem>
                                        <asp:ListItem Value="4">Thursday</asp:ListItem>
                                        <asp:ListItem Value="5">Friday</asp:ListItem>
                                        <asp:ListItem Value="6">Saturday</asp:ListItem>
                                        <asp:ListItem Value="7">Sunday</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="td-field">
                                    <asp:Label runat="server" AssociatedControlID="txtSlotStart">From</asp:Label>
                                    <asp:TextBox ID="txtSlotStart" runat="server" CssClass="md-input" TextMode="Time" Text="19:00" />
                                </div>
                                <div class="td-field">
                                    <asp:Label runat="server" AssociatedControlID="txtSlotEnd">To</asp:Label>
                                    <asp:TextBox ID="txtSlotEnd" runat="server" CssClass="md-input" TextMode="Time" Text="21:00" />
                                </div>
                                <div class="td-actions full">
                                    <asp:Button ID="btnAddSlot" runat="server" Text="Add slot" CssClass="btn btn--primary btn--sm" OnClick="btnAddSlot_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ---------- MESSAGES ---------- -->
                <section id="pane-messages" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">Messages</h2>
                                <p class="md-panel__hint">Your latest 50 messages with students. Unread ones are highlighted.</p>
                            </div>
                            <asp:Button ID="btnMarkRead" runat="server" Text="Mark all read" CssClass="btn btn--ghost btn--sm" OnClick="btnMarkRead_Click" />
                        </div>
                        <div class="md-rows">
                            <asp:Repeater ID="rptMessages" runat="server" OnItemCommand="rptMessages_ItemCommand">
                                <ItemTemplate>
                                    <div class='<%# MessageCss(Eval("IsMine"), Eval("ReadAt")) %>'>
                                        <div class="td-msg__head">
                                            <span><%# (int)Eval("IsMine") == 1 ? "You to <strong>" + Html(Eval("OtherName")) + "</strong>" : "<strong>" + Html(Eval("OtherName")) + "</strong>" %></span>
                                            <span><%# Myt(Eval("SentAt")) %></span>
                                        </div>
                                        <p class="td-msg__body"><%# Html(Eval("Body")) %></p>
                                        <asp:PlaceHolder runat="server" Visible='<%# (int)Eval("IsMine") == 0 %>'>
                                            <div class="td-inline-form">
                                                <asp:TextBox ID="txtMsgReply" runat="server" CssClass="md-input" MaxLength="2000" placeholder="Write a reply" />
                                                <asp:LinkButton runat="server" CommandName="Reply" CommandArgument='<%# Eval("MessageId") %>'
                                                    CssClass="btn btn--ghost btn--sm" Text="Send" />
                                            </div>
                                        </asp:PlaceHolder>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:PlaceHolder ID="phNoMessages" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No messages</strong>Students can message you about a booking.</div>
                        </asp:PlaceHolder>
                    </div>
                </section>

                <!-- ---------- MY COURSES ---------- -->
                <section id="pane-courses" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">My courses</h2>
                                <p class="md-panel__hint">New courses start as drafts. Submit a draft for review and an admin publishes it.</p>
                            </div>
                        </div>
                        <div class="td-table-wrap">
                            <table class="td-table">
                                <thead>
                                    <tr><th>Code</th><th>Title</th><th>Level</th><th>Lessons</th><th>Learners</th><th>Completed</th><th>Rating</th><th>Status</th><th></th></tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td class="code"><%# Html(Eval("CourseCode")) %></td>
                                                <td><strong><%# Html(Eval("Title")) %></strong><br /><span class="md-row__meta"><%# Html(Eval("Category")) %></span></td>
                                                <td><%# Html(Eval("Level")) %></td>
                                                <td class="num"><%# Eval("LessonCount") %></td>
                                                <td class="num"><%# Eval("LearnerCount") %></td>
                                                <td class="num"><%# Eval("CompletedCount") %></td>
                                                <td><%# Stars(Eval("AvgRating")) %></td>
                                                <td><%# CourseStatusTag(Eval("IsPublished"), Eval("ReviewRequestedAt")) %></td>
                                                <td class="end">
                                                    <span class="td-btns">
                                                        <asp:LinkButton runat="server" CommandName="Lessons" CommandArgument='<%# Eval("CourseId") %>'
                                                            CssClass="btn btn--ghost btn--sm" Text="Lessons" />
                                                        <a class="btn btn--ghost btn--sm" href="course.aspx?id=<%# Eval("CourseId") %>" title="See the course the way learners do">Preview</a>
                                                        <asp:LinkButton runat="server" CommandName="EditCourse" CommandArgument='<%# Eval("CourseId") %>'
                                                            CssClass="btn btn--ghost btn--sm" Text="Edit" />
                                                        <asp:LinkButton runat="server" CommandName="Submit" CommandArgument='<%# Eval("CourseId") %>'
                                                            Visible='<%# !(bool)Eval("IsPublished") && Eval("ReviewRequestedAt") == DBNull.Value %>'
                                                            CssClass="btn btn--primary btn--sm" Text="Submit for review" />
                                                        <asp:LinkButton runat="server" CommandName="Withdraw" CommandArgument='<%# Eval("CourseId") %>'
                                                            Visible='<%# !(bool)Eval("IsPublished") && Eval("ReviewRequestedAt") != DBNull.Value %>'
                                                            CssClass="btn btn--ghost btn--sm" Text="Withdraw" />
                                                        <asp:LinkButton runat="server" CommandName="DeleteCourse" CommandArgument='<%# Eval("CourseId") %>'
                                                            Visible='<%# !(bool)Eval("IsPublished") && Convert.ToInt32(Eval("LearnerCount")) == 0 %>'
                                                            CssClass="btn btn--ghost btn--sm md-danger" Text="Delete"
                                                            OnClientClick="return confirm('Delete this draft course and all its lessons?');" />
                                                    </span>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                        <asp:PlaceHolder ID="phNoCourses" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No courses yet</strong>Create your first draft below.</div>
                        </asp:PlaceHolder>
                    </div>

                    <div class="md-panel" id="courseForm">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title"><asp:Literal ID="litCourseFormTitle" runat="server">Create a course</asp:Literal></h2>
                                <p class="md-panel__hint">Editing a published course updates it straight away for enrolled learners.</p>
                            </div>
                        </div>
                        <asp:HiddenField ID="hdnCourseId" runat="server" />
                        <div class="td-grid">
                            <div class="td-field">
                                <asp:Label runat="server" AssociatedControlID="txtCourseCode">Course code</asp:Label>
                                <asp:TextBox ID="txtCourseCode" runat="server" CssClass="md-input" MaxLength="20" placeholder="e.g. SAV150" />
                                <span class="td-hint">Letters and numbers, unique. Can't be changed later.</span>
                            </div>
                            <div class="td-field">
                                <asp:Label runat="server" AssociatedControlID="txtCourseTitle">Title</asp:Label>
                                <asp:TextBox ID="txtCourseTitle" runat="server" CssClass="md-input" MaxLength="200" placeholder="e.g. Money Jars: Budgeting in AR" />
                            </div>
                            <div class="td-field">
                                <asp:Label runat="server" AssociatedControlID="ddlCategory">Category</asp:Label>
                                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="md-select" />
                            </div>
                            <div class="td-field">
                                <asp:Label runat="server" AssociatedControlID="ddlLevel">Level</asp:Label>
                                <asp:DropDownList ID="ddlLevel" runat="server" CssClass="md-select" />
                            </div>
                            <div class="td-field full">
                                <asp:Label runat="server" AssociatedControlID="txtCourseDesc">Description</asp:Label>
                                <asp:TextBox ID="txtCourseDesc" runat="server" CssClass="md-input" TextMode="MultiLine" MaxLength="1000"
                                    placeholder="What will learners be able to do with their money after this course?" />
                            </div>
                            <div class="td-actions full">
                                <asp:Button ID="btnSaveCourse" runat="server" Text="Save draft" CssClass="btn btn--primary btn--sm" OnClick="btnSaveCourse_Click" />
                                <asp:Button ID="btnCancelCourse" runat="server" Text="Clear" CssClass="btn btn--ghost btn--sm" OnClick="btnCancelCourse_Click" />
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ---------- LESSONS ---------- -->
                <section id="pane-lessons" class="md-pane" aria-labelledby="pageTitle">
                    <asp:PlaceHolder ID="phNoCourseForLessons" runat="server" Visible="false">
                        <div class="md-panel">
                            <div class="md-empty-block"><strong>Create a course first</strong>Lessons belong to one of your courses.</div>
                        </div>
                    </asp:PlaceHolder>

                    <asp:Panel ID="pnlLessons" runat="server">
                        <div class="md-panel">
                            <div class="md-panel__head">
                                <div>
                                    <h2 class="md-panel__title">Lessons</h2>
                                    <p class="md-panel__hint"><asp:Literal ID="litLessonCourseInfo" runat="server" /></p>
                                </div>
                                <asp:DropDownList ID="ddlLessonCourse" runat="server" CssClass="md-select" style="width:auto; max-width: 320px;"
                                    AutoPostBack="true" OnSelectedIndexChanged="ddlLessonCourse_SelectedIndexChanged" aria-label="Course" />
                            </div>
                            <div class="td-table-wrap">
                                <table class="td-table">
                                    <thead><tr><th>#</th><th>Title</th><th>Type</th><th>Minutes</th><th>Done by</th><th></th></tr></thead>
                                    <tbody>
                                        <asp:Repeater ID="rptLessons" runat="server" OnItemCommand="rptLessons_ItemCommand">
                                            <ItemTemplate>
                                                <tr>
                                                    <td><span class="td-pos"><%# Eval("Position") %></span></td>
                                                    <td><strong><%# Html(Eval("Title")) %></strong><%# LessonDetail(Eval("ContentType"), Eval("ContentUrl"), Eval("ARSceneKey")) %></td>
                                                    <td><%# TypeTag(Eval("ContentType")) %></td>
                                                    <td class="num"><%# Eval("DurationMinutes") %></td>
                                                    <td class="num"><%# Eval("DoneCount") %></td>
                                                    <td class="end">
                                                        <span class="td-btns">
                                                            <asp:LinkButton runat="server" CommandName="Up" CommandArgument='<%# Eval("LessonId") %>'
                                                                CssClass="btn btn--ghost btn--sm" ToolTip="Move up"><i class="bi bi-arrow-up" aria-hidden="true"></i></asp:LinkButton>
                                                            <asp:LinkButton runat="server" CommandName="Down" CommandArgument='<%# Eval("LessonId") %>'
                                                                CssClass="btn btn--ghost btn--sm" ToolTip="Move down"><i class="bi bi-arrow-down" aria-hidden="true"></i></asp:LinkButton>
                                                            <asp:LinkButton runat="server" CommandName="EditLesson" CommandArgument='<%# Eval("LessonId") %>'
                                                                CssClass="btn btn--ghost btn--sm" Text="Edit" />
                                                            <asp:LinkButton runat="server" CommandName="DeleteLesson" CommandArgument='<%# Eval("LessonId") %>'
                                                                CssClass="btn btn--ghost btn--sm md-danger" Text="Delete"
                                                                OnClientClick="return confirm('Delete this lesson? Learners lose their progress on it.');" />
                                                        </span>
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </tbody>
                                </table>
                            </div>
                            <asp:PlaceHolder ID="phNoLessons" runat="server" Visible="false">
                                <div class="md-empty-block"><strong>No lessons in this course yet</strong>Add the first one below.</div>
                            </asp:PlaceHolder>
                        </div>

                        <div class="md-panel" id="lessonForm">
                            <div class="md-panel__head">
                                <div>
                                    <h2 class="md-panel__title"><asp:Literal ID="litLessonFormTitle" runat="server">Add a lesson</asp:Literal></h2>
                                    <p class="md-panel__hint">New lessons go to the end of the course. Use the arrows to reorder.</p>
                                </div>
                            </div>
                            <asp:HiddenField ID="hdnLessonId" runat="server" />
                            <div class="td-grid">
                                <div class="td-field full">
                                    <asp:Label runat="server" AssociatedControlID="txtLessonTitle">Lesson title</asp:Label>
                                    <asp:TextBox ID="txtLessonTitle" runat="server" CssClass="md-input" MaxLength="200" placeholder="e.g. Sort a month of spending into jars" />
                                </div>
                                <div class="td-field">
                                    <asp:Label runat="server" AssociatedControlID="ddlLessonType">Type</asp:Label>
                                    <asp:DropDownList ID="ddlLessonType" runat="server" CssClass="md-select">
                                        <asp:ListItem Value="Video">Video</asp:ListItem>
                                        <asp:ListItem Value="Article">Article</asp:ListItem>
                                        <asp:ListItem Value="Quiz">Quiz</asp:ListItem>
                                        <asp:ListItem Value="AR">AR activity</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="td-field">
                                    <asp:Label runat="server" AssociatedControlID="txtLessonMinutes">Minutes</asp:Label>
                                    <asp:TextBox ID="txtLessonMinutes" runat="server" CssClass="md-input" TextMode="Number" min="1" max="240" Text="10" />
                                </div>
                                <div class="td-field full" data-for="Video">
                                    <asp:Label runat="server" AssociatedControlID="txtLessonUrl">Video link</asp:Label>
                                    <asp:TextBox ID="txtLessonUrl" runat="server" CssClass="md-input" MaxLength="400" placeholder="https://www.youtube.com/watch?v=..." />
                                </div>
                                <div class="td-field full" data-for="AR">
                                    <asp:Label runat="server" AssociatedControlID="ddlArScene">AR scene</asp:Label>
                                    <asp:DropDownList ID="ddlArScene" runat="server" CssClass="md-select" />
                                    <span class="td-hint">Learners do the activity in 3D on screen, or place it on a real table with an Android phone. Finishing it completes the lesson, and you see their results under Learners.</span>
                                </div>
                                <div class="td-field full" data-for="AR" id="arSettings">
                                    <span class="td-label">Activity settings</span>
                                    <div data-scene="budget-jars">
                                        <asp:Label runat="server" AssociatedControlID="txtArIncome">Monthly income (RM)</asp:Label>
                                        <asp:TextBox ID="txtArIncome" runat="server" CssClass="md-input" TextMode="Number" min="100" placeholder="3000" />
                                        <asp:Label runat="server" AssociatedControlID="txtArCards" style="margin-top:12px;">Expense cards</asp:Label>
                                        <asp:TextBox ID="txtArCards" runat="server" CssClass="md-input" TextMode="MultiLine" Rows="6"
                                            placeholder="Rent, 900, needs&#10;Groceries, 400, needs&#10;Eating out, 300, wants&#10;Emergency fund, 400, savings" />
                                        <span class="td-hint">One card per line: name, amount, then the jar it belongs in (needs, wants or savings). 2 to 12 cards. Leave both boxes empty to use the built-in example month.</span>
                                    </div>
                                    <div data-scene="compound-growth">
                                        <div style="display:grid; grid-template-columns:repeat(3, minmax(0, 1fr)); gap:10px;">
                                            <div>
                                                <asp:Label runat="server" AssociatedControlID="txtArMonthly">Monthly saving (RM)</asp:Label>
                                                <asp:TextBox ID="txtArMonthly" runat="server" CssClass="md-input" TextMode="Number" min="10" max="2000" placeholder="100" />
                                            </div>
                                            <div>
                                                <asp:Label runat="server" AssociatedControlID="txtArRate">Interest per year (%)</asp:Label>
                                                <asp:TextBox ID="txtArRate" runat="server" CssClass="md-input" TextMode="Number" min="0" max="12" step="0.5" placeholder="5" />
                                            </div>
                                            <div>
                                                <asp:Label runat="server" AssociatedControlID="txtArYears">Years</asp:Label>
                                                <asp:TextBox ID="txtArYears" runat="server" CssClass="md-input" TextMode="Number" min="1" max="40" placeholder="20" />
                                            </div>
                                        </div>
                                        <span class="td-hint">Where the sliders start. Leave empty for RM100 a month at 5% for 20 years.</span>
                                    </div>
                                    <p class="td-hint" data-scene="other">This scene's interactive activity isn't built yet. Learners see your written steps instead.</p>
                                </div>
                                <div class="td-field full" data-for="Article Quiz AR">
                                    <asp:Label runat="server" AssociatedControlID="txtLessonBody">Content</asp:Label>
                                    <asp:TextBox ID="txtLessonBody" runat="server" CssClass="md-input" TextMode="MultiLine"
                                        placeholder="Article text, quiz questions, or the steps for the AR activity" />
                                </div>
                                <div class="td-actions full">
                                    <asp:Button ID="btnSaveLesson" runat="server" Text="Add lesson" CssClass="btn btn--primary btn--sm" OnClick="btnSaveLesson_Click" />
                                    <asp:Button ID="btnCancelLesson" runat="server" Text="Clear" CssClass="btn btn--ghost btn--sm" OnClick="btnCancelLesson_Click" />
                                </div>
                            </div>
                        </div>
                    </asp:Panel>
                </section>

                <!-- ---------- LEARNERS ---------- -->
                <section id="pane-learners" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">Learners in my courses</h2>
                                <p class="md-panel__hint">Progress counts the lessons each learner has finished.</p>
                            </div>
                            <select id="learnerCourse" class="md-select" style="width:auto;" aria-label="Filter by course">
                                <option value="">All courses</option>
                            </select>
                        </div>
                        <div class="td-table-wrap">
                            <table class="td-table" id="learnerTable">
                                <thead><tr><th>Learner</th><th>Course</th><th>Enrolled</th><th>Progress</th><th>Status</th></tr></thead>
                                <tbody>
                                    <asp:Repeater ID="rptLearners" runat="server">
                                        <ItemTemplate>
                                            <tr data-course="<%# Attr(Eval("CourseCode")) %>" data-title="<%# Attr(Eval("Title")) %>">
                                                <td><strong><%# Html(Eval("FullName")) %></strong><br /><span class="md-row__meta"><%# Html(Eval("Email")) %></span></td>
                                                <td><span class="code"><%# Html(Eval("CourseCode")) %></span> <%# Html(Eval("Title")) %></td>
                                                <td><%# FormatDate(Eval("EnrolledAt")) %></td>
                                                <td>
                                                    <div class="md-progress">
                                                        <span class="md-progress__text"><span><%# Eval("DoneLessons") %> of <%# Eval("TotalLessons") %></span><span><%# Eval("Percent") %>%</span></span>
                                                        <span class="md-progress__track"><span class="md-progress__fill" style="width:<%# Eval("Percent") %>%"></span></span>
                                                    </div>
                                                </td>
                                                <td><%# Eval("CompletedAt") == DBNull.Value ? "<span class=\"tag\">In progress</span>" : "<span class=\"tag tag--ok\">Completed</span>" %></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                        <asp:PlaceHolder ID="phNoLearners" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No learners yet</strong>Learners appear once a published course of yours gets enrollments.</div>
                        </asp:PlaceHolder>
                    </div>

                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">AR activity results</h2>
                                <p class="md-panel__hint">The latest 50 attempts at AR activities in your courses. Learners can try more than once.</p>
                            </div>
                        </div>
                        <div class="td-table-wrap">
                            <table class="td-table">
                                <thead><tr><th>Learner</th><th>Lesson</th><th>Result</th><th>Score</th><th>Where</th><th>When</th></tr></thead>
                                <tbody>
                                    <asp:Repeater ID="rptArResults" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><strong><%# Html(Eval("FullName")) %></strong></td>
                                                <td><span class="code"><%# Html(Eval("CourseCode")) %></span> <%# Html(Eval("LessonTitle")) %></td>
                                                <td><%# Html(Eval("Summary")) %></td>
                                                <td class="num"><%# Eval("Score") == DBNull.Value ? "-" : Eval("Score") + "%" %></td>
                                                <td><%# (string)Eval("Mode") == "ar" ? "<span class=\"tag tag--accent\">On a table (AR)</span>" : (string)Eval("Mode") == "card" ? "<span class=\"tag tag--accent\">On the Meowlet card (AR)</span>" : (string)Eval("Mode") == "camera" ? "<span class=\"tag\">Camera view</span>" : "<span class=\"tag\">3D on screen</span>" %></td>
                                                <td><%# Myt(Eval("CompletedAt")) %></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                        <asp:PlaceHolder ID="phNoArResults" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No AR attempts yet</strong>Results appear when learners finish an AR activity in one of your courses.</div>
                        </asp:PlaceHolder>
                    </div>
                </section>

                <!-- ---------- REVIEWS ---------- -->
                <section id="pane-reviews" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">Reviews</h2>
                                <p class="md-panel__hint">What learners said about your courses and sessions. Your reply is shown under the review.</p>
                            </div>
                        </div>
                        <div class="md-rows">
                            <asp:Repeater ID="rptReviews" runat="server" OnItemCommand="rptReviews_ItemCommand">
                                <ItemTemplate>
                                    <div class="md-row td-row">
                                        <div>
                                            <span class="md-row__title"><%# Html(Eval("StudentName")) %> <span class="td-stars"><%# Stars(Eval("Rating")) %></span></span>
                                            <span class="md-row__meta"><%# Html(Eval("Subject")) %> · <%# FormatDate(Eval("CreatedAt")) %></span>
                                            <%# Quote(Eval("Comment"), null, false) %>
                                            <%# Quote(Eval("TutorReply"), "Your reply · " + FormatDate(Eval("TutorRepliedAt")), true) %>
                                            <asp:PlaceHolder runat="server" Visible='<%# Eval("TutorReply") == DBNull.Value %>'>
                                                <div class="td-inline-form">
                                                    <asp:TextBox ID="txtReply" runat="server" CssClass="md-input" MaxLength="1000" placeholder="Reply publicly to this review" />
                                                    <asp:LinkButton runat="server" CommandName="Reply" CommandArgument='<%# Eval("Kind") + ":" + Eval("ReviewKey") %>'
                                                        CssClass="btn btn--ghost btn--sm" Text="Reply" />
                                                </div>
                                            </asp:PlaceHolder>
                                        </div>
                                        <div class="td-row__side"><span class="tag"><%# (string)Eval("Kind") == "C" ? "Course" : "Session" %></span></div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:PlaceHolder ID="phNoReviews" runat="server" Visible="false">
                            <div class="md-empty-block"><strong>No reviews yet</strong>Reviews from learners show up here.</div>
                        </asp:PlaceHolder>
                    </div>
                </section>

                <!-- ---------- TEACHING PROFILE ---------- -->
                <section id="pane-profile" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-panel">
                        <div class="md-panel__head">
                            <div>
                                <h2 class="md-panel__title">Teaching profile</h2>
                                <p class="md-panel__hint">This is what students see in the tutor directory. Subjects and your certificate are on <a href="Profile.aspx">Account &amp; Verification</a>.</p>
                            </div>
                        </div>
                        <div class="td-grid">
                            <div class="td-field full">
                                <asp:Label runat="server" AssociatedControlID="txtHeadline">Headline</asp:Label>
                                <asp:TextBox ID="txtHeadline" runat="server" CssClass="md-input" MaxLength="150" placeholder="e.g. Budgeting coach for first jobbers" />
                            </div>
                            <div class="td-field full">
                                <asp:Label runat="server" AssociatedControlID="txtBio">About you</asp:Label>
                                <asp:TextBox ID="txtBio" runat="server" CssClass="md-input" TextMode="MultiLine" MaxLength="2000"
                                    placeholder="Your background, who you like to help, and how a session with you works." />
                            </div>
                            <div class="td-field full">
                                <asp:Label runat="server" AssociatedControlID="txtMeetingLink">Default meeting link</asp:Label>
                                <asp:TextBox ID="txtMeetingLink" runat="server" CssClass="md-input" MaxLength="400" placeholder="https://meet.google.com/..." />
                                <span class="td-hint">Google Meet, Zoom or Teams. Sent to students with confirmed sessions.</span>
                            </div>
                            <div class="td-field full td-check">
                                <asp:CheckBox ID="chkAccepting" runat="server" Checked="true" />
                                <asp:Label runat="server" AssociatedControlID="chkAccepting">Accepting new students</asp:Label>
                            </div>
                            <div class="td-actions full">
                                <asp:Button ID="btnSaveProfile" runat="server" Text="Save profile" CssClass="btn btn--primary btn--sm" OnClick="btnSaveProfile_Click" />
                            </div>
                        </div>
                    </div>
                </section>
            </main>
        </div>

        <button type="button" class="md-theme" id="themeToggle" aria-label="Switch theme">
            <span class="md-theme__knob"><i class="bi bi-moon-stars" aria-hidden="true"></i></span>
            <span id="themeLabel">Dark</span>
        </button>

        <%-- server data for the script below; arrives JS-encoded --%>
        <script type="application/json" id="tutorData">{"name":"<asp:Literal ID="litTutorNameJs" runat="server">Tutor</asp:Literal>"}</script>

        <script type="text/javascript">
            // @ts-nocheck
            (function () {
                var tutorData = JSON.parse(document.getElementById('tutorData').textContent);

                var meta = {
                    'pane-overview': ['Welcome back, ' + tutorData.name, 'Your sessions, courses and learners in one place.'],
                    'pane-sessions': ['Sessions', 'Answer booking requests and wrap up finished sessions.'],
                    'pane-availability': ['Availability', 'The weekly times students can book you.'],
                    'pane-messages': ['Messages', 'Conversations with your students.'],
                    'pane-courses': ['My Courses', 'Draft, edit and submit your courses for publishing.'],
                    'pane-lessons': ['Lessons', 'Build the lessons inside each course, including AR activities.'],
                    'pane-learners': ['Learners', 'Who is taking your courses and how far they are.'],
                    'pane-reviews': ['Reviews', 'Feedback on your courses and sessions.'],
                    'pane-profile': ['Teaching Profile', 'How you appear to students.']
                };

                var hdnPane = document.getElementById('<%= hdnPane.ClientID %>');
                var navItems = document.querySelectorAll('.md-nav[data-pane]');
                var panes = document.querySelectorAll('.md-pane');
                var title = document.getElementById('pageTitle');
                var sub = document.getElementById('pageSub');

                // ---- panes (the choice survives postbacks via hdnPane) ----
                function show(paneId, keepScroll) {
                    if (!document.getElementById(paneId) || !meta[paneId]) { paneId = 'pane-overview'; }
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

                // ---- theme (shared with the member dashboard) ----
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

                // ---- lesson form: show only the fields the chosen type needs ----
                var lessonType = document.getElementById('<%= ddlLessonType.ClientID %>');
                if (lessonType) {
                    var typed = document.querySelectorAll('#lessonForm [data-for]');
                    var syncLessonFields = function () {
                        for (var i = 0; i < typed.length; i++) {
                            var types = ' ' + typed[i].getAttribute('data-for') + ' ';
                            typed[i].hidden = types.indexOf(' ' + lessonType.value + ' ') === -1;
                        }
                    };
                    lessonType.onchange = syncLessonFields;
                    syncLessonFields();

                    // AR settings: show the fields for the chosen scene only.
                    var arScene = document.getElementById('<%= ddlArScene.ClientID %>');
                    var sceneBlocks = document.querySelectorAll('#arSettings [data-scene]');
                    var syncSceneFields = function () {
                        var known = false;
                        for (var i = 0; i < sceneBlocks.length; i++) {
                            var match = sceneBlocks[i].getAttribute('data-scene') === arScene.value;
                            if (match) { known = true; }
                            sceneBlocks[i].hidden = !match;
                        }
                        var other = document.querySelector('#arSettings [data-scene="other"]');
                        if (other) { other.hidden = known; }
                    };
                    arScene.onchange = syncSceneFields;
                    syncSceneFields();
                }

                // ---- learners: filter by course ----
                var learnerCourse = document.getElementById('learnerCourse');
                var learnerRows = document.querySelectorAll('#learnerTable tbody tr');
                var seen = {};
                for (var r = 0; r < learnerRows.length; r++) {
                    var code = learnerRows[r].getAttribute('data-course');
                    if (code && !seen[code]) {
                        seen[code] = true;
                        learnerCourse.add(new Option(code + ' · ' + learnerRows[r].getAttribute('data-title'), code));
                    }
                }
                learnerCourse.onchange = function () {
                    for (var i = 0; i < learnerRows.length; i++) {
                        learnerRows[i].hidden = !!learnerCourse.value && learnerRows[i].getAttribute('data-course') !== learnerCourse.value;
                    }
                };

                // Enter inside a one-line reply box sends that reply, not the first button on the page.
                var inlineBoxes = document.querySelectorAll('.td-inline-form input');
                for (var b = 0; b < inlineBoxes.length; b++) {
                    inlineBoxes[b].onkeydown = function (e) {
                        if (e.key !== 'Enter') { return; }
                        e.preventDefault();
                        var btn = this.parentNode.querySelector('a.btn');
                        if (btn) { btn.click(); }
                    };
                }

                // After "Edit" on a course or lesson, scroll its form into view.
                var focusForm = '<asp:Literal ID="litFocusForm" runat="server" EnableViewState="false" />';
                if (focusForm && document.getElementById(focusForm)) {
                    document.getElementById(focusForm).scrollIntoView({ block: 'start' });
                }
            })();
        </script>
    </form>
</body>
</html>

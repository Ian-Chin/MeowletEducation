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
        /* Member dashboard. Colours, buttons (.btn) and the body face come
           from style.css; the dark theme swaps the same tokens. Everything
           page-specific is prefixed md-.

           Design notes: one raised surface per screen (the course you're
           resuming); everything else sits on the page and is divided by
           hairlines, not boxed. Yellow marks progress and the one action
           that matters, nothing else. */

        /* Aeonik ships in Regular only, so its bold is synthesised. Headings,
           numbers and buttons use General Sans, which has real weights. */
        @font-face { font-family: "General Sans"; font-weight: 500; font-display: swap; src: url("assets/fonts/GeneralSans-Medium.woff2") format("woff2"); }
        @font-face { font-family: "General Sans"; font-weight: 600; font-display: swap; src: url("assets/fonts/GeneralSans-Semibold.woff2") format("woff2"); }
        @font-face { font-family: "General Sans"; font-weight: 700; font-display: swap; src: url("assets/fonts/GeneralSans-Bold.woff2") format("woff2"); }

        /* ---------- Themes ---------- */
        :root {
            --paper: #ffffff;
            --cream: #f4f4f1;
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
            --line-strong: rgba(20, 20, 19, .2);
            --shadow-sm: 0 1px 2px rgba(40, 32, 0, .05);
            --shadow: 0 14px 34px -20px rgba(40, 32, 0, .35);
            --md-display: "General Sans", var(--font);
            --md-nav-on-bg: #141413;
            --md-nav-on-ink: #ffffff;
            --md-nav-on-icon: #f5c518;
            --md-danger: #b42318;
            --md-danger-bg: #fdecea;
            --md-danger-line: #f5c2bd;
            --md-accent-text: #7a5c00;
            --md-accent-line: #e0b30f;
            --md-done: #141413;
            color-scheme: light;
        }

        html[data-theme="dark"] {
            --paper: #171716;
            --cream: #0e0e0d;
            --beige: #111110;
            --beige-deep: #242422;
            --sand: #3a3a37;
            --ink: #f3f3f0;
            --ink-soft: #d4d4cf;
            --ink-mute: #a3a39d;
            --ink-faint: #85857f;
            --accent: #f5c518;
            --accent-soft: rgba(245, 197, 24, .14);
            --line: rgba(255, 255, 255, .08);
            --line-strong: rgba(255, 255, 255, .17);
            --shadow-sm: 0 1px 2px rgba(0, 0, 0, .5);
            --shadow: 0 14px 34px -18px rgba(0, 0, 0, .85);
            --md-nav-on-bg: #f5c518;
            --md-nav-on-ink: #141413;
            --md-nav-on-icon: #141413;
            --md-danger: #f59a8f;
            --md-danger-bg: rgba(240, 82, 64, .12);
            --md-danger-line: rgba(240, 82, 64, .4);
            --md-accent-text: #f5c518;
            --md-accent-line: #f5c518;
            --md-done: #f3f3f0;
            color-scheme: dark;
        }

        html[data-theme="dark"] .md-side__logo--light,
        html[data-theme="light"] .md-side__logo--dark { display: none; }

        body {
            font-size: 14px;
            line-height: 1.5;
            color: var(--ink-soft);
            background: var(--cream);
            overflow-x: visible;
        }

        /* ---------- Buttons ---------- */
        .btn { font-family: var(--md-display); font-weight: 500; letter-spacing: 0; }
        .btn--primary:hover { background: #000000; }
        html[data-theme="dark"] .btn--primary:hover { background: #ffffff; }
        .btn--ghost:hover { background: var(--paper); border-color: var(--ink); }

        /* the one yellow button on a screen */
        .btn--accent { background: var(--accent); color: #141413; border-color: var(--md-accent-line); }
        .btn--accent:hover { background: #ffd43b; }

        /* inline text action with an arrow that steps forward */
        .md-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 0;
            border: 0;
            background: none;
            font-family: var(--md-display);
            font-weight: 500;
            color: var(--ink);
            white-space: nowrap;
        }

        .md-link .bi { font-size: .85em; transition: transform .25s var(--ease); }
        .md-link:hover .bi { transform: translateX(3px); }
        .md-link:hover { text-decoration: underline; text-decoration-color: var(--accent); text-decoration-thickness: 2px; text-underline-offset: 4px; }

        .md-link--danger { color: var(--md-danger); }
        .md-link--danger:hover { text-decoration-color: currentColor; }

        /* ---------- Shell ---------- */
        .md-shell { display: flex; min-height: 100vh; min-height: 100dvh; }

        .md-side {
            width: 220px;
            flex-shrink: 0;
            position: sticky;
            top: 0;
            height: 100vh;
            height: 100dvh;
            display: flex;
            flex-direction: column;
            padding: 20px 14px 14px;
            background: var(--beige);
            border-right: 1px solid var(--line);
        }

        .md-side__brand { display: flex; align-items: center; height: 36px; padding: 0 8px; margin-bottom: 26px; }
        .md-side__logo { height: 40px; width: auto; }
        .md-side__mark { display: none; height: 32px; width: 32px; border-radius: 8px; }

        .md-side__group { margin: 20px 10px 6px; font-size: .78rem; color: var(--ink-faint); }
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
            background: var(--md-nav-on-bg);
            color: var(--md-nav-on-ink);
            font-family: var(--md-display);
            font-weight: 500;
        }

        .md-nav.is-active .bi { color: var(--md-nav-on-icon); }

        .md-side__foot { margin-top: auto; padding-top: 12px; border-top: 1px solid var(--line); }
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
            max-width: 1240px;
            padding: 28px clamp(16px, 3.4vw, 44px) 96px;
        }

        /* ---------- Top bar ---------- */
        .md-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 20px;
            margin-bottom: 30px;
        }

        .md-title {
            margin: 0;
            font-family: var(--md-display);
            font-size: clamp(1.7rem, 2.6vw, 2.15rem);
            font-weight: 600;
            line-height: 1.1;
            letter-spacing: -.03em;
            color: var(--ink);
        }

        /* the homepage highlighter; on dark the yellow carries the word */
        .md-title em {
            font-style: normal;
            background: linear-gradient(transparent 62%, var(--accent) 62%, var(--accent) 90%, transparent 90%);
        }

        html[data-theme="dark"] .md-title em { background: none; color: var(--accent); }

        .md-sub { margin: 6px 0 0; color: var(--ink-mute); }

        .md-top__tools { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }

        .md-search { position: relative; display: block; }
        .md-search .bi {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--ink-faint);
            pointer-events: none;
        }

        .md-search .md-input { height: 40px; padding-left: 36px; }
        .md-search:focus-within .bi { color: var(--ink); }

        .md-global { width: 280px; }
        @media (max-width: 1040px) { .md-global { display: none; } }

        /* ---------- Profile menu ---------- */
        .md-menu { position: relative; }

        .md-menu__btn {
            display: flex;
            align-items: center;
            gap: 9px;
            height: 40px;
            padding: 0 12px 0 5px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink);
            font-family: var(--md-display);
            font-weight: 500;
            white-space: nowrap;
        }

        .md-menu__btn .bi-chevron-down { font-size: 11px; color: var(--ink-faint); }
        .md-menu:hover .md-menu__btn,
        .md-menu:focus-within .md-menu__btn { border-color: var(--ink); }

        /* rounded-square monogram, not a circle */
        .md-mono {
            display: inline-grid;
            place-items: center;
            width: 28px;
            height: 28px;
            border-radius: 7px;
            background: var(--accent);
            font-family: var(--md-display);
            font-size: .82rem;
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
            transform: translateY(-4px);
            transition: opacity .15s ease-out, transform .2s var(--ease), visibility .15s;
        }

        .md-menu:hover .md-menu__pop,
        .md-menu:focus-within .md-menu__pop { visibility: visible; opacity: 1; transform: none; }

        .md-menu__card {
            padding: 6px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            box-shadow: var(--shadow);
        }

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
        .md-menu__sep { height: 1px; margin: 4px 0; background: var(--line); }

        /* ---------- Feedback line ---------- */
        .md-flash {
            margin: -12px 0 24px;
            padding: 10px 14px;
            border: 1px solid var(--line);
            border-radius: var(--radius-sm);
            background: var(--paper);
            color: var(--ink);
        }

        .md-flash--error { border-color: var(--md-danger-line); background: var(--md-danger-bg); color: var(--md-danger); }

        /* ---------- Panes & sections ---------- */
        .md-pane { display: none; }
        .md-pane.is-active { display: block; }

        /* sections sit on the page; a hairline and a heading do the work a box would */
        .md-section + .md-section,
        .md-next + .md-section { margin-top: 44px; }

        .md-section__head {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: flex-end;
            gap: 12px 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--line-strong);
        }

        .md-section__title {
            margin: 0;
            font-family: var(--md-display);
            font-size: 1.15rem;
            font-weight: 600;
            letter-spacing: -.015em;
            color: var(--ink);
        }

        .md-section__hint { margin: 3px 0 0; font-size: .85rem; color: var(--ink-mute); }
        .md-section__tools { display: flex; flex-wrap: wrap; align-items: center; gap: 18px; }

        /* ---------- Overview layout: content left, a quiet column right ---------- */
        .md-overview {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 270px;
            gap: 28px 48px;
            align-items: start;
        }

        .md-aside { position: sticky; top: 24px; }

        @media (max-width: 1080px) {
            .md-overview { grid-template-columns: minmax(0, 1fr); }
            .md-aside { position: static; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 32px; }
        }

        @media (max-width: 640px) { .md-aside { grid-template-columns: minmax(0, 1fr); } }

        /* ---------- Up next: the one raised surface ---------- */
        .md-next {
            display: grid;
            grid-template-columns: minmax(180px, 300px) minmax(0, 1fr);
            gap: 26px;
            padding: 14px 26px 14px 14px;
            border-radius: 16px;
            background: var(--paper);
            box-shadow: var(--shadow-sm), 0 0 0 1px var(--line);
        }

        .md-next__img {
            display: block;
            width: 100%;
            height: 100%;
            min-height: 190px;
            max-width: none;
            border-radius: 10px;
            object-fit: cover;
            background: var(--beige-deep);
        }

        .md-next__img--empty { display: grid; place-items: center; color: var(--ink-faint); font-size: 1.8rem; }

        .md-next__body { display: flex; flex-direction: column; padding: 10px 0; min-width: 0; }

        .md-next__label {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            margin: 0 0 10px;
            font-size: .82rem;
            color: var(--ink-mute);
        }

        /* a live dot, borrowed from the homepage's .tag--live */
        .md-next__label::before {
            content: "";
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--accent);
            box-shadow: 0 0 0 3px var(--accent-soft);
        }

        .md-next__title {
            margin: 0;
            font-family: var(--md-display);
            font-size: clamp(1.3rem, 2vw, 1.65rem);
            font-weight: 600;
            line-height: 1.15;
            letter-spacing: -.025em;
            color: var(--ink);
            text-wrap: balance;
        }

        .md-next__meta { margin: 6px 0 0; color: var(--ink-mute); }

        .md-next__progress { margin-top: auto; padding-top: 22px; }

        .md-next__nums {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            margin-bottom: 8px;
            font-size: .85rem;
            color: var(--ink-mute);
        }

        .md-next__nums strong {
            font-family: var(--md-display);
            font-size: 1.5rem;
            font-weight: 600;
            letter-spacing: -.02em;
            color: var(--ink);
            font-variant-numeric: tabular-nums;
        }

        .md-next .md-progress__track { height: 8px; }
        .md-next__actions { display: flex; flex-wrap: wrap; align-items: center; gap: 20px; margin-top: 20px; }

        @media (max-width: 680px) {
            .md-next { grid-template-columns: minmax(0, 1fr); padding: 12px; }
            .md-next__img { min-height: 0; aspect-ratio: 16 / 9; }
            .md-next__body { padding: 4px 6px 8px; }
        }

        /* nothing in progress: the cat and a way forward */
        .md-next--empty {
            grid-template-columns: 120px minmax(0, 1fr);
            align-items: center;
            padding: 22px 26px;
        }

        .md-next--empty img { width: 120px; height: auto; }
        .md-next--empty .md-next__actions { margin-top: 14px; }

        @media (max-width: 680px) { .md-next--empty { grid-template-columns: minmax(0, 1fr); } .md-next--empty img { width: 96px; } }

        /* ---------- Ledger: the counts, set like a receipt ---------- */
        .md-ledger { margin: 0; padding: 0; }

        .md-ledger div {
            display: flex;
            align-items: baseline;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px solid var(--line);
        }

        .md-ledger div:first-child { padding-top: 0; }

        .md-ledger dd {
            order: -1;
            min-width: 2ch;
            margin: 0;
            font-family: var(--md-display);
            font-size: 2.1rem;
            font-weight: 600;
            line-height: 1;
            letter-spacing: -.04em;
            color: var(--ink);
            font-variant-numeric: tabular-nums;
        }

        .md-ledger dt { color: var(--ink-mute); }

        /* ---------- Account block ---------- */
        .md-account { margin-top: 30px; }

        .md-account__who { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
        .md-account__who .md-mono { width: 42px; height: 42px; border-radius: 10px; font-size: 1.05rem; }
        .md-account__name { margin: 0; font-family: var(--md-display); font-weight: 500; color: var(--ink); line-height: 1.25; }
        .md-account__role { font-size: .8rem; color: var(--ink-faint); }

        .md-facts { margin: 0 0 14px; padding: 0; }

        .md-facts div {
            display: grid;
            grid-template-columns: 92px minmax(0, 1fr);
            gap: 10px;
            padding: 6px 0;
            font-size: .85rem;
        }

        .md-facts dt { color: var(--ink-faint); }
        .md-facts dd { margin: 0; color: var(--ink); overflow-wrap: anywhere; }

        .md-aside__label { margin: 0 0 12px; font-size: .82rem; color: var(--ink-faint); }

        /* ---------- Filter tabs: text with an underline, not pills ---------- */
        .md-switch { display: inline-flex; gap: 16px; }

        .md-switch button {
            position: relative;
            padding: 4px 0;
            border: 0;
            background: transparent;
            font-size: .86rem;
            color: var(--ink-mute);
        }

        .md-switch button::after {
            content: "";
            position: absolute;
            left: 0;
            right: 0;
            bottom: -13px;
            height: 2px;
            background: var(--accent);
            transform: scaleX(0);
            transition: transform .25s var(--ease);
        }

        .md-switch button:hover { color: var(--ink); }
        .md-switch button.is-on { color: var(--ink); font-family: var(--md-display); font-weight: 500; }
        .md-switch button.is-on::after { transform: scaleX(1); }

        /* ---------- Course list: hairline rows ---------- */
        .md-rows { display: flex; flex-direction: column; }

        .md-row {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 170px 92px;
            align-items: center;
            gap: 24px;
            padding: 14px 4px;
            border-bottom: 1px solid var(--line);
            transition: background-color .2s ease-out;
        }

        .md-row:hover { background: linear-gradient(90deg, var(--accent-soft), transparent 70%); }
        .md-row[hidden] { display: none; }

        .md-row__title { display: block; font-family: var(--md-display); font-weight: 500; color: var(--ink); line-height: 1.35; }
        .md-row__meta { font-size: .8rem; color: var(--ink-mute); }
        .md-row__end { display: flex; justify-content: flex-end; gap: 16px; }

        .md-code { font-family: var(--mono); font-size: .76rem; color: var(--ink-faint); }

        .md-courses .md-row { grid-template-columns: minmax(0, 1fr) 170px 140px; }

        @media (max-width: 640px) {
            .md-row,
            .md-courses .md-row { grid-template-columns: minmax(0, 1fr) auto; gap: 10px 16px; }
            .md-row .md-progress { grid-column: 1 / -1; grid-row: 2; }
        }

        /* yellow while you're working on it, ink once it's done */
        .md-progress { display: flex; flex-direction: column; gap: 6px; }
        .md-progress__text { display: flex; justify-content: space-between; font-size: .76rem; color: var(--ink-mute); font-variant-numeric: tabular-nums; }
        .md-progress__track { display: block; height: 5px; border-radius: var(--pill); background: var(--beige-deep); overflow: hidden; }
        .md-progress__fill { display: block; height: 100%; border-radius: inherit; background: var(--accent); }
        [data-state="completed"] .md-progress__fill { background: var(--md-done); }
        [data-state="completed"] .md-progress__text span:first-child { color: var(--ink); }

        .md-empty-block { padding: 34px 18px; text-align: center; color: var(--ink-mute); }
        .md-empty-block strong { display: block; margin-bottom: 2px; font-family: var(--md-display); font-weight: 500; color: var(--ink); }
        .md-empty-block[hidden] { display: none; }
        .md-empty-block__cat { display: block; width: 104px; height: auto; margin: 0 auto 12px; }
        .md-cards .md-empty-block { grid-column: 1 / -1; }

        /* ---------- Course catalog ---------- */
        .md-tools {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 10px;
            margin: 18px 0 26px;
        }

        .md-tools .md-search { flex: 1; min-width: 220px; max-width: 420px; }
        .md-tools .md-select { width: auto; height: 40px; }
        .md-tools__meta { margin-left: auto; font-size: .82rem; color: var(--ink-faint); font-variant-numeric: tabular-nums; }

        .md-cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 34px 24px;
        }

        /* no box: picture, then type, like a shop shelf */
        .md-course { display: flex; flex-direction: column; }
        .md-course[hidden] { display: none; }

        .md-course__frame { position: relative; margin-bottom: 14px; border-radius: 12px; overflow: hidden; background: var(--beige-deep); }

        .md-course__img {
            display: block;
            width: 100%;
            max-width: none;
            aspect-ratio: 4 / 3;
            object-fit: cover;
            transition: transform .8s var(--ease);
        }

        .md-course__img--empty { display: grid; place-items: center; color: var(--ink-faint); font-size: 1.6rem; }
        .md-course:hover img.md-course__img { transform: scale(1.035); }

        /* level sits on the picture as a square flag */
        .md-course__level {
            position: absolute;
            left: 10px;
            top: 10px;
            padding: 3px 8px;
            border-radius: 4px;
            background: var(--paper);
            font-family: var(--md-display);
            font-size: .72rem;
            font-weight: 500;
            color: var(--ink);
        }

        .md-course[data-level="Advanced"] .md-course__level { background: var(--ink); color: var(--paper); }
        .md-course[data-level="Intermediate"] .md-course__level { background: var(--accent); color: #141413; }

        .md-course__title {
            margin: 0;
            font-family: var(--md-display);
            font-size: 1.02rem;
            font-weight: 600;
            line-height: 1.3;
            letter-spacing: -.01em;
            color: var(--ink);
        }

        .md-course__meta { margin: 4px 0 0; font-size: .82rem; color: var(--ink-mute); }
        .md-course__desc { margin: 8px 0 0; font-size: .85rem; color: var(--ink-soft); max-width: 46ch; }

        .md-course__foot {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            margin-top: auto;
            padding-top: 14px;
            font-size: .8rem;
            color: var(--ink-faint);
            white-space: nowrap;
        }

        .md-course__foot .btn { padding: 7px 14px; font-size: .82rem; box-shadow: none; }
        .md-course__foot .btn:hover { background: var(--accent); border-color: var(--md-accent-line); color: #141413; }

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
            transition: border-color .15s ease-out, box-shadow .15s ease-out;
        }

        .md-input::placeholder { color: var(--ink-faint); }
        .md-input:hover,
        .md-select:hover { border-color: var(--sand); }

        .md-input:focus,
        .md-select:focus { border-color: var(--ink); outline: none; box-shadow: 0 0 0 3px var(--accent-soft); }

        /* a dropdown that is narrowing the list says so */
        .md-select.is-set { border-color: var(--ink); background-color: var(--accent-soft); }

        @media (prefers-reduced-motion: reduce) {
            .md-menu__pop,
            .md-nav,
            .md-course__img,
            .md-link .bi,
            .md-switch button::after { transition: none; }
            .md-course:hover img.md-course__img,
            .md-link:hover .bi { transform: none; }
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
                        <i class="bi bi-journal-bookmark" aria-hidden="true"></i><span>My courses</span>
                    </button>
                    <button type="button" class="md-nav" data-pane="pane-catalog">
                        <i class="bi bi-book" aria-hidden="true"></i><span>Course catalog</span>
                    </button>

                    <p class="md-side__group">Account</p>
                    <a class="md-nav" href="Profile.aspx">
                        <i class="bi bi-person" aria-hidden="true"></i><span>My profile</span>
                    </a>
                    <a class="md-nav" href="index.html">
                        <i class="bi bi-house" aria-hidden="true"></i><span>Public site</span>
                    </a>
                </nav>

                <div class="md-side__foot">
                    <asp:LinkButton ID="lnkSideSignOut" runat="server" CssClass="md-nav md-nav--danger"
                        OnClick="lnkLogout_Click"
                        OnClientClick="return confirm('Sign out of Meowlet?');">
                        <i class="bi bi-box-arrow-right" aria-hidden="true"></i><span>Sign out</span>
                    </asp:LinkButton>
                </div>
            </aside>

            <!-- ================= MAIN ================= -->
            <main class="md-main">

                <header class="md-top">
                    <div>
                        <h1 class="md-title" id="pageTitle">Welcome back, <em><asp:Literal ID="litWelcomeName" runat="server">Member</asp:Literal></em></h1>
                        <p class="md-sub" id="pageSub">Here is where your courses stand.</p>
                    </div>
                    <div class="md-top__tools">
                        <label class="md-search md-global">
                            <i class="bi bi-search" aria-hidden="true"></i>
                            <input type="search" id="globalSearch" class="md-input" placeholder="Search courses" aria-label="Search the course catalog" />
                        </label>
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
                                    <button type="button" class="md-menu__item" id="themeToggle"><i class="bi bi-sun" aria-hidden="true"></i><span id="themeLabel">Light theme</span></button>
                                    <div class="md-menu__sep"></div>
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
                    <div class="md-overview">
                        <div>
                            <!-- the course to resume: most recent enrolment that isn't finished -->
                            <asp:Repeater ID="rptUpNext" runat="server">
                                <ItemTemplate>
                                    <article class="md-next">
                                        <%# MeowletEducation.CourseImages.Cover(Eval("ImageUrl"), "md-next__img") %>
                                        <div class="md-next__body">
                                            <p class="md-next__label">Up next</p>
                                            <h2 class="md-next__title"><%# Html(Eval("Title")) %></h2>
                                            <p class="md-next__meta"><span class="md-code"><%# Html(Eval("CourseCode")) %></span> · <%# Html(Eval("Category")) %> · <%# Html(Eval("Level")) %></p>
                                            <div class="md-next__progress">
                                                <div class="md-next__nums"><span><%# Html(Eval("NextLabel")) %></span><strong><%# Eval("Percent") %>%</strong></div>
                                                <span class="md-progress__track"><span class="md-progress__fill" style="width:<%# Eval("Percent") %>%"></span></span>
                                            </div>
                                            <div class="md-next__actions">
                                                <a class="btn btn--accent btn--sm" href="course.aspx?id=<%# Eval("CourseId") %>"><%# Html(Eval("ResumeLabel")) %></a>
                                                <button type="button" class="md-link" data-go="pane-courses">All my courses <i class="bi bi-arrow-right" aria-hidden="true"></i></button>
                                            </div>
                                        </div>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:PlaceHolder ID="phNoUpNext" runat="server" Visible="false">
                                <div class="md-next md-next--empty">
                                    <img src="assets/img/cat-reach.webp" alt="" />
                                    <div>
                                        <h2 class="md-next__title"><asp:Literal ID="litNoUpNext" runat="server" /></h2>
                                        <p class="md-next__meta">Pick a course from the catalog to start one.</p>
                                        <div class="md-next__actions">
                                            <button type="button" class="btn btn--accent btn--sm" data-go="pane-catalog">Browse the catalog</button>
                                        </div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>

                            <div class="md-section">
                                <div class="md-section__head">
                                    <div>
                                        <h2 class="md-section__title">Recent courses</h2>
                                        <p class="md-section__hint">Your five latest enrolments.</p>
                                    </div>
                                    <div class="md-section__tools">
                                        <div class="md-switch" role="group" aria-label="Show courses" id="overviewFilter">
                                            <button type="button" class="is-on" data-filter="" aria-pressed="true">All</button>
                                            <button type="button" data-filter="progress" aria-pressed="false">In progress</button>
                                            <button type="button" data-filter="completed" aria-pressed="false">Completed</button>
                                        </div>
                                    </div>
                                </div>
                                <div class="md-rows" id="overviewRows">
                                    <asp:Repeater ID="rptRecentCourses" runat="server">
                                        <ItemTemplate>
                                            <div class="md-row" data-state="<%# Eval("State") %>">
                                                <div>
                                                    <span class="md-row__title"><%# Html(Eval("Title")) %></span>
                                                    <span class="md-row__meta"><span class="md-code"><%# Html(Eval("CourseCode")) %></span> · <%# Html(Eval("Category")) %></span>
                                                </div>
                                                <div class="md-progress">
                                                    <span class="md-progress__text"><span><%# (string)Eval("State") == "completed" ? "Completed" : "In progress" %></span><span><%# Eval("Percent") %>%</span></span>
                                                    <span class="md-progress__track"><span class="md-progress__fill" style="width:<%# Eval("Percent") %>%"></span></span>
                                                </div>
                                                <span class="md-row__end">
                                                    <a class="md-link" href="course.aspx?id=<%# Eval("CourseId") %>">
                                                        <%# (string)Eval("State") == "completed" ? "Review" : "Continue" %> <i class="bi bi-arrow-right" aria-hidden="true"></i>
                                                    </a>
                                                </span>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <p class="md-empty-block" id="overviewNoMatch" hidden="hidden">No courses in this group yet.</p>
                                </div>
                                <asp:PlaceHolder ID="phNoRecent" runat="server" Visible="false">
                                    <div class="md-empty-block">
                                        <strong>You haven't enrolled in a course yet</strong>
                                        Courses you join show up here with your progress.
                                    </div>
                                </asp:PlaceHolder>
                            </div>
                        </div>

                        <aside class="md-aside" aria-label="Summary">
                            <div>
                                <p class="md-aside__label">Your courses</p>
                                <dl class="md-ledger">
                                    <div><dt>in progress</dt><dd><asp:Literal ID="litStatInProgress" runat="server">0</asp:Literal></dd></div>
                                    <div><dt>completed</dt><dd><asp:Literal ID="litStatCompleted" runat="server">0</asp:Literal></dd></div>
                                    <div><dt>enrolled in total</dt><dd><asp:Literal ID="litStatEnrolled" runat="server">0</asp:Literal></dd></div>
                                </dl>
                            </div>

                            <div class="md-account">
                                <p class="md-aside__label">Your account</p>
                                <div class="md-account__who">
                                    <span class="md-mono" aria-hidden="true"><asp:Literal ID="litAvatar" runat="server">?</asp:Literal></span>
                                    <div>
                                        <p class="md-account__name"><asp:Literal ID="litProfileName" runat="server" /></p>
                                        <span class="md-account__role"><asp:Literal ID="litRole" runat="server">Student</asp:Literal></span>
                                    </div>
                                </div>
                                <dl class="md-facts">
                                    <div><dt>Email</dt><dd><asp:Literal ID="litProfileEmail" runat="server" /></dd></div>
                                    <div><dt>Age range</dt><dd><asp:Literal ID="litProfileAge" runat="server">Not set</asp:Literal></dd></div>
                                    <div><dt>Experience</dt><dd><asp:Literal ID="litProfileLevel" runat="server">Not set</asp:Literal></dd></div>
                                    <div><dt>Member since</dt><dd><asp:Literal ID="litProfileJoined" runat="server" /></dd></div>
                                </dl>
                                <a class="md-link" href="Profile.aspx">Edit profile <i class="bi bi-arrow-right" aria-hidden="true"></i></a>
                            </div>
                        </aside>
                    </div>
                </section>

                <!-- ---------- MY COURSES ---------- -->
                <section id="pane-courses" class="md-pane" aria-labelledby="pageTitle">
                    <div class="md-section md-courses">
                        <div class="md-section__head">
                            <p class="md-section__hint">Dropping a course removes it from your list. Your lesson progress is kept if you enrol again.</p>
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
                                                <span class="md-code"><%# Html(Eval("CourseCode")) %></span> · <%# Html(Eval("Level")) %> ·
                                                <%# Eval("DoneLessons") %> of <%# Eval("TotalLessons") %> lessons · enrolled <%# FormatDate(Eval("EnrolledAt")) %>
                                            </span>
                                        </div>
                                        <div class="md-progress">
                                            <span class="md-progress__text"><span><%# (string)Eval("State") == "completed" ? "Completed" : "In progress" %></span><span><%# Eval("Percent") %>%</span></span>
                                            <span class="md-progress__track"><span class="md-progress__fill" style="width:<%# Eval("Percent") %>%"></span></span>
                                        </div>
                                        <span class="md-row__end">
                                            <a class="md-link" href="course.aspx?id=<%# Eval("CourseId") %>">
                                                <%# (string)Eval("State") == "completed" ? "Review" : "Open" %> <i class="bi bi-arrow-right" aria-hidden="true"></i>
                                            </a>
                                            <asp:LinkButton runat="server" CommandName="Drop" CommandArgument='<%# Eval("CourseId") %>'
                                                CssClass="md-link md-link--danger" Text="Drop"
                                                OnClientClick="return confirm('Drop this course? Your lesson progress is kept if you enrol again.');" />
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <p class="md-empty-block" id="courseNoMatch" hidden="hidden">No courses in this group yet.</p>
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

                <!-- ---------- COURSE CATALOG ---------- -->
                <section id="pane-catalog" class="md-pane" aria-labelledby="pageTitle">
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
                                    <div class="md-course__frame">
                                        <%# MeowletEducation.CourseImages.Cover(Eval("ImageUrl"), "md-course__img") %>
                                        <span class="md-course__level"><%# Html(Eval("Level")) %></span>
                                    </div>
                                    <h3 class="md-course__title"><%# Html(Eval("Title")) %></h3>
                                    <p class="md-course__meta"><span class="md-code"><%# Html(Eval("CourseCode")) %></span> · <%# Html(Eval("Category")) %> · with <%# Html(Eval("TutorName")) %></p>
                                    <%# string.IsNullOrEmpty(Convert.ToString(Eval("Description"))) ? "" : "<p class=\"md-course__desc\">" + Html(Eval("Description")) + "</p>" %>
                                    <div class="md-course__foot">
                                        <span><%# Eval("Lessons") %> lessons · <%# Eval("LearnerCount") %> learners</span>
                                        <asp:LinkButton runat="server" CommandName="Enrol" CommandArgument='<%# Eval("CourseId") %>'
                                            CssClass="btn btn--ghost btn--sm" Text="Enrol" />
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                        <p class="md-empty-block" id="catalogNoMatch" hidden="hidden"><strong>No matches</strong>Try another search or clear the filters.</p>
                    </div>
                    <asp:PlaceHolder ID="phNoCatalog" runat="server" Visible="false">
                        <div class="md-empty-block">
                            <img class="md-empty-block__cat" src="assets/img/cat-reach.webp" alt="" />
                            <strong>You're enrolled in every course</strong>
                            New courses appear here once they're published.
                        </div>
                    </asp:PlaceHolder>
                </section>
            </main>
        </div>

        <%-- server data for the script below; arrives JS-encoded --%>
        <script type="application/json" id="memberData">{"name":"<asp:Literal ID="litMemberNameJs" runat="server">Member</asp:Literal>"}</script>

        <script type="text/javascript">
            // @ts-nocheck
            (function () {
                var memberData = JSON.parse(document.getElementById('memberData').textContent);

                var meta = {
                    'pane-overview': ['Welcome back, ' + memberData.name, 'Here is where your courses stand.'],
                    'pane-courses': ['My courses', 'Everything you are enrolled in, with your progress.'],
                    'pane-catalog': ['Course catalog', 'Published courses you haven\'t joined yet.']
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
                    if (paneId === 'pane-overview') {
                        // the name gets the homepage highlighter
                        var em = document.createElement('em');
                        em.textContent = memberData.name;
                        title.textContent = 'Welcome back, ';
                        title.appendChild(em);
                    } else {
                        title.textContent = meta[paneId][0];
                    }
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
                    // the menu item names the theme it switches to
                    themeToggle.querySelector('.bi').className = dark ? 'bi bi-sun' : 'bi bi-moon-stars';
                    document.getElementById('themeLabel').textContent = dark ? 'Light theme' : 'Dark theme';
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

                    catalogCategory.className = cat ? 'md-select is-set' : 'md-select';
                    catalogLevel.className = level ? 'md-select is-set' : 'md-select';

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

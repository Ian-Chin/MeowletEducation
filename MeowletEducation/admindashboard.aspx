<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="admindashboard.aspx.cs" Inherits="MeowletEducation.AdminDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Dashboard - Meowlet Education</title>
    <link rel="stylesheet" href="assets/css/style.css" />
    <style>
        body {
            background-color: #fdfbf7;
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            color: #1a1a1a;
        }

        /* ---------- Layout ---------- */
        .admin-shell {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 212px;
            flex-shrink: 0;
            background: #0e0e0e;
            border-right: 1px solid #1f1f1f;
            padding: 18px 12px;
            position: sticky;
            top: 0;
            height: 100vh;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
        }

        .sidebar__brand {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2px 8px 16px 8px;
            border-bottom: 1px solid #242424;
            margin-bottom: 12px;
        }

        .sidebar__label {
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 1.3px;
            color: #6f6f6f;
            font-weight: 600;
            margin: 14px 10px 6px 10px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            text-align: left;
            padding: 8px 10px;
            margin-bottom: 3px;
            border: none;
            background: transparent;
            border-radius: 2px;
            font-size: 0.84rem;
            font-weight: 500;
            color: #b5b5b5;
            cursor: pointer;
            font-family: inherit;
            transition: background 0.15s, color 0.15s;
        }

        .nav-item:hover {
            background: #1b1b1b;
            color: #fff;
        }

        .nav-item.is-active {
            background: #1f2a20;
            color: #7bc47f;
            font-weight: 600;
            box-shadow: inset 2px 0 0 #7bc47f;
        }

        .nav-item .ico {
            width: 18px;
            text-align: center;
            font-size: 1rem;
        }

        .sidebar__foot {
            margin-top: auto;
            border-top: 1px solid #242424;
            padding-top: 12px;
        }

        .admin-main {
            flex: 1;
            min-width: 0;
            padding: 22px 26px 48px 26px;
        }

        /* ---------- Top bar ---------- */
        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 18px;
            margin-bottom: 22px;
        }

        .page-title {
            font-size: 1.45rem;
            font-weight: 700;
            margin: 0 0 4px 0;
        }

        .page-sub {
            color: #666;
            font-size: 0.82rem;
            margin: 0;
        }

        /* ---------- Global search ---------- */
        .topbar__tools {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-shrink: 0;
        }

        .global-search {
            position: relative;
            width: 300px;
        }

        .global-search .search-ico {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            display: flex;
            color: #a5a199;
            pointer-events: none;
        }

        .global-search .form-control {
            padding-left: 30px;
            padding-right: 56px;
        }

        .kbd-hint {
            position: absolute;
            right: 7px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 0.64rem;
            font-weight: 600;
            letter-spacing: 0.3px;
            color: #9a968c;
            border: 1px solid #e7e5dd;
            background: #faf9f5;
            border-radius: 2px;
            padding: 2px 6px;
            pointer-events: none;
        }

        @media (max-width: 1040px) {
            .global-search { display: none; }
        }

        /* ---------- Profile menu ---------- */
        .admin-menu { position: relative; }

        .admin-menu__btn { cursor: pointer; }

        .admin-menu__caret {
            margin-left: 2px;
            color: #9a968c;
            transition: transform 0.18s ease;
        }

        .admin-menu:hover .admin-menu__caret,
        .admin-menu:focus-within .admin-menu__caret { transform: rotate(180deg); }

        .admin-menu__pop {
            position: absolute;
            top: 100%;
            right: 0;
            min-width: 196px;
            padding-top: 6px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(-8px);
            transition: opacity 0.18s ease, transform 0.18s ease, visibility 0.18s;
            z-index: 60;
        }

        .admin-menu:hover .admin-menu__pop,
        .admin-menu:focus-within .admin-menu__pop {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }

        .admin-menu__card {
            background: #fff;
            border: 1px solid #eaeaea;
            border-radius: 2px;
            box-shadow: 0 10px 26px rgba(0,0,0,0.10);
            padding: 5px;
        }

        .admin-menu__who {
            padding: 7px 9px 9px 9px;
            border-bottom: 1px solid #f0efea;
            margin-bottom: 5px;
        }

        .admin-menu__name {
            display: block;
            font-size: 0.8rem;
            font-weight: 600;
            color: #1a1a1a;
        }

        .admin-menu__role {
            display: block;
            font-size: 0.7rem;
            color: #9a968c;
            margin-top: 1px;
        }

        .admin-menu__item {
            display: flex;
            align-items: center;
            gap: 9px;
            width: 100%;
            padding: 8px 9px;
            border: none;
            background: transparent;
            border-radius: 2px;
            font-family: inherit;
            font-size: 0.81rem;
            font-weight: 500;
            color: #333;
            text-align: left;
            text-decoration: none;
            cursor: pointer;
        }

        .admin-menu__item:hover { background: #f5f4ef; color: #111; }

        .admin-menu__item.is-danger { color: #d32f2f; }
        .admin-menu__item.is-danger:hover { background: #fdecea; }

        .admin-menu__sep {
            height: 1px;
            background: #f0efea;
            margin: 5px 0;
        }

        .admin-badge {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 11px;
            border-radius: 2px;
            border: 1px solid #eaeaea;
            background: #fff;
            text-decoration: none;
            color: #1a1a1a;
            font-size: 0.82rem;
            font-weight: 500;
            white-space: nowrap;
        }

        /* ---------- Icons (Bootstrap Icons sprite) ---------- */
        .mi {
            width: 14px;
            height: 14px;
            min-width: 14px;
            fill: currentColor;
            background: none;
            flex-shrink: 0;
            display: inline-block;
            vertical-align: -0.125em;
        }

        .mi-lg { width: 16px; height: 16px; min-width: 16px; }

        /* ---------- Cards ---------- */
        .card {
            background: #fff;
            border: 1px solid #eaeaea;
            border-radius: 2px;
            padding: 18px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.03);
            margin-bottom: 18px;
        }

        .card__head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 14px;
            padding-bottom: 10px;
            border-bottom: 1px solid #f0efea;
        }

        .card__title {
            font-size: 1rem;
            font-weight: 600;
            margin: 0;
        }

        .card__hint {
            font-size: 0.78rem;
            color: #888;
            margin: 3px 0 0 0;
        }

        /* ---------- KPI ---------- */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(172px, 1fr));
            gap: 14px;
            margin-bottom: 18px;
        }

        .kpi {
            background: #fff;
            border: 1px solid #eaeaea;
            border-radius: 2px;
            padding: 14px 15px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.03);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .kpi:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 24px rgba(0,0,0,0.06);
        }

        .kpi__label {
            font-size: 0.68rem;
            text-transform: uppercase;
            letter-spacing: 0.9px;
            color: #8d8980;
            font-weight: 600;
            margin: 0 0 7px 0;
        }

        .kpi__value {
            font-size: 1.5rem;
            font-weight: 700;
            line-height: 1.1;
            margin: 0 0 7px 0;
        }

        .kpi__foot {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.73rem;
            color: #777;
        }

        .delta {
            display: inline-block;
            padding: 2px 7px;
            border-radius: 2px;
            font-weight: 600;
            font-size: 0.68rem;
        }

        .delta--up { background: #eef9ec; color: #2e7d32; border: 1px solid #c8e6c9; }
        .delta--down { background: #fdecea; color: #c62828; border: 1px solid #ffcdd2; }
        .delta--flat { background: #f5f4ef; color: #777; border: 1px solid #e7e5dd; }

        /* ---------- Two column ---------- */
        .split {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 18px;
            align-items: start;
        }

        @media (max-width: 1100px) {
            .split { grid-template-columns: 1fr; }
        }

        /* ---------- Bar chart ---------- */
        .chart {
            display: flex;
            align-items: flex-end;
            gap: 10px;
            height: 168px;
            padding-top: 6px;
        }

        .bar-wrap {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 7px;
            height: 100%;
            justify-content: flex-end;
        }

        .bar {
            width: 100%;
            max-width: 38px;
            border-radius: 2px 2px 0 0;
            background: linear-gradient(180deg, #2e7d32 0%, #4a9d4f 100%);
            position: relative;
        }

        .bar--muted {
            background: linear-gradient(180deg, #d9d6cc 0%, #e8e5db 100%);
        }

        .bar-label {
            font-size: 0.68rem;
            color: #888;
            font-weight: 500;
        }

        .bar-value {
            font-size: 0.66rem;
            color: #555;
            font-weight: 600;
        }

        /* ---------- Activity ---------- */
        .activity {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .activity li {
            display: flex;
            gap: 11px;
            padding: 10px 0;
            border-bottom: 1px solid #f4f3ee;
        }

        .activity li:last-child { border-bottom: none; }

        .activity__dot {
            width: 27px;
            height: 27px;
            flex-shrink: 0;
            border-radius: 2px;
            background: #f4f6f2;
            color: #2e7d32;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
        }

        .activity__text {
            font-size: 0.82rem;
            margin: 0 0 2px 0;
            line-height: 1.4;
        }

        .activity__time {
            font-size: 0.71rem;
            color: #999;
            margin: 0;
        }

        /* ---------- Toolbar ---------- */
        .toolbar {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
            margin-bottom: 16px;
        }

        .toolbar .grow { flex: 1; min-width: 220px; }

        /* ---------- Forms ---------- */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
        }

        @media (max-width: 1200px) {
            .form-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }

        @media (max-width: 760px) {
            .form-grid { grid-template-columns: 1fr; }
        }

        .form-group { margin-bottom: 0; }

        .form-group.full { grid-column: 1 / -1; }

        .form-group label {
            display: block;
            font-weight: 500;
            font-size: 0.81rem;
            margin-bottom: 6px;
            color: #1a1a1a;
        }

        .form-control {
            width: 100%;
            padding: 8px 11px;
            border: 1px solid #ddd;
            border-radius: 2px;
            font-size: 0.83rem;
            font-family: inherit;
            color: #1a1a1a;
            background: #fff;
            outline: none;
            box-sizing: border-box;
            transition: border-color 0.2s;
        }

        .form-control:focus { border-color: #1a1a1a; }

        textarea.form-control { min-height: 88px; resize: vertical; }

        .field-hint {
            font-size: 0.72rem;
            color: #999;
            margin: 5px 0 0 0;
        }

        /* ---------- Buttons ---------- */
        .btn-a {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 15px;
            border-radius: 2px;
            font-size: 0.82rem;
            font-weight: 500;
            font-family: inherit;
            cursor: pointer;
            text-decoration: none;
            border: 1px solid transparent;
            transition: opacity 0.15s, background 0.15s;
        }

        .btn-a:hover { opacity: 0.88; }

        .btn-dark { background: #111; color: #fff; }
        .btn-ghost { background: #fff; color: #333; border-color: #ddd; }
        .btn-danger { background: #fff; color: #d32f2f; border-color: #ffcdd2; }
        .btn-sm { padding: 5px 10px; font-size: 0.74rem; border-radius: 2px; }

        /* ---------- Table ---------- */
        .table-wrap {
            overflow-x: auto;
            border: 1px solid #eaeaea;
            border-radius: 2px;
            background: #fff;
        }

        table.data {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.82rem;
            min-width: 660px;
        }

        table.data thead th {
            text-align: left;
            padding: 9px 13px;
            background: #faf9f5;
            border-bottom: 1px solid #eaeaea;
            font-size: 0.67rem;
            text-transform: uppercase;
            letter-spacing: 0.9px;
            color: #8d8980;
            font-weight: 600;
            white-space: nowrap;
        }

        table.data tbody td {
            padding: 9px 13px;
            border-bottom: 1px solid #f4f3ee;
            color: #333;
            vertical-align: middle;
        }

        table.data tbody tr:last-child td { border-bottom: none; }
        table.data tbody tr:hover { background: #fcfbf7; }

        .cell-user {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .cell-user strong { display: block; font-weight: 600; color: #1a1a1a; }
        .cell-user > span:last-child { display: block; }

        .pill {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 2px;
            font-size: 0.69rem;
            font-weight: 600;
            white-space: nowrap;
        }

        .pill--admin { background: #eef1fb; color: #33489c; border: 1px solid #d3dbf5; }
        .pill--tutor { background: #fdf3e6; color: #9a6413; border: 1px solid #f6e0bd; }
        .pill--student { background: #f3f2ed; color: #5b574c; border: 1px solid #e5e3da; }
        .pill--ok { background: #eef9ec; color: #2e7d32; border: 1px solid #c8e6c9; }
        .pill--off { background: #fdecea; color: #c62828; border: 1px solid #ffcdd2; }
        .pill--draft { background: #f5f4ef; color: #777; border: 1px solid #e7e5dd; }

        .row-actions { display: flex; gap: 6px; }

        .rating {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-weight: 600;
            color: #1a1a1a;
        }

        .rating .mi { color: #e6a417; width: 12px; height: 12px; min-width: 12px; }

        /* ---------- Data panel: one surface, no nested boxes ---------- */
        .panel {
            border: 1px solid #eaeaea;
            border-radius: 2px;
            background: #fff;
            box-shadow: 0 6px 18px rgba(0,0,0,0.03);
            margin-bottom: 18px;
            overflow: hidden;
        }

        .panel__head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            padding: 14px 16px 12px 16px;
        }

        .panel__title {
            font-size: 1rem;
            font-weight: 600;
            margin: 0;
        }

        .panel__hint {
            font-size: 0.78rem;
            color: #888;
            margin: 3px 0 0 0;
        }

        /* Filters read as a row of controls, not a strip of boxes. */
        .panel__toolbar {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 2px;
            padding: 0 12px 10px 12px;
        }

        .search-field {
            position: relative;
            flex: 1;
            min-width: 200px;
        }

        .search-field .search-ico {
            position: absolute;
            left: 11px;
            top: 50%;
            transform: translateY(-50%);
            display: flex;
            color: #a5a199;
            pointer-events: none;
        }

        .search-field .form-control {
            padding-left: 29px;
            border-color: transparent;
            background: transparent;
        }

        .search-field .form-control:hover { background: #faf9f5; }

        .search-field .form-control:focus {
            background: #faf9f5;
            border-color: transparent;
        }

        .filter-select {
            width: auto;
            min-width: 112px;
            padding: 7px 8px;
            font-size: 0.78rem;
            border-color: transparent;
            background: transparent;
            color: #5b574c;
            cursor: pointer;
        }

        .filter-select:hover { background: #faf9f5; }
        .filter-select:focus { background: #faf9f5; border-color: transparent; }

        .toolbar-sep {
            width: 1px;
            align-self: center;
            height: 18px;
            background: #e7e5dd;
            margin: 0 6px;
        }

        .toolbar-gap { flex: 1; }

        .panel__meta {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            padding: 0 12px 10px 12px;
            font-size: 0.73rem;
            color: #8d8980;
        }

        .chip-row { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 9px;
            border: none;
            border-radius: 2px;
            background: transparent;
            font-size: 0.72rem;
            font-weight: 500;
            color: #8d8980;
            cursor: pointer;
            font-family: inherit;
        }

        .chip strong { color: #5b574c; font-weight: 600; }
        .chip:hover { background: #f5f4ef; color: #333; }

        .chip.is-on { background: #111; color: #fff; }
        .chip.is-on strong { color: #fff; }

        .panel .table-wrap { border: none; border-radius: 0; border-top: 1px solid #eaeaea; }
        .panel table.data { min-width: 880px; }

        table.data th.col-check,
        table.data td.col-check { width: 40px; padding-right: 0; }

        table.data th.col-actions,
        table.data td.col-actions { text-align: right; }

        table.data td.col-actions .row-actions { justify-content: flex-end; }

        table.data tbody tr { transition: background 0.12s; }

        .cell-sub { font-size: 0.73rem; color: #999; }

        .panel__foot {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            padding: 9px 12px;
            border-top: 1px solid #eaeaea;
            background: #fff;
            font-size: 0.73rem;
            color: #777;
        }

        .pager { display: flex; gap: 5px; }

        .pager button {
            min-width: 27px;
            padding: 4px 8px;
            border: 1px solid #e3e1d8;
            border-radius: 2px;
            background: #fff;
            font-size: 0.73rem;
            font-family: inherit;
            color: #444;
            cursor: pointer;
        }

        .pager button.is-on { background: #111; border-color: #111; color: #fff; }
        .pager button:disabled { opacity: 0.45; cursor: default; }

        /* ---------- Tabs ---------- */
        .tabs {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            border-bottom: 1px solid #eaeaea;
            margin-bottom: 18px;
        }

        .tab {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 13px;
            border: none;
            background: transparent;
            border-radius: 2px 2px 0 0;
            font-family: inherit;
            font-size: 0.83rem;
            font-weight: 500;
            color: #7c7768;
            cursor: pointer;
            margin-bottom: -1px;
            border-bottom: 2px solid transparent;
            transition: color 0.15s, border-color 0.15s;
        }

        .tab:hover { color: #111; background: #faf9f5; }

        .tab.is-active {
            color: #111;
            font-weight: 600;
            border-bottom-color: #111;
        }

        .tab__count {
            font-size: 0.67rem;
            font-weight: 600;
            padding: 1px 6px;
            border-radius: 2px;
            background: #f0efea;
            color: #7c7768;
        }

        .tab.is-active .tab__count { background: #111; color: #fff; }

        .subpane { display: none; }
        .subpane.is-active { display: block; }

        /* ---------- Misc ---------- */
        .pane { display: none; }
        .pane.is-active { display: block; }

        .toggle-row {
            display: flex;
            align-items: center;
            gap: 9px;
            font-size: 0.82rem;
            color: #333;
        }

        .footer-note {
            color: #999;
            font-size: 0.75rem;
            text-align: center;
            padding-top: 16px;
        }
    </style>
</head>
<body>

    <!-- ================= ICON SPRITE (Bootstrap Icons - https://icons.getbootstrap.com/) ================= -->
    <svg xmlns="http://www.w3.org/2000/svg" style="display:none;" aria-hidden="true">
        <symbol id="i-speedometer2" viewBox="0 0 16 16">
            <path d="M8 4a.5.5 0 0 1 .5.5V6a.5.5 0 0 1-1 0V4.5A.5.5 0 0 1 8 4zM3.732 5.732a.5.5 0 0 1 .707 0l.915.914a.5.5 0 1 1-.708.708l-.914-.915a.5.5 0 0 1 0-.707zM2 10a.5.5 0 0 1 .5-.5h1.586a.5.5 0 0 1 0 1H2.5A.5.5 0 0 1 2 10zm9.5 0a.5.5 0 0 1 .5-.5h1.5a.5.5 0 0 1 0 1H12a.5.5 0 0 1-.5-.5zm.754-4.246a.389.389 0 0 0-.527-.02L7.547 9.31a.91.91 0 1 0 1.302 1.258l3.434-4.297a.389.389 0 0 0-.029-.518z" />
            <path fill-rule="evenodd" d="M0 10a8 8 0 1 1 15.547 2.661c-.442 1.253-1.845 1.602-2.932 1.25C11.309 13.488 9.475 13 8 13c-1.475 0-3.31.488-4.615.911-1.087.352-2.49.003-2.932-1.25A7.988 7.988 0 0 1 0 10zm8-7a7 7 0 0 0-6.603 9.329c.203.575.923.876 1.68.63C4.397 12.533 6.358 12 8 12s3.604.532 4.923.96c.757.245 1.477-.056 1.68-.631A7 7 0 0 0 8 3z" />
        </symbol>
        <symbol id="i-people" viewBox="0 0 16 16">
            <path d="M15 14s1 0 1-1-1-4-5-4-5 3-5 4 1 1 1 1h8zm-7.978-1A.261.261 0 0 1 7 12.996c.001-.264.167-1.03.76-1.72C8.312 10.629 9.282 10 11 10c1.717 0 2.687.63 3.24 1.276.593.69.758 1.457.76 1.72l-.008.002a.274.274 0 0 1-.014.002H7.022zM11 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm3-2a3 3 0 1 1-6 0 3 3 0 0 1 6 0zM6.936 9.28a5.88 5.88 0 0 0-1.23-.247A7.35 7.35 0 0 0 5 9c-4 0-5 3-5 4 0 .667.333 1 1 1h4.216A2.238 2.238 0 0 1 5 13c0-1.01.377-2.042 1.09-2.904.243-.294.526-.569.846-.816z" />
            <path d="M4.92 10A5.493 5.493 0 0 0 4 13H1c0-.26.164-1.03.76-1.724.545-.636 1.492-1.256 3.16-1.275zM1.5 5.5a3 3 0 1 1 6 0 3 3 0 0 1-6 0zm3-2a2 2 0 1 0 0 4 2 2 0 0 0 0-4z" />
        </symbol>
        <symbol id="i-book" viewBox="0 0 16 16">
            <path d="M1 2.828c.885-.37 2.154-.769 3.388-.893 1.33-.134 2.458.063 3.112.752v9.746c-.935-.53-2.12-.603-3.213-.493-1.18.12-2.37.461-3.287.811V2.828zm7.5-.141c.654-.689 1.782-.886 3.112-.752 1.234.124 2.503.523 3.388.893v9.923c-.918-.35-2.107-.692-3.287-.81-1.094-.111-2.278-.039-3.213.492V2.687zM8 1.783C7.015.936 5.587.81 4.287.94c-1.514.153-3.042.672-3.994 1.105A.5.5 0 0 0 0 2.5v11a.5.5 0 0 0 .707.455c.882-.4 2.303-.881 3.68-1.02 1.409-.142 2.59.087 3.223.877a.5.5 0 0 0 .78 0c.633-.79 1.814-1.019 3.222-.877 1.378.139 2.8.62 3.681 1.02A.5.5 0 0 0 16 13.5v-11a.5.5 0 0 0-.293-.455c-.952-.433-2.48-.952-3.994-1.105C10.413.809 8.985.936 8 1.783z" />
        </symbol>
        <symbol id="i-clipboard-check" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M10.854 7.146a.5.5 0 0 1 0 .708l-3 3a.5.5 0 0 1-.708 0l-1.5-1.5a.5.5 0 1 1 .708-.708L7.5 9.793l2.646-2.647a.5.5 0 0 1 .708 0z" />
            <path d="M4 1.5H3a2 2 0 0 0-2 2V14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V3.5a2 2 0 0 0-2-2h-1v1h1a1 1 0 0 1 1 1V14a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1h1v-1z" />
            <path d="M9.5 1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-3a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5h3zm-3-1A1.5 1.5 0 0 0 5 1.5v1A1.5 1.5 0 0 0 6.5 4h3A1.5 1.5 0 0 0 11 2.5v-1A1.5 1.5 0 0 0 9.5 0h-3z" />
        </symbol>
        <symbol id="i-chat-square-text" viewBox="0 0 16 16">
            <path d="M14 1a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H4.414A2 2 0 0 0 3 11.586l-2 2V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12.793a.5.5 0 0 0 .854.353l2.853-2.853A1 1 0 0 1 4.414 12H14a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z" />
            <path d="M3 3.5a.5.5 0 0 1 .5-.5h9a.5.5 0 0 1 0 1h-9a.5.5 0 0 1-.5-.5zM3 6a.5.5 0 0 1 .5-.5h9a.5.5 0 0 1 0 1h-9A.5.5 0 0 1 3 6zm0 2.5a.5.5 0 0 1 .5-.5h5a.5.5 0 0 1 0 1h-5a.5.5 0 0 1-.5-.5z" />
        </symbol>
        <symbol id="i-gear" viewBox="0 0 16 16">
            <path d="M8 4.754a3.246 3.246 0 1 0 0 6.492 3.246 3.246 0 0 0 0-6.492zM5.754 8a2.246 2.246 0 1 1 4.492 0 2.246 2.246 0 0 1-4.492 0z" />
            <path d="M9.796 1.343c-.527-1.79-3.065-1.79-3.592 0l-.094.319a.873.873 0 0 1-1.255.52l-.292-.16c-1.64-.892-3.433.902-2.54 2.541l.159.292a.873.873 0 0 1-.52 1.255l-.319.094c-1.79.527-1.79 3.065 0 3.592l.319.094a.873.873 0 0 1 .52 1.255l-.16.292c-.892 1.64.901 3.434 2.541 2.54l.292-.159a.873.873 0 0 1 1.255.52l.094.319c.527 1.79 3.065 1.79 3.592 0l.094-.319a.873.873 0 0 1 1.255-.52l.292.16c1.64.893 3.434-.902 2.54-2.541l-.159-.292a.873.873 0 0 1 .52-1.255l.319-.094c1.79-.527 1.79-3.065 0-3.592l-.319-.094a.873.873 0 0 1-.52-1.255l.16-.292c.893-1.64-.902-3.433-2.541-2.54l-.292.159a.873.873 0 0 1-1.255-.52l-.094-.319zm-2.633.283c.246-.835 1.428-.835 1.674 0l.094.319a1.873 1.873 0 0 0 2.693 1.115l.291-.16c.764-.415 1.6.42 1.184 1.185l-.159.292a1.873 1.873 0 0 0 1.116 2.692l.318.094c.835.246.835 1.428 0 1.674l-.319.094a1.873 1.873 0 0 0-1.115 2.693l.16.291c.415.764-.42 1.6-1.185 1.184l-.291-.159a1.873 1.873 0 0 0-2.693 1.116l-.094.318c-.246.835-1.428.835-1.674 0l-.094-.319a1.873 1.873 0 0 0-2.692-1.115l-.292.16c-.764.415-1.6-.42-1.184-1.185l.159-.292A1.873 1.873 0 0 0 1.945 8.93l-.319-.094c-.835-.246-.835-1.428 0-1.674l.319-.094A1.873 1.873 0 0 0 3.06 4.377l-.16-.292c-.415-.764.42-1.6 1.185-1.184l.292.159a1.873 1.873 0 0 0 2.692-1.115l.094-.319z" />
        </symbol>
        <symbol id="i-arrow-left" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z" />
        </symbol>
        <symbol id="i-search" viewBox="0 0 16 16">
            <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z" />
        </symbol>
        <symbol id="i-plus-lg" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M8 2a.5.5 0 0 1 .5.5v5h5a.5.5 0 0 1 0 1h-5v5a.5.5 0 0 1-1 0v-5h-5a.5.5 0 0 1 0-1h5v-5A.5.5 0 0 1 8 2z" />
        </symbol>
        <symbol id="i-pencil-square" viewBox="0 0 16 16">
            <path d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z" />
            <path fill-rule="evenodd" d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5v11z" />
        </symbol>
        <symbol id="i-slash-circle" viewBox="0 0 16 16">
            <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z" />
            <path d="M11.354 4.646a.5.5 0 0 0-.708 0l-6 6a.5.5 0 0 0 .708.708l6-6a.5.5 0 0 0 0-.708z" />
        </symbol>
        <symbol id="i-check-circle" viewBox="0 0 16 16">
            <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z" />
            <path d="M10.97 4.97a.75.75 0 0 1 1.07 1.05l-3.99 4.99a.75.75 0 0 1-1.08.02L4.324 8.384a.75.75 0 1 1 1.06-1.06l2.094 2.093 3.473-4.425a.267.267 0 0 1 .02-.022z" />
        </symbol>
        <symbol id="i-trash" viewBox="0 0 16 16">
            <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z" />
            <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z" />
        </symbol>
        <symbol id="i-person-plus" viewBox="0 0 16 16">
            <path d="M6 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H1s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C9.516 10.68 8.289 10 6 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z" />
            <path fill-rule="evenodd" d="M13.5 5a.5.5 0 0 1 .5.5V7h1.5a.5.5 0 0 1 0 1H14v1.5a.5.5 0 0 1-1 0V8h-1.5a.5.5 0 0 1 0-1H13V5.5a.5.5 0 0 1 .5-.5z" />
        </symbol>
        <symbol id="i-journal-check" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M10.854 6.146a.5.5 0 0 1 0 .708l-3 3a.5.5 0 0 1-.708 0l-1.5-1.5a.5.5 0 1 1 .708-.708L7.5 8.793l2.646-2.647a.5.5 0 0 1 .708 0z" />
            <path d="M3 0h10a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2zm0 1a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1H3z" />
        </symbol>
        <symbol id="i-star-fill" viewBox="0 0 16 16">
            <path d="M3.612 15.443c-.386.198-.824-.149-.746-.592l.83-4.73L.173 6.765c-.329-.314-.158-.888.283-.95l4.898-.696L7.538.792c.197-.39.73-.39.927 0l2.184 4.327 4.898.696c.441.062.612.636.282.95l-3.522 3.356.83 4.73c.078.443-.36.79-.746.592L8 13.187l-4.389 2.256z" />
        </symbol>
        <symbol id="i-person-badge" viewBox="0 0 16 16">
            <path d="M6.5 2a.5.5 0 0 0 0 1h3a.5.5 0 0 0 0-1h-3zM11 8a3 3 0 1 1-6 0 3 3 0 0 1 6 0z" />
            <path d="M4.5 0A2.5 2.5 0 0 0 2 2.5V14a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V2.5A2.5 2.5 0 0 0 11.5 0h-7zM3 2.5A1.5 1.5 0 0 1 4.5 1h7A1.5 1.5 0 0 1 13 2.5v10.795a4.2 4.2 0 0 0-.776-.492C11.392 12.387 10.063 12 8 12s-3.392.387-4.224.803a4.2 4.2 0 0 0-.776.492V2.5z" />
        </symbol>
        <symbol id="i-file-earmark-text" viewBox="0 0 16 16">
            <path d="M5.5 7a.5.5 0 0 0 0 1h5a.5.5 0 0 0 0-1h-5zM5 9.5a.5.5 0 0 1 .5-.5h5a.5.5 0 0 1 0 1h-5a.5.5 0 0 1-.5-.5zm0 2a.5.5 0 0 1 .5-.5h2a.5.5 0 0 1 0 1h-2a.5.5 0 0 1-.5-.5z" />
            <path d="M9.5 0H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V4.5L9.5 0zm0 1v2A1.5 1.5 0 0 0 11 4.5h2V14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h5.5z" />
        </symbol>
        <symbol id="i-flag" viewBox="0 0 16 16">
            <path d="M14.778.085A.5.5 0 0 1 15 .5V8a.5.5 0 0 1-.314.464L14.5 8l.186.464-.003.001-.006.003-.023.009a12.435 12.435 0 0 1-.397.15c-.264.095-.631.223-1.047.35-.816.252-1.879.523-2.71.523-.847 0-1.548-.28-2.158-.525l-.028-.01C7.68 8.71 7.14 8.5 6.5 8.5c-.7 0-1.638.23-2.437.477A19.626 19.626 0 0 0 3 9.342V15.5a.5.5 0 0 1-1 0V.5a.5.5 0 0 1 1 0v.282c.226-.079.496-.17.79-.26C4.606.272 5.67 0 6.5 0c.84 0 1.524.277 2.121.519l.043.018C9.286.788 9.828 1 10.5 1c.7 0 1.638-.23 2.437-.477a19.587 19.587 0 0 0 1.349-.476l.019-.007.004-.002h.001M14 1.221c-.22.078-.48.167-.766.255-.81.252-1.872.523-2.734.523-.886 0-1.592-.286-2.203-.534l-.008-.003C7.662 1.21 7.139 1 6.5 1c-.669 0-1.606.229-2.415.478A21.294 21.294 0 0 0 3 1.845v6.433c.22-.078.48-.167.766-.255C4.576 7.77 5.638 7.5 6.5 7.5c.847 0 1.548.28 2.158.525l.028.01C9.32 8.29 9.86 8.5 10.5 8.5c.668 0 1.606-.229 2.415-.478A21.317 21.317 0 0 0 14 7.655V1.222z" />
        </symbol>
        <symbol id="i-graph-up" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M0 0h1v15h15v1H0V0zm14.817 3.113a.5.5 0 0 1 .07.704l-4.5 5.5a.5.5 0 0 1-.74.037L7.06 6.767l-3.656 5.027a.5.5 0 0 1-.808-.588l4-5.5a.5.5 0 0 1 .758-.06l2.609 2.61 4.15-5.073a.5.5 0 0 1 .704-.07z" />
        </symbol>
        <symbol id="i-person" viewBox="0 0 16 16">
            <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4zm-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10c-2.29 0-3.516.68-4.168 1.332-.678.678-.83 1.418-.832 1.664h10z" />
        </symbol>
        <symbol id="i-box-arrow-right" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M10 12.5a.5.5 0 0 1-.5.5h-8a.5.5 0 0 1-.5-.5v-9a.5.5 0 0 1 .5-.5h8a.5.5 0 0 1 .5.5v2a.5.5 0 0 0 1 0v-2A1.5 1.5 0 0 0 9.5 2h-8A1.5 1.5 0 0 0 0 3.5v9A1.5 1.5 0 0 0 1.5 14h8a1.5 1.5 0 0 0 1.5-1.5v-2a.5.5 0 0 0-1 0v2z" />
            <path fill-rule="evenodd" d="M15.854 8.354a.5.5 0 0 0 0-.708l-3-3a.5.5 0 0 0-.708.708L14.293 7.5H5.5a.5.5 0 0 0 0 1h8.793l-2.147 2.146a.5.5 0 0 0 .708.708l3-3z" />
        </symbol>
        <symbol id="i-caret-down-fill" viewBox="0 0 16 16">
            <path d="M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z" />
        </symbol>
        <symbol id="i-mortarboard" viewBox="0 0 16 16">
            <path d="M8.211 2.047a.5.5 0 0 0-.422 0l-7.5 3.5a.5.5 0 0 0 .025.917l7.5 3a.5.5 0 0 0 .372 0L14 7.14V13a1 1 0 0 0-1 1v2h3v-2a1 1 0 0 0-1-1V6.739l.686-.275a.5.5 0 0 0 .025-.917l-7.5-3.5zM8 8.46 1.758 5.965 8 3.052l6.242 2.913L8 8.46z" />
            <path d="M4.176 9.032a.5.5 0 0 0-.656.327l-.5 1.7a.5.5 0 0 0 .294.605l4.5 1.8a.5.5 0 0 0 .372 0l4.5-1.8a.5.5 0 0 0 .294-.605l-.5-1.7a.5.5 0 0 0-.656-.327L8 10.466 4.176 9.032zm-.068 1.873.22-.748 3.496 1.311a.5.5 0 0 0 .352 0l3.496-1.311.22.748L8 12.387l-3.892-1.482z" />
        </symbol>
    </svg>

    <form id="form1" runat="server">
        <div class="admin-shell">

            <!-- ================= SIDEBAR ================= -->
            <aside class="sidebar">
                <a class="sidebar__brand" href="Index.aspx">
                    <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Education" style="height:32px; width:auto; display:block;" />
                </a>

                <p class="sidebar__label">Overview</p>
                <button type="button" class="nav-item is-active" data-pane="pane-overview">
                    <svg class="mi mi-lg" aria-hidden="true"><use href="#i-speedometer2"></use></svg><span>Dashboard</span>
                </button>

                <p class="sidebar__label">Manage</p>
                <button type="button" class="nav-item" data-pane="pane-users">
                    <svg class="mi mi-lg" aria-hidden="true"><use href="#i-people"></use></svg><span>User Management</span>
                </button>
                <button type="button" class="nav-item" data-pane="pane-courses">
                    <svg class="mi mi-lg" aria-hidden="true"><use href="#i-book"></use></svg><span>Course Management</span>
                </button>
                <button type="button" class="nav-item" data-pane="pane-enrollments">
                    <svg class="mi mi-lg" aria-hidden="true"><use href="#i-clipboard-check"></use></svg><span>Enrollments</span>
                </button>
                <button type="button" class="nav-item" data-pane="pane-feedback">
                    <svg class="mi mi-lg" aria-hidden="true"><use href="#i-chat-square-text"></use></svg><span>Feedback &amp; Reviews</span>
                </button>

                <p class="sidebar__label">System</p>
                <button type="button" class="nav-item" data-pane="pane-settings">
                    <svg class="mi mi-lg" aria-hidden="true"><use href="#i-gear"></use></svg><span>Settings</span>
                </button>

                <div class="sidebar__foot">
                    <a class="nav-item" href="Index.aspx" style="text-decoration:none;">
                        <svg class="mi mi-lg" aria-hidden="true"><use href="#i-arrow-left"></use></svg><span>Back to site</span>
                    </a>
                </div>
            </aside>

            <!-- ================= MAIN ================= -->
            <main class="admin-main">

                <div class="topbar">
                    <div>
                        <h1 class="page-title" id="pageTitle">Welcome back, <asp:Literal ID="litWelcomeName" runat="server">Admin</asp:Literal></h1>
                        <p class="page-sub" id="pageSub">Platform health, learners and course activity at a glance.</p>
                    </div>
                    <div class="topbar__tools">
                        <span class="global-search">
                            <span class="search-ico"><svg class="mi" aria-hidden="true"><use href="#i-search"></use></svg></span>
                            <input type="text" id="globalSearch" class="form-control" placeholder="Search users, courses, enrollments..." />
                            <span class="kbd-hint">Ctrl K</span>
                        </span>
                        <div class="admin-menu">
                            <span class="admin-badge admin-menu__btn" tabindex="0">
                                <svg class="mi" aria-hidden="true"><use href="#i-person-badge"></use></svg>
                                <span>
                                    <asp:Literal ID="litAdminName" runat="server">Administrator</asp:Literal>
                                </span>
                                <svg class="mi admin-menu__caret" aria-hidden="true" style="width:9px;height:9px;min-width:9px;"><use href="#i-caret-down-fill"></use></svg>
                            </span>

                            <div class="admin-menu__pop">
                                <div class="admin-menu__card">
                                    <div class="admin-menu__who">
                                        <span class="admin-menu__name">
                                            <asp:Literal ID="litMenuName" runat="server">Administrator</asp:Literal>
                                        </span>
                                        <span class="admin-menu__role">Administrator</span>
                                    </div>
                                    <a class="admin-menu__item" href="Profile.aspx">
                                        <svg class="mi" aria-hidden="true"><use href="#i-person"></use></svg>My Profile
                                    </a>
                                    <button type="button" class="admin-menu__item" data-pane="pane-settings">
                                        <svg class="mi" aria-hidden="true"><use href="#i-gear"></use></svg>Settings
                                    </button>
                                    <div class="admin-menu__sep"></div>
                                    <asp:LinkButton ID="lnkLogout" runat="server" CssClass="admin-menu__item is-danger"
                                        OnClick="lnkLogout_Click"
                                        OnClientClick="return confirm('Log out of the admin dashboard?');">
                                        <svg class="mi" aria-hidden="true"><use href="#i-box-arrow-right"></use></svg>Log out
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ---------- PANE: OVERVIEW ---------- -->
                <section id="pane-overview" class="pane is-active">

                    <div class="kpi-grid">
                        <div class="kpi">
                            <p class="kpi__label">Total Users</p>
                            <p class="kpi__value">1,248</p>
                            <div class="kpi__foot">
                                <span class="delta delta--up">+8.4%</span>
                                <span>vs last month</span>
                            </div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Active Courses</p>
                            <p class="kpi__value">16</p>
                            <div class="kpi__foot">
                                <span class="delta delta--up">+2</span>
                                <span>published this month</span>
                            </div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Enrollments (MTD)</p>
                            <p class="kpi__value">214</p>
                            <div class="kpi__foot">
                                <span class="delta delta--up">+12.1%</span>
                                <span>vs last month</span>
                            </div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Completion Rate</p>
                            <p class="kpi__value">67%</p>
                            <div class="kpi__foot">
                                <span class="delta delta--down">-1.8%</span>
                                <span>vs last month</span>
                            </div>
                        </div>
                    </div>

                    <div class="split">
                        <div class="card">
                            <div class="card__head">
                                <div>
                                    <h3 class="card__title">Enrollments by Month</h3>
                                    <p class="card__hint">New course enrollments, last 8 months.</p>
                                </div>
                                <span class="pill pill--ok">On track</span>
                            </div>
                            <div class="chart">
                                <div class="bar-wrap"><span class="bar-value">92</span><div class="bar bar--muted" style="height:42%"></div><span class="bar-label">Feb</span></div>
                                <div class="bar-wrap"><span class="bar-value">108</span><div class="bar bar--muted" style="height:49%"></div><span class="bar-label">Mar</span></div>
                                <div class="bar-wrap"><span class="bar-value">134</span><div class="bar bar--muted" style="height:61%"></div><span class="bar-label">Apr</span></div>
                                <div class="bar-wrap"><span class="bar-value">123</span><div class="bar bar--muted" style="height:56%"></div><span class="bar-label">May</span></div>
                                <div class="bar-wrap"><span class="bar-value">158</span><div class="bar bar--muted" style="height:72%"></div><span class="bar-label">Jun</span></div>
                                <div class="bar-wrap"><span class="bar-value">172</span><div class="bar bar--muted" style="height:79%"></div><span class="bar-label">Jul</span></div>
                                <div class="bar-wrap"><span class="bar-value">191</span><div class="bar bar--muted" style="height:88%"></div><span class="bar-label">Aug</span></div>
                                <div class="bar-wrap"><span class="bar-value">214</span><div class="bar" style="height:100%"></div><span class="bar-label">Sep</span></div>
                            </div>
                        </div>

                        <div class="card">
                            <div class="card__head">
                                <h3 class="card__title">Recent Activity</h3>
                            </div>
                            <ul class="activity">
                                <li>
                                    <span class="activity__dot"><svg class="mi" aria-hidden="true"><use href="#i-person-plus"></use></svg></span>
                                    <div>
                                        <p class="activity__text"><strong>Nur Aisyah</strong> enrolled in <strong>Investment &amp; Portfolio Analysis</strong>.</p>
                                        <p class="activity__time">12 minutes ago</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><svg class="mi" aria-hidden="true"><use href="#i-journal-check"></use></svg></span>
                                    <div>
                                        <p class="activity__text">Course <strong>Credit Health 101</strong> moved to <strong>Published</strong>.</p>
                                        <p class="activity__time">1 hour ago</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg></span>
                                    <div>
                                        <p class="activity__text"><strong>Daniel Tan</strong> left a <strong>5-star review</strong> on <strong>Smart Budgeting &amp; Cash Flow</strong>.</p>
                                        <p class="activity__time">3 hours ago</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><svg class="mi" aria-hidden="true"><use href="#i-person-badge"></use></svg></span>
                                    <div>
                                        <p class="activity__text">New tutor account <strong>Lim Wei Ken</strong> awaiting approval.</p>
                                        <p class="activity__time">Yesterday</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><svg class="mi" aria-hidden="true"><use href="#i-slash-circle"></use></svg></span>
                                    <div>
                                        <p class="activity__text">Account <strong>test@meowlet.my</strong> was disabled.</p>
                                        <p class="activity__time">2 days ago</p>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card__head">
                            <div>
                                <h3 class="card__title">Top Performing Courses</h3>
                                <p class="card__hint">Ranked by enrollments this month.</p>
                            </div>
                        </div>
                        <div class="table-wrap">
                            <table class="data">
                                <thead>
                                    <tr>
                                        <th>Course</th>
                                        <th>Category</th>
                                        <th>Enrollments</th>
                                        <th>Rating</th>
                                        <th>Completion</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><strong>Smart Budgeting &amp; Cash Flow</strong></td>
                                        <td>Personal Finance</td>
                                        <td>312</td>
                                        <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>4.8</span></td>
                                        <td>74%</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Investment &amp; Portfolio Analysis</strong></td>
                                        <td>Investing</td>
                                        <td>248</td>
                                        <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>4.6</span></td>
                                        <td>61%</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Debt Management &amp; Credit Health</strong></td>
                                        <td>Credit</td>
                                        <td>187</td>
                                        <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>4.4</span></td>
                                        <td>69%</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Intro to Fintech &amp; Digital Payments</strong></td>
                                        <td>Fintech</td>
                                        <td>96</td>
                                        <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>4.1</span></td>
                                        <td>52%</td>
                                        <td><span class="pill pill--draft">Draft</span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ---------- PANE: USERS ---------- -->
                <section id="pane-users" class="pane">

                    <div class="panel">

                        <div class="panel__head">
                            <div>
                                <h3 class="panel__title">User Management</h3>
                                <p class="panel__hint">Search, filter, and manage every account on the platform.</p>
                            </div>
                            <button type="button" class="btn-a btn-dark">
                                <svg class="mi" aria-hidden="true"><use href="#i-plus-lg"></use></svg>Add User
                            </button>
                        </div>

                            <!-- search + filters sit on top of the table -->
                            <div class="panel__toolbar">
                                <span class="search-field">
                                    <span class="search-ico"><svg class="mi" aria-hidden="true"><use href="#i-search"></use></svg></span>
                                    <input type="text" class="form-control" placeholder="Search by name or email..." />
                                </span>
                                <span class="toolbar-sep"></span>
                                <select class="form-control filter-select">
                                    <option>All roles</option>
                                    <option>Student</option>
                                    <option>Tutor</option>
                                    <option>Admin</option>
                                </select>
                                <select class="form-control filter-select">
                                    <option>All statuses</option>
                                    <option>Active</option>
                                    <option>Pending</option>
                                    <option>Disabled</option>
                                </select>
                                <select class="form-control filter-select">
                                    <option>Newest first</option>
                                    <option>Oldest first</option>
                                    <option>Name A&ndash;Z</option>
                                </select>
                                <span class="toolbar-gap"></span>
                                <button type="button" class="btn-a btn-ghost btn-sm">Reset</button>
                                <button type="button" class="btn-a btn-dark btn-sm">Apply</button>
                            </div>

                            <div class="panel__meta">
                                <div class="chip-row">
                                    <button type="button" class="chip is-on">All <strong>1,248</strong></button>
                                    <button type="button" class="chip">Students <strong>1,164</strong></button>
                                    <button type="button" class="chip">Tutors <strong>78</strong></button>
                                    <button type="button" class="chip">Admins <strong>6</strong></button>
                                    <button type="button" class="chip">Disabled <strong>14</strong></button>
                                </div>
                                <span>Showing 1&ndash;5 of 1,248</span>
                            </div>

                            <div class="table-wrap">
                                <table class="data">
                                    <thead>
                                        <tr>
                                            <th class="col-check"><input type="checkbox" title="Select all" /></th>
                                            <th>User</th>
                                            <th>Role</th>
                                            <th>Status</th>
                                            <th>Enrolled</th>
                                            <th>Joined</th>
                                            <th>Last Active</th>
                                            <th class="col-actions">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td class="col-check"><input type="checkbox" /></td>
                                            <td>
                                                <div class="cell-user">
                                                    <span><strong>Nur Aisyah</strong><span class="cell-sub">aisyah@meowlet.my</span></span>
                                                </div>
                                            </td>
                                            <td><span class="pill pill--student">Student</span></td>
                                            <td><span class="pill pill--ok">Active</span></td>
                                            <td>4 courses</td>
                                            <td>12 Mar 2026</td>
                                            <td>12 min ago</td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-slash-circle"></use></svg>Disable</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="col-check"><input type="checkbox" /></td>
                                            <td>
                                                <div class="cell-user">
                                                    <span><strong>Daniel Tan</strong><span class="cell-sub">daniel.tan@meowlet.my</span></span>
                                                </div>
                                            </td>
                                            <td><span class="pill pill--student">Student</span></td>
                                            <td><span class="pill pill--ok">Active</span></td>
                                            <td>2 courses</td>
                                            <td>03 Apr 2026</td>
                                            <td>3 hours ago</td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-slash-circle"></use></svg>Disable</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="col-check"><input type="checkbox" /></td>
                                            <td>
                                                <div class="cell-user">
                                                    <span><strong>Lim Wei Ken</strong><span class="cell-sub">weiken@meowlet.my</span></span>
                                                </div>
                                            </td>
                                            <td><span class="pill pill--tutor">Tutor</span></td>
                                            <td><span class="pill pill--draft">Pending</span></td>
                                            <td>3 courses taught</td>
                                            <td>17 Sep 2026</td>
                                            <td>Yesterday</td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-slash-circle"></use></svg>Disable</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="col-check"><input type="checkbox" /></td>
                                            <td>
                                                <div class="cell-user">
                                                    <span><strong>Sarah Chin</strong><span class="cell-sub">sarah.chin@meowlet.my</span></span>
                                                </div>
                                            </td>
                                            <td><span class="pill pill--admin">Admin</span></td>
                                            <td><span class="pill pill--ok">Active</span></td>
                                            <td>&mdash;</td>
                                            <td>01 Jan 2026</td>
                                            <td>1 hour ago</td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-slash-circle"></use></svg>Disable</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="col-check"><input type="checkbox" /></td>
                                            <td>
                                                <div class="cell-user">
                                                    <span><strong>Test User</strong><span class="cell-sub">test@meowlet.my</span></span>
                                                </div>
                                            </td>
                                            <td><span class="pill pill--student">Student</span></td>
                                            <td><span class="pill pill--off">Disabled</span></td>
                                            <td>0 courses</td>
                                            <td>22 Aug 2026</td>
                                            <td>2 days ago</td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-check-circle"></use></svg>Enable</button>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="panel__foot">
                                <span>5 rows per page</span>
                                <div class="pager">
                                    <button type="button" disabled="disabled">Prev</button>
                                    <button type="button" class="is-on">1</button>
                                    <button type="button">2</button>
                                    <button type="button">3</button>
                                    <button type="button">Next</button>
                                </div>
                            </div>
                    </div>
                </section>

                <!-- ---------- PANE: COURSES ---------- -->
                <section id="pane-courses" class="pane">

                    <!-- tabs replace scrolling down to reach the existing course list -->
                    <div class="tabs" data-tabgroup="courses">
                        <button type="button" class="tab is-active" data-subpane="sub-course-create">
                            <svg class="mi" aria-hidden="true"><use href="#i-plus-lg"></use></svg>Create Course
                        </button>
                        <button type="button" class="tab" data-subpane="sub-course-list">
                            <svg class="mi" aria-hidden="true"><use href="#i-book"></use></svg>Existing Courses
                            <span class="tab__count">16</span>
                        </button>
                    </div>

                    <div id="sub-course-create" class="subpane is-active">
                    <div class="card">
                        <div class="card__head">
                            <div>
                                <h3 class="card__title">Create Course</h3>
                                <p class="card__hint">Define a new personal finance or fintech module.</p>
                            </div>
                            <span class="pill pill--draft">Draft mode</span>
                        </div>

                        <div class="form-grid">
                            <div class="form-group">
                                <label>Course Title</label>
                                <input type="text" class="form-control" placeholder="e.g. Smart Budgeting &amp; Cash Flow" />
                            </div>

                            <div class="form-group">
                                <label>Course Code</label>
                                <input type="text" class="form-control" placeholder="e.g. FIN-101" />
                                <p class="field-hint">Unique identifier shown on certificates.</p>
                            </div>

                            <div class="form-group">
                                <label>Category</label>
                                <select class="form-control">
                                    <option>Personal Finance</option>
                                    <option>Investing</option>
                                    <option>Credit &amp; Debt</option>
                                    <option>Fintech &amp; Digital Payments</option>
                                    <option>Taxation</option>
                                    <option>Retirement Planning</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Difficulty Level</label>
                                <select class="form-control">
                                    <option>Beginner</option>
                                    <option>Intermediate</option>
                                    <option>Advanced</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Lessons</label>
                                <input type="number" class="form-control" placeholder="12" min="0" />
                                <p class="field-hint">Number of lessons in this module.</p>
                            </div>

                            <div class="form-group">
                                <label>Duration (hours)</label>
                                <input type="number" class="form-control" placeholder="8" min="0" />
                            </div>

                            <div class="form-group">
                                <label>Assigned Tutor</label>
                                <select class="form-control">
                                    <option>Unassigned</option>
                                    <option>Lim Wei Ken</option>
                                    <option>Sarah Chin</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Thumbnail URL</label>
                                <input type="text" class="form-control" placeholder="assets/img/course-thumb.png" />
                            </div>

                            <div class="form-group full">
                                <label>Short Description</label>
                                <textarea class="form-control" placeholder="What learners will be able to do after finishing this module..."></textarea>
                            </div>

                            <div class="form-group full">
                                <label>Learning Outcomes</label>
                                <textarea class="form-control" placeholder="One outcome per line."></textarea>
                            </div>

                            <div class="form-group full">
                                <div class="toggle-row">
                                    <input type="checkbox" id="chkPublish" />
                                    <label for="chkPublish" style="margin:0;">Publish immediately after saving</label>
                                </div>
                            </div>

                            <div class="form-group full" style="display:flex; gap:12px; padding-top:6px;">
                                <button type="button" class="btn-a btn-dark">Create Course</button>
                                <button type="button" class="btn-a btn-ghost">Save as Draft</button>
                                <button type="button" class="btn-a btn-ghost">Reset</button>
                            </div>
                        </div>
                    </div>
                    </div>

                    <div id="sub-course-list" class="subpane">
                    <div class="panel">

                        <div class="panel__head">
                            <div>
                                <h3 class="panel__title">Existing Courses</h3>
                                <p class="panel__hint">16 modules, 12 published, 4 drafts.</p>
                            </div>
                        </div>

                            <div class="panel__toolbar">
                                <span class="search-field">
                                    <span class="search-ico"><svg class="mi" aria-hidden="true"><use href="#i-search"></use></svg></span>
                                    <input type="text" class="form-control" placeholder="Search by course title or code..." />
                                </span>
                                <span class="toolbar-sep"></span>
                                <select class="form-control filter-select">
                                    <option>All categories</option>
                                    <option>Personal Finance</option>
                                    <option>Investing</option>
                                    <option>Credit &amp; Debt</option>
                                    <option>Fintech</option>
                                </select>
                                <select class="form-control filter-select">
                                    <option>All levels</option>
                                    <option>Beginner</option>
                                    <option>Intermediate</option>
                                    <option>Advanced</option>
                                </select>
                                <select class="form-control filter-select">
                                    <option>All statuses</option>
                                    <option>Published</option>
                                    <option>Draft</option>
                                </select>
                                <span class="toolbar-gap"></span>
                                <button type="button" class="btn-a btn-ghost btn-sm">Reset</button>
                                <button type="button" class="btn-a btn-dark btn-sm">Apply</button>
                            </div>

                        <div class="table-wrap">
                            <table class="data">
                                <thead>
                                    <tr>
                                        <th>Code</th>
                                        <th>Title</th>
                                        <th>Category</th>
                                        <th>Level</th>
                                        <th>Lessons</th>
                                        <th>Status</th>
                                        <th class="col-actions">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>FIN-101</td>
                                        <td><strong>Smart Budgeting &amp; Cash Flow</strong></td>
                                        <td>Personal Finance</td>
                                        <td>Beginner</td>
                                        <td>12</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                        <td>
                                            <div class="row-actions">
                                                <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Delete</button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>FIN-201</td>
                                        <td><strong>Investment &amp; Portfolio Analysis</strong></td>
                                        <td>Investing</td>
                                        <td>Intermediate</td>
                                        <td>18</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                        <td>
                                            <div class="row-actions">
                                                <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Delete</button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>FIN-150</td>
                                        <td><strong>Debt Management &amp; Credit Health</strong></td>
                                        <td>Credit &amp; Debt</td>
                                        <td>Beginner</td>
                                        <td>10</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                        <td>
                                            <div class="row-actions">
                                                <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Delete</button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>FIN-310</td>
                                        <td><strong>Intro to Fintech &amp; Digital Payments</strong></td>
                                        <td>Fintech</td>
                                        <td>Advanced</td>
                                        <td>14</td>
                                        <td><span class="pill pill--draft">Draft</span></td>
                                        <td>
                                            <div class="row-actions">
                                                <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-pencil-square"></use></svg>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Delete</button>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                            <div class="panel__foot">
                                <span>Showing 4 of 16 courses</span>
                                <div class="pager">
                                    <button type="button" disabled="disabled">Prev</button>
                                    <button type="button" class="is-on">1</button>
                                    <button type="button">2</button>
                                    <button type="button">3</button>
                                    <button type="button">4</button>
                                    <button type="button">Next</button>
                                </div>
                            </div>
                    </div>
                    </div>
                </section>

                <!-- ---------- PANE: ENROLLMENTS ---------- -->
                <section id="pane-enrollments" class="pane">
                    <div class="kpi-grid">
                        <div class="kpi">
                            <p class="kpi__label">Total Enrollments</p>
                            <p class="kpi__value">3,472</p>
                            <div class="kpi__foot"><span class="delta delta--up">+214</span><span>this month</span></div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">In Progress</p>
                            <p class="kpi__value">1,108</p>
                            <div class="kpi__foot"><span class="delta delta--up">+6.2%</span><span>vs last month</span></div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Completed</p>
                            <p class="kpi__value">2,319</p>
                            <div class="kpi__foot"><span class="delta delta--up">+3.4%</span><span>vs last month</span></div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Dropped Off</p>
                            <p class="kpi__value">45</p>
                            <div class="kpi__foot"><span class="delta delta--down">+9</span><span>needs follow-up</span></div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card__head">
                            <div>
                                <h3 class="card__title">Recent Enrollments</h3>
                                <p class="card__hint">Latest learner sign-ups across all modules.</p>
                            </div>
                            <button type="button" class="btn-a btn-ghost"><svg class="mi" aria-hidden="true"><use href="#i-file-earmark-text"></use></svg>Export CSV</button>
                        </div>
                        <div class="table-wrap">
                            <table class="data">
                                <thead>
                                    <tr>
                                        <th>Learner</th>
                                        <th>Course</th>
                                        <th>Enrolled On</th>
                                        <th>Progress</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>Nur Aisyah</td>
                                        <td>Investment &amp; Portfolio Analysis</td>
                                        <td>18 Sep 2026</td>
                                        <td>12%</td>
                                        <td><span class="pill pill--ok">In progress</span></td>
                                    </tr>
                                    <tr>
                                        <td>Daniel Tan</td>
                                        <td>Smart Budgeting &amp; Cash Flow</td>
                                        <td>15 Sep 2026</td>
                                        <td>100%</td>
                                        <td><span class="pill pill--ok">Completed</span></td>
                                    </tr>
                                    <tr>
                                        <td>Chong Mei Ling</td>
                                        <td>Debt Management &amp; Credit Health</td>
                                        <td>14 Sep 2026</td>
                                        <td>48%</td>
                                        <td><span class="pill pill--ok">In progress</span></td>
                                    </tr>
                                    <tr>
                                        <td>Arif Rahman</td>
                                        <td>Smart Budgeting &amp; Cash Flow</td>
                                        <td>09 Sep 2026</td>
                                        <td>4%</td>
                                        <td><span class="pill pill--off">Stalled</span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ---------- PANE: FEEDBACK & REVIEWS ---------- -->
                <section id="pane-feedback" class="pane">
                    <div class="kpi-grid">
                        <div class="kpi">
                            <p class="kpi__label">Average Rating</p>
                            <p class="kpi__value">4.6</p>
                            <div class="kpi__foot"><span class="delta delta--up">+0.2</span><span>vs last month</span></div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Reviews This Month</p>
                            <p class="kpi__value">186</p>
                            <div class="kpi__foot"><span class="delta delta--up">+24</span><span>vs last month</span></div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Awaiting Moderation</p>
                            <p class="kpi__value">12</p>
                            <div class="kpi__foot"><span class="delta delta--flat">needs review</span></div>
                        </div>
                        <div class="kpi">
                            <p class="kpi__label">Reported Reviews</p>
                            <p class="kpi__value">3</p>
                            <div class="kpi__foot"><span class="delta delta--down">+1</span><span>this week</span></div>
                        </div>
                    </div>

                    <div class="panel">

                        <div class="panel__head">
                            <div>
                                <h3 class="panel__title">Course Reviews</h3>
                                <p class="panel__hint">Learner feedback across every module.</p>
                            </div>
                            <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-file-earmark-text"></use></svg>Export CSV</button>
                        </div>

                            <div class="panel__toolbar">
                                <span class="search-field">
                                    <span class="search-ico"><svg class="mi" aria-hidden="true"><use href="#i-search"></use></svg></span>
                                    <input type="text" class="form-control" placeholder="Search reviews by learner or course..." />
                                </span>
                                <span class="toolbar-sep"></span>
                                <select class="form-control filter-select">
                                    <option>All ratings</option>
                                    <option>5 stars</option>
                                    <option>4 stars</option>
                                    <option>3 stars and below</option>
                                </select>
                                <select class="form-control filter-select">
                                    <option>All statuses</option>
                                    <option>Published</option>
                                    <option>Pending</option>
                                    <option>Reported</option>
                                </select>
                                <span class="toolbar-gap"></span>
                                <button type="button" class="btn-a btn-ghost btn-sm">Reset</button>
                                <button type="button" class="btn-a btn-dark btn-sm">Apply</button>
                            </div>

                            <div class="panel__meta">
                                <div class="chip-row">
                                    <button type="button" class="chip is-on">All <strong>1,842</strong></button>
                                    <button type="button" class="chip">Published <strong>1,827</strong></button>
                                    <button type="button" class="chip">Pending <strong>12</strong></button>
                                    <button type="button" class="chip">Reported <strong>3</strong></button>
                                </div>
                                <span>Showing 1&ndash;4 of 1,842</span>
                            </div>

                            <div class="table-wrap">
                                <table class="data">
                                    <thead>
                                        <tr>
                                            <th>Learner</th>
                                            <th>Course</th>
                                            <th>Rating</th>
                                            <th>Comment</th>
                                            <th>Submitted</th>
                                            <th>Status</th>
                                            <th class="col-actions">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Daniel Tan</td>
                                            <td>Smart Budgeting &amp; Cash Flow</td>
                                            <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>5.0</span></td>
                                            <td>Clear examples, easy to follow every week.</td>
                                            <td>18 Sep 2026</td>
                                            <td><span class="pill pill--ok">Published</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-check-circle"></use></svg>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Remove</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Nur Aisyah</td>
                                            <td>Investment &amp; Portfolio Analysis</td>
                                            <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>4.0</span></td>
                                            <td>Good depth, wish there were more practice sets.</td>
                                            <td>17 Sep 2026</td>
                                            <td><span class="pill pill--draft">Pending</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-check-circle"></use></svg>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Remove</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Chong Mei Ling</td>
                                            <td>Debt Management &amp; Credit Health</td>
                                            <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>2.0</span></td>
                                            <td>Flagged as off-topic by another learner.</td>
                                            <td>15 Sep 2026</td>
                                            <td><span class="pill pill--off">Reported</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-check-circle"></use></svg>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Remove</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Arif Rahman</td>
                                            <td>Smart Budgeting &amp; Cash Flow</td>
                                            <td><span class="rating"><svg class="mi" aria-hidden="true"><use href="#i-star-fill"></use></svg>4.5</span></td>
                                            <td>The cash flow worksheet alone was worth it.</td>
                                            <td>12 Sep 2026</td>
                                            <td><span class="pill pill--ok">Published</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-check-circle"></use></svg>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><svg class="mi" aria-hidden="true"><use href="#i-trash"></use></svg>Remove</button>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="panel__foot">
                                <span>4 rows per page</span>
                                <div class="pager">
                                    <button type="button" disabled="disabled">Prev</button>
                                    <button type="button" class="is-on">1</button>
                                    <button type="button">2</button>
                                    <button type="button">3</button>
                                    <button type="button">Next</button>
                                </div>
                            </div>
                    </div>
                </section>

                <!-- ---------- PANE: SETTINGS ---------- -->
                <section id="pane-settings" class="pane">
                    <div class="card">
                        <div class="card__head">
                            <div>
                                <h3 class="card__title">Platform Settings</h3>
                                <p class="card__hint">Global configuration for the learning portal.</p>
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="form-group">
                                <label>Platform Name</label>
                                <input type="text" class="form-control" value="Meowlet Education" />
                            </div>
                            <div class="form-group">
                                <label>Support Email</label>
                                <input type="email" class="form-control" value="support@meowlet.my" />
                            </div>
                            <div class="form-group">
                                <label>Default Language</label>
                                <select class="form-control">
                                    <option>English</option>
                                    <option>Bahasa Malaysia</option>
                                    <option>Mandarin</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Default User Role</label>
                                <select class="form-control">
                                    <option>Student</option>
                                    <option>Tutor</option>
                                </select>
                            </div>
                            <div class="form-group full">
                                <div class="toggle-row">
                                    <input type="checkbox" id="chkSignups" checked="checked" />
                                    <label for="chkSignups" style="margin:0;">Allow new public sign-ups</label>
                                </div>
                            </div>
                            <div class="form-group full">
                                <div class="toggle-row">
                                    <input type="checkbox" id="chkMaint" />
                                    <label for="chkMaint" style="margin:0;">Maintenance mode (site visible to admins only)</label>
                                </div>
                            </div>
                            <div class="form-group full" style="padding-top:6px;">
                                <button type="button" class="btn-a btn-dark">Save Settings</button>
                            </div>
                        </div>
                    </div>
                </section>

                <p class="footer-note">&copy; 2026 Meowlet Education. Admin Control Center.</p>
            </main>
        </div>

        <script type="text/javascript">
            (function () {
                var adminFirstName = '<asp:Literal ID="litAdminNameJs" runat="server">Admin</asp:Literal>';

                var meta = {
                    'pane-overview': ['Welcome back, ' + adminFirstName, 'Platform health, learners and course activity at a glance.'],
                    'pane-users': ['User Management', 'Review accounts, change roles, and control access.'],
                    'pane-courses': ['Course Management', 'Create and maintain personal finance and fintech modules.'],
                    'pane-enrollments': ['Enrollments', 'Track learner progress across every module.'],
                    'pane-feedback': ['Feedback &amp; Reviews', 'Learner ratings and review moderation.'],
                    'pane-settings': ['Settings', 'Global configuration for the learning portal.']
                };

                var navItems = document.querySelectorAll('.nav-item[data-pane]');
                var panes = document.querySelectorAll('.pane');
                var title = document.getElementById('pageTitle');
                var sub = document.getElementById('pageSub');

                function show(paneId) {
                    for (var i = 0; i < panes.length; i++) {
                        panes[i].className = panes[i].id === paneId ? 'pane is-active' : 'pane';
                    }
                    for (var j = 0; j < navItems.length; j++) {
                        var active = navItems[j].getAttribute('data-pane') === paneId;
                        navItems[j].className = active ? 'nav-item is-active' : 'nav-item';
                    }
                    if (meta[paneId]) {
                        title.innerHTML = meta[paneId][0];
                        sub.innerHTML = meta[paneId][1];
                    }
                    window.scrollTo(0, 0);
                }

                for (var k = 0; k < navItems.length; k++) {
                    navItems[k].onclick = function () {
                        show(this.getAttribute('data-pane'));
                    };
                }

                // profile menu entries that jump to a pane
                var menuJumps = document.querySelectorAll('.admin-menu__item[data-pane]');
                for (var m = 0; m < menuJumps.length; m++) {
                    menuJumps[m].onclick = function () {
                        show(this.getAttribute('data-pane'));
                        if (document.activeElement && document.activeElement.blur) {
                            document.activeElement.blur();
                        }
                    };
                }

                // ---- in-pane tabs (Course Management) ----
                var tabs = document.querySelectorAll('.tab[data-subpane]');

                function showSub(group, subId) {
                    var groupTabs = group.querySelectorAll('.tab[data-subpane]');
                    for (var i = 0; i < groupTabs.length; i++) {
                        var on = groupTabs[i].getAttribute('data-subpane') === subId;
                        groupTabs[i].className = on ? 'tab is-active' : 'tab';
                        var sub = document.getElementById(groupTabs[i].getAttribute('data-subpane'));
                        if (sub) { sub.className = on ? 'subpane is-active' : 'subpane'; }
                    }
                }

                for (var t = 0; t < tabs.length; t++) {
                    tabs[t].onclick = function () {
                        showSub(this.parentNode, this.getAttribute('data-subpane'));
                    };
                }

                // ---- Ctrl/Cmd + K focuses the global search ----
                document.onkeydown = function (e) {
                    e = e || window.event;
                    if ((e.ctrlKey || e.metaKey) && (e.key === 'k' || e.key === 'K')) {
                        var gs = document.getElementById('globalSearch');
                        if (gs) {
                            if (e.preventDefault) { e.preventDefault(); }
                            gs.focus();
                            gs.select();
                        }
                    }
                };
            })();
        </script>
    </form>
</body>
</html>

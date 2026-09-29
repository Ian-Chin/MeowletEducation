<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="admindashboard.aspx.cs" Inherits="MeowletEducation.AdminDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Dashboard - Meowlet Education</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
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
            font-size: 9px;
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

        /* ---------- Icons (Bootstrap Icons font) ---------- */
        .mi { font-size: 14px; line-height: 1; flex-shrink: 0; }

        .mi-lg { font-size: 16px; }

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

        .rating .mi { color: #e6a417; font-size: 12px; }

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

    <form id="form1" runat="server">
        <div class="admin-shell">

            <!-- ================= SIDEBAR ================= -->
            <aside class="sidebar">
                <a class="sidebar__brand" href="Index.aspx">
                    <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Education" style="height:32px; width:auto; display:block;" />
                </a>

                <p class="sidebar__label">Overview</p>
                <button type="button" class="nav-item is-active" data-pane="pane-overview">
                    <i class="bi bi-speedometer2 mi mi-lg" aria-hidden="true"></i><span>Dashboard</span>
                </button>

                <p class="sidebar__label">Manage</p>
                <button type="button" class="nav-item" data-pane="pane-users">
                    <i class="bi bi-people mi mi-lg" aria-hidden="true"></i><span>User Management</span>
                </button>
                <button type="button" class="nav-item" data-pane="pane-courses">
                    <i class="bi bi-book mi mi-lg" aria-hidden="true"></i><span>Course Management</span>
                </button>
                <button type="button" class="nav-item" data-pane="pane-enrollments">
                    <i class="bi bi-clipboard-check mi mi-lg" aria-hidden="true"></i><span>Enrollments</span>
                </button>
                <button type="button" class="nav-item" data-pane="pane-feedback">
                    <i class="bi bi-chat-square-text mi mi-lg" aria-hidden="true"></i><span>Feedback &amp; Reviews</span>
                </button>

                <p class="sidebar__label">System</p>
                <button type="button" class="nav-item" data-pane="pane-settings">
                    <i class="bi bi-gear mi mi-lg" aria-hidden="true"></i><span>Settings</span>
                </button>

                <div class="sidebar__foot">
                    <a class="nav-item" href="Index.aspx" style="text-decoration:none;">
                        <i class="bi bi-arrow-left mi mi-lg" aria-hidden="true"></i><span>Back to site</span>
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
                            <span class="search-ico"><i class="bi bi-search mi" aria-hidden="true"></i></span>
                            <input type="text" id="globalSearch" class="form-control" placeholder="Search users, courses, enrollments..." />
                            <span class="kbd-hint">Ctrl K</span>
                        </span>
                        <div class="admin-menu">
                            <span class="admin-badge admin-menu__btn" tabindex="0">
                                <i class="bi bi-person-badge mi" aria-hidden="true"></i>
                                <span>
                                    <asp:Literal ID="litAdminName" runat="server">Administrator</asp:Literal>
                                </span>
                                <i class="bi bi-caret-down-fill mi admin-menu__caret" aria-hidden="true"></i>
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
                                        <i class="bi bi-person mi" aria-hidden="true"></i>My Profile
                                    </a>
                                    <button type="button" class="admin-menu__item" data-pane="pane-settings">
                                        <i class="bi bi-gear mi" aria-hidden="true"></i>Settings
                                    </button>
                                    <div class="admin-menu__sep"></div>
                                    <asp:LinkButton ID="lnkLogout" runat="server" CssClass="admin-menu__item is-danger"
                                        OnClick="lnkLogout_Click"
                                        OnClientClick="return confirm('Log out of the admin dashboard?');">
                                        <i class="bi bi-box-arrow-right mi" aria-hidden="true"></i>Log out
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
                                    <span class="activity__dot"><i class="bi bi-person-plus mi" aria-hidden="true"></i></span>
                                    <div>
                                        <p class="activity__text"><strong>Nur Aisyah</strong> enrolled in <strong>Investment &amp; Portfolio Analysis</strong>.</p>
                                        <p class="activity__time">12 minutes ago</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><i class="bi bi-journal-check mi" aria-hidden="true"></i></span>
                                    <div>
                                        <p class="activity__text">Course <strong>Credit Health 101</strong> moved to <strong>Published</strong>.</p>
                                        <p class="activity__time">1 hour ago</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><i class="bi bi-star-fill mi" aria-hidden="true"></i></span>
                                    <div>
                                        <p class="activity__text"><strong>Daniel Tan</strong> left a <strong>5-star review</strong> on <strong>Smart Budgeting &amp; Cash Flow</strong>.</p>
                                        <p class="activity__time">3 hours ago</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><i class="bi bi-person-badge mi" aria-hidden="true"></i></span>
                                    <div>
                                        <p class="activity__text">New tutor account <strong>Lim Wei Ken</strong> awaiting approval.</p>
                                        <p class="activity__time">Yesterday</p>
                                    </div>
                                </li>
                                <li>
                                    <span class="activity__dot"><i class="bi bi-slash-circle mi" aria-hidden="true"></i></span>
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
                                        <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>4.8</span></td>
                                        <td>74%</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Investment &amp; Portfolio Analysis</strong></td>
                                        <td>Investing</td>
                                        <td>248</td>
                                        <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>4.6</span></td>
                                        <td>61%</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Debt Management &amp; Credit Health</strong></td>
                                        <td>Credit</td>
                                        <td>187</td>
                                        <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>4.4</span></td>
                                        <td>69%</td>
                                        <td><span class="pill pill--ok">Published</span></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Intro to Fintech &amp; Digital Payments</strong></td>
                                        <td>Fintech</td>
                                        <td>96</td>
                                        <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>4.1</span></td>
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
                                <i class="bi bi-plus-lg mi" aria-hidden="true"></i>Add User
                            </button>
                        </div>

                            <!-- search + filters sit on top of the table -->
                            <div class="panel__toolbar">
                                <span class="search-field">
                                    <span class="search-ico"><i class="bi bi-search mi" aria-hidden="true"></i></span>
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
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-slash-circle mi" aria-hidden="true"></i>Disable</button>
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
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-slash-circle mi" aria-hidden="true"></i>Disable</button>
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
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-slash-circle mi" aria-hidden="true"></i>Disable</button>
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
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-slash-circle mi" aria-hidden="true"></i>Disable</button>
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
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-check-circle mi" aria-hidden="true"></i>Enable</button>
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
                            <i class="bi bi-plus-lg mi" aria-hidden="true"></i>Create Course
                        </button>
                        <button type="button" class="tab" data-subpane="sub-course-list">
                            <i class="bi bi-book mi" aria-hidden="true"></i>Existing Courses
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
                                    <span class="search-ico"><i class="bi bi-search mi" aria-hidden="true"></i></span>
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
                                                <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Delete</button>
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
                                                <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Delete</button>
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
                                                <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Delete</button>
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
                                                <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-pencil-square mi" aria-hidden="true"></i>Edit</button>
                                                <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Delete</button>
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
                            <button type="button" class="btn-a btn-ghost"><i class="bi bi-file-earmark-text mi" aria-hidden="true"></i>Export CSV</button>
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
                            <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-file-earmark-text mi" aria-hidden="true"></i>Export CSV</button>
                        </div>

                            <div class="panel__toolbar">
                                <span class="search-field">
                                    <span class="search-ico"><i class="bi bi-search mi" aria-hidden="true"></i></span>
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
                                            <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>5.0</span></td>
                                            <td>Clear examples, easy to follow every week.</td>
                                            <td>18 Sep 2026</td>
                                            <td><span class="pill pill--ok">Published</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-check-circle mi" aria-hidden="true"></i>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Remove</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Nur Aisyah</td>
                                            <td>Investment &amp; Portfolio Analysis</td>
                                            <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>4.0</span></td>
                                            <td>Good depth, wish there were more practice sets.</td>
                                            <td>17 Sep 2026</td>
                                            <td><span class="pill pill--draft">Pending</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-check-circle mi" aria-hidden="true"></i>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Remove</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Chong Mei Ling</td>
                                            <td>Debt Management &amp; Credit Health</td>
                                            <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>2.0</span></td>
                                            <td>Flagged as off-topic by another learner.</td>
                                            <td>15 Sep 2026</td>
                                            <td><span class="pill pill--off">Reported</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-check-circle mi" aria-hidden="true"></i>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Remove</button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Arif Rahman</td>
                                            <td>Smart Budgeting &amp; Cash Flow</td>
                                            <td><span class="rating"><i class="bi bi-star-fill mi" aria-hidden="true"></i>4.5</span></td>
                                            <td>The cash flow worksheet alone was worth it.</td>
                                            <td>12 Sep 2026</td>
                                            <td><span class="pill pill--ok">Published</span></td>
                                            <td class="col-actions">
                                                <div class="row-actions">
                                                    <button type="button" class="btn-a btn-ghost btn-sm"><i class="bi bi-check-circle mi" aria-hidden="true"></i>Approve</button>
                                                    <button type="button" class="btn-a btn-danger btn-sm"><i class="bi bi-trash mi" aria-hidden="true"></i>Remove</button>
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

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="MeowletEducation.Landing" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description"
        content="Meowlet Educations is a web-based learning system for money skills. Budgeting, saving, credit, investing and taxes, taught through virtual labs, simulations, self-assessments and live discussion. Free to browse." />
    <meta name="author" content="Meowlet Educations" />
    <meta name="theme-color" content="#f7f7f5" />
    <title>Meowlet Educations, a Web-based Learning System for Money Skills</title>

    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="apple-touch-icon" href="assets/img/apple-touch-icon.png" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="assets/css/style.css" />
    <style>
        .rate-note { margin-top: 14px; font-size: .82rem; color: var(--ink-faint); }

/* Level tags */
        .level-tag {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 99px;
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: capitalize;
            line-height: 1.4;
            background: var(--beige, #f3f4f6);   /* default (grey) for any other level */
            color: var(--ink-mute, #6b7280);
        }
        .level-beginner { background: #dcfce7; color: #166534; }      /* green */
        .level-intermediate { background: #fef3c7; color: #92400e; }  /* amber */
        .level-advanced { background: #fee2e2; color: #991b1b; }      /* red */

        /* Course grid + cards (image on top, like the Netacad catalog) */
        .course-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-top: 28px;
        }
        @media (max-width: 1100px) { .course-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 600px)  { .course-grid { grid-template-columns: 1fr; } }
        .course-card {
            display: flex;
            flex-direction: column;
            background: var(--paper);
            border: 1px solid var(--line);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            transition: transform .35s var(--ease, ease), box-shadow .35s var(--ease, ease), border-color .35s var(--ease, ease);
        }
        .course-card[hidden] { display: none; }
        .course-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow);
            border-color: var(--sand);
        }
        .course-card__img {
            position: relative;
            aspect-ratio: 16 / 9;
            overflow: hidden;
            background: linear-gradient(135deg, var(--beige, #f3f1ec), var(--sand, #e7e1d6));
        }
        .course-card__ph {
            position: absolute;
            inset: 0;
            display: grid;
            place-items: center;
            font-size: 2rem;
            color: var(--ink-faint, #9ca3af);
        }
        .course-card__img img {
            position: relative;
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .course-card__badge {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 2px 9px;
            border-radius: 99px;
            background: var(--paper);
            color: var(--ink);
            font-size: .66rem;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            box-shadow: 0 1px 4px rgba(0,0,0,.15);
        }
        .course-card__body {
            display: flex;
            flex-direction: column;
            flex: 1;
            padding: 16px 16px 14px;
        }
        .course-card__top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            font-size: .74rem;
            color: var(--ink-mute);
            font-family: var(--mono, monospace);
            margin-bottom: 8px;
        }
        .course-card__title {
            margin: 0 0 8px;
            font-size: 1rem;
            font-weight: 600;
            line-height: 1.35;
            color: var(--ink);
        }
        .course-card__desc {
            margin: 0 0 12px;
            font-size: .85rem;
            color: var(--ink-soft);
            line-height: 1.45;
            flex: 1;
        }
        .course-card__meta {
            margin: 0 0 12px;
            font-size: .76rem;
            color: var(--ink-faint);
        }
        .course-card__actions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
        }
        .course-card__lock {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: .78rem;
            color: var(--ink-mute);
        }

        .course-more {
            margin-top: 28px;
            text-align: center;
        }
        .course-more p {
            margin: 0 0 12px;
            color: var(--ink-mute);
            font-size: .95rem;
        }
        .course-more .btn + .btn { margin-left: 8px; }

        .cp-modal {
            position: fixed;
            inset: 0;
            z-index: 2000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background: rgba(20, 16, 12, .45);
            opacity: 0;
            visibility: hidden;
            transition: opacity .2s ease, visibility .2s ease;
        }
        .cp-modal.is-open {
            opacity: 1;
            visibility: visible;
        }
        .cp-modal__dialog {
            position: relative;
            background: var(--paper);
            border: 1px solid var(--line);
            border-radius: calc(var(--radius) + 4px);
            box-shadow: 0 20px 50px rgba(0,0,0,.18);
            max-width: 480px;
            width: 100%;
            max-height: min(88vh, 640px);
            overflow: auto;
            transform: translateY(10px);
            transition: transform .2s ease;
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
        .cp-modal__dialog::-webkit-scrollbar {
            display: none;
        }
        .cp-modal.is-open .cp-modal__dialog { transform: translateY(0); }
        .cp-modal__close {
            position: absolute;
            top: 12px;
            right: 12px;
            width: 36px;
            height: 36px;
            border: 0;
            border-radius: 50%;
            background: var(--beige);
            color: var(--ink);
            font-size: 1.25rem;
            line-height: 1;
            cursor: pointer;
            display: grid;
            place-items: center;
        }
        .cp-modal__close:hover { background: var(--sand); }
        .cp-modal__body { padding: 28px 26px 24px; }
        .cp-modal__code {
            margin: 0 0 4px;
            font-family: var(--mono, monospace);
            font-size: .78rem;
            color: var(--ink-mute);
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 6px;
        }
        .cp-modal__title {
            margin: 0 0 10px;
            font-size: 1.25rem;
            font-weight: 600;
            line-height: 1.3;
            color: var(--ink);
            padding-right: 28px;
        }
        .cp-modal__desc {
            margin: 0 0 14px;
            font-size: .92rem;
            color: var(--ink-soft);
            line-height: 1.5;
        }
        .cp-modal__meta {
            margin: 0 0 16px;
            font-size: .82rem;
            color: var(--ink-mute);
        }
        .cp-modal__outline {
            margin: 0 0 20px;
            padding: 0;
            list-style: none;
            border: 1px solid var(--line);
            border-radius: var(--radius);
            overflow: hidden;
        }
        .cp-modal__outline li {
            display: flex;
            align-items: baseline;
            gap: 10px;
            padding: 10px 14px;
            font-size: .88rem;
            border-top: 1px solid var(--line);
            color: var(--ink);
        }
        .cp-modal__outline li:first-child { border-top: 0; }
        .cp-modal__outline .pos {
            font-family: var(--mono, monospace);
            font-size: .75rem;
            color: var(--ink-faint);
            min-width: 1.5em;
        }
        .cp-modal__outline .type {
            margin-left: auto;
            font-size: .75rem;
            color: var(--ink-faint);
            white-space: nowrap;
        }
        .cp-modal__actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
        }
        .cp-modal__lock {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: .84rem;
            color: var(--ink-mute);
        }

        /* Header nav + global search */
        .header-nav { display: flex; align-items: center; gap: 4px; margin: 0 auto 0 12px; }
        .header-nav a {
            padding: 8px 12px;
            border-radius: 99px;
            font-size: .92rem;
            font-weight: 500;
            color: var(--ink);
            text-decoration: none;
        }
        .header-nav a:hover,
        .header-nav a[aria-current="page"] { background: var(--beige); }

        .gs { position: relative; flex: 1 1 260px; max-width: 360px; margin: 0 16px; }
        .gs__field { position: relative; display: flex; align-items: center; }
        .gs__field > i { position: absolute; left: 13px; color: var(--ink-mute); pointer-events: none; }
        .gs__input {
            width: 100%;
            height: 38px;
            padding: 0 38px 0 36px;
            border: 1px solid var(--line);
            border-radius: 99px;
            background: var(--paper);
            color: var(--ink);
            font: inherit;
            font-size: .9rem;
        }
        .gs__input:focus { outline: 2px solid var(--ink, #222); outline-offset: 1px; }
        .gs__kbd {
            position: absolute;
            right: 10px;
            padding: 0 6px;
            border: 1px solid var(--line);
            border-radius: 5px;
            font-family: var(--mono, monospace);
            font-size: .7rem;
            color: var(--ink-faint);
            pointer-events: none;
        }
        .gs__input:not(:placeholder-shown) ~ .gs__kbd { display: none; }
        .gs__panel {
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            right: 0;
            min-width: 320px;
            max-height: 70vh;
            overflow: auto;
            padding: 6px;
            background: var(--paper);
            border: 1px solid var(--line);
            border-radius: var(--radius);
            box-shadow: 0 16px 40px rgba(0,0,0,.14);
            z-index: 1500;
        }
        .gs__panel[hidden] { display: none; }
        .gs__group {
            padding: 8px 10px 4px;
            font-size: .68rem;
            font-weight: 700;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: var(--ink-faint);
        }
        .gs__item {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            padding: 8px 10px;
            border: 0;
            border-radius: 8px;
            background: transparent;
            color: var(--ink);
            font: inherit;
            font-size: .88rem;
            text-align: left;
            text-decoration: none;
            cursor: pointer;
        }
        .gs__item:hover, .gs__item:focus { background: var(--beige); outline: none; }
        .gs__thumb {
            flex: 0 0 44px;
            width: 44px;
            height: 32px;
            border-radius: 6px;
            overflow: hidden;
            display: grid;
            place-items: center;
            background: var(--beige);
            color: var(--ink-faint);
        }
        .gs__thumb img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .gs__text { flex: 1; min-width: 0; display: flex; flex-direction: column; }
        .gs__title { font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .gs__sub { font-size: .76rem; color: var(--ink-mute); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .gs__empty { padding: 14px 12px; font-size: .88rem; color: var(--ink-mute); }
        .gs__all {
            display: block;
            margin-top: 4px;
            padding: 10px;
            border-top: 1px solid var(--line);
            text-align: center;
            font-size: .85rem;
            font-weight: 600;
            color: var(--ink);
            text-decoration: none;
        }
        .gs__all:hover, .gs__all:focus { background: var(--beige); outline: none; }
        @media (max-width: 760px) {
            .header__inner { flex-wrap: wrap; }
            .gs { order: 10; flex: 1 0 100%; max-width: none; margin: 8px 0 0; }
            .gs__panel { min-width: 0; }
        }

        /* Preview modal image */
        .cp-modal__img { aspect-ratio: 16 / 7; background: var(--beige); overflow: hidden; }
        .cp-modal__img[hidden] { display: none; }
        .cp-modal__img img { display: block; width: 100%; height: 100%; object-fit: cover; }
        .cp-modal__close { z-index: 2; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <a class="skip-link" href="#main">Skip to main content</a>

    <header class="header" id="siteHeader">
        <div class="shell header__inner">
            <a class="brand" href="index.aspx" aria-label="Meowlet Educations home">
                <img src="assets/img/meowlet-logo.png" alt="Meowlet Educations" />
            </a>
            <nav class="header-nav" aria-label="Main">
                <a href="index.aspx" aria-current="page">Home</a>
                <a href="Courses.aspx">Courses</a>
            </nav>
            <div class="gs" role="search">
                <div class="gs__field">
                    <i class="bi bi-search" aria-hidden="true"></i>
                    <input type="search" id="globalSearch" class="gs__input" placeholder="Search courses and pages" autocomplete="off"
                           aria-label="Search courses and pages" aria-controls="globalSearchPanel" aria-expanded="false" />
                    <span class="gs__kbd" aria-hidden="true">/</span>
                </div>
                <div class="gs__panel" id="globalSearchPanel" role="listbox" aria-label="Search results" hidden></div>
            </div>
            <div class="nav__actions" data-auth="guest">
                <a class="btn btn--ghost btn--sm" href="Signin.aspx">Log in</a>
                <a class="btn btn--primary btn--sm" href="Signup.aspx">Join free</a>
            </div>
            <div class="nav-user" id="navUser" data-auth="user" hidden>
                <button type="button" class="nav-user__btn" id="navUserBtn" aria-haspopup="true" aria-expanded="false" aria-controls="navUserMenu">
                    <span class="nav-user__avatar" id="navUserInitials" aria-hidden="true"></span>
                    <span class="nav-user__name" id="navUserName"></span>
                    <i class="bi bi-chevron-down" aria-hidden="true"></i>
                </button>
                <div class="nav-user__menu" id="navUserMenu" hidden>
                    <a href="#" data-auth-link="dashboard"><i class="bi bi-grid-1x2" aria-hidden="true"></i>My dashboard</a>
                    <a href="Profile.aspx" data-auth-link="profile"><i class="bi bi-person" aria-hidden="true"></i>Profile</a>
                    <button type="button" id="navUserLogout"><i class="bi bi-box-arrow-right" aria-hidden="true"></i>Log out</button>
                </div>
            </div>
        </div>
    </header>

    <main id="main">

        <section class="hero">
            <div class="shell hero__grid">
                <figure class="hero__art reveal">
                    <img src="assets/img/cat-burst.webp"
                        alt="The Meowlet cat bursting through a screen in a shower of banknotes and coins" />
                </figure>
                <div class="hero__copy reveal">
                    <h1 class="display hero__title">The most fun way to learn finance, budgeting and more.</h1>
                    <div class="stack hero__actions">
                        <a class="btn btn--primary" href="Signup.aspx" data-auth-cta>Create a free account</a>
                        <a class="btn btn--ghost" href="#courses">Browse as a guest</a>
                    </div>
                    <p class="hero__note">Educational content only, never personal financial advice.</p>
                </div>
            </div>
        </section>

        <div class="section--paper">
            <div class="shell marquee-strip">
                <span>Budgeting</span><span>Saving</span><span>Credit &amp; debt</span><span>Investing basics</span>
                <span>Taxes</span><span>Insurance</span><span>Retirement</span>
            </div>
        </div>

        <section class="section" id="learn">
            <div class="shell split">
                <div class="reveal">
                    <p class="eyebrow">01. Ways to learn</p>
                    <h2 class="h2">Six ways to practise.</h2>
                    <p class="lead">Every resource asks you to do something.</p>
                    <ul class="feature-list">
                        <li>
                            <span class="feature-list__icon"><i class="bi bi-broadcast" aria-hidden="true"></i></span>
                            <div><strong>Live rooms</strong>Weekly, with a tutor. Transcript after.</div>
                        </li>
                        <li>
                            <span class="feature-list__icon"><i class="bi bi-joystick" aria-hidden="true"></i></span>
                            <div><strong>Virtual labs</strong>Try a decision, see the outcome, try again.</div>
                        </li>
                        <li>
                            <span class="feature-list__icon"><i class="bi bi-graph-up" aria-hidden="true"></i></span>
                            <div><strong>Simulations</strong>Compound growth, debt payoff, a year of spending.</div>
                        </li>
                        <li>
                            <span class="feature-list__icon"><i class="bi bi-clipboard-check" aria-hidden="true"></i></span>
                            <div><strong>Self-assessments</strong>Short checks that show what to study next.</div>
                        </li>
                        <li>
                            <span class="feature-list__icon"><i class="bi bi-chat-dots" aria-hidden="true"></i></span>
                            <div><strong>Discussion boards</strong>Ask, answer, leave a worked example.</div>
                        </li>
                        <li>
                            <span class="feature-list__icon"><i class="bi bi-box" aria-hidden="true"></i></span>
                            <div><strong>Learning objects</strong>Budget builders, payslips, amortisation tables.</div>
                        </li>
                    </ul>
                    <a class="btn btn--ghost" href="Courses.aspx">
                        Browse the catalog <i class="bi bi-arrow-right" aria-hidden="true"></i>
                    </a>
                </div>
                <figure class="figure reveal">
                    <img src="assets/img/cat-money-run.webp" alt="The Meowlet cat running with a stack of banknotes" />
                </figure>
            </div>
        </section>

        <section class="section section--beige" id="catalog">
            <div class="shell split split--flip">
                <figure class="figure reveal">
                    <img src="assets/img/cat-coin-leap.webp" alt="The Meowlet cat leaping up to catch a coin" />
                </figure>
                <div class="reveal">
                    <p class="eyebrow">02. Featured this week</p>
                    <h2 class="h2">Start small. Finish tonight.</h2>
                    <p class="lead">Guests get everything. An account just remembers where you stopped.</p>
                    <ul class="feature-list">
                        <li>
                            <div>
                                <strong>Compound interest, felt not memorised</strong>
                                Drag the timeline to forty years. Add a one percent fee and watch.
                                <div class="progress">
                                    <div class="progress__track">
                                        <span class="progress__bar" data-progress="72" style="width:0"></span>
                                    </div>
                                </div>
                                <span class="feature-list__meta">Simulation, 30 min</span>
                            </div>
                        </li>
                        <li>
                            <div>
                                <strong>One missed card payment</strong>
                                Run a year of minimum payments. Then rerun it paying fifty more.
                                <div class="progress">
                                    <div class="progress__track">
                                        <span class="progress__bar" data-progress="58" style="width:0"></span>
                                    </div>
                                </div>
                                <span class="feature-list__meta">Simulation, 25 min</span>
                            </div>
                        </li>
                    </ul>
                    <a class="btn btn--ghost" href="Courses.aspx">
                        See all courses <i class="bi bi-arrow-right" aria-hidden="true"></i>
                    </a>
                </div>
            </div>
        </section>

        <section class="section" id="courses">
            <div class="shell">
                <div class="section-head reveal">
                    <p class="eyebrow">Featured courses</p>
                    <h2 class="h2">Start here.</h2>
                    <p class="lead">Four short courses to get you moving tonight.</p>
                </div>

                <div class="course-grid">
                    <asp:Repeater ID="rptCourses" runat="server">
                        <ItemTemplate>
                            <article class="course-card reveal">
                                <div class="course-card__img">
                                    <i class="bi bi-mortarboard course-card__ph" aria-hidden="true"></i>
                                    <%# ImgTag(Eval("ImageSrc")) %>
                                    <span class="course-card__badge"><%# Html(Eval("Category")) %></span>
                                </div>
                                <div class="course-card__body">
                                    <div class="course-card__top">
                                        <span><%# Html(Eval("CourseCode")) %></span>
                                        <span class='<%# LevelClass(Eval("Level")) %>'><%# Html(Eval("Level")) %></span>
                                    </div>
                                    <h3 class="course-card__title"><%# Html(Eval("Title")) %></h3>
                                    <p class="course-card__desc"><%# ShortDesc(Eval("Description")) %></p>
                                    <p class="course-card__meta">
                                        <i class="bi bi-journal-text" aria-hidden="true"></i>
                                        <%# Eval("LessonCount") %> lessons · <%# Html(Eval("TutorName")) %>
                                    </p>
                                    <div class="course-card__actions">
                                        <button type="button" class="btn btn--primary btn--sm"
                                                data-preview-id='<%# Eval("CourseId") %>'>
                                            Preview
                                        </button>
                                        <span class="course-card__lock">
                                            <i class="bi bi-lock-fill" aria-hidden="true"></i>
                                            Login for more
                                        </span>
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="cat-empty">
                    No published courses yet. Check back soon.
                </asp:Panel>

                <div class="course-more reveal">
                    <p>Want the full catalog?</p>
                    <a class="btn btn--primary" href="Courses.aspx">Browse all courses</a>
                    <a class="btn btn--ghost" href="Signup.aspx">Join free</a>
                </div>
            </div>
        </section>

        <div class="cp-modal" id="coursePreviewModal" role="dialog" aria-modal="true" aria-labelledby="cpTitle" hidden>
            <div class="cp-modal__dialog">
                <button type="button" class="cp-modal__close" id="cpClose" aria-label="Close">&times;</button>
                <div class="cp-modal__img" id="cpImageWrap" hidden><img id="cpImage" alt="" /></div>
                <div class="cp-modal__body">
                    <p class="cp-modal__code" id="cpCode"></p>
                    <h3 class="cp-modal__title" id="cpTitle"></h3>
                    <p class="cp-modal__desc" id="cpDesc"></p>
                    <p class="cp-modal__meta" id="cpMeta"></p>
                    <p class="eyebrow" style="margin:0 0 8px">Outline</p>
                    <ul class="cp-modal__outline" id="cpOutline"></ul>
                    <div class="cp-modal__actions">
                        <a class="btn btn--primary btn--sm" href="Signup.aspx">Join free to start</a>
                        <a class="btn btn--ghost btn--sm" href="Signin.aspx">Log in</a>
                        <span class="cp-modal__lock">
                            <i class="bi bi-lock-fill" aria-hidden="true"></i>
                            Full lessons after you sign in
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <script type="application/json" id="coursePreviewData"><%= CoursePreviewJson %></script>
        <script>
        (function () {
            "use strict";

            var dataEl = document.getElementById("coursePreviewData");
            var modal = document.getElementById("coursePreviewModal");
            if (!dataEl || !modal) return;

            var courses = [];
            try { courses = JSON.parse(dataEl.textContent || "[]"); } catch (err) { courses = []; }

            var byId = {};
            for (var i = 0; i < courses.length; i++) byId[String(courses[i].id)] = courses[i];

            var codeEl = document.getElementById("cpCode");
            var titleEl = document.getElementById("cpTitle");
            var descEl = document.getElementById("cpDesc");
            var metaEl = document.getElementById("cpMeta");
            var outlineEl = document.getElementById("cpOutline");
            var closeBtn = document.getElementById("cpClose");
            var imgWrap = document.getElementById("cpImageWrap");
            var imgEl = document.getElementById("cpImage");
            if (!codeEl || !titleEl || !descEl || !metaEl || !outlineEl || !closeBtn) return;

            var lastFocus = null;

            function esc(s) {
                return String(s == null ? "" : s)
                    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
                    .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
            }

            function levelClass(lvl) {
                return "level-tag level-" + String(lvl || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
            }

            function openPreview(id) {
                var c = byId[String(id)];
                if (!c) return;

                var lvl = c.level || "";
                codeEl.innerHTML = esc(c.code) + " · <span class='" + levelClass(lvl) + "'>" + esc(lvl) + "</span> · " + esc(c.category);

                if (imgWrap && imgEl) {
                    if (c.image) { imgEl.src = c.image; imgWrap.hidden = false; }
                    else { imgEl.removeAttribute("src"); imgWrap.hidden = true; }
                }

                titleEl.textContent = c.title;
                descEl.textContent = c.description || "No description yet.";
                var count = c.lessonCount || (c.lessons && c.lessons.length) || 0;
                metaEl.textContent = count + " lessons · Tutor: " + (c.tutorName || "Meowlet team");

                var html = "";
                var lessons = c.lessons || [];
                for (var j = 0; j < lessons.length; j++) {
                    var l = lessons[j];
                    html += "<li><span class=\"pos\">" + l.position + "</span>" +
                        "<span>" + esc(l.title) + "</span>" +
                        "<span class=\"type\">" + esc(l.contentType) + " · " + l.durationMinutes + " min</span></li>";
                }
                outlineEl.innerHTML = html || "<li>No lessons listed yet.</li>";

                lastFocus = document.activeElement;
                modal.hidden = false;
                modal.classList.add("is-open");
                document.body.style.overflow = "hidden";
                closeBtn.focus();
            }

            function closePreview() {
                modal.classList.remove("is-open");
                document.body.style.overflow = "";
                setTimeout(function () { if (!modal.classList.contains("is-open")) modal.hidden = true; }, 200);
                if (lastFocus && typeof lastFocus.focus === "function") lastFocus.focus();
            }

            document.addEventListener("click", function (e) {
                var t = e.target;
                if (!t || !t.closest) return;
                var btn = t.closest("[data-preview-id]");
                if (!btn) return;
                e.preventDefault();
                openPreview(btn.getAttribute("data-preview-id"));
            });

            closeBtn.addEventListener("click", closePreview);
            modal.addEventListener("click", function (e) { if (e.target === modal) closePreview(); });
            document.addEventListener("keydown", function (e) {
                if (e.key === "Escape" && modal.classList.contains("is-open")) closePreview();
            });

            // ---------- Global search (courses from the database + page sections) ----------
            var input = document.getElementById("globalSearch");
            var panel = document.getElementById("globalSearchPanel");
            if (!input || !panel) return;

            var pages = [
                { title: "Course catalog", sub: "Browse every course", href: "Courses.aspx", icon: "bi-mortarboard", kw: "courses catalog browse all learn netacad" },
                { title: "Ways to learn", sub: "Labs, simulations, live rooms", href: "#learn", icon: "bi-lightbulb", kw: "virtual labs simulations self-assessments discussion boards live rooms learning objects" },
                { title: "Guests and members", sub: "What an account gives you", href: "#access", icon: "bi-people", kw: "guest member account register progress free access" },
                { title: "Meet the developers", sub: "The team behind Meowlet", href: "#team", icon: "bi-code-slash", kw: "developers team ian isac yong han ye wen" }
            ];

            function norm(s) { return String(s == null ? "" : s).toLowerCase(); }
            function termsOf(q) { return norm(q).split(/\s+/).filter(Boolean); }

            function findCourses(q) {
                var terms = termsOf(q), out = [];
                if (!terms.length) return out;
                courses.forEach(function (c) {
                    var title = norm(c.title);
                    var hay = [c.code, c.title, c.category, c.level, c.description, c.tutorName].map(norm).join(" ");
                    var score = 0;
                    for (var i = 0; i < terms.length; i++) {
                        if (hay.indexOf(terms[i]) < 0) return;
                        score += title.indexOf(terms[i]) === 0 ? 3 : (title.indexOf(terms[i]) > -1 ? 2 : 1);
                    }
                    out.push({ c: c, score: score });
                });
                out.sort(function (a, b) { return b.score - a.score; });
                return out.map(function (x) { return x.c; });
            }

            function findPages(q) {
                var terms = termsOf(q);
                return pages.filter(function (p) {
                    var hay = norm(p.title + " " + p.sub + " " + p.kw);
                    return terms.length && terms.every(function (t) { return hay.indexOf(t) > -1; });
                });
            }

            function render(q) {
                var cHits = findCourses(q), pHits = findPages(q), html = "";
                if (cHits.length) {
                    html += "<div class=\"gs__group\">Courses</div>";
                    cHits.slice(0, 6).forEach(function (c) {
                        var thumb = c.image ? "<img src=\"" + esc(c.image) + "\" alt=\"\" />" : "<i class=\"bi bi-mortarboard\" aria-hidden=\"true\"></i>";
                        html += "<button type=\"button\" class=\"gs__item\" role=\"option\" data-preview-id=\"" + esc(c.id) + "\">" +
                            "<span class=\"gs__thumb\">" + thumb + "</span>" +
                            "<span class=\"gs__text\"><span class=\"gs__title\">" + esc(c.title) + "</span>" +
                            "<span class=\"gs__sub\">" + esc(c.category) + " · " + esc(c.level) + " · " + (c.lessonCount || 0) + " lessons</span></span></button>";
                    });
                }
                if (pHits.length) {
                    html += "<div class=\"gs__group\">Pages</div>";
                    pHits.slice(0, 3).forEach(function (p) {
                        html += "<a class=\"gs__item\" role=\"option\" href=\"" + esc(p.href) + "\">" +
                            "<span class=\"gs__thumb\"><i class=\"bi " + p.icon + "\" aria-hidden=\"true\"></i></span>" +
                            "<span class=\"gs__text\"><span class=\"gs__title\">" + esc(p.title) + "</span>" +
                            "<span class=\"gs__sub\">" + esc(p.sub) + "</span></span></a>";
                    });
                }
                if (!html) html = "<div class=\"gs__empty\">No results for &ldquo;" + esc(q) + "&rdquo;.</div>";
                html += "<a class=\"gs__all\" href=\"Courses.aspx?q=" + encodeURIComponent(q) + "\">See all results in the catalog</a>";
                panel.innerHTML = html;
            }

            function openPanel() { panel.hidden = false; input.setAttribute("aria-expanded", "true"); }
            function closePanel() { panel.hidden = true; input.setAttribute("aria-expanded", "false"); }
            function items() { return [].slice.call(panel.querySelectorAll(".gs__item, .gs__all")); }

            function update() {
                var q = input.value.trim();
                if (!q) { closePanel(); return; }
                render(q);
                openPanel();
            }

            input.addEventListener("input", update);
            input.addEventListener("focus", update);
            input.addEventListener("keydown", function (e) {
                if (e.key === "Enter") {
                    e.preventDefault();   // stop the WebForms page from posting back
                    var q = input.value.trim();
                    window.location.href = "Courses.aspx" + (q ? "?q=" + encodeURIComponent(q) : "");
                } else if (e.key === "ArrowDown") {
                    var list = items();
                    if (list.length) { e.preventDefault(); list[0].focus(); }
                } else if (e.key === "Escape") {
                    closePanel();
                    input.blur();
                }
            });

            panel.addEventListener("keydown", function (e) {
                var list = items(), idx = list.indexOf(document.activeElement);
                if (e.key === "ArrowDown") { e.preventDefault(); if (idx < list.length - 1) list[idx + 1].focus(); }
                else if (e.key === "ArrowUp") { e.preventDefault(); if (idx > 0) list[idx - 1].focus(); else input.focus(); }
                else if (e.key === "Escape") { closePanel(); input.focus(); }
            });

            panel.addEventListener("click", function (e) {
                if (e.target.closest && e.target.closest("[data-preview-id]")) closePanel();
            });

            document.addEventListener("click", function (e) {
                if (!e.target.closest || !e.target.closest(".gs")) closePanel();
            });

            // Press "/" anywhere to jump to the search box
            document.addEventListener("keydown", function (e) {
                if (e.key !== "/" || e.ctrlKey || e.metaKey || e.altKey) return;
                var t = e.target, tag = t && t.tagName ? t.tagName.toLowerCase() : "";
                if (tag === "input" || tag === "textarea" || tag === "select" || (t && t.isContentEditable)) return;
                e.preventDefault();
                input.focus();
            });
        })();
        </script>

        <section class="section" id="access">
            <div class="shell">
                <div class="section-head reveal">
                    <p class="eyebrow">03. Guests and members</p>
                    <h2 class="h2">Nothing is locked.</h2>
                    <p class="lead">An account keeps your progress. That is the whole difference.</p>
                </div>
                <div class="grid grid-split">
                    <div class="table-wrap reveal">
                        <table class="compare">
                            <caption class="sr-only">Comparison of guest and registered member access</caption>
                            <thead>
                                <tr>
                                    <th scope="col">What you get</th>
                                    <th scope="col">Guest</th>
                                    <th scope="col">Registered</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <th scope="row">Open every resource</th>
                                    <td class="yes">Yes</td>
                                    <td class="yes">Yes</td>
                                </tr>
                                <tr>
                                    <th scope="row">Run labs and simulations</th>
                                    <td class="yes">Yes</td>
                                    <td class="yes">Yes</td>
                                </tr>
                                <tr>
                                    <th scope="row">Read the threads</th>
                                    <td class="yes">Yes</td>
                                    <td class="yes">Yes</td>
                                </tr>
                                <tr>
                                    <th scope="row">Post and reply</th>
                                    <td class="no">Read only</td>
                                    <td class="yes">Yes</td>
                                </tr>
                                <tr>
                                    <th scope="row">Saved budgets and lab runs</th>
                                    <td class="no">No</td>
                                    <td class="yes">Yes</td>
                                </tr>
                                <tr>
                                    <th scope="row">Progress across devices</th>
                                    <td class="no">No</td>
                                    <td class="yes">Yes</td>
                                </tr>
                                <tr>
                                    <th scope="row">Live room seat</th>
                                    <td class="no">Waitlist</td>
                                    <td class="yes">Priority</td>
                                </tr>
                            </tbody>
                        </table>
                        <p class="rate-note">Figures and comparisons are illustrative.</p>
                    </div>
                    <figure class="figure reveal">
                        <img src="assets/img/cat-reading.webp"
                            alt="The Meowlet cat reading a book and thinking about a stack of coins" />
                        <figcaption>Guest or member, the lesson is the same.</figcaption>
                    </figure>
                </div>
            </div>
        </section>

        <section class="section" id="team">
            <div class="shell">
                <div class="section-head reveal">
                    <p class="eyebrow">04. Developers</p>
                    <h2 class="h2">Meet the Developers</h2>
                    <p class="lead">The team behind Meowlet Educations.</p>
                </div>
                <div class="grid grid-4">
                    <article class="dev-card reveal">
                        <span class="dev-card__pfp"><img src="assets/img/Ian.png" alt="Ian Chin" /></span>
                        <h3 class="dev-card__name">Ian Chin</h3>
                        <div class="dev-card__links">
                            <a class="btn btn--ghost btn--sm" href="https://www.linkedin.com/in/ian-chin-jun-sheng-721364270/" aria-label="Ian Chin on LinkedIn">
                                <i class="bi bi-linkedin" aria-hidden="true"></i> LinkedIn
                            </a>
                            <a class="btn btn--ghost btn--sm" href="https://github.com/Ian-Chin" aria-label="Ian Chin on GitHub">
                                <i class="bi bi-github" aria-hidden="true"></i> GitHub
                            </a>
                        </div>
                    </article>
                    <article class="dev-card reveal">
                        <span class="dev-card__pfp"><img src="assets/img/Isac.jpg" alt="Isac Lim" /></span>
                        <h3 class="dev-card__name">Isac Lim</h3>
                        <div class="dev-card__links">
                            <a class="btn btn--ghost btn--sm" href="https://www.linkedin.com/in/isac-lim-9050b6341/" aria-label="Isac Lim on LinkedIn">
                                <i class="bi bi-linkedin" aria-hidden="true"></i> LinkedIn
                            </a>
                            <a class="btn btn--ghost btn--sm" href="https://github.com/Jellyfish0412" aria-label="Isac Lim on GitHub">
                                <i class="bi bi-github" aria-hidden="true"></i> GitHub
                            </a>
                        </div>
                    </article>
                    <article class="dev-card reveal">
                        <span class="dev-card__pfp"><img src="assets/img/Yw.png" alt="Yong Han" /></span>
                        <h3 class="dev-card__name">Yong Han</h3>
                        <div class="dev-card__links">
                            <a class="btn btn--ghost btn--sm" href="#" aria-label="Yong Han on LinkedIn">
                                <i class="bi bi-linkedin" aria-hidden="true"></i> LinkedIn
                            </a>
                            <a class="btn btn--ghost btn--sm" href="#" aria-label="Yong Han on GitHub">
                                <i class="bi bi-github" aria-hidden="true"></i> GitHub
                            </a>
                        </div>
                    </article>
                    <article class="dev-card reveal">
                        <span class="dev-card__pfp"><img src="assets/img/Yw.png" alt="Ye Wen" /></span>
                        <h3 class="dev-card__name">Ye Wen</h3>
                        <div class="dev-card__links">
                            <a class="btn btn--ghost btn--sm" href="#" aria-label="Ye Wen on LinkedIn">
                                <i class="bi bi-linkedin" aria-hidden="true"></i> LinkedIn
                            </a>
                            <a class="btn btn--ghost btn--sm" href="#" aria-label="Ye Wen on GitHub">
                                <i class="bi bi-github" aria-hidden="true"></i> GitHub
                            </a>
                        </div>
                    </article>
                </div>
            </div>
        </section>

        <section class="section finale">
            <div class="shell finale__inner reveal">
                <p class="eyebrow">Ready when you are</p>
                <h2 class="h2">Pick one lesson. Finish it tonight.</h2>
                <p class="lead">Twenty minutes is enough to finish something.</p>
                <div class="stack finale__actions">
                    <a class="btn btn--primary" href="Signup.aspx" data-auth-cta>Create a free account</a>
                    <a class="btn btn--ghost" href="#courses">Browse as a guest</a>
                </div>
            </div>
            <img class="finale__cat" src="assets/img/cat-reach.webp"
                alt="The Meowlet cat reaching up for a coin above its paws" />
        </section>
    </main>

    <footer class="footer">
        <div class="shell">
            <div class="footer__grid">
                <div class="footer__brand">
                    <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Educations" />
                    <p style="max-width:34ch;font-size:.92rem">Money skills, taught by doing. Open to everyone, kept for members.</p>
                </div>
                <div>
                    <h4>Learn</h4>
                    <a href="Courses.aspx">Catalog</a><br />
                    <a href="#learn">Virtual labs</a><br />
                    <a href="#learn">Simulations</a><br />
                    <a href="#learn">Self-assessments</a>
                </div>
                <div>
                    <h4>Community</h4>
                    <a href="#learn">Discussion boards</a><br />
                    <a href="#learn">Live rooms</a><br />
                    <a href="#team">Developers</a><br />
                    <a href="#access">Guest access</a>
                </div>
                <div>
                    <h4>Account</h4>
                    <span data-auth="guest"><a href="Signin.aspx">Log in</a><br />
                    <a href="Signup.aspx">Register</a><br /></span>
                    <span data-auth="user" hidden><a href="#" data-auth-link="dashboard">My dashboard</a><br /></span>
                    <a href="#access">What you get</a><br />
                    <a href="#learn">Ways to learn</a>
                </div>
            </div>
            <div class="footer__bottom">
                <span>© 2026 Meowlet Educations. Educational content only, not financial advice.</span>
                <span>Ian, Isac, YongHan, YeWen</span>
            </div>
        </div>
    </footer>
    </form>

    <script src="assets/js/site.js"></script>
</body>
</html>
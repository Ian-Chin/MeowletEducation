<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="MeowletEducation.CourseCatalog" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Browse the full Meowlet Educations course catalog. Search by topic, filter by category and level, and preview any course outline for free." />
    <meta name="author" content="Meowlet Educations" />
    <meta name="theme-color" content="#f7f7f5" />
    <title>Course catalog | Meowlet Educations</title>

    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="apple-touch-icon" href="assets/img/apple-touch-icon.png" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="assets/css/style.css" />
    <style>
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

        /* Catalog page */
        .cat-toolbar { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-top: 24px; }
        .cat-search { position: relative; flex: 1 1 280px; }
        .cat-search > i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--ink-mute); pointer-events: none; }
        .cat-search input,
        .cat-select {
            height: 42px;
            border: 1px solid var(--line);
            border-radius: 99px;
            background: var(--paper);
            color: var(--ink);
            font: inherit;
            font-size: .92rem;
        }
        .cat-search input { width: 100%; padding: 0 16px 0 38px; }
        .cat-select { padding: 0 14px; }
        .cat-search input:focus, .cat-select:focus { outline: 2px solid var(--ink, #222); outline-offset: 1px; }
        .cat-count { margin: 18px 0 0; font-size: .88rem; color: var(--ink-mute); }
        .cat-empty { margin-top: 28px; text-align: center; color: var(--ink-mute); }
        .cat-empty[hidden] { display: none; }
        .course-grid.course-grid--catalog { grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); margin-top: 18px; }

        .course-more { margin-top: 28px; text-align: center; }
        .course-more p { margin: 0 0 12px; color: var(--ink-mute); font-size: .95rem; }
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

        @media (max-width: 760px) {
            .header__inner { flex-wrap: wrap; }
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
                <a href="index.aspx">Home</a>
                <a href="Courses.aspx" aria-current="page">Courses</a>
            </nav>
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
        <section class="section">
            <div class="shell">
                <div class="section-head reveal">
                    <p class="eyebrow">Course catalog</p>
                    <h1 class="h2">Browse all courses</h1>
                    <p class="lead">Search by topic, filter by category or level, and preview any outline. Join free to start learning.</p>
                </div>

                <div class="cat-toolbar" role="search">
                    <div class="cat-search">
                        <i class="bi bi-search" aria-hidden="true"></i>
                        <input type="search" id="catQ" placeholder="Search courses, topics or tutors" autocomplete="off" aria-label="Search courses" />
                    </div>
                    <select id="catCategory" class="cat-select" aria-label="Filter by category">
                        <option value="">All categories</option>
                    </select>
                    <select id="catLevel" class="cat-select" aria-label="Filter by level">
                        <option value="">All levels</option>
                    </select>
                </div>
                <p class="cat-count" id="catCount" aria-live="polite"></p>

                <div class="course-grid course-grid--catalog">
                    <asp:Repeater ID="rptCourses" runat="server">
                        <ItemTemplate>
                            <article class="course-card reveal"
                                     data-search='<%# SearchText(Container.DataItem) %>'
                                     data-category='<%# Html(Eval("Category")) %>'
                                     data-level='<%# Html(Eval("Level")) %>'>
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

                <div class="cat-empty" id="catNoMatch" hidden>
                    <p>No courses match your search.</p>
                    <button type="button" class="btn btn--ghost btn--sm" id="catReset">Clear filters</button>
                </div>

                <div class="course-more reveal">
                    <p>Create a free account to save your progress.</p>
                    <a class="btn btn--primary" href="Signup.aspx">Join free</a>
                    <a class="btn btn--ghost" href="Signin.aspx">Log in</a>
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
        <script src="assets/js/ar/courses.js"></script>
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
                    <a href="index.aspx#learn">Virtual labs</a><br />
                    <a href="index.aspx#learn">Simulations</a><br />
                    <a href="index.aspx#learn">Self-assessments</a>
                </div>
                <div>
                    <h4>Community</h4>
                    <a href="index.aspx#learn">Discussion boards</a><br />
                    <a href="index.aspx#learn">Live rooms</a><br />
                    <a href="index.aspx#team">Developers</a><br />
                    <a href="index.aspx#access">Guest access</a>
                </div>
                <div>
                    <h4>Account</h4>
                    <span data-auth="guest"><a href="Signin.aspx">Log in</a><br />
                    <a href="Signup.aspx">Register</a><br /></span>
                    <span data-auth="user" hidden><a href="#" data-auth-link="dashboard">My dashboard</a><br /></span>
                    <a href="index.aspx#access">What you get</a><br />
                    <a href="index.aspx#learn">Ways to learn</a>
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
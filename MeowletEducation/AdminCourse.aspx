<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCourse.aspx.cs" Inherits="MeowletEducation.AdminCourse" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex" />
    <title>Course builder - Meowlet Education</title>
    <link rel="icon" href="favicon.ico" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
    <link rel="stylesheet" href="assets/css/style.css" />
    <link rel="stylesheet" href="assets/css/admin-theme.css" />
    <link rel="stylesheet" href="assets/css/admin-shell.css" />
    <link rel="stylesheet" href="assets/css/course-builder.css" />
    <script type="text/javascript">
        // @ts-nocheck
        // Same theme choice as the admin dashboard.
        (function () {
            var theme = 'dark';
            try { theme = localStorage.getItem('meowletAdminTheme') || 'dark'; } catch (e) { }
            document.documentElement.setAttribute('data-theme', theme === 'light' ? 'light' : 'dark');
        })();
    </script>
</head>
<body class="cb" data-course-id="<asp:Literal ID="litCourseId" runat="server" />">
    <div class="ad-shell" id="adminShell">
        <script type="text/javascript">
            // @ts-nocheck
            // same collapsed / expanded sidebar as the dashboard, before first paint
            try {
                if (localStorage.getItem('meowletAdminSidebar') === 'collapsed') {
                    document.getElementById('adminShell').className += ' is-collapsed';
                }
            } catch (e) { }
        </script>

        <!-- Same sidebar as the admin dashboard; its items link back to the dashboard panes. -->
        <aside class="ad-side">
            <a class="ad-side__brand" href="index.html" title="Open the public site">
                <img class="ad-side__logo ad-side__logo--light" src="assets/img/meowlet-logo.png" alt="Meowlet Education" />
                <img class="ad-side__logo ad-side__logo--dark" src="assets/img/meowlet-logo-dark.png" alt="Meowlet Education" />
                <img class="ad-side__mark" src="assets/img/meowlet-mark.png" alt="Meowlet Education" />
            </a>

            <nav aria-label="Admin sections">
                <p class="ad-side__group">Overview</p>
                <a class="ad-nav" href="admindashboard.aspx#overview">
                    <i class="bi bi-grid-1x2" aria-hidden="true"></i><span>Dashboard</span>
                </a>

                <p class="ad-side__group">Manage</p>
                <a class="ad-nav" href="admindashboard.aspx#users">
                    <i class="bi bi-people" aria-hidden="true"></i><span>Users</span>
                </a>
                <a class="ad-nav is-active" href="admindashboard.aspx#courses" aria-current="page">
                    <i class="bi bi-book" aria-hidden="true"></i><span>Courses</span>
                </a>
                <a class="ad-nav" href="admindashboard.aspx#enrollments">
                    <i class="bi bi-journal-check" aria-hidden="true"></i><span>Enrollments</span>
                </a>
                <a class="ad-nav" href="admindashboard.aspx#feedback">
                    <i class="bi bi-chat-square-text" aria-hidden="true"></i><span>Reviews</span>
                </a>

                <p class="ad-side__group">System</p>
                <a class="ad-nav" href="admindashboard.aspx#settings">
                    <i class="bi bi-gear" aria-hidden="true"></i><span>Settings</span>
                </a>
            </nav>

            <div class="ad-side__foot">
                <button type="button" class="ad-nav ad-collapse" id="sidebarToggle" aria-pressed="false">
                    <i class="bi bi-chevron-double-left" aria-hidden="true"></i><span>Collapse</span>
                </button>
            </div>
        </aside>

        <main class="ad-main cb-page">
            <header class="cb-top">
                <a class="cb-back" href="admindashboard.aspx#courses"><i class="bi bi-arrow-left" aria-hidden="true"></i>Courses</a>
                <div class="cb-top__course">
                    <asp:Literal ID="litCover" runat="server" />
                    <div>
                        <p class="cb-top__code"><asp:Literal ID="litCode" runat="server" /></p>
                        <h1 class="cb-top__title"><asp:Literal ID="litTitle" runat="server" /></h1>
                    </div>
                    <asp:Literal ID="litStatus" runat="server" />
                </div>
                <p class="cb-save" id="saveStatus" role="status" aria-live="polite"></p>
                <asp:HyperLink ID="lnkPreview" runat="server" CssClass="btn btn--ghost btn--sm cb-preview" Target="_blank"
                    ToolTip="Opens the course the way students see it"><i class="bi bi-display" aria-hidden="true"></i>&nbsp;Preview as a student</asp:HyperLink>
            </header>

            <div class="cb-layout">
                <aside class="cb-side" aria-labelledby="chaptersHeading">
                    <div class="cb-side__head">
                        <h2 id="chaptersHeading">Chapters</h2>
                        <span class="cb-count" id="chapterCount">0</span>
                    </div>
                    <p class="cb-hint">Drag to reorder. Drop content on a chapter to move it there.</p>
                    <ol class="cb-chapters" id="chapterList"></ol>
                    <button type="button" class="btn btn--primary btn--sm cb-add-chapter" id="addChapter">
                        <i class="bi bi-plus-lg" aria-hidden="true"></i>Add chapter
                    </button>
                </aside>

                <section class="cb-main" id="chapterEditor" aria-live="polite">
                    <p class="cb-loading">Loading the course...</p>
                </section>
            </div>
        </main>
    </div>

    <!-- Add chapter: name it, then pick what it starts with. -->
    <dialog class="cb-dialog" id="chapterDialog" aria-labelledby="chapterDialogTitle">
        <form method="dialog" class="cb-dialog__form" id="chapterDialogForm">
            <div class="cb-dialog__head">
                <h2 id="chapterDialogTitle">Add a chapter</h2>
                <button type="button" class="cb-icon" id="chapterDialogClose" aria-label="Close"><i class="bi bi-x-lg" aria-hidden="true"></i></button>
            </div>

            <div class="cb-dialog__body">
                <label class="cb-dialog__label" for="newChapterTitle">Chapter title</label>
                <input class="ad-input" id="newChapterTitle" type="text" maxlength="200" placeholder="e.g. Your first savings goal" autocomplete="off" />

                <p class="cb-dialog__label" id="startWithLabel">Start it with</p>
                <div class="cb-starts" role="group" aria-labelledby="startWithLabel">
                    <button type="button" class="cb-start" data-start="Text">
                        <i class="bi bi-text-paragraph" aria-hidden="true"></i>
                        <strong>Content</strong>
                        <span>Write the lesson text.</span>
                    </button>
                    <button type="button" class="cb-start" data-start="Media">
                        <i class="bi bi-image" aria-hidden="true"></i>
                        <strong>Media</strong>
                        <span>A picture or video, by link or upload.</span>
                    </button>
                    <button type="button" class="cb-start" data-start="Quiz">
                        <i class="bi bi-patch-question" aria-hidden="true"></i>
                        <strong>Quiz</strong>
                        <span>Questions with one right answer.</span>
                    </button>
                    <button type="button" class="cb-start cb-start--ai" id="startWhiskerAI" aria-describedby="whiskerSoon">
                        <img src="assets/img/meowlet-mark.png" alt="" class="cb-start__mark" />
                        <strong>Create with WhiskerAI</strong>
                        <span>Draft the whole chapter for you.</span>
                        <em class="cb-soon" id="whiskerSoon">Coming soon</em>
                    </button>
                </div>
            </div>

            <div class="cb-dialog__foot">
                <button type="button" class="cb-link" id="startEmpty">Add an empty chapter instead</button>
            </div>
        </form>
    </dialog>

    <script src="assets/js/course-builder.js"></script>
</body>
</html>

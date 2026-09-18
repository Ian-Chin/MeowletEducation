<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Onboarding.aspx.cs" Inherits="MeowletEducation.Onboarding" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#fdfaf4" />
    <title>Get started · Meowlet Educations</title>
    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="stylesheet" href="assets/css/style.css" />
    <style>
        html, body { height: 100%; margin: 0; }
        body {
            background: #fdfaf4;
            overflow: hidden;
        }

        .auth-header {
            flex-shrink: 0;
            display: flex;
            align-items: center;
            padding: 12px 0;
            background: #fdfaf4;
            border-bottom: 1px solid rgba(36, 29, 21, 0.08);
        }
        .auth-header__inner {
            width: 100%;
            padding: 0 16px 0 80px;
            display: flex;
            align-items: center;
        }
        .auth-header .brand img {
            height: 42px;
            width: auto;
            max-width: 220px;
            object-fit: contain;
            display: block;
        }

        /* ---------- Wizard shell ---------- */
        .ob-main {
            height: calc(100vh - 66px);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 24px 16px;
            box-sizing: border-box;
            gap: 20px;
        }

        .ob-progress-wrap {
            width: 560px;
            max-width: 100%;
        }
        .ob-progress-track {
            width: 100%;
            height: 8px;
            background: rgba(36, 29, 21, 0.08);
            border-radius: 99px;
            overflow: hidden;
        }
        .ob-progress-fill {
            height: 100%;
            width: 20%;
            background: var(--accent, #b9703c);
            border-radius: 99px;
            transition: width 0.4s ease;
        }

        .ob-card {
            width: 560px;
            max-width: 100%;
            background: #fffefb;
            border: 1px solid rgba(36, 29, 21, 0.1);
            border-radius: 16px;
            padding: 28px 32px 24px;
            box-shadow: 0 10px 32px -18px rgba(36, 29, 21, 0.22);
            box-sizing: border-box;
            position: relative;
            min-height: 320px;
        }

        .ob-step {
            display: none;
            flex-direction: column;
            opacity: 0;
            transform: translateX(24px);
            transition: opacity 0.28s ease, transform 0.28s ease;
        }
        .ob-step.is-active {
            display: flex;
        }
        .ob-step.is-active.is-shown {
            opacity: 1;
            transform: translateX(0);
        }
        .ob-step.is-leaving {
            opacity: 0;
            transform: translateX(-24px);
        }

        .ob-step h1 {
            margin: 0 0 6px;
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--ink, #241d15);
            text-align: center;
        }
        .ob-step p.ob-sub {
            margin: 0 0 22px;
            font-size: 0.88rem;
            color: var(--ink-mute, #6d6053);
            text-align: center;
            line-height: 1.5;
        }

        /* ---------- Chips (multi-select, question 1) ---------- */
        .ob-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            justify-content: center;
            margin-bottom: 8px;
        }
        .ob-chip {
            padding: 10px 18px;
            border-radius: 99px;
            font: inherit;
            font-size: 0.9rem;
            font-weight: 600;
            border: 1.5px solid rgba(36, 29, 21, 0.18);
            background: #fdfaf4;
            color: var(--ink, #241d15);
            cursor: pointer;
            transition: transform 0.15s ease, background 0.15s ease, border-color 0.15s ease, color 0.15s ease;
        }
        .ob-chip:hover {
            border-color: var(--accent, #b9703c);
        }
        .ob-chip.is-selected {
            background: var(--accent-soft, #f6e3d1);
            border-color: var(--accent, #b9703c);
            color: var(--accent, #b9703c);
            animation: obPop 0.25s ease;
        }

        /* ---------- Single-choice options (questions 2-5) ---------- */
        .ob-options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 8px;
        }
        .ob-option {
            padding: 14px 16px;
            border-radius: 12px;
            border: 1.5px solid rgba(36, 29, 21, 0.14);
            background: #fdfaf4;
            color: var(--ink, #241d15);
            font: inherit;
            font-size: 0.92rem;
            font-weight: 600;
            text-align: left;
            cursor: pointer;
            transition: transform 0.15s ease, background 0.15s ease, border-color 0.15s ease, color 0.15s ease;
        }
        .ob-option:hover {
            border-color: var(--accent, #b9703c);
        }
        .ob-option.is-selected {
            background: var(--accent-soft, #f6e3d1);
            border-color: var(--accent, #b9703c);
            color: var(--accent, #b9703c);
            animation: obPop 0.25s ease;
        }

        @keyframes obPop {
            0%   { transform: scale(1); }
            45%  { transform: scale(1.06); }
            100% { transform: scale(1); }
        }

        /* ---------- Footer buttons ---------- */
        .ob-footer {
            margin-top: auto;
            padding-top: 18px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .ob-nav-row {
            display: flex;
            gap: 10px;
        }
        .ob-btn {
            flex: 1;
            padding: 12px 16px;
            border-radius: 10px;
            border: none;
            font: inherit;
            font-size: 0.95rem;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: opacity 0.15s ease, transform 0.1s ease;
        }
        .ob-btn:active { transform: scale(0.98); }
        .ob-btn--primary {
            background: var(--accent, #b9703c);
            color: #fff;
        }
        .ob-btn--primary:disabled {
            background: rgba(36, 29, 21, 0.12);
            color: rgba(36, 29, 21, 0.35);
            cursor: not-allowed;
        }
        .ob-btn--ghost {
            background: transparent;
            color: var(--ink-mute, #6d6053);
            border: 1.5px solid rgba(36, 29, 21, 0.14);
            flex: 0 0 110px;
        }
        .ob-skip {
            background: none;
            border: none;
            color: var(--ink-faint, #9c8d79);
            font: inherit;
            font-size: 0.82rem;
            text-decoration: underline;
            cursor: pointer;
            align-self: center;
        }

        .ob-spinner {
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255,255,255,0.4);
            border-top-color: #fff;
            border-radius: 50%;
            animation: obSpin 0.7s linear infinite;
            display: none;
        }
        .ob-btn--loading .ob-spinner { display: inline-block; }
        .ob-btn--loading .ob-btn-label { opacity: 0.85; }
        @keyframes obSpin { to { transform: rotate(360deg); } }

        .msg {
            padding: 8px 10px;
            border-radius: 8px;
            font-size: 0.82rem;
            margin-bottom: 10px;
        }
        .msg--error { background: #fde8e6; color: #8a1f11; }
        .msg--ok { background: #e8f5e6; color: #2d5a27; }

        /* ---------- Celebration overlay ---------- */
        .ob-confetti-piece {
            position: fixed;
            top: -10px;
            width: 8px;
            height: 14px;
            opacity: 0.9;
            border-radius: 2px;
            pointer-events: none;
            animation: obFall linear forwards;
            z-index: 999;
        }
        @keyframes obFall {
            to { transform: translateY(110vh) rotate(540deg); opacity: 0.6; }
        }
        .ob-celebrate-check {
            position: fixed;
            inset: 0;
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            background: rgba(253, 250, 244, 0.55);
        }
        .ob-celebrate-check.is-active { display: flex; }
        .ob-celebrate-check__circle {
            width: 84px;
            height: 84px;
            border-radius: 50%;
            background: var(--accent, #b9703c);
            display: flex;
            align-items: center;
            justify-content: center;
            transform: scale(0.6);
            animation: obCheckPop 0.4s cubic-bezier(.34,1.56,.64,1) forwards;
        }
        .ob-celebrate-check__circle svg { width: 40px; height: 40px; }
        @keyframes obCheckPop {
            to { transform: scale(1); }
        }

        /* ---------- Mobile ---------- */
        @media (max-width: 860px) {
            body { overflow: auto; }
            .ob-main {
                height: auto;
                min-height: calc(100vh - 66px);
                padding: 20px 16px 32px;
            }
            .ob-card { padding: 22px 18px 18px; min-height: 0; }
            .ob-options { grid-template-columns: 1fr; }
            .ob-nav-row { flex-direction: column-reverse; }
            .ob-btn--ghost { flex: 1; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="auth-header">
            <div class="auth-header__inner">
                <a class="brand" href="index.html" aria-label="Meowlet Educations home">
                    <img src="assets/img/meowlet-logo.png" alt="Meowlet Educations" />
                </a>
            </div>
        </header>

        <div class="ob-main">
            <div class="ob-progress-wrap">
                <div class="ob-progress-track">
                    <div class="ob-progress-fill" id="obProgressFill"></div>
                </div>
            </div>

            <div class="ob-card">
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="msg">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <!-- Step 1: tags (multi-select chips) -->
                <div class="ob-step" data-step="0">
                    <h1 id="obQ1Title">What do you want to learn?</h1>
                    <p class="ob-sub" id="obQ1Sub">Pick the topics you're interested in. We'll recommend courses based on this.</p>
                    <div class="ob-chips" id="obChips"></div>
                    <div class="ob-footer">
                        <div class="ob-nav-row">
                            <button type="button" class="ob-btn ob-btn--primary" id="obNext0" disabled>
                                <span class="ob-btn-label">Next</span>
                            </button>
                        </div>
                        <button type="button" class="ob-skip" id="obSkipTop">Skip for now</button>
                    </div>
                </div>

                <!-- Steps 2-5: single choice, rendered by JS from QUESTIONS -->
                <div class="ob-step" data-step="1"></div>
                <div class="ob-step" data-step="2"></div>
                <div class="ob-step" data-step="3"></div>
                <div class="ob-step" data-step="4"></div>
            </div>
        </div>

        <asp:HiddenField ID="hidAnswersJson" runat="server" />
        <asp:Button ID="btnFinish" runat="server" Text="Finish" OnClick="btnFinish_Click" style="display:none" />
        <asp:Button ID="btnSkip" runat="server" Text="Skip" OnClick="btnSkip_Click" style="display:none" />
    </form>

    <div class="ob-celebrate-check" id="obCelebrate">
        <div class="ob-celebrate-check__circle">
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
        </div>
    </div>

    <script>
        // TAGS, QUESTIONS, Q1_TITLE, Q1_SUB are injected server-side by
        // Onboarding.aspx.cs (Page_Load -> RenderInitData) via RegisterStartupScript,
        // based on Session["Role"] and the real Tags table. No hardcoding here.

        var TOTAL_STEPS = 1 + QUESTIONS.length;
        var currentStep = 0;
        var selectedTags = {};
        var answers = {};

        var stepEls = Array.prototype.slice.call(document.querySelectorAll(".ob-step"));
        var progressFill = document.getElementById("obProgressFill");
        var chipsContainer = document.getElementById("obChips");
        var next0Btn = document.getElementById("obNext0");

        document.getElementById("obQ1Title").textContent = Q1_TITLE;
        document.getElementById("obQ1Sub").textContent = Q1_SUB;

        function renderChips() {
            chipsContainer.innerHTML = "";
            TAGS.forEach(function (tag) {
                var btn = document.createElement("button");
                btn.type = "button";
                btn.className = "ob-chip";
                btn.textContent = tag.label;
                btn.dataset.key = tag.key;
                if (selectedTags[tag.key]) btn.classList.add("is-selected");
                btn.addEventListener("click", function () {
                    if (selectedTags[tag.key]) {
                        delete selectedTags[tag.key];
                    } else {
                        selectedTags[tag.key] = true;
                    }
                    renderChips();
                    next0Btn.disabled = Object.keys(selectedTags).length === 0;
                });
                chipsContainer.appendChild(btn);
            });
        }

        function buildQuestionStep(stepIndex) {
            var q = QUESTIONS[stepIndex - 1];
            var el = stepEls[stepIndex];
            if (el.dataset.built === "1") return;
            el.dataset.built = "1";

            var isLast = stepIndex === TOTAL_STEPS - 1;

            el.innerHTML =
                '<h1>' + q.title + '</h1>' +
                '<p class="ob-sub">' + q.sub + '</p>' +
                '<div class="ob-options"></div>' +
                '<div class="ob-footer">' +
                    '<div class="ob-nav-row">' +
                        '<button type="button" class="ob-btn ob-btn--ghost" data-action="back">Back</button>' +
                        '<button type="button" class="ob-btn ob-btn--primary" data-action="next" disabled>' +
                            '<span class="ob-spinner"></span>' +
                            '<span class="ob-btn-label">' + (isLast ? "Finish" : "Next") + '</span>' +
                        '</button>' +
                    '</div>' +
                    '<button type="button" class="ob-skip" data-action="skip">Skip for now</button>' +
                '</div>';

            var optionsWrap = el.querySelector(".ob-options");
            var nextBtn = el.querySelector('[data-action="next"]');

            q.options.forEach(function (opt) {
                var btn = document.createElement("button");
                btn.type = "button";
                btn.className = "ob-option";
                btn.textContent = opt.label;
                btn.dataset.value = opt.value;
                btn.addEventListener("click", function () {
                    answers[q.key] = opt.value;
                    Array.prototype.forEach.call(optionsWrap.children, function (c) {
                        c.classList.toggle("is-selected", c === btn);
                    });
                    nextBtn.disabled = false;
                });
                optionsWrap.appendChild(btn);
            });

            el.querySelector('[data-action="back"]').addEventListener("click", function () {
                goToStep(stepIndex - 1, -1);
            });
            el.querySelector('[data-action="skip"]').addEventListener("click", handleSkip);
            nextBtn.addEventListener("click", function () {
                if (isLast) {
                    handleFinish();
                } else {
                    goToStep(stepIndex + 1, 1);
                }
            });
        }

        function goToStep(targetIndex, direction) {
            var current = stepEls[currentStep];
            current.classList.remove("is-shown");
            current.classList.add("is-leaving");

            setTimeout(function () {
                current.classList.remove("is-active", "is-leaving");
                currentStep = targetIndex;

                if (currentStep > 0) buildQuestionStep(currentStep);

                var next = stepEls[currentStep];
                next.classList.add("is-active");
                void next.offsetWidth;
                requestAnimationFrame(function () {
                    next.classList.add("is-shown");
                });

                progressFill.style.width = (((currentStep + 1) / TOTAL_STEPS) * 100) + "%";
            }, 220);
        }

        function handleSkip() {
            var btnSkip = document.getElementById("<%= btnSkip.ClientID %>");
            btnSkip.click();
        }

        function handleFinish() {
            var finishBtn = stepEls[currentStep].querySelector('[data-action="next"]');
            if (finishBtn) finishBtn.classList.add("ob-btn--loading");

            var payload = {
                tags: Object.keys(selectedTags),
                answers: answers
            };
            document.getElementById("<%= hidAnswersJson.ClientID %>").value = JSON.stringify(payload);

            playCelebration(function () {
                document.getElementById("<%= btnFinish.ClientID %>").click();
            });
        }

        function playCelebration(onDone) {
            var celebrate = document.getElementById("obCelebrate");
            celebrate.classList.add("is-active");

            var colors = ["#b9703c", "#f6e3d1", "#241d15", "#dba876"];
            for (var i = 0; i < 24; i++) {
                var piece = document.createElement("div");
                piece.className = "ob-confetti-piece";
                piece.style.left = (Math.random() * 100) + "vw";
                piece.style.background = colors[i % colors.length];
                piece.style.animationDuration = (0.9 + Math.random() * 0.6) + "s";
                piece.style.animationDelay = (Math.random() * 0.15) + "s";
                document.body.appendChild(piece);
                (function (p) {
                    setTimeout(function () { p.remove(); }, 2000);
                })(piece);
            }

            setTimeout(onDone, 900);
        }

        document.getElementById("obSkipTop").addEventListener("click", handleSkip);
        next0Btn.addEventListener("click", function () {
            if (Object.keys(selectedTags).length === 0) return;
            goToStep(1, 1);
        });

        // init
        renderChips();
        stepEls[0].classList.add("is-active");
        requestAnimationFrame(function () {
            stepEls[0].classList.add("is-shown");
        });
    </script>
</body>
</html>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="MeowletEducation.Signup" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#fdfaf4" />
    <title>Join free · Meowlet Educations</title>

    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="stylesheet" href="assets/css/style.css" />

    <style>
        .auth {
            min-height: calc(100vh - 72px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px 60px;
        }
        .auth__card {
            width: 100%;
            max-width: 440px;
            background: var(--paper);
            border: 1px solid var(--line);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow);
            padding: 36px 32px 32px;
        }
        .auth__logo { width: 140px; margin: 0 auto 20px; display: block; }
        .auth__title {
            margin: 0 0 6px;
            font-size: 1.55rem;
            color: var(--ink);
            text-align: center;
        }
        .auth__sub {
            margin: 0 0 28px;
            font-size: .95rem;
            color: var(--ink-mute);
            text-align: center;
        }
        .auth__form { display: flex; flex-direction: column; gap: 16px; }
        .auth__form .btn {
            width: 100%;
            justify-content: center;
            margin-top: 8px;
            cursor: pointer;
        }
        .auth__footer {
            margin-top: 22px;
            text-align: center;
            font-size: .9rem;
            color: var(--ink-mute);
        }
        .auth__footer a { color: var(--accent); font-weight: 600; }
        .field-error { font-size: .8rem; color: #b33a2b; display: block; }
        .auth__hint { margin-top: -8px; font-size: .78rem; color: var(--ink-faint); }
        .msg {
            padding: 10px 12px;
            border-radius: 8px;
            font-size: .9rem;
            margin-bottom: 12px;
        }
        .msg--error { background: #fde8e6; color: #8a1f11; }
        .msg--ok { background: #e8f5e6; color: #2d5a27; }
        .field input[type="text"],
        .field input[type="email"],
        .field input[type="password"] {
            font: inherit;
            padding: 12px 14px;
            border: 1px solid var(--line-strong);
            border-radius: var(--radius-btn);
            background: var(--paper);
            color: var(--ink);
            width: 100%;
        }

        /* Student / Tutor 滑动切换 */
        .role-toggle {
            position: relative;
            display: grid;
            grid-template-columns: 1fr 1fr;
            background: var(--beige);
            border: 1px solid var(--line-strong);
            border-radius: var(--pill);
            padding: 4px;
        }
        .role-toggle__btn {
            position: relative;
            z-index: 2;
            border: 0;
            background: transparent;
            padding: 10px 12px;
            font: inherit;
            font-size: .92rem;
            font-weight: 600;
            color: var(--ink-mute);
            cursor: pointer;
            border-radius: var(--pill);
            transition: color .25s ease;
        }
        .role-toggle__btn.is-active { color: var(--paper); }
        .role-toggle__slider {
            position: absolute;
            z-index: 1;
            top: 4px;
            left: 4px;
            width: calc(50% - 4px);
            height: calc(100% - 8px);
            background: var(--ink);
            border-radius: var(--pill);
            box-shadow: var(--shadow-sm);
            transition: transform .28s cubic-bezier(.16, 1, .3, 1);
        }
        .role-toggle.is-tutor .role-toggle__slider {
            transform: translateX(100%);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="header">
            <div class="shell header__inner">
                <a class="brand" href="index.html">
                    <img src="assets/img/meowlet-logo.png" alt="Meowlet Educations" />
                </a>
                <div class="nav__actions">
                    <a class="btn btn--ghost btn--sm" href="Signin.aspx">Log in</a>
                    <a class="btn btn--primary btn--sm" href="Signup.aspx">Join free</a>
                </div>
            </div>
        </header>

        <main>
            <section class="auth">
                <div class="auth__card">
                    <img class="auth__logo" src="assets/img/meowlet-mark.png" alt="" />
                    <h1 class="auth__title">Create your account</h1>
                    <p class="auth__sub">Free to join. Start learning money skills today.</p>

                    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="msg">
                        <asp:Literal ID="litMessage" runat="server" />
                    </asp:Panel>

                    <div class="auth__form">
                        <div class="field">
                            <label>Full name</label>
                            <asp:TextBox ID="txtFullName" runat="server" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvName" runat="server"
                                ControlToValidate="txtFullName"
                                ErrorMessage="Please enter your name."
                                CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="field">
                            <label>Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ErrorMessage="Please enter your email."
                                CssClass="field-error" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                ErrorMessage="Please enter a valid email."
                                CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="field">
                            <label>Password</label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                                ControlToValidate="txtPassword"
                                ErrorMessage="Please enter a password."
                                CssClass="field-error" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revPassword" runat="server"
                                ControlToValidate="txtPassword"
                                ValidationExpression="^.{8,}$"
                                ErrorMessage="Password must be at least 8 characters."
                                CssClass="field-error" Display="Dynamic" />
                            <p class="auth__hint">Use 8+ characters.</p>
                        </div>

                        <div class="field">
                            <label>Confirm password</label>
                            <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" />
                            <asp:CompareValidator ID="cvConfirm" runat="server"
                                ControlToValidate="txtConfirm"
                                ControlToCompare="txtPassword"
                                ErrorMessage="Passwords do not match."
                                CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="field">
                            <label>I am a</label>
                            <div class="role-toggle" id="roleToggle" role="group" aria-label="Choose role">
                                <asp:HiddenField ID="hfRole" runat="server" Value="Student" />
                                <button type="button" class="role-toggle__btn is-active" data-role="Student" id="btnRoleStudent">Student</button>
                                <button type="button" class="role-toggle__btn" data-role="Tutor" id="btnRoleTutor">Tutor</button>
                                <span class="role-toggle__slider" aria-hidden="true"></span>
                            </div>
                        </div>

                        <asp:Button ID="btnSignup" runat="server"
                            Text="Create free account"
                            CssClass="btn btn--primary"
                            OnClick="btnSignup_Click" />
                    </div>

                    <p class="auth__footer">
                        Already have an account?
                        <a href="Login.aspx">Log in</a>
                    </p>
                </div>
            </section>
        </main>
    </form>

    <script>
        (function () {
            var root = document.getElementById("roleToggle");
            if (!root) return;

            var hf = document.getElementById("<%= hfRole.ClientID %>");
            var btnS = document.getElementById("btnRoleStudent");
            var btnT = document.getElementById("btnRoleTutor");

            function setRole(role) {
                if (hf) hf.value = role;
                root.classList.toggle("is-tutor", role === "Tutor");
                btnS.classList.toggle("is-active", role === "Student");
                btnT.classList.toggle("is-active", role === "Tutor");
            }

            btnS.addEventListener("click", function() { setRole("Student"); });
            btnT.addEventListener("click", function() { setRole("Tutor"); });
            setRole(hf && hf.value ? hf.value : "Student");
        })();
    </script>
</body>
</html>
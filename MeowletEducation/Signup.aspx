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
        :root {
            --auth-logo-inset: 80px;
        }

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
            box-shadow: none;
        }
        .auth-header__inner {
            width: 100%;
            max-width: none;
            margin: 0;
            padding: 0 16px 0 var(--auth-logo-inset);
            display: flex;
            align-items: center;
            justify-content: flex-start;
        }
        .auth-header .brand {
            display: inline-flex;
            align-items: center;
            line-height: 0;
        }
        .auth-header .brand img {
            height: 42px;
            width: auto;
            max-width: 220px;
            object-fit: contain;
            object-position: left center;
            display: block;
        }

        .auth-main {
            height: calc(100vh - 66px);
            display: grid;
            grid-template-columns: 1fr 1fr;
            min-height: 0;
            background: #fdfaf4;
        }

        .split__art {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 14px;
            padding: 28px 32px 20px;
            min-height: 0;
            overflow: hidden;
            text-align: center;
        }

        .split__art-copy {
            flex-shrink: 0;
            max-width: 440px;
        }

        .split__eyebrow {
            margin: 0 0 8px;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            color: var(--ink-faint, #9c8d79);
        }

        .split__welcome {
            margin: 0 0 10px;
            font-size: clamp(1.75rem, 3.2vw, 2.35rem);
            line-height: 1.2;
            font-weight: 700;
            color: var(--ink, #241d15);
            letter-spacing: -0.02em;
        }

        .split__welcome-sub {
            margin: 0;
            font-size: 1rem;
            line-height: 1.5;
            color: var(--ink-mute, #6d6053);
        }

        .split__art-visual {
            flex: 1 1 auto;
            min-height: 0;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .split__art-visual img {
            width: 100%;
            height: 100%;
            max-height: 100%;
            object-fit: contain;
            display: block;
        }

        .split__panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 16px 28px;
            min-height: 0;
            overflow: hidden;
            box-sizing: border-box;
        }

        .split__inner {
            width: 100%;
            max-width: 380px;
            background: #fffefb;
            border: 1px solid rgba(36, 29, 21, 0.1);
            border-radius: 16px;
            padding: 22px 24px 20px;
            box-shadow: 0 10px 32px -18px rgba(36, 29, 21, 0.22);
            box-sizing: border-box;
        }

        .split__title {
            margin: 0 0 4px;
            font-size: 1.28rem;
            line-height: 1.25;
            color: var(--ink, #241d15);
            font-weight: 700;
            text-align: center;
        }
        .split__sub {
            margin: 0 0 16px;
            font-size: 0.84rem;
            line-height: 1.4;
            color: var(--ink-mute, #6d6053);
            text-align: center;
        }

        .auth__form {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .auth__form .btn {
            width: 100%;
            justify-content: center;
            margin-top: 4px;
            cursor: pointer;
            min-height: 40px;
            font-size: 0.95rem;
        }

        .field label {
            display: block;
            margin-bottom: 4px;
            font-size: 0.72rem;
        }
        .field input[type="text"],
        .field input[type="email"],
        .field input[type="password"] {
            font: inherit;
            font-size: 0.92rem;
            padding: 9px 12px;
            border: 1px solid rgba(36, 29, 21, 0.18);
            border-radius: 8px;
            background: #fdfaf4;
            color: var(--ink, #241d15);
            width: 100%;
            box-sizing: border-box;
        }
        .field input:focus {
            outline: none;
            background: #fff;
            border-color: var(--accent, #b9703c);
            box-shadow: 0 0 0 3px var(--accent-soft, #f6e3d1);
        }
        .field-error {
            font-size: 0.75rem;
            color: #b33a2b;
            display: block;
            margin-top: 2px;
        }
        .auth__hint {
            margin: 3px 0 0;
            font-size: 0.72rem;
            color: var(--ink-faint, #9c8d79);
        }

        .msg {
            padding: 8px 10px;
            border-radius: 8px;
            font-size: 0.82rem;
            margin-bottom: 10px;
        }
        .msg--error { background: #fde8e6; color: #8a1f11; }
        .msg--ok { background: #e8f5e6; color: #2d5a27; }

        .split__links {
            margin-top: 14px;
            font-size: 0.82rem;
            color: var(--ink-mute, #6d6053);
            line-height: 1.55;
            text-align: center;
        }
        .split__links a {
            color: var(--accent, #b9703c);
            font-weight: 600;
        }

        @media (max-width: 860px) {
            body { overflow: auto; }
            .auth-main {
                grid-template-columns: 1fr;
                height: auto;
                min-height: calc(100vh - 66px);
            }
            .auth-header .brand img { height: 36px; }
            .split__art {
                padding: 16px 16px 0px;
                gap: 4px;
            }
            .split__welcome { font-size: 1.55rem; }
            .split__welcome-sub { font-size: 0.9rem; }
            .split__art-visual {
                min-height: 140px;
                max-height: 22vh;
            }
            .split__panel {
                padding: 12px 16px 28px;
                overflow: visible;
            }
            .split__inner { max-width: 100%; }
        }

        @media (max-height: 700px) and (min-width: 861px) {
            .split__panel { overflow-y: auto; }
            .split__inner { padding: 16px 20px; }
            .split__title { font-size: 1.15rem; }
            .auth__form { gap: 8px; }
            .split__welcome { font-size: 1.5rem; }
            .split__welcome-sub { font-size: 0.9rem; }
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

        <div class="auth-main">
            <div class="split__art">
                <div class="split__art-copy">
                    <p class="split__eyebrow">Meowlet Educations</p>
                    <h2 class="split__welcome">Welcome to our platform</h2>
                    <p class="split__welcome-sub">Learn money skills the simple way — budget, save, and grow with confidence.</p>
                </div>
                <div class="split__art-visual">
                    <img src="assets/img/LoginImage2.png" alt="" />
                </div>
            </div>

            <div class="split__panel">
                <div class="split__inner">
                    <h1 class="split__title">Create your account</h1>
                    <p class="split__sub">Student registration · free to join</p>

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
                        <asp:Button ID="btnSignup" runat="server"
                            Text="Create free account"
                            CssClass="btn btn--primary"
                            OnClick="btnSignup_Click" />
                    </div>

                    <div class="split__links">
                        <div>Already have an account? <a href="Signin.aspx">Log in</a></div>
                        <div>Are you a Tutor? <a href="SignupTutor.aspx">Register as Tutor</a></div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
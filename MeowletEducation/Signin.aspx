<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="MeowletEducation.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#fdfaf4" />
    <title>Log in · Meowlet Educations</title>

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
                    <a class="btn btn--ghost btn--sm" href="Login.aspx">Log in</a>
                    <a class="btn btn--primary btn--sm" href="Signup.aspx">Join free</a>
                </div>
            </div>
        </header>

        <main>
            <section class="auth">
                <div class="auth__card">
                    <img class="auth__logo" src="assets/img/meowlet-mark.png" alt="" />
                    <h1 class="auth__title">Welcome back</h1>
                    <p class="auth__sub">Log in to continue your money skills journey.</p>

                    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="msg">
                        <asp:Literal ID="litMessage" runat="server" />
                    </asp:Panel>

                    <div class="auth__form">
                        <div class="field">
                            <label>Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ErrorMessage="Please enter your email."
                                CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="field">
                            <label>Password</label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                                ControlToValidate="txtPassword"
                                ErrorMessage="Please enter your password."
                                CssClass="field-error" Display="Dynamic" />
                        </div>

                        <asp:Button ID="btnLogin" runat="server"
                            Text="Log in"
                            CssClass="btn btn--primary"
                            OnClick="btnLogin_Click" />
                    </div>

                    <p class="auth__footer">
                        Don't have an account?
                        <a href="Signup.aspx">Join free</a>
                    </p>
                </div>
            </section>
        </main>
    </form>
</body>
</html>
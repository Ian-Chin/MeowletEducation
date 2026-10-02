<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Signin.aspx.cs" Inherits="MeowletEducation.Signin" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#241d15" />
    <title>Log in · Meowlet Educations</title>
    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="auth">
            <aside class="auth__side">
                <a class="auth__logo" href="index.html" aria-label="Meowlet Educations home">
                    <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Educations" />
                </a>
                <div class="auth__welcome">
                    <h2 class="auth__heading">Welcome back</h2>
                    <p class="auth__lead">Log in to continue learning money skills.</p>
                    <p class="auth__copy" id="adminEgg">&copy; 2026 Meowlet Educations</p>
                </div>
            </aside>

            <main class="auth__main">
                <div class="auth__card">
                    <nav class="auth__switch" aria-label="Log in or sign up">
                        <a class="auth__switch-tab is-active" aria-current="page" href="Signin.aspx">Log in</a>
                        <a class="auth__switch-tab" href="Signup.aspx">Sign up</a>
                    </nav>

                    <h1 class="auth__title">Log in</h1>
                    <p class="auth__sub">Use your email and password</p>

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
                        <asp:Button ID="btnLogin" runat="server" Text="Log in"
                            CssClass="btn btn--primary" OnClick="btnLogin_Click" />
                    </div>

                    <div class="auth__links">
                        <div>Are you a Tutor? <a href="SignupTutor.aspx">Register as Tutor</a></div>
                    </div>
                </div>
            </main>
        </div>

        <footer class="footer">
            <div class="shell">
                <div class="footer__grid">
                    <div class="footer__brand">
                        <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Educations">
                        <p style="max-width:34ch;font-size:.92rem">Money skills, taught by doing. Open to everyone, kept for
                            members.</p>
                    </div>
                    <div>
                        <h4>Learn</h4>
                        <a href="index.html#catalog">Catalog</a><br>
                        <a href="index.html#learn">Virtual labs</a><br>
                        <a href="index.html#learn">Simulations</a><br>
                        <a href="index.html#learn">Self-assessments</a>
                    </div>
                    <div>
                        <h4>Community</h4>
                        <a href="index.html#learn">Discussion boards</a><br>
                        <a href="index.html#learn">Live rooms</a><br>
                        <a href="index.html#team">Developers</a><br>
                        <a href="index.html#access">Guest access</a>
                    </div>
                    <div>
                        <h4>Account</h4>
                        <a href="Signin.aspx">Log in</a><br>
                        <a href="Signup.aspx">Register</a><br>
                        <a href="index.html#access">What you get</a><br>
                        <a href="index.html#learn">Ways to learn</a>
                    </div>
                </div>

                <div class="footer__bottom">
                    <span>© 2026 Meowlet Educations. Educational content only, not financial advice.</span>
                    <span>Ian, Isac, YongHan, YeWen</span>
                </div>
            </div>
        </footer>
    </form>
    <script>
        /* Hidden admin entrance: 7 quick clicks on the copyright line.
           The count resets if you pause for more than 1.5s between clicks. */
        (function () {
            var el = document.getElementById("adminEgg");
            if (!el) return;
            var clicks = 0, timer = null;
            el.style.userSelect = "none";
            el.addEventListener("click", function () {
                clicks++;
                clearTimeout(timer);
                if (clicks >= 7) {
                    window.location.href = "AdminSignin.aspx";
                    return;
                }
                timer = setTimeout(function () { clicks = 0; }, 1500);
            });
        })();
    </script>
</body>
</html>
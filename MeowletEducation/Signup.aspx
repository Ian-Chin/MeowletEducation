<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="MeowletEducation.Signup" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#241d15" />
    <title>Join free · Meowlet Educations</title>
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
                    <h2 class="auth__heading">Welcome to our platform</h2>
                    <p class="auth__lead">Learn money skills the simple way: budget, save, and grow with confidence.</p>
                    <p class="auth__copy">&copy; 2026 Meowlet Educations</p>
                </div>
            </aside>

            <main class="auth__main">
                <div class="auth__card">
                    <nav class="auth__switch auth__switch--signup" aria-label="Log in or sign up">
                        <a class="auth__switch-tab" href="Signin.aspx">Log in</a>
                        <a class="auth__switch-tab is-active" aria-current="page" href="Signup.aspx">Sign up</a>
                    </nav>

                    <h1 class="auth__title">Create your account</h1>
                    <p class="auth__sub">Student registration · free to join</p>

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
</body>
</html>
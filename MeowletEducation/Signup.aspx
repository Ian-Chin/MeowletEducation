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
        <asp:HiddenField ID="hidStep" runat="server" Value="1" />

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

                    <!-- STEP 1 -->
                    <asp:Panel ID="pnlStep1" runat="server">
                        <nav class="auth__switch auth__switch--signup" aria-label="Log in or sign up">
                            <a class="auth__switch-tab" href="Signin.aspx">Log in</a>
                            <a class="auth__switch-tab is-active" aria-current="page" href="Signup.aspx">Sign up</a>
                        </nav>

                        <h1 class="auth__title">Create Your Account</h1>
                        <p class="auth__sub">Student registration · free to join</p>

                        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="msg">
                            <asp:Literal ID="litMessage" runat="server" />
                        </asp:Panel>

                        <div class="auth__form">
                            <div class="field">
                                <label>Full name</label>
                                <asp:TextBox ID="txtFullName" runat="server" MaxLength="100" />
                                <asp:RequiredFieldValidator ID="rfvName" runat="server"
                                    ControlToValidate="txtFullName" ValidationGroup="step1"
                                    ErrorMessage="Please enter your name."
                                    CssClass="field-error" Display="Dynamic" />
                            </div>
                            <div class="field">
                                <label>Email</label>
                                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" />
                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                                    ControlToValidate="txtEmail" ValidationGroup="step1"
                                    ErrorMessage="Please enter your email."
                                    CssClass="field-error" Display="Dynamic" />
                                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                    ControlToValidate="txtEmail" ValidationGroup="step1"
                                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                    ErrorMessage="Please enter a valid email."
                                    CssClass="field-error" Display="Dynamic" />
                            </div>
                            <div class="field">
                                <label>Password</label>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
                                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                                    ControlToValidate="txtPassword" ValidationGroup="step1"
                                    ErrorMessage="Please enter a password."
                                    CssClass="field-error" Display="Dynamic" />
                                <asp:RegularExpressionValidator ID="revPassword" runat="server"
                                    ControlToValidate="txtPassword" ValidationGroup="step1"
                                    ValidationExpression="^.{8,}$"
                                    ErrorMessage="Password must be at least 8 characters."
                                    CssClass="field-error" Display="Dynamic" />
                                <p class="auth__hint">Use 8+ characters.</p>
                            </div>
                            <div class="field">
                                <label>Confirm password</label>
                                <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" />
                                <asp:CompareValidator ID="cvConfirm" runat="server"
                                    ControlToValidate="txtConfirm" ControlToCompare="txtPassword"
                                    ValidationGroup="step1"
                                    ErrorMessage="Passwords do not match."
                                    CssClass="field-error" Display="Dynamic" />
                            </div>
                            <asp:Button ID="btnStep1" runat="server" Text="Create"
                                CssClass="btn btn--primary" ValidationGroup="step1"
                                OnClick="btnStep1_Click" />
                        </div>

                        <div class="auth__links">
                            <div>Are you a Tutor? <a href="SignupTutor.aspx">Tutor Portal</a></div>
                        </div>
                    </asp:Panel>

                    <!-- STEP 2：必须答完 Age + Interests 才能 Create Account -->
                    <asp:Panel ID="pnlStep2" runat="server" Visible="false">
                        <div class="auth__progress">
                            <span></span>
                            <span class="is-on"></span>
                        </div>

                        <h1 class="auth__title">Few More Questions</h1>
                        <p class="auth__sub">Answer both sections below, or skip for now.</p>

                        <asp:Panel ID="pnlMessage2" runat="server" Visible="false" CssClass="msg">
                            <asp:Literal ID="litMessage2" runat="server" />
                        </asp:Panel>

                        <div class="auth__form">
                            <div class="field">
                                <label>Age Range</label>
                                <asp:RadioButtonList ID="rblAge" runat="server"
                                    RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="chip-list">
                                    <asp:ListItem Text="Under 18" Value="under_18" />
                                    <asp:ListItem Text="18–24" Value="18_24" />
                                    <asp:ListItem Text="25–34" Value="25_34" />
                                    <asp:ListItem Text="35+" Value="35_plus" />
                                </asp:RadioButtonList>
                            </div>

                            <div class="field">
                                <label>Interested in</label>
                                <asp:CheckBoxList ID="cblInterests" runat="server"
                                    RepeatDirection="Horizontal" RepeatLayout="Flow"
                                    CssClass="chip-list chip-list--wide" />
                            </div>

                            <asp:Button ID="btnStep2" runat="server" Text="Create Account"
                                CssClass="btn btn--primary" OnClick="btnStep2_Click" />
                            <asp:LinkButton ID="btnSkip" runat="server" CssClass="auth__skip"
                                OnClick="btnSkip_Click" CausesValidation="false">Skip for now</asp:LinkButton>
                        </div>

                        <div class="auth__links">
                            <div>Are you a Tutor? <a href="SignupTutor.aspx">Tutor Portal</a></div>
                        </div>
                    </asp:Panel>

                    <!-- STEP 3 -->
                    <asp:Panel ID="pnlStep3" runat="server" Visible="false">
                        <div class="auth__success">
                            <h1 class="auth__title">You Are All Set!</h1>
                            <p class="auth__sub">Your student account is ready. Log in to start learning.</p>
                            <a class="btn btn--primary"
                               href="Signin.aspx?registered=1"
                               style="display:inline-flex;width:100%;justify-content:center;min-height:48px;align-items:center;text-decoration:none;">
                                Go to Login
                            </a>
                        </div>
                    </asp:Panel>

                </div>
            </main>
        </div>
    </form>
</body>
</html>
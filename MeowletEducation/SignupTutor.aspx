<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignupTutor.aspx.cs" Inherits="MeowletEducation.SignupTutor" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#241d15" />
    <title>Tutor registration · Meowlet Educations</title>
    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <asp:HiddenField ID="hidStep" runat="server" Value="1" />

        <div class="auth">
            <aside class="auth__side">
                <a class="auth__logo" href="index.html" aria-label="Meowlet Educations home">
                    <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Educations" />
                </a>
                <div class="auth__welcome">
                    <h2 class="auth__heading">Welcome to our platform</h2>
                    <p class="auth__lead">Join as a Tutor. Verify your identity so students can trust you.</p>
                    <p class="auth__copy">&copy; 2026 Meowlet Educations</p>
                </div>
            </aside>

            <main class="auth__main">
                <div class="auth__card">

                    <!-- ========== STEP 1: Create account ========== -->
                    <asp:Panel ID="pnlStep1" runat="server">
                        <nav class="auth__switch auth__switch--signup" aria-label="Log in or sign up">
                            <a class="auth__switch-tab" href="Signin.aspx">Log in</a>
                            <a class="auth__switch-tab is-active" aria-current="page" href="SignupTutor.aspx">Sign up</a>
                        </nav>

                        <h1 class="auth__title">Create Your Account</h1>
                        <p class="auth__sub">Tutor registration</p>

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
                            <asp:Button ID="btnStep1" runat="server" Text="Verify My Info"
                                CssClass="btn btn--primary" ValidationGroup="step1"
                                OnClick="btnStep1_Click" />
                        </div>

                        <div class="auth__links">
                            <div>Are you a Student? <a href="Signup.aspx">Register as Student</a></div>
                        </div>
                    </asp:Panel>

                    <!-- ========== STEP 2: ID Verification ========== -->
                    <asp:Panel ID="pnlStep2" runat="server" Visible="false">
                        <div class="auth__progress"><span></span><span class="is-on"></span></div>

                        <h1 class="auth__title">ID Verification</h1>
                        <p class="auth__sub">Upload a photo of your ID or certificate. An admin will review it.</p>

                        <asp:Panel ID="pnlMessage2" runat="server" Visible="false" CssClass="msg">
                            <asp:Literal ID="litMessage2" runat="server" />
                        </asp:Panel>

                        <div class="auth__form">
                            <div class="field">
                                <label>Upload ID / certificate</label>
                                <div class="upload-box">
                                    <asp:FileUpload ID="fuCertificate" runat="server" accept=".jpg,.jpeg,.png,.pdf" />
                                    <p class="auth__hint">JPG, PNG or PDF · max 10 MB</p>
                                </div>
                            </div>

                            <asp:Button ID="btnVerify" runat="server" Text="Verify"
                                CssClass="btn btn--primary" OnClick="btnVerify_Click" />
                            <asp:LinkButton ID="btnSkipVerify" runat="server" CssClass="auth__skip"
                                OnClick="btnSkipVerify_Click" CausesValidation="false">Skip for now</asp:LinkButton>
                        </div>
                    </asp:Panel>

                </div>
            </main>
        </div>
    </form>
</body>
</html>
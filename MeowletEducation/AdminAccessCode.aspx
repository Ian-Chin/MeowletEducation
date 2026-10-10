<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminAccessCode.aspx.cs" Inherits="MeowletEducation.AdminAccessCode" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#000000" />
    <meta name="robots" content="noindex" />
    <title>Admin access code · Meowlet Educations</title>
    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body class="admin-auth">
    <form id="form1" runat="server" class="admin-auth__card" novalidate="novalidate">
        <a class="admin-auth__logo" href="index.html" aria-label="Meowlet Educations home">
            <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Educations" />
        </a>

        <ol class="admin-auth__steps" aria-label="Step 2 of 2">
            <li class="is-done"></li>
            <li class="is-done"></li>
        </ol>

        <h1 class="admin-auth__title">Enter your access code</h1>
        <p class="admin-auth__lead">Your details were sent to the admin team for approval.</p>

        <div class="admin-auth__form">
            <p class="admin-auth__note">
                An existing admin will generate an <strong>8-character code</strong> and send it to you.
                Codes last 24 hours. Your account stays locked until the code is entered.
            </p>

            <asp:Literal ID="litMessage" runat="server" />

            <div class="admin-auth__field">
                <asp:Label runat="server" AssociatedControlID="txtCode">Access code</asp:Label>
                <asp:TextBox ID="txtCode" runat="server" MaxLength="12" CssClass="admin-auth__code"
                    autocomplete="one-time-code" spellcheck="false" placeholder="XXXXXXXX" autofocus="autofocus" />
            </div>

            <asp:Button ID="btnVerify" runat="server" Text="Verify and open dashboard" CssClass="admin-auth__submit" OnClick="btnVerify_Click" />
        </div>

        <p class="admin-auth__switch">Already active? <a href="AdminSignin.aspx">Log in</a></p>
    </form>
</body>
</html>

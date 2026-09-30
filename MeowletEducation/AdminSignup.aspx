<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminSignup.aspx.cs" Inherits="MeowletEducation.AdminSignup" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#140f0a" />
    <meta name="robots" content="noindex" />
    <title>Admin sign up · Meowlet Educations</title>
    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body class="admin-auth">
    <form id="form1" runat="server" class="admin-auth__card" novalidate="novalidate">
        <a class="admin-auth__logo" href="index.html" aria-label="Meowlet Educations home">
            <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Educations" />
        </a>

        <h1 class="admin-auth__title">Create an admin account</h1>
        <p class="admin-auth__lead">You need the admin access code to sign up.</p>

        <asp:Literal ID="litMessage" runat="server" />

        <asp:PlaceHolder ID="phForm" runat="server">
            <div class="admin-auth__form">
                <div class="admin-auth__field">
                    <asp:Label runat="server" AssociatedControlID="txtFullName">Full name</asp:Label>
                    <asp:TextBox ID="txtFullName" runat="server" MaxLength="100" autocomplete="name" autofocus="autofocus" />
                </div>

                <div class="admin-auth__field">
                    <asp:Label runat="server" AssociatedControlID="txtEmail">Email</asp:Label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" autocomplete="email" />
                </div>

                <div class="admin-auth__field">
                    <asp:Label runat="server" AssociatedControlID="txtPassword">Password</asp:Label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="new-password" />
                    <p>At least 8 characters.</p>
                </div>

                <div class="admin-auth__field">
                    <asp:Label runat="server" AssociatedControlID="txtConfirm">Confirm password</asp:Label>
                    <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" autocomplete="new-password" />
                </div>

                <div class="admin-auth__field">
                    <asp:Label runat="server" AssociatedControlID="txtCode">Admin access code</asp:Label>
                    <asp:TextBox ID="txtCode" runat="server" TextMode="Password" autocomplete="off" />
                    <p>Ask an existing admin for it.</p>
                </div>

                <asp:Button ID="btnSignup" runat="server" Text="Create admin account" CssClass="admin-auth__submit" OnClick="btnSignup_Click" />
            </div>
        </asp:PlaceHolder>

        <p class="admin-auth__switch">Already an admin? <a href="AdminSignin.aspx">Log in</a></p>
    </form>
</body>
</html>

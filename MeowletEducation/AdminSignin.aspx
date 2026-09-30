<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminSignin.aspx.cs" Inherits="MeowletEducation.AdminSignin" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#140f0a" />
    <meta name="robots" content="noindex" />
    <title>Admin log in · Meowlet Educations</title>
    <link rel="icon" href="favicon.ico" sizes="any" />
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32.png" />
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body class="admin-auth" id="page">
    <form id="form1" runat="server" class="admin-auth__card" novalidate="novalidate">
        <a class="admin-auth__logo" href="index.html" aria-label="Meowlet Educations home">
            <img src="assets/img/meowlet-logo-dark.png" alt="Meowlet Educations" />
        </a>

        <h1 class="admin-auth__title">Admin log in</h1>
        <p class="admin-auth__lead">For people who run Meowlet.</p>

        <div class="admin-auth__form">
            <asp:Literal ID="litMessage" runat="server" />

            <div class="admin-auth__field">
                <asp:Label runat="server" AssociatedControlID="txtEmail">Email</asp:Label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" autocomplete="username" autofocus="autofocus" />
            </div>

            <div class="admin-auth__field">
                <asp:Label runat="server" AssociatedControlID="txtPassword">Password</asp:Label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" />
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Log in" CssClass="admin-auth__submit" OnClick="btnLogin_Click" />
        </div>

        <p class="admin-auth__switch">New admin? <a href="AdminSignup.aspx">Create an admin account</a></p>
    </form>

    <asp:PlaceHolder ID="phWelcome" runat="server" Visible="false">
        <div class="admin-welcome" id="welcome" role="status" aria-live="polite">
            <p>Welcome back, <asp:Literal ID="litFirstName" runat="server" /></p>
        </div>

        <script type="text/javascript">
            // Signed in: fade the form out, show the greeting, then hand over
            // to the dashboard, which fades in from this same dark colour.
            (function () {
                var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
                var page = document.getElementById('page');
                var welcome = document.getElementById('welcome');
                var t = reduce ? { out: 0, hold: 900, fade: 0 } : { out: 380, hold: 1300, fade: 500 };

                page.className += ' is-leaving';

                setTimeout(function () {
                    welcome.className += ' is-visible';

                    setTimeout(function () {
                        welcome.className = welcome.className.replace(' is-visible', '');

                        setTimeout(function () {
                            try { sessionStorage.setItem('meowletAdminArrive', '1'); } catch (e) { }
                            window.location.replace('admindashboard.aspx');
                        }, t.fade);
                    }, t.hold + t.fade);
                }, t.out);
            })();
        </script>
    </asp:PlaceHolder>
</body>
</html>

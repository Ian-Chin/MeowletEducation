<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="MeowletEducation.Profile" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Profile & Settings - Meowlet Educations</title>
    <link rel="stylesheet" href="assets/css/style.css" />
    <style>
        .profile-container {
            max-width: 760px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .card {
            background: #fff;
            border: 1px solid #eaeaea;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.03);
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 24px;
        }
        .form-group label {
            display: block;
            font-weight: 500;
            font-size: 0.95rem;
            margin-bottom: 8px;
            color: #1a1a1a;
        }
        .form-control {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid #ddd;
            border-radius: 12px;
            font-size: 0.95rem;
            outline: none;
            transition: border-color 0.2s;
            box-sizing: border-box;
        }
        .form-control:focus {
            border-color: #1a1a1a;
        }
        .section-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        .msg-box {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 0.9rem;
            font-weight: 500;
        }
        .msg-success { background: #eef9ec; color: #2e7d32; border: 1px solid #c8e6c9; }
        .msg-error { background: #fdecea; color: #c62828; border: 1px solid #ffcdd2; }
        
        .header__inner {
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 80px;
        }
        .nav__links {
            display: flex;
            gap: 24px;
            align-items: center;
        }
        .nav__links a {
            text-decoration: none;
            color: #444;
            font-weight: 500;
            font-size: 0.95rem;
        }
        .nav__links a:hover {
            color: #000;
        }
        .user-profile-badge {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            color: inherit;
            font-weight: 500;
            font-size: 0.9rem;
            padding: 4px 12px;
            border-radius: 20px;
            border: 1px solid #eaeaea;
            background: #faf9f5;
        }
        .user-avatar-small {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #111;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="header" style="border-bottom: 1px solid #eaeaea;">
            <div class="shell header__inner">
                <a class="brand" href="Index.aspx">
                    <img src="assets/img/meowlet-logo.png" alt="Meowlet Logo" style="height:36px;">
                </a>
                <div class="nav__links">
                    <a href="Index.aspx">Home</a>
                    <a href="Index.aspx#catalog">Courses</a>
                    <a href="Profile.aspx" class="user-profile-badge">
                        <span class="user-avatar-small">
                            <asp:Literal ID="litInitial" runat="server"></asp:Literal>
                        </span>
                        <span>
                            <asp:Literal ID="litName" runat="server"></asp:Literal>
                        </span>
                    </a>
                </div>
            </div>
        </header>

        <main class="profile-container">
            <div style="margin-bottom: 35px;">
                <p style="font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #888; margin-bottom: 6px;">Account Center</p>
                <h1 style="font-size: 2.2rem; font-weight: 700; margin: 0 0 8px 0;">Profile & Settings</h1>
                <p style="color: #666; font-size: 0.95rem;">Manage your personal information, credentials, and account preferences.</p>
            </div>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="card">
                <h3 class="section-title">Personal Information</h3>
                
                <div class="form-group">
                    <label>Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Role</label>
                    <asp:TextBox ID="txtRole" runat="server" CssClass="form-control" ReadOnly="true" style="background-color: #f9f9f9; color: #666;"></asp:TextBox>
                </div>

                <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn btn--primary" OnClick="btnSave_Click" OnClientClick="return confirm('Are you sure you want to update your profile details?');" />
            </div>

            <div class="card">
                <h3 class="section-title">Change Password</h3>

                <div class="form-group">
                    <label>New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" autocomplete="new-password"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Confirm New Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" autocomplete="new-password"></asp:TextBox>
                </div>

                <asp:Button ID="btnChangePassword" runat="server" Text="Update Password" CssClass="btn btn--ghost" OnClick="btnChangePassword_Click" OnClientClick="return confirm('Are you sure you want to change your password?');" />
            </div>

            <div style="margin-bottom: 60px;">
                <asp:Button ID="btnLogout" runat="server" Text="Log Out" CssClass="btn" style="color: #d32f2f; border-color: #ffcdd2;" OnClick="btnLogout_Click" OnClientClick="return confirm('Are you sure you want to log out?');" />
            </div>
        </main>
    </form>
</body>
</html>
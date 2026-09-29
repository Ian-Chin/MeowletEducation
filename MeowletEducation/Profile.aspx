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
            border: 1px solid rgba(36, 29, 21, 0.1);
            border-radius: 16px;
            padding: 32px 36px;
            box-shadow: 0 10px 30px -18px rgba(36, 29, 21, 0.12);
            margin-bottom: 24px;
        }
        .form-group {
            margin-bottom: 22px;
        }
        .form-group label {
            display: block;
            font-weight: 600;
            font-size: 0.82rem;
            letter-spacing: 0.02em;
            margin-bottom: 7px;
            color: #241d15;
        }
        .form-group .field-hint {
            display: block;
            font-size: 0.78rem;
            color: #9c8d79;
            margin-top: 6px;
            line-height: 1.4;
        }
        .form-control {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid rgba(36, 29, 21, 0.18);
            border-radius: 10px;
            font-size: 0.95rem;
            background: #fdfaf4;
            color: #241d15;
            outline: none;
            transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
            box-sizing: border-box;
        }
        .form-control:focus {
            background: #fff;
            border-color: #b9703c;
            box-shadow: 0 0 0 3px #f6e3d1;
        }
        .form-control[readonly] {
            background: #f4ecdd;
            color: #6d6053;
            cursor: default;
        }
        .section-title {
            font-size: 1.15rem;
            font-weight: 700;
            margin: 0 0 22px;
            padding-bottom: 12px;
            border-bottom: 1px solid rgba(36, 29, 21, 0.08);
            color: #241d15;
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

        /* Button layout helpers */
        .card-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 8px;
            padding-top: 8px;
        }
        .card-actions .btn {
            min-height: 44px;
            padding: 12px 22px;
            font-size: 0.92rem;
            font-weight: 600;
            border-radius: 10px;
            cursor: pointer;
        }

        /* Danger / destructive button */
        .btn--danger {
            background: #fff;
            color: #c62828;
            border: 1px solid #ffcdd2;
            box-shadow: none;
        }
        .btn--danger:hover {
            background: #fdecea;
            border-color: #ef9a9a;
            color: #b71c1c;
        }
        .btn--danger:active {
            transform: scale(0.965);
        }

        .btn--ghost {
            border-radius: 10px;
        }
        .btn--primary {
            border-radius: 10px;
        }

        /* Danger zone (logout) */
        .danger-zone {
            margin: 8px 0 60px;
            padding: 24px 28px;
            border: 1px solid #ffcdd2;
            border-radius: 16px;
            background: #fffaf9;
        }
        .danger-zone__title {
            font-size: 0.95rem;
            font-weight: 700;
            color: #c62828;
            margin: 0 0 6px;
        }
        .danger-zone__desc {
            font-size: 0.85rem;
            color: #8a6a6a;
            margin: 0 0 16px;
            line-height: 1.45;
        }

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
            background: #241d15;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            font-weight: bold;
        }

        @media (max-width: 560px) {
            .card { padding: 24px 20px; }
            .card-actions .btn { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
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
                    <asp:TextBox ID="txtRole" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                </div>

                <asp:Panel ID="pnlInstitution" runat="server" Visible="false">
                    <div class="form-group">
                        <label>Education Institution</label>
                        <asp:TextBox ID="txtInstitution" runat="server" CssClass="form-control" MaxLength="200"></asp:TextBox>
                        <span class="field-hint">Optional. Shown on your tutor profile alongside your certificate.</span>
                    </div>

                    <div class="form-group" style="margin-top: 28px; padding-top: 22px; border-top: 1px solid rgba(36,29,21,0.08);">
                        <label>Teaching certificate</label>

                        <div style="margin-bottom: 12px;">
                            <asp:Literal ID="litCertBadge" runat="server" />
                        </div>

                        <asp:Literal ID="litCertFileName" runat="server" />

                        <asp:FileUpload ID="fuCertificate" runat="server" CssClass="form-control" style="padding: 10px 12px;" />
                        <span class="field-hint">PDF, JPG, or PNG. Max 5MB. Uploading a new file will require re-review by an admin.</span>

                        <div class="card-actions" style="margin-top: 14px;">
                            <asp:Button ID="btnUploadCertificate" runat="server"
                                Text="Upload certificate" CssClass="btn btn--ghost"
                                OnClick="btnUploadCertificate_Click" />
                        </div>
                    </div>
                </asp:Panel>

                <div class="card-actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save changes"
                        CssClass="btn btn--primary"
                        OnClick="btnSave_Click"
                        OnClientClick="return confirm('Save your profile changes?');" />
                </div>
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

                <div class="card-actions">
                    <asp:Button ID="btnChangePassword" runat="server" Text="Update password"
                        CssClass="btn btn--ghost"
                        OnClick="btnChangePassword_Click"
                        OnClientClick="return confirm('Change your password now?');" />
                </div>
            </div>

            <div class="danger-zone">
                <p class="danger-zone__title">Log out</p>
                <p class="danger-zone__desc">You will need to sign in again to access your account and saved progress.</p>
                <asp:Button ID="btnLogout" runat="server" Text="Log out"
                    CssClass="btn btn--danger"
                    OnClick="btnLogout_Click"
                    OnClientClick="return confirm('Log out of Meowlet Educations?');" />
            </div>
        </main>
    </form>
</body>
</html>
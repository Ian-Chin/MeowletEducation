<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="MeowletEducation.Profile" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Profile - Meowlet Education</title>
    <link rel="stylesheet" href="assets/css/style.css" />
    <style>
        body { background-color: var(--cream); }

        .profile-layout {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 48px;
            padding: 60px 0 100px;
            max-width: var(--shell);
            margin: 0 auto;
            padding-inline: 22px;
        }

        @media (max-width: 900px) {
            .profile-layout { grid-template-columns: 1fr; gap: 32px; }
        }

        .profile-sidebar .card {
            position: sticky;
            top: 100px;
            text-align: center;
            padding: 40px 32px;
        }

        .profile-avatar-large {
            width: 96px; height: 96px;
            border-radius: 50%;
            background: var(--ink);
            color: var(--paper);
            font-size: 36px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px;
            box-shadow: var(--shadow);
        }

        .profile-name { font-size: 1.5rem; margin-bottom: 4px; color: var(--ink); }
        .profile-email { font-size: 0.9rem; color: var(--ink-mute); margin-bottom: 24px; }
        
        .profile-role-tag {
            display: inline-block;
            padding: 6px 16px;
            border-radius: var(--pill);
            background: var(--beige);
            color: var(--ink-soft);
            font-size: 0.75rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.05em;
            margin-bottom: 32px;
        }

        .profile-meta {
            text-align: left;
            border-top: 1px solid var(--line);
            padding-top: 24px;
        }
        .profile-meta h4 {
            font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.1em;
            color: var(--ink-faint); margin: 0 0 12px 0; font-weight: 700;
        }
        .profile-meta-tags { display: flex; flex-wrap: wrap; gap: 8px; }

        .profile-content { display: flex; flex-direction: column; gap: 32px; }
        
        .content-panel {
            background: var(--paper);
            border: 1px solid var(--line);
            border-radius: var(--radius-lg);
            padding: 48px;
            box-shadow: var(--shadow-sm);
        }

        @media (max-width: 600px) { .content-panel { padding: 24px; } }

        .content-panel h2 {
            font-size: 1.5rem; margin-bottom: 32px; color: var(--ink);
            border-bottom: 1px solid var(--line); padding-bottom: 16px;
        }

        .form-row {
            display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;
        }
        @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }

        .danger-panel {
            border-color: #fde8e6;
        }
        .danger-panel h2 { color: #8a1f11; border-bottom-color: #fde8e6; }
        
        .profile-header-actions { display: flex; align-items: center; gap: 16px; }
        .btn-back-text {
            font-size: 0.9rem; color: var(--ink-mute); font-weight: 600;
            text-decoration: none; transition: color 0.2s;
        }
        .btn-back-text:hover { color: var(--ink); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="header">
            <div class="shell header__inner">
                <a href="index.html" class="brand">
                    <img src="assets/img/meowlet-logo.png" alt="Meowlet" />
                </a>
                <div class="profile-header-actions">
                    <div class="tag" style="padding: 6px 14px; gap: 8px;">
                        <span style="width: 20px; height: 20px; border-radius: 50%; background: var(--ink); color: #fff; display: inline-flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 700;">
                            <asp:Literal ID="litNavInitial" runat="server">U</asp:Literal>
                        </span>
                        <asp:Literal ID="litNavName" runat="server">User</asp:Literal>
                    </div>
                    <a href="javascript:history.back()" class="btn-back-text">← Back</a>
                </div>
            </div>
        </header>

        <div class="profile-layout">
            
            <aside class="profile-sidebar">
                <div class="card">
                    <div id="divAvatar" runat="server" class="profile-avatar-large">
                        <asp:Literal ID="litAvatar" runat="server">U</asp:Literal>
                    </div>
                    <h1 class="profile-name">
                        <asp:Literal ID="litFullName" runat="server">User Name</asp:Literal>
                    </h1>
                    <p class="profile-email">
                        <asp:Literal ID="litEmail" runat="server">email@example.com</asp:Literal>
                    </p>
                    
                    <asp:Literal ID="litVerifiedBadge" runat="server" />
                    <span id="roleBadge" runat="server" class="profile-role-tag">
                        <asp:Literal ID="litRole" runat="server">STUDENT</asp:Literal>
                    </span>

                    <div class="profile-meta">
                        <h4>Age Range</h4>
                        <div class="profile-meta-tags">
                            <div id="displayAge" runat="server">
                                <span class="tag">Not specified</span>
                            </div>
                        </div>
                    </div>

                    <div class="profile-meta" style="margin-top: 24px; border-top: 0; padding-top: 0;">
                        <h4>Areas of Interest</h4>
                        <div id="displayInterests" runat="server" class="profile-meta-tags">
                            <span class="tag">Loading...</span>
                        </div>
                    </div>
                </div>
            </aside>

            <main class="profile-content">
                
                <asp:Panel ID="pnlFlash" runat="server" Visible="false">
                    <div class="msg msg--ok">
                        <asp:Literal ID="litFlash" runat="server" />
                    </div>
                </asp:Panel>

                <div class="content-panel">
                    <h2>Account Details</h2>
                    <div class="form-row">
                        <div class="field">
                            <label for="txtFullName">Full Name</label>
                            <asp:TextBox ID="txtFullName" runat="server" />
                        </div>
                        <div class="field">
                            <label for="txtEmail">Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" ReadOnly="true" style="background: var(--beige); color: var(--ink-mute); cursor: not-allowed;" />
                        </div>
                    </div>
                    <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                        <asp:Button ID="btnSaveBasic" runat="server" Text="Update Details" CssClass="btn btn--primary" OnClick="btnSaveBasic_Click" />
                    </div>

                    <div style="margin-top: 48px; border-top: 1px solid var(--line); padding-top: 32px;">
                        <h3 class="h3" style="margin-bottom: 24px;">Security</h3>
                        <div class="form-row">
                            <div class="field">
                                <label for="txtCurrentPassword">Current Password</label>
                                <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" />
                            </div>
                            <div class="field">
                                <label for="txtNewPassword">New Password</label>
                                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" />
                            </div>
                        </div>
                        <div class="form-row" style="grid-template-columns: 1fr;">
                             <div class="field">
                                <label for="txtConfirmPassword">Confirm New Password</label>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" />
                            </div>
                        </div>
                        <div style="display: flex; justify-content: flex-end;">
                            <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" CssClass="btn btn--ghost" OnClick="btnChangePassword_Click" />
                        </div>
                    </div>
                </div>

                <div class="content-panel">
                    <h2>Learning Preferences</h2>
                    
                    <div class="field" style="margin-bottom: 40px;">
                        <label>Age Range</label>
                        <div class="chip-list">
                            <asp:RadioButton ID="rbAge1" runat="server" GroupName="AgeRange" />
                            <label for="<%= rbAge1.ClientID %>">Under 18</label>
                            
                            <asp:RadioButton ID="rbAge2" runat="server" GroupName="AgeRange" />
                            <label for="<%= rbAge2.ClientID %>">18 - 24</label>
                            
                            <asp:RadioButton ID="rbAge3" runat="server" GroupName="AgeRange" />
                            <label for="<%= rbAge3.ClientID %>">25 - 34</label>
                            
                            <asp:RadioButton ID="rbAge4" runat="server" GroupName="AgeRange" />
                            <label for="<%= rbAge4.ClientID %>">35 - 44</label>
                            
                            <asp:RadioButton ID="rbAge5" runat="server" GroupName="AgeRange" />
                            <label for="<%= rbAge5.ClientID %>">45+</label>
                        </div>
                    </div>

                    <div class="field">
                        <label>Areas of Interest</label>
                        <asp:CheckBoxList ID="cblInterests" runat="server" CssClass="chip-list" RepeatLayout="Flow" RepeatDirection="Horizontal">
                        </asp:CheckBoxList>
                    </div>

                    <div style="display: flex; justify-content: flex-end; margin-top: 32px;">
                        <asp:Button ID="btnSavePrefs" runat="server" Text="Save Preferences" CssClass="btn btn--primary" OnClick="btnSavePrefs_Click" />
                    </div>
                </div>

                <asp:Panel ID="pnlTutorVerify" runat="server" Visible="false">
                    <div class="content-panel">
                        <h2>Tutor Verification</h2>
                        <asp:Literal ID="litTutorStatus" runat="server" />
                        <div class="field" style="margin-top: 24px;">
                            <label for="txtInstitution">Institution</label>
                            <asp:TextBox ID="txtInstitution" runat="server" placeholder="e.g., Harvard University" />
                        </div>
                        <div class="field" style="margin-top: 24px;">
                            <label for="fuCertificate">Upload Certificate</label>
                            <div style="padding: 20px; border: 1px dashed var(--line-strong); border-radius: var(--radius); background: var(--cream); text-align: center;">
                                <asp:FileUpload ID="fuCertificate" runat="server" />
                            </div>
                            <asp:Literal ID="litCertPath" runat="server" />
                        </div>
                        <div style="display: flex; justify-content: flex-end; margin-top: 24px;">
                            <asp:Button ID="btnUploadCert" runat="server" Text="Submit for Review" CssClass="btn btn--primary" OnClick="btnUploadCert_Click" />
                        </div>
                    </div>
                </asp:Panel>

                <div class="content-panel danger-panel">
                    <h2>Account Actions</h2>
                    <p style="color: var(--ink-mute); font-size: 0.95rem; margin-bottom: 32px; max-width: 60ch;">
                        Requesting account deletion will queue your profile for review. You can cancel this request within 7 days.
                    </p>
                    
                    <asp:Panel ID="pnlDeletePending" runat="server" Visible="false">
                        <div class="msg msg--error" style="margin-bottom: 20px;">
                            <asp:Literal ID="litDeletePending" runat="server" />
                        </div>
                        <div style="display: flex; justify-content: flex-end;">
                            <asp:Button ID="btnCancelDelete" runat="server" Text="Cancel Request" CssClass="btn btn--ghost" OnClick="btnCancelDelete_Click" />
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlDeleteActions" runat="server">
                        <div style="display: flex; gap: 16px; justify-content: flex-end;">
                            <asp:Button ID="btnLogout" runat="server" Text="Log Out" CssClass="btn btn--ghost" OnClick="btnLogout_Click" CausesValidation="false" />
                            <asp:Button ID="btnRequestDelete" runat="server" Text="Delete Account" CssClass="btn" style="background: #fff; color: #8a1f11; border-color: #fde8e6;" OnClick="btnRequestDelete_Click" OnClientClick="return confirm('Are you sure?');" />
                        </div>
                    </asp:Panel>
                </div>

            </main>
        </div>
    </form>
</body>
</html>
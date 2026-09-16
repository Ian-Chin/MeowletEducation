<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="MeowletEducation.Index" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Meowlet Education - Fintech & Personal Finance Learning</title>
    <link rel="stylesheet" href="assets/css/style.css" />
    <style>
        .hero-section {
            padding: 80px 20px 60px 20px;
            max-width: 1200px;
            margin: auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 40px;
        }
        .hero-content {
            max-width: 600px;
        }
        .hero-title {
            font-size: 3rem;
            font-weight: 700;
            line-height: 1.2;
            margin-bottom: 20px;
            color: #1a1a1a;
        }
        .hero-desc {
            font-size: 1.1rem;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .courses-section {
            padding: 60px 20px;
            max-width: 1200px;
            margin: auto;
        }
        .section-header {
            margin-bottom: 40px;
        }
        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 30px;
        }
        .course-card {
            background: #fff;
            border: 1px solid #eaeaea;
            border-radius: 16px;
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .course-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.06);
        }
        .course-body {
            padding: 24px;
        }
        .course-tag {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #2e7d32;
            font-weight: 600;
            margin-bottom: 8px;
            display: block;
        }
        .course-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 12px;
            color: #1a1a1a;
        }
        .course-desc {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 20px;
            line-height: 1.5;
        }
        .account-badge {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            color: #1a1a1a;
            font-weight: 500;
            font-size: 0.9rem;
            padding: 6px 16px;
            border-radius: 30px;
            border: 1px solid #e5e5e5;
            background: #fff;
            transition: background 0.2s;
        }
        .account-badge:hover {
            background: #f9f9f9;
        }
        .account-avatar-circle {
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
<body style="background-color: #fdfbf7;">
    <form id="form1" runat="server">
        <header class="site-header" style="border-bottom: 1px solid #eaeaea; background: #fff;">
            <div class="container nav-wrap" style="display: flex; justify-content: space-between; align-items: center; height: 80px; max-width: 1200px; margin: auto; padding: 0 30px;">
                <a href="Index.aspx" class="brand">
                    <img src="assets/img/meowlet-logo.png" alt="Meowlet Education" style="height:36px;" />
                </a>
                <div style="display: flex; align-items: center; gap: 40px;">
                    <nav class="main-nav" style="display: flex; gap: 30px; align-items: center;">
                        <a href="Index.aspx" style="text-decoration: none; color: #1a1a1a; font-weight: 500; font-size: 0.95rem;">Home</a>
                        <a href="#courses" style="text-decoration: none; color: #666; font-weight: 500; font-size: 0.95rem;">Courses</a>
                    </nav>
                    <div class="account-area">
                        <a href="Profile.aspx" class="account-badge">
                            <span class="account-avatar-circle">
                                <asp:Literal ID="litIndexInitial" runat="server">U</asp:Literal>
                            </span>
                            <span>
                                <asp:Literal ID="litIndexName" runat="server">Account</asp:Literal>
                            </span>
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <main>
            <section class="hero-section">
                <div class="hero-content">
                    <asp:Literal ID="litRoleWelcome" runat="server">
                        <p style="font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #2e7d32; font-weight:600; margin-bottom: 10px;">Fintech & Personal Finance Portal</p>
                    </asp:Literal>
                    <h1 class="hero-title">Master Your Wealth & Personal Finance Management.</h1>
                    <p class="hero-desc">Empowering students and professionals with modern financial literacy, automated budget tracking, and smart investment modules.</p>
                    <div style="display: flex; gap: 15px;">
                        <a href="#courses" class="btn btn--primary" style="padding: 12px 24px; border-radius: 10px; text-decoration: none; background: #111; color: #fff; font-weight: 500;">Explore Modules</a>
                        <a href="Profile.aspx" class="btn btn--ghost" style="padding: 12px 24px; border-radius: 10px; text-decoration: none; border: 1px solid #ccc; color: #333; font-weight: 500;">Account Settings</a>
                    </div>
                </div>
                <div>
                    <img src="assets/img/cat-burst.png" alt="Illustration" style="max-width: 380px; width: 100%;" />
                </div>
            </section>

            <section id="courses" class="courses-section">
                <div class="section-header">
                    <p style="font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #2e7d32; font-weight: 600; margin-bottom: 6px;">Curriculum</p>
                    <h2 style="font-size: 2rem; font-weight: 700;">Personal Finance & Fintech Modules</h2>
                    <p style="color: #666; font-size: 0.95rem;">Core financial literacy and quantitative wealth management tracks available on your dashboard.</p>
                </div>

                <div class="course-grid">
                    <div class="course-card">
                        <div class="course-body">
                            <span class="course-tag">Module 01</span>
                            <h3 class="course-title">Smart Budgeting & Cash Flow</h3>
                            <p class="course-desc">Learn how to categorize monthly expenses, track cash inflows/outflows, and establish automated savings frameworks.</p>
                            <a href="Index.aspx#courses" style="color: #111; font-weight: 600; text-decoration: none; font-size: 0.9rem;">View details &rarr;</a>
                        </div>
                    </div>

                    <div class="course-card">
                        <div class="course-body">
                            <span class="course-tag">Module 02</span>
                            <h3 class="course-title">Investment & Portfolio Analysis</h3>
                            <p class="course-desc">Understand asset allocation, risk-return trade-offs, compound interest forecasting, and modern digital portfolio tracking.</p>
                            <a href="Index.aspx#courses" style="color: #111; font-weight: 600; text-decoration: none; font-size: 0.9rem;">View details &rarr;</a>
                        </div>
                    </div>

                    <div class="course-card">
                        <div class="course-body">
                            <span class="course-tag">Module 03</span>
                            <h3 class="course-title">Debt Management & Credit Health</h3>
                            <p class="course-desc">Master credit scoring mechanics, debt consolidation strategies, and long-term financial risk mitigation plans.</p>
                            <a href="Index.aspx#courses" style="color: #111; font-weight: 600; text-decoration: none; font-size: 0.9rem;">View details &rarr;</a>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <footer style="border-top: 1px solid #eaeaea; padding: 40px 20px; background: #fff; margin-top: 60px;">
            <div style="max-width: 1200px; margin: auto; display: flex; justify-content: space-between; align-items: center; color: #666; font-size: 0.9rem;">
                <p>© 2026 Meowlet Education. All rights reserved.</p>
                <p>Fintech & Personal Finance Platform.</p>
            </div>
        </footer>
    </form>
</body>
</html>
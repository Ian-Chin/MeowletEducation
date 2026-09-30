# Product

## Register

product

## Users

Two audiences. Learners and tutors use the public site (`index.html`, sign-in, onboarding) to study personal finance. Platform admins use `admindashboard.aspx` to look after accounts, courses, enrollments and reviews.

The project is a portfolio piece, so a third reader matters: someone reviewing the work, clicking through the admin panel to judge craft and whether it is really wired to a database.

## Product Purpose

Meowlet Education is a web-based learning system for money skills: budgeting, saving, investing, debt, taxes. Everything is open to guests; an account only keeps progress.

The admin dashboard exists so an admin can find a person or a course quickly and act on it. Success is a panel that reads as one product with the public site and shows real data from SQL Server, not a template filled with sample numbers.

## Brand Personality

Warm, plain-spoken, a little playful. The landing page talks in short, confident sentences ("Nothing is locked.") and uses a white cat mascot on cream and beige. The admin side keeps that warmth but turns the volume down: calm, tidy, honest about what it knows.

## Anti-references

- The generic SaaS admin template: KPI tiles with green and red percentage badges, "vs last month" deltas, sparkline filler.
- Card-everything layouts, cards nested in cards, identical card grids.
- Invented sample numbers presented as if they were live.
- A dark sidebar and system font that make the admin feel like a different product from the public site.

## Design Principles

1. **One product.** The admin panel uses the landing page's palette, type and voice.
2. **Real or absent.** Show what the database knows. Anything not yet wired is labelled as sample data, not dressed up as live.
3. **Find, then act.** Every screen starts from search or a list; actions sit next to the thing they act on.
4. **Quiet structure.** Hierarchy from type and spacing, not boxes and badges.

## Accessibility & Inclusion

No stated requirements. Baseline: WCAG AA text contrast, full keyboard use, visible focus, and respect for `prefers-reduced-motion`.

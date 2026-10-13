-- Meowlet Education: lesson content for the courses that have a cover picture.
-- Run after SeedData.sql (setup-db.cmd does both). Safe to re-run.
--
-- Fills every lesson (chapter) of BUD101, BUD201, SAV101, SAV201, INV101,
-- INV301, DEB101, TAX101, TAX301, INS101, RET201 and FIN101 with LessonBlocks:
-- a Media block (YouTube video) for video lessons, a Text block, a Quiz block
-- for quiz lessons, and a final Text block listing the sources. Content was
-- researched online on 2026-10-13 from official Malaysian sources (LHDN/HASiL,
-- KWSP, Bank Negara, PIDM, SC, PPA, AKPK) and reference sites; every video and
-- link was checked. Figures (tax reliefs, EPF dividend, stamp duty) are for
-- YA 2025 / 2025 and change with each Budget.
--
-- Blocks are only added to a lesson that has none, so content an admin or
-- tutor edited in the course builder is never overwritten.
-- To change a lesson later, edit it in the course builder (AdminCourse.aspx).

USE MeowletEducation;
GO

SET NOCOUNT ON;

IF OBJECT_ID('dbo.LessonBlocks', 'U') IS NULL
    RAISERROR('LessonBlocks is missing. Run CreateDatabase.sql first.', 16, 1);   -- sqlcmd -b stops here
GO

------------------------------------------------------------------------------
-- 1. TAX301 had no lessons: add them, its description, and the lesson count.
------------------------------------------------------------------------------
INSERT INTO dbo.CourseLessons (CourseId, Position, Title, ContentType, DurationMinutes)
SELECT c.CourseId, s.Position, s.Title, s.ContentType, s.DurationMinutes
FROM (VALUES
    (1, N'Are you a freelancer in LHDN''s eyes?', 'Article', 8),
    (2, N'Registering and keeping records', 'Article', 10),
    (3, N'Form B: reporting business income', 'Video', 16),
    (4, N'Deductible expenses and capital allowances', 'Article', 12),
    (5, N'Paying in instalments: CP500', 'Article', 8),
    (6, N'Lowering your tax legally', 'Video', 12),
    (7, N'Final quiz', 'Quiz', 12)
) AS s (Position, Title, ContentType, DurationMinutes)
JOIN dbo.Courses c ON c.CourseCode = N'TAX301'
WHERE NOT EXISTS (SELECT 1 FROM dbo.CourseLessons x WHERE x.CourseId = c.CourseId AND x.Position = s.Position);

UPDATE dbo.Courses SET Description = N'Report freelance and side income on Form B, claim the expenses you are allowed to, and plan for CP500 instalments.'
WHERE CourseCode = N'TAX301' AND Description IS NULL;

UPDATE c SET Lessons = (SELECT COUNT(*) FROM dbo.CourseLessons l WHERE l.CourseId = c.CourseId)
FROM dbo.Courses c
WHERE c.CourseCode = N'TAX301';

------------------------------------------------------------------------------
-- 2. Video lessons: the lesson's own video link (used when a lesson has no blocks).
------------------------------------------------------------------------------
UPDATE l SET ContentUrl = s.Url
FROM (VALUES
    (N'BUD101', 1, N'https://www.youtube.com/watch?v=hYoqJiaukGw'),
    (N'BUD101', 3, N'https://www.youtube.com/watch?v=LKxOamnP8J4'),
    (N'BUD101', 4, N'https://www.youtube.com/watch?v=ndFexNfakf8'),
    (N'BUD101', 6, N'https://www.youtube.com/watch?v=4siS3vQE4Eg'),
    (N'BUD201', 1, N'https://www.youtube.com/watch?v=Ryn49zHaYcM'),
    (N'BUD201', 3, N'https://www.youtube.com/watch?v=RLgm_wkaAEw'),
    (N'BUD201', 4, N'https://www.youtube.com/watch?v=HJez8egLQcc'),
    (N'BUD201', 6, N'https://www.youtube.com/watch?v=Zu1kaPLt66E'),
    (N'BUD201', 8, N'https://www.youtube.com/watch?v=8LsD73abBYo'),
    (N'SAV101', 1, N'https://www.youtube.com/watch?v=-OAUpu9nhMU'),
    (N'SAV101', 3, N'https://www.youtube.com/watch?v=NMU5khdLgr4'),
    (N'SAV101', 4, N'https://www.youtube.com/watch?v=cs_iYDU8ugM'),
    (N'SAV201', 1, N'https://www.youtube.com/watch?v=Duxo4xXeMec'),
    (N'SAV201', 3, N'https://www.youtube.com/watch?v=OhRDvSnJxZk'),
    (N'SAV201', 4, N'https://www.youtube.com/watch?v=VtUDhbGxo_0'),
    (N'SAV201', 6, N'https://www.youtube.com/watch?v=zMet_DFnitQ'),
    (N'INV101', 1, N'https://www.youtube.com/watch?v=6UdC93aERMY'),
    (N'INV101', 2, N'https://www.youtube.com/watch?v=7mo167ohvJw'),
    (N'INV101', 4, N'https://www.youtube.com/watch?v=WWVzZQf17aE'),
    (N'INV101', 5, N'https://www.youtube.com/watch?v=FmTX-XCxtII'),
    (N'INV101', 7, N'https://www.youtube.com/watch?v=MZchH0Ddzn8'),
    (N'INV101', 9, N'https://www.youtube.com/watch?v=D6go3NOON1c'),
    (N'INV101', 11, N'https://www.youtube.com/watch?v=K6OIu-Vzkic'),
    (N'INV301', 2, N'https://www.youtube.com/watch?v=0--AvwZabIQ'),
    (N'INV301', 3, N'https://www.youtube.com/watch?v=FaY17jAD29Y'),
    (N'INV301', 4, N'https://www.youtube.com/watch?v=CMv1zlZhb4Q'),
    (N'INV301', 6, N'https://www.youtube.com/watch?v=DiVPAjgmnj0'),
    (N'INV301', 8, N'https://www.youtube.com/watch?v=YxUK0nzf6eg'),
    (N'INV301', 10, N'https://www.youtube.com/watch?v=HRiAXk3t0EM'),
    (N'INV301', 12, N'https://www.youtube.com/watch?v=XhCeX98vY28'),
    (N'INV301', 13, N'https://www.youtube.com/watch?v=Y62o9JbQYOk'),
    (N'DEB101', 1, N'https://www.youtube.com/watch?v=SnlHbMIWJak'),
    (N'DEB101', 3, N'https://www.youtube.com/watch?v=jtgnRJKSJlw'),
    (N'DEB101', 5, N'https://www.youtube.com/watch?v=SDciJugmvKo'),
    (N'TAX101', 1, N'https://www.youtube.com/watch?v=m1Z0s3cbML0'),
    (N'TAX101', 3, N'https://www.youtube.com/watch?v=_0z02EfJiEM'),
    (N'TAX101', 4, N'https://www.youtube.com/watch?v=w1S9AdngrZg'),
    (N'TAX301', 3, N'https://www.youtube.com/watch?v=gYmYR0_FYGg'),
    (N'TAX301', 6, N'https://www.youtube.com/watch?v=RnMOIi65_kM'),
    (N'INS101', 1, N'https://www.youtube.com/watch?v=3ctoSEQsY54'),
    (N'INS101', 2, N'https://www.youtube.com/watch?v=Ty-IdP0uhM8'),
    (N'INS101', 4, N'https://www.youtube.com/watch?v=tuSS61eKC48'),
    (N'RET201', 1, N'https://www.youtube.com/watch?v=jLQEqZaJqYU'),
    (N'RET201', 3, N'https://www.youtube.com/watch?v=3VSH6Ufx5Q8'),
    (N'RET201', 5, N'https://www.youtube.com/watch?v=fyBKteJDUKY'),
    (N'RET201', 7, N'https://www.youtube.com/watch?v=SEItn9Csitg'),
    (N'FIN101', 1, N'https://www.youtube.com/watch?v=n5g_T287kJw'),
    (N'FIN101', 3, N'https://www.youtube.com/watch?v=EWk1WCB68lg')
) AS s (CourseCode, Position, Url)
JOIN dbo.Courses c       ON c.CourseCode = s.CourseCode
JOIN dbo.CourseLessons l ON l.CourseId = c.CourseId AND l.Position = s.Position
WHERE l.ContentType = 'Video' AND l.ContentUrl IS NULL;

------------------------------------------------------------------------------
-- 3. Lesson blocks
------------------------------------------------------------------------------
DECLARE @Blocks TABLE (
    CourseCode NVARCHAR(20)  NOT NULL,
    LessonPos  INT           NOT NULL,
    BlockPos   INT           NOT NULL,
    BlockType  NVARCHAR(10)  NOT NULL,
    MediaKind  NVARCHAR(10)  NULL,
    MediaUrl   NVARCHAR(400) NULL,
    Body       NVARCHAR(MAX) NULL
);

-- BUD101
INSERT INTO @Blocks VALUES

(N'BUD101', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=hYoqJiaukGw',
N'Video: "Why Most Budgets Fail (7 Common Budgeting Pitfalls)" by Lissa Lumutenga, CFP (YouTube).')
,
(N'BUD101', 1, 2, N'Text', NULL, NULL,
N'A budget is a plan for your money: how much comes in each month, and where every ringgit is meant to go. Most first budgets fail for the same few reasons, and none of them is a lack of willpower.

Common reasons a budget breaks:
- It is built on guesses instead of what you really spent last month.
- It is too tight, with nothing left for food with friends or small treats, so you give up on it.
- It forgets bills that do not come every month: road tax, insurance, festive spending, a laptop repair.
- It is never reviewed, so small leaks (subscriptions, delivery fees) grow quietly.

How yours will be different:
1. You will start from a real month of spending (next lesson).
2. You will keep a small "fun" line on purpose, so the plan is one you can live with.
3. You will put aside a little each month for irregular bills.
4. You will review it once a month, in about 20 minutes.

Remember: a budget is not a punishment. It is a way of deciding in advance, while you are calm, what matters most to you.')
,
(N'BUD101', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Why Most Budgets Fail (7 Common Budgeting Pitfalls), Lissa Lumutenga, CFP: https://www.youtube.com/watch?v=hYoqJiaukGw
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp
- KWSP: EPF releases Belanjawanku 2024/2025 and the Retirement Income Adequacy framework: https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework')
,
(N'BUD101', 2, 1, N'Text', NULL, NULL,
N'You cannot plan what you have not measured. For the next 30 days, record every ringgit that leaves your accounts, e-wallets and purse.

How to track without hating it:
- Download your bank and e-wallet statements at the end of the month instead of writing down every coffee. Touch ''n Go, GrabPay, ShopeePay and your bank app all let you export history.
- Keep cash spending in a single note on your phone. Cash is where most tracking gaps come from.
- Give each line a simple category: housing, food at home, food outside, transport, bills, debt payments, personal, giving, savings.

At the end of the month, add each category up. Most people find two surprises: food outside the home is far higher than expected, and small digital payments add up to hundreds of ringgit.

Compare your numbers with a reference. EPF''s Belanjawanku guide publishes typical monthly expenses for different households in Malaysian cities, which is useful for checking whether your rent or transport is unusually high.

Do not judge the numbers yet. This month is about honest data. You will make decisions with it in the next lessons.')
,
(N'BUD101', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- KWSP: EPF releases Belanjawanku 2024/2025 and the Retirement Income Adequacy framework: https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp')
,
(N'BUD101', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=LKxOamnP8J4',
N'Video: "Budgeting and the 50:30:20 rule" by Khan Academy (YouTube).')
,
(N'BUD101', 3, 2, N'Text', NULL, NULL,
N'The 50/30/20 rule is a simple starting point for splitting your take-home pay:
- 50% for needs: rent, utilities, groceries, transport to work, minimum debt payments, insurance.
- 30% for wants: eating out, shopping, streaming, holidays, hobbies.
- 20% for savings and extra debt payments: emergency fund, investing, paying off cards faster.

Example with RM3,000 take-home pay:
- Needs: RM1,500
- Wants: RM900
- Savings: RM600

Treat the rule as a guide, not a law. In expensive cities, needs often take 60% or more of a first salary, especially rent. If that is you, it is fine to start with something like 60/25/15 and move towards 50/30/20 as your income grows.

The two questions that matter:
1. Is something going to savings every month, even if small?
2. Are your needs really needs? A phone plan is a need; the most expensive phone plan is partly a want.

Use your tracked month from the previous lesson to see where you are today, then pick target percentages that are realistic for the next three months.')
,
(N'BUD101', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Budgeting and the 50:30:20 rule, Khan Academy: https://www.youtube.com/watch?v=LKxOamnP8J4
- Investopedia: The 50/30/20 budget rule: https://www.investopedia.com/ask/answers/022916/what-502030-budget-rule.asp
- KWSP: EPF releases Belanjawanku 2024/2025 and the Retirement Income Adequacy framework: https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework')
,
(N'BUD101', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=ndFexNfakf8',
N'Video: "EASY Budget & Expense Tracker with Google Sheets! *FULL TUTORIAL*" by Jeremy''s Tutorials (YouTube).')
,
(N'BUD101', 4, 2, N'Text', NULL, NULL,
N'A budget sheet only needs four parts. You can build it in Google Sheets or Excel in about 15 minutes, or copy the structure into a budgeting app.

1. Income: your take-home pay after EPF, SOCSO, EIS and PCB, plus any side income you can count on.
2. Fixed costs: amounts that barely change, such as rent, loan instalments, phone plan, insurance premiums.
3. Variable costs: groceries, petrol or transit, eating out, personal shopping. Set a monthly limit for each.
4. Savings: emergency fund, sinking funds for irregular bills, investing.

Add two columns next to every line: "Planned" and "Actual". Each week, paste in your actual spending. A third column, "Difference", shows instantly where you are over.

Tips that keep the sheet useful:
- Keep the number of categories small (8 to 12). Too many and you will stop updating it.
- Put savings near the top, not at the bottom, so it is paid first.
- Use one tab per month and copy last month''s tab to start the next one.

The video walks through building an expense tracker step by step in Google Sheets.')
,
(N'BUD101', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: EASY Budget & Expense Tracker with Google Sheets! *FULL TUTORIAL*, Jeremy''s Tutorials: https://www.youtube.com/watch?v=ndFexNfakf8
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp')
,
(N'BUD101', 5, 1, N'Text', NULL, NULL,
N'The envelope method is an old cash system: you put each category''s money in its own envelope, and when an envelope is empty, spending in that category stops for the month.

Very few people carry that much cash today, but the idea works digitally:
- Use separate accounts or "pockets". Many Malaysian banks and digital banks let you create sub-accounts or saving pockets inside the app.
- Use an e-wallet as your "food outside" or "fun" envelope. Top it up with the monthly amount on payday and spend only from it.
- Keep fixed bills in the main account, on auto-debit.

Why it works: you see the remaining balance before you spend, not after. The decision becomes "Do I want this more than the rest of this week''s food?" rather than "Can I afford it?" (the answer to which is often yes, until the month ends).

Rules of thumb:
- Start with envelopes for the two or three categories where you overspend most, not everything.
- If you overspend one envelope, move money from another envelope, never from savings.
- At month end, roll leftovers into savings or next month''s envelope.')
,
(N'BUD101', 5, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp')
,
(N'BUD101', 6, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=4siS3vQE4Eg',
N'Video: "What is a Sinking Fund and How Do You Create One?" by Rachel Cruze (YouTube).')
,
(N'BUD101', 6, 2, N'Text', NULL, NULL,
N'Some bills arrive once or twice a year, and they are the most common reason a good monthly budget breaks. Think road tax and car insurance, annual subscriptions, school fees, Hari Raya, Chinese New Year or Deepavali spending, gifts, and gadget replacements.

The fix is a sinking fund: you save a small, fixed amount every month for a known future cost.

How to set one up:
1. List every non-monthly cost you paid last year. Your bank statements will remind you.
2. Write down the amount and the month it is due.
3. Divide each amount by the number of months until it is due.

Example: car insurance and road tax of RM1,200 due in 12 months means RM100 a month. Festive spending of RM900 in 9 months means RM100 a month.

Keep sinking funds separate from your emergency fund. The emergency fund is for surprises; sinking funds are for things you know are coming. When the bill arrives, you pay it from the fund and your monthly budget does not notice.')
,
(N'BUD101', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: What is a Sinking Fund and How Do You Create One?, Rachel Cruze: https://www.youtube.com/watch?v=4siS3vQE4Eg
- Investopedia: Sinking fund: https://www.investopedia.com/terms/s/sinkingfund.asp
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp')
,
(N'BUD101', 7, 1, N'Text', NULL, NULL,
N'Your first monthly review is where the budget becomes a habit. Block 20 minutes near the end of the month.

The review, step by step:
1. Fill in the "Actual" column for every category.
2. Circle the three biggest differences between planned and actual.
3. For each one, ask: was the plan unrealistic, or was the spending a one-off? Adjust next month''s plan only if the plan was unrealistic.
4. Check savings: did the planned amount actually move? If not, set up an automatic transfer on payday.
5. Look ahead: any irregular bills, birthdays or trips next month? Add them now.

Signs your budget is working:
- You are not using your credit card to cover the last week of the month.
- Your emergency fund and sinking funds are growing, even slowly.
- You can spend on wants without guilt, because they are planned.

Expect the first three months to be messy. Every review makes the plan more accurate. After that, most people only need a quick check each month and a deeper look once a year or when their income changes.')
,
(N'BUD101', 7, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp')
,
(N'BUD101', 8, 1, N'Text', NULL, NULL,
N'Check what you learned in Your First Monthly Budget. Choose an answer for each question before opening it.')
,
(N'BUD101', 8, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"Under the 50/30/20 rule, how much of RM3,000 take-home pay goes to savings?","options":["RM300","RM600","RM900","RM1,500"],"answer":1},{"q":"Which of these is a ''need'' rather than a ''want''?","options":["A streaming subscription","Monthly rent","A weekend trip","New sneakers"],"answer":1},{"q":"What is a sinking fund for?","options":["Unexpected emergencies like losing your job","Known costs that come once or twice a year","Long-term retirement investing","Paying off a credit card"],"answer":1},{"q":"Road tax and insurance of RM1,200 are due in 12 months. How much should you set aside each month?","options":["RM50","RM100","RM120","RM200"],"answer":1},{"q":"What is the best first step when building a budget?","options":["Copy someone else''s budget","Track a real month of spending","Cut all wants to zero","Open a credit card"],"answer":1},{"q":"You overspent your ''eating out'' envelope. What should you do?","options":["Take money from savings","Move money from another spending envelope","Use a credit card and pay later","Stop budgeting"],"answer":1}]}')
,
(N'BUD101', 8, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: The 50/30/20 budget rule: https://www.investopedia.com/ask/answers/022916/what-502030-budget-rule.asp
- Investopedia: Sinking fund: https://www.investopedia.com/terms/s/sinkingfund.asp
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp')
;

-- BUD201
INSERT INTO @Blocks VALUES

(N'BUD201', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=Ryn49zHaYcM',
N'Video: "What Is a Zero-Based Budget?" by EveryDollar (YouTube).')
,
(N'BUD201', 1, 2, N'Text', NULL, NULL,
N'Zero-based budgeting means income minus everything you plan for equals zero. Not zero money in the bank, but zero ringgit without a job.

If you take home RM4,200, you assign all RM4,200 before the month starts: bills, food, transport, giving, debt payments, savings, investing, even fun money. Anything not needed for spending is assigned to a savings or debt goal.

The idea started in business: in the 1970s Peter Pyhrr popularised building each year''s budget from zero, justifying every line, instead of adding a few percent to last year''s numbers. For households it has the same benefit: every expense has to earn its place.

Why it helps:
- Money left "floating" in your account tends to get spent. Giving it a job protects it.
- It forces you to make trade-offs consciously. Want a new phone? Which line gives up money for it?
- It makes saving the default, not the leftover.

What it is not: it is not a rule that you must spend everything. Savings and investments are jobs too.')
,
(N'BUD201', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: What Is a Zero-Based Budget?, EveryDollar: https://www.youtube.com/watch?v=Ryn49zHaYcM
- Investopedia: Zero-based budgeting: https://www.investopedia.com/terms/z/zbb.asp
- Wikipedia: Zero-based budgeting: https://en.wikipedia.org/wiki/Zero-based_budgeting')
,
(N'BUD201', 2, 1, N'Text', NULL, NULL,
N'A zero-based budget only works if your categories cover your whole life. Missing categories are where money leaks.

Build your list in three layers:

1. Monthly essentials: rent or mortgage, utilities (electricity, water, internet), phone, groceries, transport (petrol, tolls, parking, public transit or e-hailing), insurance or takaful premiums, loan and PTPTN instalments, childcare.

2. Monthly lifestyle: eating out and drinks, food delivery, subscriptions, personal care, clothing, hobbies, gifts, giving (zakat, sedekah, donations), allowance for parents.

3. Non-monthly (turn these into sinking funds): road tax and car insurance, car servicing and tyres, festive spending, travel, annual subscriptions and memberships, medical and dental top-ups, gadget replacement, education fees.

Then add your goal categories: emergency fund, investing, extra debt payments, big-goal savings.

Use your bank and e-wallet statements from the last three months to check nothing is missing. A good test: if you can name an expense that happened last year and it has no home in your list, add one.')
,
(N'BUD201', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Zero-based budgeting: https://www.investopedia.com/terms/z/zbb.asp
- KWSP: EPF releases Belanjawanku 2024/2025 and the Retirement Income Adequacy framework: https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework
- Investopedia: Sinking fund: https://www.investopedia.com/terms/s/sinkingfund.asp')
,
(N'BUD201', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=RLgm_wkaAEw',
N'Video: "How to Budget on an Irregular Income" by EveryDollar (YouTube).')
,
(N'BUD201', 3, 2, N'Text', NULL, NULL,
N'Freelancers, gig workers, commission earners and small business owners do not know next month''s income. Zero-based budgeting still works, with two changes.

1. Budget on your lowest realistic month. Look at the last 6 to 12 months and take a low month (not the very worst one). Plan your essentials to fit inside that number.

2. Pay yourself a "salary". Keep a separate business or holding account. All income lands there. On the same date each month, move a fixed amount to your personal account, the salary you budgeted. In good months the holding account grows; in bad months it tops you up.

When a big month arrives, give the extra a job in this order:
- Fill the holding account until it covers 1 to 3 months of your salary.
- Set aside money for tax. Self-employed income has no PCB, so you pay the tax yourself (see the TAX301 course).
- Top up your emergency fund.
- Then goals: debt, investing, big purchases.

The prioritised list also helps in a bad month: you know exactly which lines stop first.')
,
(N'BUD201', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How to Budget on an Irregular Income, EveryDollar: https://www.youtube.com/watch?v=RLgm_wkaAEw
- Investopedia: Zero-based budgeting: https://www.investopedia.com/terms/z/zbb.asp
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- LHDN (HASiL): Instalment scheme (CP500): https://www.hasil.gov.my/en/individu/bayaran/bayaran-pendahuluan-anggaran-cukai/')
,
(N'BUD201', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=HJez8egLQcc',
N'Video: "The 6 "Sinking Funds" That Make Me Ready For Any Expense" by The Financial Diet (YouTube).')
,
(N'BUD201', 4, 2, N'Text', NULL, NULL,
N'In a zero-based budget, sinking funds are just categories you fund every month but spend only occasionally.

Typical sinking funds in Malaysia:
- Car: road tax, insurance renewal, servicing, tyres.
- Festive season: Hari Raya, CNY, Deepavali, Christmas: duit raya and ang pao, travel home, clothes, open house.
- Travel and holidays.
- Medical and dental extras not covered by insurance.
- Gadgets: phone and laptop replacement every few years.
- Annual fees: memberships, software, professional bodies.

Running them simply:
- One savings account with a list in your sheet works fine. You do not need a separate bank account for each fund, just track each balance.
- Fund them on payday, by automatic transfer.
- When you pay the bill, take the money from the fund, not from this month''s spending categories.

If an annual cost is larger than you expected, increase the monthly amount right away instead of waiting for next year.')
,
(N'BUD201', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: The 6 "Sinking Funds" That Make Me Ready For Any Expense, The Financial Diet: https://www.youtube.com/watch?v=HJez8egLQcc
- Investopedia: Sinking fund: https://www.investopedia.com/terms/s/sinkingfund.asp
- Investopedia: Zero-based budgeting: https://www.investopedia.com/terms/z/zbb.asp')
,
(N'BUD201', 5, 1, N'Text', NULL, NULL,
N'Some months the money simply is not enough for every category. A clear order of priorities stops panic decisions, like skipping rent to pay a credit card.

A widely used order when money is short:
1. Food and essential utilities (electricity, water).
2. Shelter: rent or home loan.
3. Transport needed to keep earning.
4. Insurance that protects your income and health.
5. Minimum payments on secured loans (car, house), because the asset can be repossessed.
6. Minimum payments on unsecured debt (credit cards, personal loans).
7. Everything else: wants, extra savings, extra debt payments.

Practical steps:
- Pause sinking-fund contributions and extra investing first. They can restart later.
- Cut wants to the minimum for a month or two.
- Call your bank before you miss a payment. Banks have hardship and rescheduling options, and AKPK offers free advice and a Debt Management Programme (see DEB101).
- Never borrow from an unlicensed lender (Ah Long) to fill a gap.

A short squeeze is a budget problem. A squeeze lasting several months is an income or debt problem, and needs a bigger plan.')
,
(N'BUD201', 5, 2, N'Text', NULL, NULL,
N'Sources and further reading
- AKPK: Debt Management Programme: https://www.akpk.org.my/debt-management-programme
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp')
,
(N'BUD201', 6, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=Zu1kaPLt66E',
N'Video: "The money talk that every couple needs to have" by TED (YouTube).')
,
(N'BUD201', 6, 2, N'Text', NULL, NULL,
N'Budgeting as a couple is mostly about communication, and only partly about spreadsheets.

Three common ways to organise money:
1. Fully joint: all income goes into one account and is budgeted together.
2. Yours, mine and ours: each partner contributes to a joint account for shared costs and keeps a personal account.
3. Fully separate: each pays agreed bills from their own account.

How much each puts into shared costs can be equal, or proportional to income (for example, a partner who earns 60% of household income pays 60% of shared costs). Proportional splits often feel fairer when incomes are very different.

Make it work:
- Hold a short monthly money meeting: review last month, plan next month, check goals.
- Give each person a personal allowance that needs no explanation.
- Agree a spending limit (for example RM500) above which you check with each other first.
- Be honest about debts, family support (allowance for parents is common in Malaysia), and goals.

No system is right for everyone. The right one is the system both of you understand and agree on.')
,
(N'BUD201', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: The money talk that every couple needs to have, TED: https://www.youtube.com/watch?v=Zu1kaPLt66E
- Investopedia: Zero-based budgeting: https://www.investopedia.com/terms/z/zbb.asp
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp')
,
(N'BUD201', 7, 1, N'Text', NULL, NULL,
N'Automating transfers on payday is the most reliable way to keep a zero-based budget. You make the decision once and the bank repeats it.

Set up on payday (or the day after):
1. Savings transfer: emergency fund and investing go out first ("pay yourself first").
2. Sinking funds: one transfer to your sinking-fund account.
3. Bills: auto-debit or standing instructions for rent, loans, insurance, utilities.
4. Spending: move your monthly "fun" and "food outside" amounts to a separate account or e-wallet.

What remains in the main account is for variable essentials like groceries and petrol.

Tools in Malaysia: most banking apps support scheduled or recurring transfers and DuitNow. Many digital banks let you create saving pockets with automatic transfers. EPF also accepts voluntary contributions (i-Saraan and i-Topup) if you want to automate extra retirement savings.

Check automation every few months: confirm amounts still match your plan, and increase savings transfers whenever your income goes up. Automating a raise before you get used to spending it is one of the easiest wins in personal finance.')
,
(N'BUD201', 7, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp
- KWSP: i-Topup, contributing more than the statutory rate: https://www.kwsp.gov.my/en/member/savings/voluntary-excess')
,
(N'BUD201', 8, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=8LsD73abBYo',
N'Video: "9 Ways You''re Sabotaging Your Budget Without Realizing It" by The Financial Diet (YouTube).')
,
(N'BUD201', 8, 2, N'Text', NULL, NULL,
N'By the middle of the month you will know whether the plan is holding. A five-minute check-in on the 15th catches problems while they can still be fixed.

The mid-month check:
1. Compare each variable category''s spending so far with half its monthly limit.
2. Any category above 60% by mid-month is at risk.
3. Decide: slow down, or move money from another category to cover it. In a zero-based budget, money must come from somewhere specific, never from "nowhere".

Rules for moving money:
- Move between spending categories freely.
- Avoid taking from sinking funds, and never from the emergency fund for a want.
- Write down every change so the review at month end shows what really happened.

If the same category is over every month, the plan is wrong, not you. Increase that category in next month''s plan and reduce another one.

Watch for budget leaks: small frequent purchases, delivery fees, in-app purchases, and "buy now, pay later" instalments that pile up across several apps.')
,
(N'BUD201', 8, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: 9 Ways You''re Sabotaging Your Budget Without Realizing It, The Financial Diet: https://www.youtube.com/watch?v=8LsD73abBYo
- Investopedia: Zero-based budgeting: https://www.investopedia.com/terms/z/zbb.asp
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp')
,
(N'BUD201', 9, 1, N'Text', NULL, NULL,
N'A budget is a habit, and habits need a fixed time and place.

The monthly review (about 30 minutes, on the same day each month):
1. Record actual spending for every category.
2. Note the three biggest differences and why they happened.
3. Update sinking-fund and goal balances.
4. Build next month''s zero-based plan, including known events.

The yearly review (about an hour, once a year, or after a pay rise or big life change):
- Compare total spending to last year.
- Re-check insurance cover, EPF statement and tax reliefs before the filing season.
- Raise savings and investing percentages if your income went up.
- Retire categories you no longer need, add new ones.

Make it easier to stick to:
- Put the review in your calendar as a repeating event.
- Pair it with something pleasant, a favourite drink or café.
- Track one motivating number, such as net worth or months of expenses saved.

Research on habits shows consistency matters more than intensity. A short review you never skip beats a long one you do twice a year.')
,
(N'BUD201', 9, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/')
,
(N'BUD201', 10, 1, N'Text', NULL, NULL,
N'Final quiz for Zero-Based Budgeting in Practice. Choose an answer for each question before opening it.')
,
(N'BUD201', 10, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"In a zero-based budget, what should equal zero?","options":["Your bank balance at month end","Income minus all assigned money","Your savings","Your credit card balance"],"answer":1},{"q":"With irregular income, what should you budget on?","options":["Your best month","Your average month","A realistic low month","Next year''s expected income"],"answer":2},{"q":"Which bill should usually come first when money is short?","options":["Credit card minimum payment","Food and essential utilities","Streaming subscriptions","Extra investing"],"answer":1},{"q":"What does ''pay yourself first'' mean?","options":["Spend on wants before bills","Move savings out on payday before spending","Pay yourself a bonus every month","Pay your credit card first"],"answer":1},{"q":"A partner earns 60% of household income. Under a proportional split, what share of shared costs do they pay?","options":["40%","50%","60%","100%"],"answer":2},{"q":"By mid-month you have spent 70% of your groceries budget. What is the best move?","options":["Ignore it until month end","Take money from the emergency fund","Slow down or move money from another spending category","Stop buying groceries"],"answer":2}]}')
,
(N'BUD201', 10, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Zero-based budgeting: https://www.investopedia.com/terms/z/zbb.asp
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp')
;

-- SAV101
INSERT INTO @Blocks VALUES

(N'SAV101', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=-OAUpu9nhMU',
N'Video: "Everything You Need To Know About Emergency Funds | The 3-Minute Guide" by The Financial Diet (YouTube).')
,
(N'SAV101', 1, 2, N'Text', NULL, NULL,
N'An emergency fund is money set aside only for unexpected, necessary costs: losing your job, a medical bill, an urgent car or home repair, or flying home for a family emergency.

Why it matters:
- Without one, an emergency usually goes on a credit card (up to 18% a year in Malaysia) or a personal loan, and a one-time problem becomes a long-term debt.
- It buys you time. If you lose your job, three to six months of expenses lets you look for the right next job instead of the first one.
- It reduces stress, which helps you make better decisions in every other part of your finances.

What it is not for:
- Holidays, festive shopping, a new phone (use sinking funds, see BUD101).
- Investing opportunities.
- Things you knew were coming.

A useful test before using it: is it unexpected, is it necessary, and is it urgent? If the answer to all three is yes, use the fund without guilt. That is exactly its job.')
,
(N'SAV101', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Everything You Need To Know About Emergency Funds | The 3-Minute Guide, The Financial Diet: https://www.youtube.com/watch?v=-OAUpu9nhMU
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- Bank Negara Malaysia: Policy document on Credit Card and Credit Card-i: https://www.bnm.gov.my/documents/20124/938039/credit_card_and_credit_card-i_PD.pdf')
,
(N'SAV101', 2, 1, N'Text', NULL, NULL,
N'The common guideline is three to six months of essential expenses. Note: expenses, not income, and essentials only.

Step 1: Work out your essential monthly costs: rent or home loan, utilities, groceries, transport, insurance or takaful, minimum loan payments, and family support you cannot stop. Leave out eating out, shopping and holidays.

Example: RM2,200 of essentials a month gives a target of RM6,600 (3 months) to RM13,200 (6 months).

Step 2: Pick your number of months. Aim for the higher end if:
- your income is irregular (freelance, commission, gig work),
- you are the only earner in the household,
- you support parents or children,
- your industry has frequent layoffs,
- you have no medical card.

Aim for the lower end if you have a stable job, a second household income and good insurance.

Step 3: Start with a mini target. RM1,000 covers many small emergencies and is reachable in a few months. Then build to one month of expenses, then three.

Note that EPF''s Akaun Fleksibel (Account 3) can be withdrawn at any time, which can act as a last-resort backup, but using it reduces your retirement savings.')
,
(N'SAV101', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- KWSP: EPF Account 3, what you need to know: https://www.kwsp.gov.my/en/w/article/epf-account-3-info
- KWSP: EPF releases Belanjawanku 2024/2025 and the Retirement Income Adequacy framework: https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework')
,
(N'SAV101', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=NMU5khdLgr4',
N'Video: "A complete guide to money market funds | Versa Malaysia" by Swan Thinks (YouTube).')
,
(N'SAV101', 3, 2, N'Text', NULL, NULL,
N'An emergency fund needs to be safe, quickly accessible and kept separate from daily spending. Return comes last.

Common places in Malaysia:

1. Savings account (bank or digital bank): instant access. Deposits at PIDM member banks are protected up to RM250,000 per depositor per member bank. Choose an account at a different bank from your daily account, so it is out of sight.

2. Fixed deposit (FD): a slightly higher rate, also PIDM-protected. Withdrawing early usually means losing some or all interest, so split the fund into several smaller FDs, or keep part in a savings account.

3. Money market funds: unit trust funds that invest in short-term deposits and money market instruments, sold by fund managers and many apps. They often pay more than savings accounts and allow withdrawal within one to a few working days. They are not PIDM-protected, though they are low-risk.

Avoid for emergency money: shares, crypto, property and long-term unit trusts. Their value can fall exactly when you need the money, such as during a recession when layoffs also rise.

A practical mix: one month of expenses in a savings account for instant access, the rest in FDs or a money market fund.')
,
(N'SAV101', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: A complete guide to money market funds | Versa Malaysia, Swan Thinks: https://www.youtube.com/watch?v=NMU5khdLgr4
- PIDM: Coverage for the Deposit Insurance System: https://www.pidm.gov.my/en/for-public/deposit-insurance-system-dis/coverage-for-dis/
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- Securities Commission Malaysia: Investment Checker: https://www.sc.com.my/investment-checker')
,
(N'SAV101', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=cs_iYDU8ugM',
N'Video: "How to Save Money on a Low Income (Realistic Strategies That Work)" by Clever Girl Finance (YouTube).')
,
(N'SAV101', 4, 2, N'Text', NULL, NULL,
N'Building an emergency fund on a tight income is slow, but the habit matters more than the amount.

Strategies that work:
1. Start tiny and automatic. Even RM50 a month, moved on payday, builds a habit. Increase by RM20 every few months.
2. Save windfalls. Bonuses, tax refunds, festive money, side-gig income, and cash gifts go straight to the fund, at least half of each.
3. Round up. Some banks and e-wallets can round up purchases and move the change to savings.
4. Cut one big cost instead of many small ones. A cheaper phone plan, sharing a room, or switching from e-hailing to public transit for daily trips can free more than skipping coffee.
5. Sell what you no longer use: old gadgets, furniture, clothes.
6. Use "no-spend" weeks: once a month, spend only on essentials and move the difference to savings.

Check the numbers: RM100 a month reaches RM1,200 in a year, plus a little interest. That is enough to cover many common emergencies without borrowing.

Most importantly: keep going after a setback. Using the fund for a real emergency is a success, not a failure. Just restart the transfers.')
,
(N'SAV101', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How to Save Money on a Low Income (Realistic Strategies That Work), Clever Girl Finance: https://www.youtube.com/watch?v=cs_iYDU8ugM
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp')
,
(N'SAV101', 5, 1, N'Text', NULL, NULL,
N'Having an emergency fund is half the job. The other half is using it well and refilling it.

Before using it, ask:
- Is it unexpected? (Not a known bill, not a festive season.)
- Is it necessary? (Not a want.)
- Is it urgent? (Cannot wait until you can save for it.)
Three yeses means use it.

Good uses: job loss, a medical bill not covered by insurance, an urgent car repair you need to get to work, a broken fridge, emergency travel for family.

Bad uses: a sale, a holiday, a new phone, lending to friends for non-emergencies, an investment "opportunity".

After using it:
1. Pause extra investing and non-essential sinking funds.
2. Redirect those amounts to refilling the emergency fund until it is back to target.
3. Ask whether the emergency could happen again. If so, fix the cause: better insurance, a car service routine, or a larger fund.

Review your target once a year. If your expenses grew (new rent, a child, a car), your emergency fund should grow too.')
,
(N'SAV101', 5, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- insuranceinfo (BNM): Medical and health insurance: https://insuranceinfo.com.my/learn-the-basics/types-of-insurance/medical-health-insurance/')
,
(N'SAV101', 6, 1, N'Text', NULL, NULL,
N'Check what you learned in Building an Emergency Fund. Choose an answer for each question before opening it.')
,
(N'SAV101', 6, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"What is a common guideline for the size of an emergency fund?","options":["One week of income","3 to 6 months of essential expenses","12 months of total income","RM100,000"],"answer":1},{"q":"Which is a good use of the emergency fund?","options":["A holiday sale","A new phone","A sudden medical bill not covered by insurance","Buying shares during a dip"],"answer":2},{"q":"How much does PIDM protect at a member bank?","options":["RM25,000 per account","RM100,000 per bank","RM250,000 per depositor per member bank","Unlimited"],"answer":2},{"q":"Why are shares a poor place for an emergency fund?","options":["They are illegal for savings","Their value may drop exactly when you need the money","They pay no returns","They cannot be sold"],"answer":1},{"q":"Essential costs are RM2,000 a month. What is a 3-month emergency fund?","options":["RM2,000","RM4,000","RM6,000","RM12,000"],"answer":2},{"q":"Who should aim for the higher end of the range?","options":["Someone with two stable household incomes","A freelancer who supports parents","Someone with very low expenses","A student living at home"],"answer":1}]}')
,
(N'SAV101', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- PIDM: Coverage for the Deposit Insurance System: https://www.pidm.gov.my/en/for-public/deposit-insurance-system-dis/coverage-for-dis/')
;

-- SAV201
INSERT INTO @Blocks VALUES

(N'SAV201', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=Duxo4xXeMec',
N'Video: "How to Set Financial Goals | Step-by-Step Guide" by Money Instructor (YouTube).')
,
(N'SAV201', 1, 2, N'Text', NULL, NULL,
N'"I want to save more" is a wish. "I will save RM18,000 for a house deposit by December 2028" is a goal. The difference is detail.

Use the SMART checklist:
- Specific: what exactly? A down payment for a RM400,000 condo.
- Measurable: how much? RM40,000 for 10% plus around RM15,000 for fees and moving costs.
- Achievable: does the monthly amount fit your budget?
- Relevant: does it matter to you, not just to people around you?
- Time-bound: by when?

Write each goal with three numbers: target amount, deadline, and monthly saving needed.

Sort goals by time:
- Short term (under 2 years): a holiday, a laptop, a wedding deposit. Keep this money safe: savings accounts, FDs, money market funds.
- Medium term (2 to 5 years): a car, a house deposit, a wedding.
- Long term (over 5 years): children''s education, financial independence, retirement. These can usually take more investment risk.

Finally, give each goal its own name and balance in your budget. Seeing "House 2028: RM6,200 of RM55,000" is far more motivating than an anonymous savings account.')
,
(N'SAV201', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How to Set Financial Goals | Step-by-Step Guide, Money Instructor: https://www.youtube.com/watch?v=Duxo4xXeMec
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp')
,
(N'SAV201', 2, 1, N'Text', NULL, NULL,
N'Working backwards turns a big number into a monthly one.

The basic formula:
monthly saving = (target amount - what you already have) / months left

Example: a RM30,000 wedding in 30 months, with RM6,000 already saved:
(30,000 - 6,000) / 30 = RM800 a month.

Adjust for returns. If the money earns around 3% a year in an FD or money market fund, you can save slightly less each month, because interest adds a little. For short deadlines the difference is small, so many people ignore it and treat interest as a buffer.

Adjust for inflation. Prices rise. If your deadline is more than a few years away, increase the target by an estimate of inflation, for example 2% to 3% a year.

If the monthly number is too high, you have four levers:
1. Extend the deadline.
2. Lower the target (smaller wedding, cheaper car).
3. Increase income (side income, raise).
4. Cut other spending.

Recalculate every 6 months. Life changes, and a goal that is updated stays realistic.')
,
(N'SAV201', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Compound interest: https://www.investopedia.com/terms/c/compoundinterest.asp
- Investopedia: Inflation: https://www.investopedia.com/terms/i/inflation.asp')
,
(N'SAV201', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=OhRDvSnJxZk',
N'Video: "Financing vs. Paying Cash For a Car: Which is the Best Strategy?" by The Money Guy Show (YouTube).')
,
(N'SAV201', 3, 2, N'Text', NULL, NULL,
N'A car is often a Malaysian''s second-biggest purchase, and hire-purchase loans of 7 to 9 years are common. A larger down payment saves a lot of interest.

Know the true cost of a car loan:
Malaysian hire-purchase loans have traditionally quoted a flat rate, where interest is calculated on the original loan for the whole term. A 3% flat rate actually costs much more than 3% a year on a reducing balance. Bank Negara''s hire purchase consumer guide explains the move to the effective interest rate (EIR), so check the EIR when comparing offers.

Plan the purchase:
1. Decide the full budget: price, insurance, road tax, petrol, parking, tolls and servicing. A common guideline is to keep total car costs below 15% to 20% of take-home pay.
2. Save a down payment of at least 10%, ideally more. Larger down payments mean a smaller loan and less total interest.
3. Choose a shorter loan term if the monthly payment still fits.
4. Consider a reliable used car. Most depreciation happens in the first few years.

Use the formula from the previous lesson to work out the monthly saving needed for your down payment and first-year costs (insurance and road tax).')
,
(N'SAV201', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Financing vs. Paying Cash For a Car: Which is the Best Strategy?, The Money Guy Show: https://www.youtube.com/watch?v=OhRDvSnJxZk
- Bank Negara Malaysia: Hire purchase consumer guide (effective interest rate): https://www.bnm.gov.my/documents/20124/40668/HP+Consumer+Guide_EN_2026.pdf
- Investopedia: Compound interest: https://www.investopedia.com/terms/c/compoundinterest.asp')
,
(N'SAV201', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=VtUDhbGxo_0',
N'Video: "First Time Home Buyers'' Guide to Purchase Property in Malaysia" by KCLau''s Money Tips (YouTube).')
,
(N'SAV201', 4, 2, N'Text', NULL, NULL,
N'A home needs more cash upfront than most people expect. Plan for:

1. Down payment: usually 10% of the price (bank loans commonly cover up to 90%).
2. Legal fees for the sale and purchase agreement (SPA) and the loan agreement.
3. Stamp duty on the memorandum of transfer (MOT) and on the loan agreement.
4. Valuation fee, moving costs, renovation and furniture.

Stamp duty relief for first-time buyers: first-time home buyers have a full stamp duty exemption on both the MOT and the loan agreement for homes up to RM500,000, extended to 31 December 2027. In Budget 2027 (October 2026) the government proposed continuing it for sale agreements from 2027 to 2030, with homes up to RM750,000 getting full exemption on the first RM500,000 and 50% on the rest. Check the final rules when you buy, because budget proposals still need to be passed.

Other help: EPF''s Akaun Sejahtera (Account 2) can be withdrawn for buying or building a house, subject to EPF conditions. First-home loan interest also gets tax relief (RM7,000 or RM5,000 depending on price) for SPAs signed from 2025 to 2027.

Rule of thumb: save at least 10% of the price for the deposit, plus another 5% for fees and moving.')
,
(N'SAV201', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: First Time Home Buyers'' Guide to Purchase Property in Malaysia, KCLau''s Money Tips: https://www.youtube.com/watch?v=VtUDhbGxo_0
- The Star: Budget 2027, stamp duty exemption for first-time homebuyers: https://www.thestar.com.my/news/nation/2026/10/09/budget-2027-stamp-duty-exemption-for-first-time-homebuyers
- StashAway: First-time home buyer in Malaysia, costs, schemes and stamp duty: https://www.stashaway.my/r/complete-guide-first-time-home-buyer-buying-house-in-malaysia
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/
- KWSP: A quick guide to EPF account restructuring: https://www.kwsp.gov.my/en/w/article/account-restructuring-guide')
,
(N'SAV201', 5, 1, N'Text', NULL, NULL,
N'Weddings, a master''s degree, a big trip, or a home renovation are one-off goals. They have a fixed date and a cost that is easy to underestimate.

Plan them in three steps:

1. Price it properly. Build a line-by-line list. For a wedding: venue and catering per guest, outfits, photography, hantaran or dowry, rings, invitations, honeymoon. Get two quotes for big items. Add 10% for things you forgot.

2. Agree who pays. For weddings in Malaysia, families often contribute, and gifts (duit kahwin, ang pao) can offset part of the cost. Do not count on gifts in your plan; treat them as a bonus.

3. Set the monthly amount. Use the working-backwards formula. Keep the money in a safe place (savings account, FD or money market fund), because the date is fixed.

Watch out for:
- Financing a one-off event with a personal loan or credit card. You will still be paying for it years later.
- Lifestyle pressure. The best guide is your own budget, not someone else''s social media.

When the event is over, redirect the monthly amount to the next goal immediately, so the habit continues.')
,
(N'SAV201', 5, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Budget: https://www.investopedia.com/terms/b/budget.asp
- Investopedia: Sinking fund: https://www.investopedia.com/terms/s/sinkingfund.asp')
,
(N'SAV201', 6, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=zMet_DFnitQ',
N'Video: "Why (& How) I Maintain 7 Different Savings Accounts" by The Financial Diet (YouTube).')
,
(N'SAV201', 6, 2, N'Text', NULL, NULL,
N'Most people have several goals at once. A simple system keeps them from competing.

1. Put goals in order:
- Emergency fund (at least a starter amount) comes first.
- High-interest debt (credit cards) usually comes next, because paying 15% to 18% interest beats any savings return.
- Then split money between the other goals by deadline and importance.

2. Split by percentage. Example: of RM1,000 saved each month, RM400 to the house deposit, RM300 to the car, RM200 to travel, RM100 to gadgets. Adjust as goals are reached.

3. Keep balances visible. Use separate accounts or saving pockets for each goal, or one account with a tracking sheet. Seeing each goal fill up keeps you motivated.

4. Match the place to the deadline:
- Under 2 years: savings, FDs, money market funds.
- 2 to 5 years: mostly safe, maybe some bonds or balanced funds.
- Over 5 years: investing can make sense (see INV101).

5. Do not forget retirement. EPF covers part of it automatically for employees, but voluntary top-ups or PRS can fill the gap (see RET201).

Review the split every quarter.')
,
(N'SAV201', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Why (& How) I Maintain 7 Different Savings Accounts, The Financial Diet: https://www.youtube.com/watch?v=zMet_DFnitQ
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp
- Investopedia: Emergency fund: https://www.investopedia.com/terms/e/emergency_fund.asp
- Investopedia: Compound interest: https://www.investopedia.com/terms/c/compoundinterest.asp')
,
(N'SAV201', 7, 1, N'Text', NULL, NULL,
N'Final quiz for Saving for Big Goals. Choose an answer for each question before opening it.')
,
(N'SAV201', 7, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"You need RM24,000 in 24 months and have RM0 saved. How much per month?","options":["RM500","RM1,000","RM1,200","RM2,400"],"answer":1},{"q":"What does the ''T'' in SMART goals stand for?","options":["Tax-free","Time-bound","Tracked","Total"],"answer":1},{"q":"Why check the effective interest rate (EIR) on a car loan?","options":["It is always lower than the flat rate","A flat rate understates the true yearly cost of borrowing","EIR loans have no interest","Banks are not allowed to quote flat rates"],"answer":1},{"q":"For first-time buyers, the stamp duty exemption covers homes up to what price (until end-2027)?","options":["RM300,000","RM500,000","RM1 million","There is no limit"],"answer":1},{"q":"Where should money for a goal due in 12 months usually be kept?","options":["Individual shares","Crypto","A savings account, FD or money market fund","A long-term equity fund"],"answer":2},{"q":"Which goal usually comes before the others?","options":["A holiday","A starter emergency fund","A new car","A wedding"],"answer":1}]}')
,
(N'SAV201', 7, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Pay yourself first: https://www.investopedia.com/terms/p/payyourselffirst.asp
- The Star: Budget 2027, stamp duty exemption for first-time homebuyers: https://www.thestar.com.my/news/nation/2026/10/09/budget-2027-stamp-duty-exemption-for-first-time-homebuyers
- Bank Negara Malaysia: Hire purchase consumer guide (effective interest rate): https://www.bnm.gov.my/documents/20124/40668/HP+Consumer+Guide_EN_2026.pdf')
;

-- INV101
INSERT INTO @Blocks VALUES

(N'INV101', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=6UdC93aERMY',
N'Video: "Saving vs Investing: The Smartest Place For Your Money" by NerdWallet (YouTube).')
,
(N'INV101', 1, 2, N'Text', NULL, NULL,
N'Saving and investing are both important, but they do different jobs.

Saving means keeping money safe and easy to reach: savings accounts, fixed deposits, money market funds. The value barely moves, and bank deposits are protected by PIDM. The trade-off is a low return, which may not keep up with inflation over many years.

Investing means buying assets that can grow: shares, bonds, unit trusts, ETFs, REITs. Over long periods they have historically earned more than deposits, but their value goes up and down, sometimes sharply, and there is no guarantee.

A simple rule:
- Money needed within about 3 years: save it.
- Money not needed for 5 years or more: consider investing it.
- In between: a mix, leaning safer as the date gets closer.

Before you invest, have:
1. A starter emergency fund.
2. No high-interest debt (credit cards at 15% to 18% a year cost more than most investments earn).
3. A clear goal and time horizon.

Why bother investing at all? Compounding. RM300 a month for 30 years is RM108,000 put in. At 2% a year it grows to about RM148,000; at 6% to about RM301,000.')
,
(N'INV101', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Saving vs Investing: The Smartest Place For Your Money, NerdWallet: https://www.youtube.com/watch?v=6UdC93aERMY
- Investopedia: Compound interest: https://www.investopedia.com/terms/c/compoundinterest.asp
- Investopedia: Risk-return tradeoff: https://www.investopedia.com/terms/r/riskreturntradeoff.asp
- PIDM: Coverage for the Deposit Insurance System: https://www.pidm.gov.my/en/for-public/deposit-insurance-system-dis/coverage-for-dis/')
,
(N'INV101', 2, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=7mo167ohvJw',
N'Video: "What is risk and return?" by Khan Academy (YouTube).')
,
(N'INV101', 2, 2, N'Text', NULL, NULL,
N'In investing, risk usually means how much and how often the value of an investment moves up and down, and the chance of losing money. Return is what you earn: price gains plus income such as dividends or interest.

The risk-return trade-off: investments that can earn higher returns usually come with bigger swings and a higher chance of loss. There is no reliable high return with no risk. Anyone promising one is a red flag.

From lower to higher risk, roughly:
1. Bank deposits and FDs
2. Money market funds
3. Government bonds and sukuk
4. Corporate bonds
5. Balanced funds (shares plus bonds)
6. Diversified share funds and ETFs
7. Individual shares
8. Speculative assets (crypto, leveraged products)

Time changes the picture. A share fund can lose 30% in a bad year. Over 1 year, that is a real risk to your money. Over 20 years, history shows diversified share markets have recovered from crashes, though past results are no guarantee.

Your risk tolerance depends on:
- Time horizon: longer means you can usually take more risk.
- Need: money for rent next month should not be in shares.
- Temperament: if a 20% drop would make you sell in panic, choose a calmer mix.')
,
(N'INV101', 2, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: What is risk and return?, Khan Academy: https://www.youtube.com/watch?v=7mo167ohvJw
- Investopedia: Risk-return tradeoff: https://www.investopedia.com/terms/r/riskreturntradeoff.asp
- Investopedia: Stock: https://www.investopedia.com/terms/s/stock.asp
- Securities Commission Malaysia: Investor Alert List: https://www.sc.com.my/investor-alert-list')
,
(N'INV101', 3, 1, N'Text', NULL, NULL,
N'A share (stock) is a small piece of ownership in a company. If a company has 1 billion shares and you own 1,000, you own one millionth of it.

What owning a share gives you:
- A claim on future profits. Companies may pay part of their profit as dividends.
- Price changes. If investors expect the company to earn more, the share price tends to rise; if they expect less, it tends to fall.
- Voting rights at the annual general meeting (AGM).
- Limited liability: the most you can lose is what you paid.

Where shares are traded in Malaysia: Bursa Malaysia, the stock exchange, with the Main Market for larger companies and the ACE Market for growth companies. Shares trade in lots of 100 units, although some brokers offer fractional or odd-lot trading.

Two ways shares make money:
1. Dividends: cash paid out of profits, often quarterly or twice a year.
2. Capital gains: selling at a higher price than you paid.

Two ways they lose money:
1. The company does badly and the price falls.
2. The whole market falls, even if the company is fine.

Owning one company is risky. Most beginners are better off starting with funds that hold many companies (lesson 5).')
,
(N'INV101', 3, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Stock: https://www.investopedia.com/terms/s/stock.asp
- Bursa Malaysia: Listed companies: https://www.bursamalaysia.com/listing/listed_companies
- Investopedia: Dividend payout ratio: https://www.investopedia.com/terms/d/dividendpayoutratio.asp')
,
(N'INV101', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=WWVzZQf17aE',
N'Video: "Bond & Sukuk 101" by BIX Malaysia (YouTube).')
,
(N'INV101', 4, 2, N'Text', NULL, NULL,
N'A bond is a loan you make to a government or a company. In return, the issuer pays you interest (the coupon) at set times and repays the face value on the maturity date.

Example: a 5-year bond with a face value of RM1,000 and a 4% coupon pays RM40 a year for 5 years, then returns the RM1,000.

A sukuk is the Islamic finance equivalent. Instead of lending money for interest, sukuk holders own a share in an underlying asset or venture and receive a share of the profit or rental it produces. Malaysia is one of the largest sukuk markets in the world, and the government issues both conventional bonds (MGS) and sukuk (GII).

Main risks:
- Credit risk: the issuer might not pay. Government issuers are usually safer than companies. Ratings agencies grade issuers.
- Interest rate risk: when market rates rise, existing bonds with lower coupons fall in price (and the opposite when rates fall). This matters if you sell before maturity.
- Inflation risk: fixed payments buy less over time.

How individuals invest: mostly through bond or sukuk funds (unit trusts), or via platforms such as BIX Malaysia for retail bonds and sukuk. Bonds usually move less than shares, so they often balance a portfolio.')
,
(N'INV101', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Bond & Sukuk 101, BIX Malaysia: https://www.youtube.com/watch?v=WWVzZQf17aE
- Investopedia: Bond: https://www.investopedia.com/terms/b/bond.asp
- Investopedia: Sukuk: https://www.investopedia.com/terms/s/sukuk.asp')
,
(N'INV101', 5, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=FmTX-XCxtII',
N'Video: "ETFs Or Mutual Funds? What''s The Difference & How To Choose Between Them" by CNA Insider (YouTube).')
,
(N'INV101', 5, 2, N'Text', NULL, NULL,
N'Most beginners invest through funds: a fund pools money from many investors and buys a basket of shares, bonds or both.

Unit trusts (called mutual funds in other countries):
- Managed by a fund manager licensed by the Securities Commission. Bought from the fund house, banks, agents or online platforms.
- Priced once a day at net asset value (NAV) per unit.
- Most are actively managed: the manager picks investments to try to beat the market.
- Costs: a sales charge (up to several percent, lower or zero on many online platforms) plus an annual management fee, often around 1% to 1.8% for equity funds.

ETFs (exchange-traded funds):
- Traded on a stock exchange like a share, through a broker, at live prices.
- Usually track an index (for example, a market index of the 30 biggest companies), so they are passively managed.
- Costs: broker fees when buying and selling, plus usually low annual fees.

How to choose:
- Check fees first. Costs are one of the few things you control (next lesson).
- Read the fund''s prospectus and product highlights sheet: objective, holdings, risks.
- Make sure the provider is licensed: use the SC''s Investment Checker.')
,
(N'INV101', 5, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: ETFs Or Mutual Funds? What''s The Difference & How To Choose Between Them, CNA Insider: https://www.youtube.com/watch?v=FmTX-XCxtII
- Investopedia: Unit trust: https://www.investopedia.com/terms/u/unittrust.asp
- Investopedia: Exchange-traded fund (ETF): https://www.investopedia.com/terms/e/etf.asp
- Securities Commission Malaysia: Investment Checker: https://www.sc.com.my/investment-checker')
,
(N'INV101', 6, 1, N'Text', NULL, NULL,
N'Fees look small as percentages, but they compound against you just as returns compound for you.

Types of fees:
- Sales charge (upfront fee): paid when you buy unit trusts, often 0% to 5.5% depending on where you buy.
- Annual management fee: charged every year as a percentage of your money. Shown in the fund''s total expense ratio (TER) together with trustee and other costs.
- Broker fees: when buying shares or ETFs.
- Platform or wrap fees: some apps and robo-advisors charge a yearly percentage.
- Switching or redemption fees.

How much difference does it make?
Investing RM500 a month for 25 years (RM150,000 put in):
- At 6% a year, minus 0.5% fees (5.5% net), it grows to roughly RM321,000.
- At 6% a year, minus 2% fees (4% net), it grows to roughly RM257,000.
That 1.5% difference costs about RM64,000.

Ways to cut costs:
- Compare TERs between similar funds.
- Buy unit trusts through low or zero sales-charge platforms.
- Consider low-cost index funds or ETFs for the core of your portfolio.
- Avoid switching often.

A higher fee is only worth paying if you get something clearly valuable for it.')
,
(N'INV101', 6, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Expense ratio: https://www.investopedia.com/terms/e/expenseratio.asp
- Investopedia: Compound interest: https://www.investopedia.com/terms/c/compoundinterest.asp
- Investopedia: Unit trust: https://www.investopedia.com/terms/u/unittrust.asp')
,
(N'INV101', 7, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=MZchH0Ddzn8',
N'Video: "What Is Diversification?" by Fidelity Investments (YouTube).')
,
(N'INV101', 7, 2, N'Text', NULL, NULL,
N'Diversification means not putting all your eggs in one basket. Spreading money across many investments means one bad result cannot ruin your plan.

Ways to diversify:
- Across companies: own many companies, not one or two. A fund or ETF does this for you.
- Across sectors: banks, consumer, healthcare, technology, utilities.
- Across countries: Malaysia makes up a small part of the world''s share markets. Global funds add companies from the US, Europe and Asia.
- Across asset types: shares, bonds and sukuk, cash, and maybe REITs. These often move differently from each other.
- Across time: investing a fixed amount regularly (lesson 10).

What diversification does not do: it does not prevent losses in a broad market crash, when most shares fall together. It reduces the risk of one company or one sector hurting you badly.

A common mistake: owning five funds that all hold the same Malaysian banks. Check what each fund actually holds in its fact sheet.

A simple diversified starting point for a long-term goal could be a global share fund plus a bond or sukuk fund. Adjust the mix to your risk tolerance and timeline.')
,
(N'INV101', 7, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: What Is Diversification?, Fidelity Investments: https://www.youtube.com/watch?v=MZchH0Ddzn8
- Investopedia: Diversification: https://www.investopedia.com/terms/d/diversification.asp
- Investopedia: Risk-return tradeoff: https://www.investopedia.com/terms/r/riskreturntradeoff.asp')
,
(N'INV101', 8, 1, N'Text', NULL, NULL,
N'To buy shares or ETFs on Bursa Malaysia you need two accounts:

1. A CDS account (Central Depository System) at Bursa Depository, where your shares are recorded in your name.
2. A trading account with a stockbroker (a Participating Organisation of Bursa Malaysia), through which you place orders.

Most brokers open both for you, often fully online with your MyKad and a selfie or video check.

Choosing a broker, compare:
- Brokerage fees: some charge a percentage of each trade, others a flat fee. For small trades, a low minimum fee matters most.
- Other costs: clearing fee and stamp duty on contract notes apply to every trade.
- Account type: cash upfront accounts (you pay before buying) are best for beginners. Avoid margin accounts until you are experienced.
- Platform: app quality, research, access to foreign markets.
- Licensing: confirm the broker is licensed using the SC''s Investment Checker.

Before your first order:
- Know the stock or ETF code.
- Use a limit order (you set the maximum price) rather than a market order.
- Remember the settlement period: trades settle two market days after the trade date (T+2).

Never give your login or OTP to anyone claiming to be a "remisier" or investment coach on social media.')
,
(N'INV101', 8, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Bursa Malaysia: Listed companies: https://www.bursamalaysia.com/listing/listed_companies
- Securities Commission Malaysia: Investment Checker: https://www.sc.com.my/investment-checker
- Securities Commission Malaysia: Investor Alert List: https://www.sc.com.my/investor-alert-list')
,
(N'INV101', 9, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=D6go3NOON1c',
N'Video: "Should I Use a Robo-Advisor?" by Two Cents (YouTube).')
,
(N'INV101', 9, 2, N'Text', NULL, NULL,
N'A robo-advisor is an online service that builds and manages a diversified portfolio for you, based on a questionnaire about your goals and risk tolerance.

In Malaysia, the Securities Commission introduced a framework for Digital Investment Management (DIM) in 2017. Robo-advisors here must be licensed by the SC as digital investment managers. Several are, including StashAway, Wahed, Kenanga''s platform and others. Always check the current list with the SC''s Investment Checker.

How they work: you answer questions, the service picks a mix (usually of ETFs or funds), invests your deposits automatically, and rebalances when the mix drifts.

Pros:
- Low minimum investment, sometimes from RM1 or RM100.
- Automatic diversification and rebalancing.
- Lower fees than many traditional unit trusts.
- Removes emotion from day-to-day decisions.

Cons:
- An annual management fee on top of the underlying fund fees.
- Limited personal advice.
- Portfolios are based on a model; you do not choose individual investments.
- Your money is still invested in markets, so it can fall in value.

A robo-advisor suits people who want a hands-off, diversified, regular investing habit.')
,
(N'INV101', 9, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Should I Use a Robo-Advisor?, Two Cents: https://www.youtube.com/watch?v=D6go3NOON1c
- Investopedia: Robo-advisor: https://www.investopedia.com/terms/r/roboadvisor-roboadviser.asp
- Securities Commission Malaysia: Framework for Digital Investment Management services: https://www.sc.com.my/resources/media/media-release/sc-introduces-regulatory-framework-to-facilitate-digital-investment-management-services
- Securities Commission Malaysia: Investment Checker: https://www.sc.com.my/investment-checker')
,
(N'INV101', 10, 1, N'Text', NULL, NULL,
N'Dollar-cost averaging (DCA), sometimes called ringgit-cost averaging, means investing a fixed amount at regular intervals, for example RM300 on the 1st of every month, no matter what the market is doing.

Why it helps:
- When prices are high, your RM300 buys fewer units. When prices are low, it buys more. Over time you avoid putting everything in at a peak.
- It removes the need to time the market, which even professionals struggle to do.
- It matches how most people earn: monthly.

Example (unit price, units bought with RM300):
- Month 1: RM1.00, 300 units
- Month 2: RM0.75, 400 units
- Month 3: RM1.25, 240 units
Total: RM900 for 940 units, an average cost of about RM0.96, below the average price of RM1.00.

What DCA does not do: it does not guarantee a profit or protect against a long falling market.

DCA versus lump sum: if you already have a large sum, research suggests investing it all at once has historically done better more often, because markets rise more often than they fall. But DCA reduces regret and is a good choice if a sudden drop would make you panic.

Set it up with an automatic transfer and a standing investment instruction.')
,
(N'INV101', 10, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Dollar-cost averaging: https://www.investopedia.com/terms/d/dollarcostaveraging.asp
- Investopedia: Compound interest: https://www.investopedia.com/terms/c/compoundinterest.asp')
,
(N'INV101', 11, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=K6OIu-Vzkic',
N'Video: "Warren Buffett: 5 Rules For Investing In Stock Market Crashes" by New Money (YouTube).')
,
(N'INV101', 11, 2, N'Text', NULL, NULL,
N'Markets fall regularly. A drop of 10% or more happens most years in some form, and deep falls of 30% or more have happened several times in recent decades (2008, early 2020). Your plan needs to expect this.

What usually goes wrong: people sell after prices have already dropped, locking in losses, and buy back after prices have recovered. Selling in panic turns a temporary fall into a permanent loss.

Before the next fall:
1. Keep an emergency fund, so you never have to sell investments to pay bills.
2. Only invest money you will not need for at least five years.
3. Choose a mix you can live with. If a 30% fall would make you sell, hold more bonds.
4. Write down your plan: "I invest RM500 a month into a global fund until 2045."

During a fall:
- Keep your regular investing going. With DCA, you are buying more units cheaply.
- Look at your plan, not the daily news.
- Rebalance if your mix drifted far from target.
- Check that the fall is market-wide, not a problem with one company you hold.

Past recoveries are not a guarantee, but diversified, patient investors have historically been rewarded.')
,
(N'INV101', 11, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Warren Buffett: 5 Rules For Investing In Stock Market Crashes, New Money: https://www.youtube.com/watch?v=K6OIu-Vzkic
- Investopedia: Dollar-cost averaging: https://www.investopedia.com/terms/d/dollarcostaveraging.asp
- Investopedia: Diversification: https://www.investopedia.com/terms/d/diversification.asp
- Investopedia: Risk-return tradeoff: https://www.investopedia.com/terms/r/riskreturntradeoff.asp')
,
(N'INV101', 12, 1, N'Text', NULL, NULL,
N'Final quiz for Investing Basics: Stocks, Bonds, Funds. Choose an answer for each question before opening it.')
,
(N'INV101', 12, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"Money you need in 12 months is best kept in:","options":["Individual shares","A savings account or money market fund","A global equity ETF","Crypto"],"answer":1},{"q":"What is the risk-return trade-off?","options":["Higher potential return usually comes with higher risk","Lower risk always gives higher return","Risk and return are unrelated","Funds have no risk"],"answer":0},{"q":"A sukuk differs from a conventional bond because holders:","options":["Get no returns","Share in an underlying asset or venture''s profit instead of earning interest","Own the issuing company","Can never sell it"],"answer":1},{"q":"Which is usually true of ETFs?","options":["They trade on an exchange at live prices","They can only be bought once a year","They are always actively managed","They have no fees"],"answer":0},{"q":"What does dollar-cost averaging mean?","options":["Buying only when prices fall","Investing a fixed amount at regular intervals","Selling when prices rise","Converting ringgit to dollars"],"answer":1},{"q":"Who licenses robo-advisors (digital investment managers) in Malaysia?","options":["Bank Negara Malaysia","Bursa Malaysia","The Securities Commission Malaysia","LHDN"],"answer":2},{"q":"The market drops 25%. Your plan is long-term and your emergency fund is in place. A sensible action is:","options":["Sell everything","Continue regular investing and stick to the plan","Borrow money to buy more","Stop checking your plan for good"],"answer":1}]}')
,
(N'INV101', 12, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Risk-return tradeoff: https://www.investopedia.com/terms/r/riskreturntradeoff.asp
- Investopedia: Dollar-cost averaging: https://www.investopedia.com/terms/d/dollarcostaveraging.asp
- Securities Commission Malaysia: Framework for Digital Investment Management services: https://www.sc.com.my/resources/media/media-release/sc-introduces-regulatory-framework-to-facilitate-digital-investment-management-services')
;

-- INV301
INSERT INTO @Blocks VALUES

(N'INV301', 1, 1, N'Text', NULL, NULL,
N'Every company listed on Bursa Malaysia must publish financial results, and that information is free.

Where to find it:
- Bursa Malaysia website: search for the company in the listed companies directory. Its company page links to announcements, quarterly reports and annual reports.
- The company''s investor relations (IR) page on its own website.

What each document gives you:
- Quarterly reports: unaudited results every three months. Good for spotting trends early.
- Annual report: audited financial statements, plus the chairman''s statement, management discussion and analysis (MD&A), corporate governance and sustainability reports.
- Circulars and prospectuses: for big events such as acquisitions, rights issues and listings.

How to read an annual report efficiently:
1. Start with the MD&A: management''s own explanation of the year.
2. Then the three core statements: income statement, balance sheet (statement of financial position) and cash flow statement.
3. Then the notes, where the details (and sometimes the problems) are.
4. Finally the auditor''s report. Look for words like "qualified opinion", "material uncertainty" or "going concern", which are warning signs.

Download at least three to five years of reports, so you can see trends instead of a single snapshot.')
,
(N'INV301', 1, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Annual report: https://www.investopedia.com/terms/a/annualreport.asp
- Bursa Malaysia: Listed companies: https://www.bursamalaysia.com/listing/listed_companies')
,
(N'INV301', 2, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=0--AvwZabIQ',
N'Video: "The INCOME STATEMENT for BEGINNERS" by Accounting Stuff (YouTube).')
,
(N'INV301', 2, 2, N'Text', NULL, NULL,
N'The income statement (also called the statement of profit or loss) shows how much a company earned and spent over a period, usually a quarter or a year.

The structure, top to bottom:
1. Revenue: sales of goods or services.
2. Cost of sales: the direct cost of producing what was sold.
3. Gross profit = revenue - cost of sales.
4. Operating expenses: selling, administration, distribution.
5. Operating profit (sometimes shown as profit from operations or EBIT).
6. Finance costs: interest on borrowings. Finance income: interest earned.
7. Share of results of associates and joint ventures.
8. Profit before tax.
9. Tax expense. (Malaysia''s standard corporate tax rate is 24%.)
10. Profit after tax, split between owners of the company and non-controlling interests.
11. Earnings per share (EPS) = profit attributable to owners / number of shares.

What to look for:
- Revenue growth over several years. Is it steady or lumpy?
- Margins: gross margin and operating margin. Are they stable, rising or falling?
- Finance costs growing faster than profit, a sign of rising debt.
- Profit attributable to owners, not total profit, for EPS and valuation.

Always compare the same period across years, because many businesses are seasonal.')
,
(N'INV301', 2, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: The INCOME STATEMENT for BEGINNERS, Accounting Stuff: https://www.youtube.com/watch?v=0--AvwZabIQ
- Investopedia: Income statement: https://www.investopedia.com/terms/i/incomestatement.asp
- Investopedia: Annual report: https://www.investopedia.com/terms/a/annualreport.asp')
,
(N'INV301', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=FaY17jAD29Y',
N'Video: "Earnings Quality" by Edspira (YouTube).')
,
(N'INV301', 3, 2, N'Text', NULL, NULL,
N'Not all profit is equal. Quality of earnings asks: how much of this profit comes from the core business and is likely to repeat?

One-off items that can distort profit:
- Gains on disposal of land, buildings or subsidiaries.
- Fair value gains on investment properties or financial assets.
- Impairments of goodwill, assets or receivables.
- Restructuring costs, legal settlements, write-offs.
- Foreign exchange gains or losses.

Malaysian companies often show these in the notes or the MD&A, and many report a "core" or "normalised" profit that excludes them. Read how the company defines it.

Revenue quality checks:
- Is revenue from one or two big customers? (Check the segment and customer notes.)
- Is revenue growing because of acquisitions rather than the existing business?
- Are trade receivables growing much faster than revenue? That may mean sales are being booked but not collected.
- Is revenue recognised on long contracts (construction, property) based on estimates of progress?

The test that cuts through most of this: compare profit with operating cash flow over several years (lesson 6). Profit that never turns into cash deserves suspicion.')
,
(N'INV301', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Earnings Quality, Edspira: https://www.youtube.com/watch?v=FaY17jAD29Y
- Investopedia: Quality of earnings: https://www.investopedia.com/terms/q/qualityofearnings.asp
- Investopedia: Extraordinary items: https://www.investopedia.com/terms/e/extraordinaryitem.asp
- Investopedia: Income statement: https://www.investopedia.com/terms/i/incomestatement.asp')
,
(N'INV301', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=CMv1zlZhb4Q',
N'Video: "The BALANCE SHEET for BEGINNERS (Full Example)" by Accounting Stuff (YouTube).')
,
(N'INV301', 4, 2, N'Text', NULL, NULL,
N'The balance sheet (statement of financial position) is a snapshot of what a company owns and owes on one date.

The equation: assets = liabilities + equity.

Assets:
- Non-current: property, plant and equipment, investment properties, intangible assets and goodwill, investments in associates, right-of-use assets.
- Current (expected to turn into cash within 12 months): inventories, trade and other receivables, cash and bank balances.

Liabilities:
- Non-current: long-term borrowings, lease liabilities, deferred tax.
- Current: trade and other payables, short-term borrowings, tax payable.

Equity: share capital, retained earnings and reserves, plus non-controlling interests.

Line by line, ask:
- Cash vs borrowings: is the company in net cash or net debt?
- Receivables and inventory: are they growing faster than revenue?
- Goodwill: large goodwill means past acquisitions; check for impairment risk.
- Short-term borrowings: can they be refinanced or repaid?
- Retained earnings: growing over time is a good sign.

Compare at least two balance sheet dates, because changes tell you more than one snapshot.')
,
(N'INV301', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: The BALANCE SHEET for BEGINNERS (Full Example), Accounting Stuff: https://www.youtube.com/watch?v=CMv1zlZhb4Q
- Investopedia: Balance sheet: https://www.investopedia.com/terms/b/balancesheet.asp
- Investopedia: Annual report: https://www.investopedia.com/terms/a/annualreport.asp')
,
(N'INV301', 5, 1, N'Text', NULL, NULL,
N'Ratios turn balance sheet numbers into quick health checks.

Liquidity: can the company pay bills due within a year?
- Current ratio = current assets / current liabilities. Above 1 means short-term assets cover short-term obligations. Very low values can mean stress; very high values can mean idle cash.
- Quick ratio = (current assets - inventories) / current liabilities. Stricter, because inventory can be hard to sell fast.

Solvency: can it survive its debt over the long run?
- Debt-to-equity = total borrowings / total equity. Higher means more leverage. What is "normal" depends on the industry: utilities and REITs carry more debt than tech companies.
- Net gearing = (borrowings - cash) / equity. Often quoted in Malaysian annual reports.
- Interest coverage = operating profit (EBIT) / finance costs. Below about 2 to 3 times is a warning sign; it means a fall in profit could make interest hard to pay.

How to use ratios:
1. Calculate them for at least three years to see the trend.
2. Compare with two or three companies in the same industry.
3. Look behind any big change in the notes.

Banks are the big exception: their business is borrowing and lending, so these ratios do not apply to them (see lesson 13).')
,
(N'INV301', 5, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Current ratio: https://www.investopedia.com/terms/c/currentratio.asp
- Investopedia: Debt-to-equity ratio: https://www.investopedia.com/terms/d/debtequityratio.asp
- Investopedia: Interest coverage ratio: https://www.investopedia.com/terms/i/interestcoverageratio.asp')
,
(N'INV301', 6, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=DiVPAjgmnj0',
N'Video: "The CASH FLOW STATEMENT for BEGINNERS" by Accounting Stuff (YouTube).')
,
(N'INV301', 6, 2, N'Text', NULL, NULL,
N'Profit is an accounting opinion; cash is a fact. The cash flow statement shows the actual cash coming in and going out.

Three sections:
1. Operating activities: cash generated by the core business. Usually starts from profit before tax and adjusts for non-cash items (depreciation, impairments) and changes in working capital (receivables, inventory, payables).
2. Investing activities: buying or selling property, equipment, subsidiaries and investments.
3. Financing activities: borrowing and repaying debt, issuing shares, paying dividends, lease payments.

Net change in cash = operating + investing + financing.

What healthy usually looks like:
- Positive operating cash flow, roughly in line with profit over several years.
- Investing outflows (the company reinvests in the business).
- Financing outflows from repaying debt and paying dividends.

Warning signs:
- Profit rising every year while operating cash flow is flat or negative.
- Dividends paid with borrowed money (financing inflows fund the dividend).
- Constant large asset sales to keep cash positive.

Note that in Malaysian reports, interest and dividends received or paid can appear in different sections depending on the company''s accounting choice. Read the labels.')
,
(N'INV301', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: The CASH FLOW STATEMENT for BEGINNERS, Accounting Stuff: https://www.youtube.com/watch?v=DiVPAjgmnj0
- Investopedia: Cash flow statement: https://www.investopedia.com/terms/c/cashflowstatement.asp
- Investopedia: Quality of earnings: https://www.investopedia.com/terms/q/qualityofearnings.asp')
,
(N'INV301', 7, 1, N'Text', NULL, NULL,
N'Free cash flow (FCF) is the cash a company has left after spending what it needs to maintain and grow its business. It is the cash that can pay dividends, repay debt or fund acquisitions.

The common formula:
FCF = cash flow from operating activities - capital expenditure (purchase of property, plant and equipment)

Some analysts also subtract lease payments, since under accounting rules (MFRS 16) lease payments move into financing activities and would otherwise flatter FCF.

Worked example (RM million):
- Operating cash flow: 420
- Capital expenditure: 150
- Lease payments: 30
FCF = 420 - 150 - 30 = RM240 million.
If 1,000 million shares are in issue, FCF per share is 24 sen.

How to use it:
- FCF yield = FCF per share / share price. Comparing it with dividend yield shows whether dividends are covered.
- FCF consistently below dividends paid means the dividend relies on debt or cash reserves.
- Growing FCF over 5 years is one of the strongest signs of a quality business.

Caveat: FCF can be negative for a good reason, such as a big investment in a new plant. Read the MD&A to understand why.')
,
(N'INV301', 7, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Free cash flow: https://www.investopedia.com/terms/f/freecashflow.asp
- Investopedia: Cash flow statement: https://www.investopedia.com/terms/c/cashflowstatement.asp
- Investopedia: Dividend payout ratio: https://www.investopedia.com/terms/d/dividendpayoutratio.asp')
,
(N'INV301', 8, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=YxUK0nzf6eg',
N'Video: "6 Profitability Ratios You Should Know" by Accounting Stuff (YouTube).')
,
(N'INV301', 8, 2, N'Text', NULL, NULL,
N'Profitability ratios show how well a company turns sales and capital into profit.

Margin ratios (from the income statement):
- Gross margin = gross profit / revenue.
- Operating margin = operating profit / revenue.
- Net margin = profit after tax / revenue.

Return ratios (combine income statement and balance sheet):
- Return on equity (ROE) = profit attributable to owners / average shareholders'' equity. Shows how much profit is generated from shareholders'' money.
- Return on assets (ROA) = profit after tax / average total assets.
- Return on invested capital (ROIC) = operating profit after tax / (equity + borrowings - cash). Shows returns on all capital, regardless of how it is financed.

Interpreting them:
- Compare within the same industry. Supermarkets have thin margins but turn over goods fast; software companies have high margins.
- High ROE with high debt can be fragile. Break ROE down: margin x asset turnover x leverage (the DuPont analysis).
- Stable or rising margins over 5 to 10 years suggest pricing power or efficiency.
- Sudden jumps often come from one-off items (lesson 3).')
,
(N'INV301', 8, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: 6 Profitability Ratios You Should Know, Accounting Stuff: https://www.youtube.com/watch?v=YxUK0nzf6eg
- Investopedia: Profitability ratios: https://www.investopedia.com/terms/p/profitabilityratios.asp
- Investopedia: Return on equity (ROE): https://www.investopedia.com/terms/r/returnonequity.asp')
,
(N'INV301', 9, 1, N'Text', NULL, NULL,
N'Dividends are the part of profit paid to shareholders in cash. Many Malaysian investors buy shares for dividends, so understanding payout policy matters.

Key measures:
- Dividend per share (DPS): total dividends declared per share for the year.
- Dividend yield = DPS / share price. A RM2.00 share paying 10 sen yields 5%.
- Payout ratio = dividends / profit attributable to owners. A 60% payout means 40% of profit is kept to grow the business.

Dividend policy: many Bursa-listed companies state a policy, such as "at least 40% of net profit". REITs distribute most of their income (see lesson 12). Check the annual report or IR page.

Single-tier system: dividends from Malaysian companies are paid under the single-tier system, where the company has already paid tax, so dividends are tax-exempt in shareholders'' hands.

Warning signs:
- Payout ratio above 100%: paying more than it earns, which is unsustainable.
- A very high yield (8%+) often means the market expects a dividend cut.
- Dividends funded by borrowing (check the cash flow statement).

A modest, steadily rising dividend backed by free cash flow is usually worth more than a high but unstable one.')
,
(N'INV301', 9, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Dividend payout ratio: https://www.investopedia.com/terms/d/dividendpayoutratio.asp
- Investopedia: Free cash flow: https://www.investopedia.com/terms/f/freecashflow.asp')
,
(N'INV301', 10, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=HRiAXk3t0EM',
N'Video: "Notes To Financial Statements" by Accounting Sphere (YouTube).')
,
(N'INV301', 10, 2, N'Text', NULL, NULL,
N'The notes to the financial statements often run to over 100 pages, and they are where the detail lives. You do not need to read every page, but you should know where to look.

The most useful notes:
1. Significant accounting policies and judgements: how revenue is recognised, how assets are valued, key estimates.
2. Segment information: revenue and profit by business division and by country.
3. Borrowings: amount, interest rates, currency, maturity dates. Large amounts due within a year deserve attention.
4. Related party transactions: deals with directors, major shareholders or their companies. Large or unusual ones can signal conflicts of interest.
5. Contingent liabilities and commitments: guarantees, lawsuits and promised spending not yet on the balance sheet.
6. Trade receivables ageing: how much is overdue and by how long.
7. Impairment testing: assumptions used to support goodwill and asset values.
8. Subsequent events: important events after the year end.

Reading strategy: when a number in the main statements changes a lot, find its note number (printed next to the line item) and read that note. The explanation of an unexpected change is almost always there.')
,
(N'INV301', 10, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Notes To Financial Statements, Accounting Sphere: https://www.youtube.com/watch?v=HRiAXk3t0EM
- Investopedia: Annual report: https://www.investopedia.com/terms/a/annualreport.asp
- Investopedia: Red flag: https://www.investopedia.com/terms/r/redflag.asp')
,
(N'INV301', 11, 1, N'Text', NULL, NULL,
N'No single sign proves a problem, but several together deserve caution.

Accounting and earnings:
- Profit growing while operating cash flow stays flat or negative for years.
- Receivables or inventory growing much faster than revenue.
- Frequent changes in accounting policies, financial year end, or auditors.
- Large, repeated "one-off" items.
- Capitalising costs that peers expense.

Governance:
- An auditor''s report with a qualified opinion, disclaimer, or a "material uncertainty related to going concern".
- Large related party transactions or loans to directors'' companies.
- Frequent resignations of independent directors, CFOs or company secretaries.
- Delayed quarterly reports, or queries from Bursa Malaysia.

Balance sheet and financing:
- Rising short-term borrowings with little cash.
- Frequent private placements or rights issues to raise cash.
- Dividends paid with borrowed money.

Market behaviour:
- Unusual price and volume spikes with no news (Bursa may issue an Unusual Market Activity query).
- Heavy promotion on social media or in chat groups.

Also check the SC''s Investor Alert List for unlicensed entities promoting investments.')
,
(N'INV301', 11, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Red flag: https://www.investopedia.com/terms/r/redflag.asp
- Investopedia: Quality of earnings: https://www.investopedia.com/terms/q/qualityofearnings.asp
- Securities Commission Malaysia: Investor Alert List: https://www.sc.com.my/investor-alert-list')
,
(N'INV301', 12, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=XhCeX98vY28',
N'Video: "How to invest in REIT? What are REITs? 5 Steps to analyse REITs" by Zerodha Varsity (YouTube).')
,
(N'INV301', 12, 2, N'Text', NULL, NULL,
N'A REIT (real estate investment trust) owns income-producing property, such as malls, offices, hotels, hospitals, warehouses and industrial buildings, and passes most of the rental income to unitholders. Malaysia has REITs listed on Bursa Malaysia across these sectors.

Why REITs distribute so much: under Malaysian tax rules, a REIT that distributes at least 90% of its total taxable income is not taxed at the REIT level. Unitholders are taxed instead, with individuals typically subject to a final withholding tax on distributions.

What to analyse:
1. Distribution per unit (DPU) and its trend over 5+ years.
2. Distribution yield = DPU / unit price.
3. Portfolio quality: location, tenant mix, occupancy rates, weighted average lease expiry (WALE).
4. Gearing = borrowings / total assets. Malaysian REITs have a regulatory gearing limit (raised temporarily during the pandemic); lower gearing gives more safety.
5. Cost of debt and the share of fixed-rate borrowings. Rising interest rates hurt REITs.
6. Net asset value (NAV) per unit vs price: a price far below NAV may signal value or market doubts.
7. The manager''s fees and its track record on acquisitions.

Case study approach: pick one listed REIT and calculate these numbers for the last 3 years using its annual reports.')
,
(N'INV301', 12, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How to invest in REIT? What are REITs? 5 Steps to analyse REITs, Zerodha Varsity: https://www.youtube.com/watch?v=XhCeX98vY28
- Investopedia: Real estate investment trust (REIT): https://www.investopedia.com/terms/r/reit.asp
- Wikipedia: Real estate investment trust: https://en.wikipedia.org/wiki/Real_estate_investment_trust
- Bursa Malaysia: Listed companies: https://www.bursamalaysia.com/listing/listed_companies')
,
(N'INV301', 13, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=Y62o9JbQYOk',
N'Video: "A complete guide to bank stocks | How to value bank stocks" by Swan Thinks (YouTube).')
,
(N'INV301', 13, 2, N'Text', NULL, NULL,
N'Banks need their own toolkit. Their raw material is money: they take deposits and borrow, then lend at higher rates. Normal debt ratios do not apply.

Key bank measures:
1. Net interest margin (NIM) = net interest income / average interest-earning assets. Shows the spread between lending and funding costs.
2. Non-interest income: fees, wealth management, treasury, insurance. Diversified income is more stable.
3. Cost-to-income ratio = operating expenses / operating income. Lower is more efficient.
4. Gross impaired loans (GIL) ratio: share of loans not being repaid. Rising GIL is an early warning.
5. Credit cost: loan loss provisions as a percentage of loans.
6. Loan loss coverage: provisions relative to impaired loans.
7. Capital ratios: CET1 and total capital ratios, regulated by Bank Negara Malaysia under Basel III. Higher ratios mean a bigger buffer.
8. Loan-to-deposit ratio and CASA (current and savings account) ratio: more cheap deposits mean lower funding costs.
9. ROE and price-to-book (P/B): banks are often valued on P/B relative to their ROE.

Case study approach: pick a large Malaysian bank and track NIM, GIL, cost-to-income, ROE and dividend payout for 5 years. Compare with one peer.')
,
(N'INV301', 13, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: A complete guide to bank stocks | How to value bank stocks, Swan Thinks: https://www.youtube.com/watch?v=Y62o9JbQYOk
- Investopedia: Net interest margin: https://www.investopedia.com/terms/n/netinterestmargin.asp
- Investopedia: Return on equity (ROE): https://www.investopedia.com/terms/r/returnonequity.asp
- Bursa Malaysia: Listed companies: https://www.bursamalaysia.com/listing/listed_companies')
,
(N'INV301', 14, 1, N'Text', NULL, NULL,
N'Final assessment for Reading a Company''s Financials. Choose an answer for each question before opening it.')
,
(N'INV301', 14, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"Which statement shows a company''s assets, liabilities and equity on one date?","options":["Income statement","Balance sheet","Cash flow statement","Statement of changes in equity"],"answer":1},{"q":"Profit rises every year but operating cash flow stays negative. This is:","options":["A sign of strong earnings quality","A possible red flag worth investigating","Normal for every company","Irrelevant"],"answer":1},{"q":"Free cash flow is usually calculated as:","options":["Revenue minus cost of sales","Operating cash flow minus capital expenditure","Net profit plus dividends","Cash minus borrowings"],"answer":1},{"q":"A company''s interest coverage ratio is 1.5 times. What does that suggest?","options":["Very comfortable debt levels","A fall in profit could make interest hard to pay","The company has no debt","Dividends are tax-exempt"],"answer":1},{"q":"Malaysian REITs avoid tax at the REIT level if they distribute at least what share of taxable income?","options":["50%","75%","90%","100%"],"answer":2},{"q":"Which ratio matters most specifically for banks?","options":["Inventory turnover","Net interest margin","Gross margin","Days payable"],"answer":1},{"q":"Where would you find details of loans to a director''s company?","options":["The chairman''s statement","Related party transactions note","The cover page","The share price chart"],"answer":1},{"q":"A payout ratio above 100% means the company:","options":["Pays out more than it earns","Keeps all profits","Has no debt","Is a REIT"],"answer":0}]}')
,
(N'INV301', 14, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Free cash flow: https://www.investopedia.com/terms/f/freecashflow.asp
- Investopedia: Quality of earnings: https://www.investopedia.com/terms/q/qualityofearnings.asp
- Investopedia: Real estate investment trust (REIT): https://www.investopedia.com/terms/r/reit.asp
- Investopedia: Net interest margin: https://www.investopedia.com/terms/n/netinterestmargin.asp')
;

-- DEB101
INSERT INTO @Blocks VALUES

(N'DEB101', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=SnlHbMIWJak',
N'Video: "How Credit Card Interest Works: The Math" by Will Peterson (YouTube).')
,
(N'DEB101', 1, 2, N'Text', NULL, NULL,
N'Credit cards are free if you pay the full statement balance by the due date. The moment you carry a balance, they become one of the most expensive ways to borrow.

How it works in Malaysia (Bank Negara Malaysia''s rules):
- Interest is capped and tiered by your payment record: up to 15% a year if you paid at least the minimum on time for 12 straight months, up to 17% if on time for at least 10 of 12 months, and up to 18% otherwise.
- The minimum monthly payment must be at least 5% of the outstanding balance.
- When you carry a balance, interest usually applies from the transaction date, and you lose the interest-free period on new purchases until the balance is cleared.
- Cash advances are charged interest from the day of withdrawal (up to 18% a year) plus a cash advance fee.
- Late payment fees apply on top.

What this means in ringgit:
A RM5,000 balance at 18% costs about RM75 in interest in the first month.
Paying only the 5% minimum (at least RM50) takes about 69 months, nearly 6 years, and costs about RM1,876 in interest.
Paying a fixed RM300 a month clears it in about 20 months, with about RM797 in interest.

The cheapest card is the one you pay in full every month.')
,
(N'DEB101', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How Credit Card Interest Works: The Math, Will Peterson: https://www.youtube.com/watch?v=SnlHbMIWJak
- Bank Negara Malaysia: Policy document on Credit Card and Credit Card-i: https://www.bnm.gov.my/documents/20124/938039/credit_card_and_credit_card-i_PD.pdf
- Bank Negara Malaysia: Tiered pricing structure for credit card users: https://www.bnm.gov.my/-/bank-negara-malaysia-introduces-tiered-pricing-structure-to-promote-good-financial-discipline-among-credit-card-users')
,
(N'DEB101', 2, 1, N'Text', NULL, NULL,
N'You cannot fix debt you cannot see. Make one complete list.

For every debt, write down:
- Lender and type (credit card, personal loan, car loan, PTPTN, home loan, BNPL, loans from family).
- Outstanding balance.
- Interest or profit rate, and whether it is flat or reducing balance.
- Minimum monthly payment.
- Due date.
- Any arrears or late fees.

Where to find what you owe:
- Your bank and card statements.
- Your CCRIS report from Bank Negara Malaysia, which lists loans from banks and some other financial institutions. You can request it free through BNM''s eCCRIS online service.
- Credit reporting agencies such as CTOS, which also show other information like trade references and legal records.
- Buy now, pay later apps and e-wallet PayLater features, which are easy to forget.

Then calculate two numbers:
1. Total debt.
2. Total minimum payments per month, as a percentage of take-home pay. If minimum payments take more than about a third of your income, you are under real pressure and should consider talking to AKPK (lesson 5).

This list is your starting point for choosing a payoff strategy.')
,
(N'DEB101', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Bank Negara Malaysia: Policy document on Credit Card and Credit Card-i: https://www.bnm.gov.my/documents/20124/938039/credit_card_and_credit_card-i_PD.pdf
- AKPK: Debt Management Programme: https://www.akpk.org.my/debt-management-programme')
,
(N'DEB101', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=jtgnRJKSJlw',
N'Video: "Debt Snowball Vs Debt Avalanche | Which is the Best Debt Payoff Strategy?" by Next Level Life (YouTube).')
,
(N'DEB101', 3, 2, N'Text', NULL, NULL,
N'Both methods follow the same rule: pay the minimum on every debt, and put every extra ringgit on one target debt. When it is gone, roll its payment into the next one.

They differ only in which debt you target first.

Avalanche: highest interest rate first.
- Saves the most money and usually finishes fastest.
- Typical order in Malaysia: credit cards and cash advances (15% to 18%), then personal loans, then car loans, then PTPTN and home loans.

Snowball: smallest balance first.
- You clear a whole debt quickly, which builds motivation.
- Costs a bit more in interest.

Example: three debts with RM600 a month to pay off.
- Card A: RM2,000 at 18%
- Card B: RM6,000 at 15%
- Personal loan: RM1,000 at 8%
Avalanche targets Card A then Card B then the loan. Snowball targets the loan, then Card A, then Card B.

Which is better? The one you will stick with. If you need quick wins, choose snowball. If you are driven by numbers, choose avalanche.

While paying off debt: stop adding new debt. Keep a small emergency fund (even RM1,000) so a surprise does not go back on the card.')
,
(N'DEB101', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Debt Snowball Vs Debt Avalanche | Which is the Best Debt Payoff Strategy?, Next Level Life: https://www.youtube.com/watch?v=jtgnRJKSJlw
- Investopedia: Debt avalanche: https://www.investopedia.com/terms/d/debt-avalanche.asp
- Bank Negara Malaysia: Policy document on Credit Card and Credit Card-i: https://www.bnm.gov.my/documents/20124/938039/credit_card_and_credit_card-i_PD.pdf')
,
(N'DEB101', 4, 1, N'Text', NULL, NULL,
N'Two tools can cut your interest cost, if used carefully.

Balance transfer: moving a credit card balance to another card (or a balance transfer plan from your bank) at a low or 0% promotional rate for 6 to 12 months.
- Check the one-time fee or the effective rate.
- Check what rate applies after the promotion ends.
- Divide the balance by the number of promo months: that is your monthly target. If you cannot pay it off in time, the remaining balance goes back to a high rate.
- Do not use the old card again, or you will end up with two balances.

Debt consolidation loan: a personal loan used to repay several high-interest debts, leaving one monthly payment.
- Compare the effective interest rate, not the flat rate. Personal loans in Malaysia are often quoted as flat rates, which look lower than the true annual cost.
- Include processing fees and stamp duty.
- A longer term lowers the monthly payment but can increase total interest.

Both only work if spending is fixed first. Consolidation without changing habits often leads to a new card balance on top of the loan.

If you are already missing payments or are overwhelmed, a free AKPK consultation may be a better next step than a new loan.')
,
(N'DEB101', 4, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Debt consolidation: https://www.investopedia.com/terms/d/debtconsolidation.asp
- Bank Negara Malaysia: Hire purchase consumer guide (effective interest rate): https://www.bnm.gov.my/documents/20124/40668/HP+Consumer+Guide_EN_2026.pdf
- AKPK: Debt Management Programme: https://www.akpk.org.my/debt-management-programme')
,
(N'DEB101', 5, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=SDciJugmvKo',
N'Video: "AKPK Debt Management Programme (DMP) - English Version" by AKPK Official (YouTube).')
,
(N'DEB101', 5, 2, N'Text', NULL, NULL,
N'AKPK (Agensi Kaunseling dan Pengurusan Kredit) was set up by Bank Negara Malaysia in 2006 to help people manage money and debt. Its services are free.

What AKPK offers:
- Financial counselling and advisory: a confidential session to review your income, spending and debts and make a plan.
- Debt Management Programme (DMP): AKPK negotiates with your banks to restructure your debts into one affordable monthly payment, for loans of up to RM5 million, with repayment periods of up to 10 years.
- Financial education: courses and online tools.

DMP eligibility (from AKPK): you must not be bankrupt, must be unable to manage your debts, have a positive net income, not be facing advanced legal action, and owe only to participating financial institutions.

How it works:
1. Apply online or visit an AKPK branch.
2. An advisor reviews your income, expenses and debts.
3. AKPK proposes a repayment plan to your creditors.
4. Once approved, you make the first payment and pay AKPK monthly; AKPK distributes it to your banks.

Things to know: while you are on the DMP you generally cannot take new credit, and the programme is noted in your credit records. Many people see this as a fair trade for one affordable payment and no harassment from collectors.')
,
(N'DEB101', 5, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: AKPK Debt Management Programme (DMP) - English Version, AKPK Official: https://www.youtube.com/watch?v=SDciJugmvKo
- AKPK: Debt Management Programme: https://www.akpk.org.my/debt-management-programme
- AKPK: DMP application process: https://www.akpk.org.my/content/199-dmp-debt-management-programme-application-process')
,
(N'DEB101', 6, 1, N'Text', NULL, NULL,
N'Check what you learned in Getting Out of Credit Card Debt. Choose an answer for each question before opening it.')
,
(N'DEB101', 6, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"What is the maximum credit card interest for someone who paid on time for 12 straight months?","options":["10% a year","15% a year","18% a year","24% a year"],"answer":1},{"q":"The minimum monthly credit card payment in Malaysia must be at least:","options":["1% of the balance","5% of the balance","10% of the balance","RM500"],"answer":1},{"q":"The avalanche method targets which debt first?","options":["The smallest balance","The highest interest rate","The newest debt","The largest balance"],"answer":1},{"q":"What is a key risk of a balance transfer?","options":["It is illegal","The rate jumps after the promo period if not paid off","It closes all your accounts","It has no risks"],"answer":1},{"q":"How much does an AKPK counselling session cost?","options":["RM50","RM200","It is free","1% of your debt"],"answer":2},{"q":"Where can you see loans reported by banks under your name?","options":["Your CCRIS report","Your EPF statement","Your tax return","Your phone bill"],"answer":0}]}')
,
(N'DEB101', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Bank Negara Malaysia: Policy document on Credit Card and Credit Card-i: https://www.bnm.gov.my/documents/20124/938039/credit_card_and_credit_card-i_PD.pdf
- Investopedia: Debt avalanche: https://www.investopedia.com/terms/d/debt-avalanche.asp
- AKPK: Debt Management Programme: https://www.akpk.org.my/debt-management-programme')
;

-- TAX101
INSERT INTO @Blocks VALUES

(N'TAX101', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=m1Z0s3cbML0',
N'Video: "INCOME TAX: PCB - MONTHLY TAX DEDUCTION" by Betty Leong (YouTube).')
,
(N'TAX101', 1, 2, N'Text', NULL, NULL,
N'PCB (Potongan Cukai Bulanan), or MTD (monthly tax deduction), is income tax your employer takes from your salary every month and pays to LHDN (HASiL) on your behalf.

How it is calculated: your employer uses LHDN''s computerised calculation (or LHDN''s PCB calculator), based on your monthly pay, EPF contribution, marital status, number of children, and any reliefs you declare to your employer. It spreads your estimated yearly tax over 12 months.

The tax rates for resident individuals (YA 2023 to 2025):
- First RM5,000 of chargeable income: 0%
- RM5,001 to 20,000: 1%
- RM20,001 to 35,000: 3%
- RM35,001 to 50,000: 6%
- RM50,001 to 70,000: 11%
- RM70,001 to 100,000: 19%
- RM100,001 to 400,000: 25%
- Higher bands: 26%, 28% and 30%
These are marginal rates: each rate applies only to the part of income inside that band.

PCB as final tax: if PCB has been deducted and you have only employment income, you may be able to treat PCB as your final tax. But you can still file to claim reliefs that your employer did not know about, which may give you a refund.

Your EA form, given by your employer by end February, shows your yearly pay and PCB.')
,
(N'TAX101', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: INCOME TAX: PCB - MONTHLY TAX DEDUCTION, Betty Leong: https://www.youtube.com/watch?v=m1Z0s3cbML0
- LHDN (HASiL): Tax rate for individuals: https://www.hasil.gov.my/en/individu/kadar-cukai/
- LHDN (HASiL): Specification for the computerised PCB calculation method 2026: https://www.hasil.gov.my/wp-content/uploads/spesifikasi-kaedah-pengiraan-berkomputer-pcb-2026.pdf
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/')
,
(N'TAX101', 2, 1, N'Text', NULL, NULL,
N'Tax reliefs reduce your chargeable income, so you pay tax on less. For YA 2025 (income earned in 2025, filed in 2026), common reliefs for resident individuals include:

- Individual and dependent relatives: RM9,000 (automatic).
- Lifestyle: RM2,500, for books, a personal computer, smartphone or tablet, internet subscription, and skills courses.
- Sports: RM1,000, for sports equipment, facility rental, competition fees and gym membership.
- EPF and life insurance: RM7,000 combined.
- Education and medical insurance: RM4,000.
- Private Retirement Scheme (PRS): RM3,000.
- SOCSO and EIS: RM350.
- Education fees (self): RM7,000, for approved courses.
- Medical expenses (self, spouse, child): RM10,000, for serious diseases, fertility treatment, vaccination, check-ups and more (with sub-limits).
- Medical expenses for parents: RM8,000.
- Net SSPN deposits: RM8,000.
- Childcare fees: RM3,000.
- EV charging facilities: RM2,500.
- First home loan interest: up to RM7,000 or RM5,000, for SPAs from 2025 to 2027.

Keep receipts for 7 years. LHDN can ask for them.

How much does a relief save? Your top tax rate times the relief. A RM2,500 lifestyle claim at a 6% top rate saves RM150; at 19% it saves RM475.

Always check HASiL''s relief page for the latest year, because limits and items change with each Budget.')
,
(N'TAX101', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/
- LHDN (HASiL): Explanatory notes for Form BE: https://ef.hasil.gov.my/eBE2026/Pdf/Nota_BE_e.pdf
- LHDN (HASiL): Rebates: https://www.hasil.gov.my/en/individu/rebat/')
,
(N'TAX101', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=_0z02EfJiEM',
N'Video: "MyTax [STEP BY STEP] First Time Login MyTax ID Registration (Daftar) Tax Identification Number (TIN)" by Life Ledger JWYX (YouTube).')
,
(N'TAX101', 3, 2, N'Text', NULL, NULL,
N'Before you can file, you need a tax identification number (TIN) and access to MyTax, LHDN''s online portal.

Your TIN: Malaysian citizens and permanent residents aged 18 and above are automatically given a TIN using National Registration Department data. Non-citizens and some others register through e-Daftar on MyTax. You can check your TIN on MyTax or through the HASiL Contact Centre (03-8911 1000).

First-time MyTax access:
1. Go to mytax.hasil.gov.my.
2. Choose first-time login and enter your MyKad number.
3. Get your digital certificate in one of two ways:
   - e-KYC: verify with your MyKad and a face scan, entirely online.
   - e-CP55D: an online request for a PIN, or visit a HASiL branch with your MyKad to get one.
4. Set your password and security phrase.

Once you are in, e-Filing is under the e-Filing menu. Keep your login details private, and only use the official site: scammers send fake LHDN links by SMS and email.

When do you need to file? If your income is above the threshold for paying tax, you must file even if PCB was deducted. Many first jobbers file anyway to claim reliefs and get refunds.')
,
(N'TAX101', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: MyTax [STEP BY STEP] First Time Login MyTax ID Registration (Daftar) Tax Identification Number (TIN), Life Ledger JWYX: https://www.youtube.com/watch?v=_0z02EfJiEM
- LHDN (HASiL): Registration (TIN and e-Daftar): https://www.hasil.gov.my/en/individu/pendaftaran/
- MyTax portal (LHDN): https://mytax.hasil.gov.my/
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/')
,
(N'TAX101', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=w1S9AdngrZg',
N'Video: "How to File Income Tax Malaysia | Step by Step Guide For Beginners" by Ziet Invests (YouTube).')
,
(N'TAX101', 4, 2, N'Text', NULL, NULL,
N'Form BE is for resident individuals who do not carry on a business, which includes most salaried employees.

Deadlines (from HASiL):
- Manual Form BE: by 30 April.
- e-Filing (e-BE): by 15 May.
(Form B, for people with business income, is due 30 June, or 15 July via e-Filing.)

Before you start, have: your EA form, receipts for reliefs, EPF and insurance statements, zakat receipts, and bank account details for refunds.

Filing on MyTax, step by step:
1. Log in, choose e-Filing, then e-BE for the correct year of assessment.
2. Check your personal details and bank account number.
3. Enter statutory income from employment, using your EA form.
4. Enter other income, if any (for example, rental).
5. Fill in reliefs, using your receipts. Only claim what you can prove.
6. Enter PCB already deducted (from the EA form) and any zakat.
7. Review the summary: tax payable or refund due.
8. Sign and submit with your password. Save the acknowledgement receipt.

After filing: if you owe tax, pay by the deadline through FPX, DuitNow or banks. Late payment adds a 10% increase on the unpaid tax. If you overpaid, the refund goes to your bank account.

Mistakes can be corrected by filing an amended return within the allowed period.')
,
(N'TAX101', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How to File Income Tax Malaysia | Step by Step Guide For Beginners, Ziet Invests: https://www.youtube.com/watch?v=w1S9AdngrZg
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/
- LHDN (HASiL): Explanatory notes for Form BE: https://ef.hasil.gov.my/eBE2026/Pdf/Nota_BE_e.pdf
- LHDN (HASiL): Increase in tax for late payment: https://www.hasil.gov.my/en/individu/bayaran/kenaikan-cukai-lewat-bayar/')
,
(N'TAX101', 5, 1, N'Text', NULL, NULL,
N'Check what you learned in Malaysian Income Tax for First Jobbers. Choose an answer for each question before opening it.')
,
(N'TAX101', 5, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"What is PCB?","options":["A tax refund","Monthly tax deducted from your salary by your employer","A government bonus","An EPF withdrawal"],"answer":1},{"q":"What is the e-Filing deadline for Form BE?","options":["31 March","30 April","15 May","30 June"],"answer":2},{"q":"What is the YA 2025 lifestyle relief limit?","options":["RM1,000","RM2,500","RM3,000","RM9,000"],"answer":1},{"q":"Which document from your employer shows yearly pay and PCB?","options":["EA form","Form B","CP500","Payslip only"],"answer":0},{"q":"Your top tax rate is 6%. How much tax does a RM1,000 relief save?","options":["RM6","RM60","RM600","RM1,000"],"answer":1},{"q":"How long should you keep receipts for tax reliefs?","options":["1 year","3 years","7 years","No need to keep them"],"answer":2}]}')
,
(N'TAX101', 5, 3, N'Text', NULL, NULL,
N'Sources and further reading
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/
- LHDN (HASiL): Tax rate for individuals: https://www.hasil.gov.my/en/individu/kadar-cukai/')
;

-- TAX301
INSERT INTO @Blocks VALUES

(N'TAX301', 1, 1, N'Text', NULL, NULL,
N'If you earn money from your own work, without being an employee, LHDN treats it as business income. That includes:
- Freelance design, writing, coding, photography, tutoring.
- Gig and platform work: e-hailing, food delivery, online selling.
- Commission-based work as an agent (insurance, property, direct selling).
- Content creation: sponsorships, affiliate income, gifts in kind.

This is true even if it is a side job alongside a salaried job, and even if you never registered a business with SSM.

What changes compared with employment:
- No PCB is deducted, so no tax is paid automatically during the year.
- You file Form B (not Form BE): due 30 June, or 15 July through e-Filing.
- You can deduct business expenses from the income, and claim capital allowances on equipment.
- You may be put on the CP500 instalment scheme.

If you have both a salary and freelance income, you file one Form B that covers both. Your EA form handles the employment part and you add the business part.

Self-employed people also have no automatic EPF contributions. i-Saraan (EPF) and PRS can fill that gap, and you can register for SOCSO''s self-employment scheme (SKSPS) where it applies to your work.')
,
(N'TAX301', 1, 2, N'Text', NULL, NULL,
N'Sources and further reading
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/
- Investopedia: Self-employed: https://www.investopedia.com/terms/s/self-employed.asp
- LHDN (HASiL): Instalment scheme (CP500): https://www.hasil.gov.my/en/individu/bayaran/bayaran-pendahuluan-anggaran-cukai/')
,
(N'TAX301', 2, 1, N'Text', NULL, NULL,
N'Good records are the difference between paying the right tax and paying too much, or facing penalties in an audit.

Register:
- You already have a TIN if you are a Malaysian citizen aged 18 or above. Log in to MyTax (see TAX101).
- Many freelancers also register a sole proprietorship or partnership with SSM (Suruhanjaya Syarikat Malaysia). It is not always required, but helps with invoicing clients and opening a business account.

Keep records (Malaysian law requires keeping them for 7 years):
- Every invoice you send and payment you receive.
- Receipts and invoices for every expense you claim.
- Bank statements: use a separate account for business income and expenses. Mixing personal and business money is the most common record-keeping problem.
- A simple income and expense ledger: date, client or supplier, description, amount, category.
- Records of equipment bought (for capital allowances).
- Platform statements (Grab, Shopee, Fiverr, YouTube and others).

Tools: a spreadsheet works fine at the start. Accounting apps can link to your bank account and categorise transactions.

Set a monthly 30-minute session to file receipts and update the ledger. Doing it once a year in June is far harder.')
,
(N'TAX301', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- LHDN (HASiL): Registration (TIN and e-Daftar): https://www.hasil.gov.my/en/individu/pendaftaran/
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/
- MyTax portal (LHDN): https://mytax.hasil.gov.my/')
,
(N'TAX301', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=gYmYR0_FYGg',
N'Video: "How to File Tax for Freelancer in Malaysia 2024 I The Ultimate Guide" by Mr Money TV (YouTube).')
,
(N'TAX301', 3, 2, N'Text', NULL, NULL,
N'Form B is for resident individuals who carry on a business. Deadlines from HASiL: 30 June for paper, 15 July for e-Filing (e-B).

What you report:
1. Business income: gross income from your freelance work, minus allowable expenses, gives adjusted income. Then capital allowances are deducted to give statutory business income.
2. Employment income, if you also have a salary (from your EA form).
3. Other income: rental, interest, royalties.
4. Reliefs: the same personal reliefs as Form BE (lifestyle, EPF and life insurance, PRS and others).
5. Tax already paid: CP500 instalments and any PCB from employment.

Step by step on MyTax:
1. Log in, choose e-Filing, then e-B for the year.
2. Confirm personal and bank details.
3. Enter business income details. You will need your profit and loss figures from your records.
4. Enter any employment income and reliefs.
5. Check the computation: tax payable, minus instalments already paid.
6. Submit and save the acknowledgement.

The video above walks through filing as a freelancer. Remember that the forms update every year, so follow the explanatory notes for the current year of assessment.')
,
(N'TAX301', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How to File Tax for Freelancer in Malaysia 2024 I The Ultimate Guide, Mr Money TV: https://www.youtube.com/watch?v=gYmYR0_FYGg
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/
- MyTax portal (LHDN): https://mytax.hasil.gov.my/')
,
(N'TAX301', 4, 1, N'Text', NULL, NULL,
N'Under Section 33(1) of the Income Tax Act 1967, you can deduct expenses that are "wholly and exclusively incurred in the production of gross income". In plain words: costs you only had because of the business.

Usually deductible (keep receipts):
- Software subscriptions and tools for your work.
- Internet and phone bills, the business share only.
- Platform fees and commissions (for example, marketplace or app fees).
- Advertising and marketing.
- Professional fees: accountant, legal, SSM renewal.
- Business travel and transport to client sites.
- Rent for a workspace or co-working membership.
- Materials and stock.

Usually not deductible:
- Personal or private expenses, including your own meals.
- Capital spending, such as buying a laptop or camera, as a direct expense. Instead, claim capital allowances: a yearly deduction spread over the asset''s life. Small value assets (low-cost items under the limit set by LHDN) may be fully claimed in one year, subject to a yearly cap.
- Fines and penalties.
- Expenses specifically restricted by Section 39 of the Act, such as most entertainment beyond the allowed limits.

Mixed-use items (a phone used for work and personal calls) should be split fairly, for example 60% business. Write down how you estimated it.

The burden of proof is on you. If you cannot show a receipt and a business reason, assume LHDN will not allow it.')
,
(N'TAX301', 4, 2, N'Text', NULL, NULL,
N'Sources and further reading
- LHDN (HASiL): Explanatory notes for Form BE: https://ef.hasil.gov.my/eBE2026/Pdf/Nota_BE_e.pdf
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/
- Investopedia: Self-employed: https://www.investopedia.com/terms/s/self-employed.asp')
,
(N'TAX301', 5, 1, N'Text', NULL, NULL,
N'Because freelancers have no PCB, LHDN collects tax during the year through the CP500 instalment scheme.

How CP500 works (from HASiL):
- Taxpayers with non-employment income, such as business, rental or royalty income, may be placed on CP500.
- LHDN estimates the year''s tax based on your past returns and sends a CP500 notice at the start of the year (you can download a copy on MyTax if you did not receive one by end February).
- You pay in 6 instalments, every two months, starting in March.
- When you file Form B, the instalments are deducted from your final tax. Any balance is paid, or any excess is refunded.

Revising the estimate (CP502): if your income has dropped (or risen), you can ask to revise your instalments. First revision by 30 June, and a second by 31 October.

Penalties: late or missed instalments attract a 10% increase on the unpaid amount. Unpaid tax after the Form B deadline also gets a 10% increase.

Budgeting tip: put aside a fixed percentage of every freelance payment into a separate "tax" account. Use your estimated top rate plus a margin, for example 10% to 20%. Then CP500 and the final bill come from that account, not your spending money.')
,
(N'TAX301', 5, 2, N'Text', NULL, NULL,
N'Sources and further reading
- LHDN (HASiL): Instalment scheme (CP500): https://www.hasil.gov.my/en/individu/bayaran/bayaran-pendahuluan-anggaran-cukai/
- LHDN (HASiL): Increase in tax for late payment: https://www.hasil.gov.my/en/individu/bayaran/kenaikan-cukai-lewat-bayar/')
,
(N'TAX301', 6, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=RnMOIi65_kM',
N'Video: "5 Tips for Sole Proprietors in Malaysia | LHDN Borang B Tax Filing" by Ziet Invests (YouTube).')
,
(N'TAX301', 6, 2, N'Text', NULL, NULL,
N'Paying less tax legally comes down to three things: claim every allowable expense, claim every relief you qualify for, and plan your contributions.

1. Claim all business expenses and capital allowances (lesson 4). Many freelancers overpay simply because they did not keep receipts.

2. Use personal reliefs. Form B allows the same personal reliefs as Form BE, including for YA 2025:
- Lifestyle RM2,500 and sports RM1,000.
- EPF and life insurance RM7,000 combined (EPF voluntary contributions through i-Saraan count toward the EPF part).
- PRS RM3,000.
- Education and medical insurance RM4,000.
- SOCSO contributions RM350.
- Education fees for yourself RM7,000, for approved courses that build skills.

3. Plan before 31 December. Reliefs only count for money paid within the calendar year. Review your income in November and decide on PRS, EPF and insurance contributions while there is still time.

4. Zakat and fitrah you pay can be claimed as a rebate, reducing tax ringgit for ringgit, up to the tax payable.

Avoid: under-reporting income, claiming personal costs as business expenses, or relying on "tax tips" from social media. Penalties for incorrect returns can be heavy.

For larger or more complex income, a licensed tax agent can be worth the fee.')
,
(N'TAX301', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: 5 Tips for Sole Proprietors in Malaysia | LHDN Borang B Tax Filing, Ziet Invests: https://www.youtube.com/watch?v=RnMOIi65_kM
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/
- LHDN (HASiL): Rebates: https://www.hasil.gov.my/en/individu/rebat/
- Private Pension Administrator (PPA): PRS tax relief: https://www.ppa.my/joining-prs/prs-tax-relief/
- KWSP: i-Topup, contributing more than the statutory rate: https://www.kwsp.gov.my/en/member/savings/voluntary-excess')
,
(N'TAX301', 7, 1, N'Text', NULL, NULL,
N'Final quiz for Tax Planning for Freelancers. Choose an answer for each question before opening it.')
,
(N'TAX301', 7, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"Which form does a freelancer file?","options":["Form BE","Form B","Form E","Form EA"],"answer":1},{"q":"What is the e-Filing deadline for Form B?","options":["30 April","15 May","30 June","15 July"],"answer":3},{"q":"How many CP500 instalments are paid in a year?","options":["4","6","12","1"],"answer":1},{"q":"A laptop bought for freelance work is usually claimed as:","options":["A personal relief","A capital allowance","A rebate","It cannot be claimed"],"answer":1},{"q":"Which expense is usually NOT deductible?","options":["Software subscription for client work","Platform commission","Your personal lunch","Accountant''s fee"],"answer":2},{"q":"How long should business records be kept?","options":["1 year","3 years","7 years","Until you stop freelancing"],"answer":2},{"q":"Your income dropped this year. How do you lower CP500 instalments?","options":["Stop paying","Apply to revise them (CP502)","File Form BE instead","Nothing can be done"],"answer":1}]}')
,
(N'TAX301', 7, 3, N'Text', NULL, NULL,
N'Sources and further reading
- LHDN (HASiL): Income declaration and filing deadlines: https://www.hasil.gov.my/en/individu/lapor-pendapatan/
- LHDN (HASiL): Instalment scheme (CP500): https://www.hasil.gov.my/en/individu/bayaran/bayaran-pendahuluan-anggaran-cukai/
- LHDN (HASiL): Explanatory notes for Form BE: https://ef.hasil.gov.my/eBE2026/Pdf/Nota_BE_e.pdf')
;

-- INS101
INSERT INTO @Blocks VALUES

(N'INS101', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=3ctoSEQsY54',
N'Video: "How Does Insurance Work?" by Concerning Reality (YouTube).')
,
(N'INS101', 1, 2, N'Text', NULL, NULL,
N'Insurance moves a financial risk you cannot afford from you to an insurer. Many people pay a small, predictable premium into a pool; the few who suffer a loss are paid from that pool.

What it is for: big, unlikely losses that would seriously damage your finances.
- A hospital stay costing tens of thousands of ringgit.
- Your family losing your income if you die or become disabled.
- Third-party claims after a car accident (motor third-party cover is compulsory in Malaysia).

What it is not for: small, frequent costs you can pay from savings. Insuring those is usually expensive, because premiums also cover the insurer''s costs and profit.

Key words:
- Premium (insurance) or contribution (takaful): what you pay.
- Sum insured or sum covered: the maximum paid.
- Deductible: the part of a claim you pay first.
- Co-payment or co-takaful: the percentage of each claim you share.
- Exclusions: what the policy does not cover, including pre-existing conditions in many policies.
- Waiting period: time before certain conditions are covered.

Your protection plan should follow your life stage: a single first jobber needs medical cover most; a parent with a home loan also needs life cover.

Bank Negara''s insuranceinfo website explains insurance and takaful products in plain language.')
,
(N'INS101', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How Does Insurance Work?, Concerning Reality: https://www.youtube.com/watch?v=3ctoSEQsY54
- insuranceinfo (BNM): What is insurance/takaful?: https://insuranceinfo.com.my/learn-the-basics/what-is-insurance-takaful/
- insuranceinfo (BNM): Insurance glossary: https://insuranceinfo.com.my/learn-the-basics/insurance-glossary/')
,
(N'INS101', 2, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=Ty-IdP0uhM8',
N'Video: "Best insurance plan (Malaysia) | Medical, life insurance guide" by Swan Thinks (YouTube).')
,
(N'INS101', 2, 2, N'Text', NULL, NULL,
N'Medical and health insurance (often called a "medical card") pays hospital bills when you are admitted, and often some outpatient treatment linked to the admission, such as pre- and post-hospital care.

What to compare:
- Annual limit and lifetime limit: how much the plan pays per year and in total. Medical costs rise quickly, so higher limits matter more over time.
- Room and board: the daily room rate covered. Choosing a higher room than covered can reduce the whole claim.
- Deductible: many plans offer a zero or RM500 (or higher) deductible. A deductible lowers your premium.
- Co-payment: Bank Negara now requires new medical plans to include cost-sharing options (deductible or co-payment), to help keep premiums sustainable.
- Panel hospitals and cashless admission (the medical card itself).
- Waiting periods and exclusions, especially pre-existing conditions.
- Premium increases with age, and repricing across the industry.

Standalone vs investment-linked: medical riders on investment-linked policies can see charges rise sharply as you age, draining the investment value. A standalone medical plan has more transparent pricing.

Employer group cover often ends when you leave the job, so a personal plan bought while young and healthy is a safer base.')
,
(N'INS101', 2, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Best insurance plan (Malaysia) | Medical, life insurance guide, Swan Thinks: https://www.youtube.com/watch?v=Ty-IdP0uhM8
- insuranceinfo (BNM): Medical and health insurance: https://insuranceinfo.com.my/learn-the-basics/types-of-insurance/medical-health-insurance/
- insuranceinfo: BNM mandates cost-sharing in medical and health insurance/takaful: https://insuranceinfo.com.my/bnm-mandates-cost-sharing-in-medical-and-health-insurance-takaful-products/
- Investopedia: Deductible: https://www.investopedia.com/terms/d/deductible.asp')
,
(N'INS101', 3, 1, N'Text', NULL, NULL,
N'Life insurance pays a lump sum to your beneficiaries if you die, and usually if you become totally and permanently disabled (TPD).

Who needs it: anyone whose income others depend on: a spouse, children, parents you support, or anyone with a home loan. A single person with no dependants often needs little life cover.

Term life:
- Covers you for a fixed period (for example, 20 years or until age 65).
- Pays only if you die or become TPD within the term.
- No savings value, so premiums are much lower.

Whole life:
- Covers you for life (often to age 100).
- Builds a cash value over time.
- Much higher premiums for the same cover.

Investment-linked (ILP) plans combine cover and investment; their charges and fund performance determine how long the cover lasts.

A common approach is "buy term and invest the difference": take a cheaper term policy and invest the premium saved, for example in EPF top-ups, PRS or funds.

How much cover? A simple estimate: debts to clear (home loan, car) + income replacement (for example, 5 to 10 years of income) + children''s education, minus existing savings and other cover (EPF death benefit, employer group cover).

Tax: life insurance premiums count toward the RM7,000 combined EPF and life insurance relief.')
,
(N'INS101', 3, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Investopedia: Term life insurance: https://www.investopedia.com/terms/t/termlife.asp
- Investopedia: Whole life insurance: https://www.investopedia.com/terms/w/wholelife.asp
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/')
,
(N'INS101', 4, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=tuSS61eKC48',
N'Video: "What is Takaful? Islamic Insurance Meaning, Principles, Models & Types" by AIMS Education (YouTube).')
,
(N'INS101', 4, 2, N'Text', NULL, NULL,
N'Takaful is Islamic insurance, based on mutual help (ta''awun). Participants contribute to a shared fund, and claims are paid from that fund to those who suffer a loss.

How it differs from conventional insurance:
- Risk is shared among participants, rather than transferred to the insurer.
- Contributions are split: part goes into the participants'' risk fund (as tabarru'', a donation), part covers the operator''s fees.
- The takaful operator manages the fund for a fee (wakalah model) or a share of profit (mudharabah model), or a mix.
- Funds must be invested in Shariah-compliant assets.
- Any surplus in the risk fund may be shared with participants or kept to strengthen the fund, depending on the contract.

Takaful is open to everyone, not only Muslims. Malaysia has one of the most developed takaful markets in the world, regulated by Bank Negara Malaysia under the Islamic Financial Services Act 2013.

Products mirror conventional insurance: family takaful (life cover), medical takaful, and general takaful (motor, home, travel). When comparing, look at the same things as for insurance: cover, limits, exclusions and total cost, not only the label.')
,
(N'INS101', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: What is Takaful? Islamic Insurance Meaning, Principles, Models & Types, AIMS Education: https://www.youtube.com/watch?v=tuSS61eKC48
- Investopedia: Takaful: https://www.investopedia.com/terms/t/takaful.asp
- Wikipedia: Takaful: https://en.wikipedia.org/wiki/Takaful
- insuranceinfo (BNM): What is insurance/takaful?: https://insuranceinfo.com.my/learn-the-basics/what-is-insurance-takaful/')
,
(N'INS101', 5, 1, N'Text', NULL, NULL,
N'Comparing two policies is easier with a checklist and the official documents.

Ask for these documents:
- Product Disclosure Sheet (PDS): a standard summary of benefits, premiums, fees, exclusions and key terms. Insurers and takaful operators must give it to you.
- Sales illustration (for investment-linked plans): shows how charges and fund values may change, under different return assumptions.
- The policy contract.

Compare side by side:
1. What is covered, and the limits (annual, lifetime, per item).
2. Premium today and how it will change with age, and whether it can be repriced.
3. Deductible and co-payment.
4. Exclusions, waiting periods and pre-existing condition rules.
5. Panel hospitals and claims process.
6. For life cover: the sum assured, the term, and what happens if you stop paying.
7. Total cost over 10 or 20 years, not just the first year.

Your rights:
- A free-look period (usually 15 days after receiving the policy) lets you cancel for a refund if it does not suit you.
- If you have a complaint the insurer does not resolve, you can go to the Ombudsman for Financial Services (OFS).

Never sign a blank or incomplete proposal form, and always declare your health honestly. Non-disclosure is a common reason claims are rejected.')
,
(N'INS101', 5, 2, N'Text', NULL, NULL,
N'Sources and further reading
- insuranceinfo (BNM): Insurance glossary: https://insuranceinfo.com.my/learn-the-basics/insurance-glossary/
- insuranceinfo (BNM): Medical and health insurance: https://insuranceinfo.com.my/learn-the-basics/types-of-insurance/medical-health-insurance/
- Investopedia: Term life insurance: https://www.investopedia.com/terms/t/termlife.asp')
,
(N'INS101', 6, 1, N'Text', NULL, NULL,
N'Check what you learned in Insurance Without the Jargon. Choose an answer for each question before opening it.')
,
(N'INS101', 6, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"Insurance is best used for:","options":["Small, frequent expenses","Big, unlikely losses you could not afford","Growing your wealth fast","Avoiding tax"],"answer":1},{"q":"What is a deductible?","options":["The premium paid each month","The part of a claim you pay before cover starts","A tax relief","A type of takaful fund"],"answer":1},{"q":"Term life insurance:","options":["Builds a large cash value","Covers a fixed period and usually costs less","Covers only medical bills","Has no exclusions"],"answer":1},{"q":"In takaful, contributions to the shared risk fund are made as:","options":["Interest","Tabarru'' (donation)","Tax","Loans"],"answer":1},{"q":"Which standard document summarises a policy''s benefits, fees and exclusions?","options":["EA form","Product Disclosure Sheet (PDS)","CCRIS report","Annual report"],"answer":1},{"q":"Who most likely needs life insurance?","options":["A single student with no dependants","A parent with a home loan and young children","Nobody","Only retirees"],"answer":1}]}')
,
(N'INS101', 6, 3, N'Text', NULL, NULL,
N'Sources and further reading
- insuranceinfo (BNM): What is insurance/takaful?: https://insuranceinfo.com.my/learn-the-basics/what-is-insurance-takaful/
- Investopedia: Term life insurance: https://www.investopedia.com/terms/t/termlife.asp
- Investopedia: Takaful: https://www.investopedia.com/terms/t/takaful.asp')
;

-- RET201
INSERT INTO @Blocks VALUES

(N'RET201', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=jLQEqZaJqYU',
N'Video: "How Much Do You Actually Need to Retire in Malaysia?" by Ringgit Explained (YouTube).')
,
(N'RET201', 1, 2, N'Text', NULL, NULL,
N'EPF''s Retirement Income Adequacy (RIA) framework, launched for 2026, gives three savings targets at age 60:

- Basic: RM390,000, covering essential needs.
- Adequate: RM650,000, a reasonable standard of living. EPF built this from the Belanjawanku guide''s monthly spending for a single senior in the Klang Valley (RM2,690), times 240 months (20 years of retirement).
- Enhanced: RM1.3 million, for more comfort and independence.

EPF reviews these levels every five years, in line with the Belanjawanku guide and inflation.

Your own number:
1. Estimate monthly spending in retirement, in today''s ringgit. Many people use 60% to 70% of current spending, but healthcare usually rises.
2. Multiply by 12, then by the years you expect to be retired (20 to 25 years is a common planning range, since Malaysians are living longer).
3. Subtract other income, such as a pension, rental income or support from family.

Example: RM3,000 a month x 12 x 20 years = RM720,000 in today''s money.

The gap between this number and your projected EPF balance (lesson 3) is what PRS, voluntary contributions and other investments need to fill.')
,
(N'RET201', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: How Much Do You Actually Need to Retire in Malaysia?, Ringgit Explained: https://www.youtube.com/watch?v=jLQEqZaJqYU
- KWSP: Retirement Income Adequacy (RIA) leaflet: https://www.kwsp.gov.my/documents/d/guest/ria_en_28102025
- KWSP: EPF releases Belanjawanku 2024/2025 and the Retirement Income Adequacy framework: https://www.kwsp.gov.my/en/w/epf-releases-belanjawanku-2024/2025-and-retirement-income-adequacy-framework')
,
(N'RET201', 2, 1, N'Text', NULL, NULL,
N'The EPF (Employees Provident Fund, KWSP) is Malaysia''s main retirement savings scheme for private sector employees.

Contributions: for employees under 60 earning RM5,000 or less, the employee contributes 11% and the employer 13% of monthly wages; above RM5,000, the employer rate is 12%. Self-employed people and others can contribute voluntarily through i-Saraan.

Three accounts (since 11 May 2024):
- Akaun Persaraan (75% of new contributions): for retirement; cannot be withdrawn before age 55.
- Akaun Sejahtera (15%): for pre-retirement needs: housing, education, health, insurance or takaful protection, Hajj, and at age 50.
- Akaun Fleksibel (10%): can be withdrawn at any time, minimum RM50.

Dividends: EPF declares dividends each year based on its investment income. For 2025, EPF declared 6.15% for both conventional and Shariah savings (2024: 6.30%). Dividends are credited to your accounts and compound over time. Past dividends do not guarantee future ones.

Check your balance and statements on the KWSP i-Akaun app or website.

The key point: Akaun Fleksibel is convenient, but every withdrawal reduces your retirement savings and future compounding. Treat it as a last resort, not spending money.')
,
(N'RET201', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- KWSP: A quick guide to EPF account restructuring: https://www.kwsp.gov.my/en/w/article/account-restructuring-guide
- KWSP: Employer mandatory contribution: https://www.kwsp.gov.my/en/employer/responsibilities/mandatory-contribution
- RinggitPlus: EPF declares 6.15% dividend for 2025: https://ringgitplus.com/en/blog/personal-finance-news/epf-declares-6-15-dividend-for-2025.html
- KWSP: EPF Account 3, what you need to know: https://www.kwsp.gov.my/en/w/article/epf-account-3-info')
,
(N'RET201', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=3VSH6Ufx5Q8',
N'Video: "[NEW] EPF Account 3: Everything You NEED to Know" by Ziet Invests (YouTube).')
,
(N'RET201', 3, 2, N'Text', NULL, NULL,
N'A projection turns your EPF statement into a picture of retirement.

What you need:
- Current balance.
- Monthly contribution (employee plus employer).
- Expected yearly salary growth.
- Expected dividend rate (be conservative; for example 5% to 5.5%).
- Years to retirement.

Worked example (a simplified model):
- Age 25, salary RM3,000, contributions 24% (RM720 a month).
- Salary grows 4% a year, dividends 5.5% a year, no withdrawals.
- At age 60: about RM1.55 million.

That sounds like a lot, but it is in future ringgit. At 2.5% inflation, it is worth roughly RM655,000 in today''s money, close to EPF''s "Adequate" level. Withdrawals from Akaun Sejahtera and Akaun Fleksibel along the way would lower it.

Tools: EPF offers a Retirement Goal Calculator and projections in i-Akaun. A spreadsheet with the FV formula also works.

What moves the result most:
1. Starting early (compounding time).
2. Salary growth.
3. Not withdrawing.
4. Dividend rate.

Re-run your projection every year when your statement arrives.')
,
(N'RET201', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: [NEW] EPF Account 3: Everything You NEED to Know, Ziet Invests: https://www.youtube.com/watch?v=3VSH6Ufx5Q8
- KWSP: Retirement Income Adequacy (RIA) leaflet: https://www.kwsp.gov.my/documents/d/guest/ria_en_28102025
- RinggitPlus: EPF declares 6.15% dividend for 2025: https://ringgitplus.com/en/blog/personal-finance-news/epf-declares-6-15-dividend-for-2025.html
- Investopedia: Compound interest: https://www.investopedia.com/terms/c/compoundinterest.asp
- Investopedia: Inflation: https://www.investopedia.com/terms/i/inflation.asp')
,
(N'RET201', 4, 1, N'Text', NULL, NULL,
N'If your projection falls short, EPF accepts voluntary contributions on top of the mandatory ones.

Ways to top up:
- i-Topup: you or your employer contribute more than the statutory rate through payroll.
- i-Saraan: voluntary contributions for self-employed people and those without fixed income. The government has offered matching incentives under i-Saraan, subject to yearly limits and conditions; check KWSP for the current terms.
- Self contribution: a direct transfer to your own EPF account through online banking or at counters.

Limits: voluntary contributions are capped per year (currently up to RM100,000 a year). Check KWSP for the latest limit.

Why EPF top-ups can make sense:
- Dividends have historically been competitive with fixed deposits, with capital protected by the EPF Act (a minimum dividend of 2.5% a year is guaranteed for conventional savings).
- Contributions count toward the RM7,000 EPF and life insurance tax relief (up to the RM4,000 EPF portion).
- It is low effort and well diversified.

Drawbacks:
- Money is mostly locked until 55 or 60, except Akaun Sejahtera and Akaun Fleksibel portions.
- Returns are not guaranteed above the minimum.

Make sure your emergency fund is in place before locking money away.')
,
(N'RET201', 4, 2, N'Text', NULL, NULL,
N'Sources and further reading
- KWSP: i-Topup, contributing more than the statutory rate: https://www.kwsp.gov.my/en/member/savings/voluntary-excess
- KWSP: Employer mandatory contribution: https://www.kwsp.gov.my/en/employer/responsibilities/mandatory-contribution
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/
- Wikipedia: Employees Provident Fund (Malaysia): https://en.wikipedia.org/wiki/Employees_Provident_Fund_(Malaysia)')
,
(N'RET201', 5, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=fyBKteJDUKY',
N'Video: "A complete guide to PRS Malaysia | Private retirement scheme" by Swan Thinks (YouTube).')
,
(N'RET201', 5, 2, N'Text', NULL, NULL,
N'Private Retirement Schemes (PRS) are voluntary, long-term retirement funds, launched in 2012 to complement EPF. They are regulated by the Securities Commission and administered centrally by the Private Pension Administrator (PPA).

How PRS works:
- You choose a PRS provider (fund house) and one or more funds: conservative, moderate, growth, or Shariah-compliant versions.
- Default option: if you do not choose, money goes into a core fund matched to your age, becoming more conservative as you get older.
- Contributions are split into two sub-accounts: Sub-account A (70%), locked until retirement age (55); Sub-account B (30%), allowing one withdrawal a year (subject to an 8% tax penalty on the amount withdrawn).

Costs: fund management fees plus sales charges (which are capped, and often lower online), and a small PPA fee.

Who it suits:
- Self-employed people without EPF.
- Employees who want more retirement savings beyond EPF, with a choice of risk level.
- Higher earners who benefit more from the tax relief (next lesson).

Compare PRS funds on PPA''s website by fees, past performance and risk. Remember that PRS funds invest in markets, so their value can fall as well as rise.')
,
(N'RET201', 5, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: A complete guide to PRS Malaysia | Private retirement scheme, Swan Thinks: https://www.youtube.com/watch?v=fyBKteJDUKY
- Private Pension Administrator (PPA): Why PRS: https://www.ppa.my/about-prs/why-prs/
- Securities Commission Malaysia: FAQs on Private Retirement Schemes: https://www.sc.com.my/regulation/regulatory-faqs/frequently-asked-questions-on-private-retirement-scheme-prs
- Private Pension Administrator (PPA): PRS tax relief: https://www.ppa.my/joining-prs/prs-tax-relief/')
,
(N'RET201', 6, 1, N'Text', NULL, NULL,
N'PRS contributions qualify for an individual tax relief of up to RM3,000 a year, available until year of assessment 2030 (according to PPA).

How much tax does it save? The relief reduces your chargeable income, so the saving equals your top marginal tax rate times the amount contributed (up to RM3,000):
- At 6%: RM180.
- At 11%: RM330.
- At 19%: RM570.
- At 25%: RM750.

So PRS relief is worth much more to people in higher tax bands. If your income is too low to pay tax, the relief saves nothing, and EPF voluntary contributions may suit you better.

Timing: contributions must be made within the calendar year (by 31 December) to count for that year of assessment. Many people contribute in December, but contributing monthly also spreads market timing risk.

How to claim: PRS providers issue a contribution statement. Enter the amount in the PRS relief section of your e-BE form, and keep the statement for 7 years.

Remember: a tax saving is a bonus, not a reason on its own. Choose PRS funds with reasonable fees and a risk level that suits your age.')
,
(N'RET201', 6, 2, N'Text', NULL, NULL,
N'Sources and further reading
- Private Pension Administrator (PPA): PRS tax relief: https://www.ppa.my/joining-prs/prs-tax-relief/
- LHDN (HASiL): Tax relief: https://www.hasil.gov.my/en/individu/pelepasan-cukai/
- LHDN (HASiL): Tax rate for individuals: https://www.hasil.gov.my/en/individu/kadar-cukai/')
,
(N'RET201', 7, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=SEItn9Csitg',
N'Video: "The Truth About FIRE - Is Early Retirement Actually Possible?" by The Plain Bagel (YouTube).')
,
(N'RET201', 7, 2, N'Text', NULL, NULL,
N'FIRE (Financial Independence, Retire Early) is a movement built on high savings rates, often 40% to 70% of income, and investing them so you can stop depending on a salary well before 60.

The math behind it:
- The "4% rule" from US research suggests withdrawing about 4% of a portfolio in the first year (then adjusting for inflation) has historically lasted around 30 years. That means needing about 25 times your yearly spending.
- Example: RM48,000 a year (RM4,000 a month) x 25 = RM1.2 million.

What changes in Malaysia if you retire early:
- EPF: most of your savings (Akaun Persaraan) stay locked until 55, with full withdrawals at 55 or 60 under current rules. You need other investments to bridge the gap.
- Healthcare: no employer cover. You need personal medical insurance, and premiums rise with age.
- A longer retirement: 40 years instead of 20 means a lower safe withdrawal rate (many use 3% to 3.5%).
- Sequence of returns risk: a market crash in the first few years of retirement hurts far more than one later.

Many people choose a softer version: "Coast FIRE" or "Barista FIRE", working part-time or doing work they enjoy, with investments covering part of their costs.')
,
(N'RET201', 7, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: The Truth About FIRE - Is Early Retirement Actually Possible?, The Plain Bagel: https://www.youtube.com/watch?v=SEItn9Csitg
- Investopedia: Financial independence, retire early (FIRE): https://www.investopedia.com/terms/f/financial-independence-retire-early-fire.asp
- Investopedia: The 4% rule: https://www.investopedia.com/terms/f/four-percent-rule.asp
- Investopedia: Sequence risk: https://www.investopedia.com/terms/s/sequence-risk.asp')
,
(N'RET201', 8, 1, N'Text', NULL, NULL,
N'Retirement turns saving into spending. Your plan needs to make money last for 20 years or more.

EPF withdrawal options at retirement age: under current rules, you can withdraw your Akaun Persaraan savings at 55 (partially or fully) and at 60, or leave money in EPF to keep earning dividends (members can keep accounts and earn dividends up to age 100). Monthly or periodic withdrawals are also available. Check KWSP''s current options when you get close.

Common drawdown approaches:
1. Fixed percentage: withdraw a set percentage (for example 4%) each year.
2. Bucket strategy:
   - Bucket 1: 1 to 2 years of spending in cash or EPF/FD, for daily needs.
   - Bucket 2: 3 to 7 years in lower-risk investments (bonds, sukuk, balanced funds).
   - Bucket 3: the rest in growth investments, for later years.
   Refill bucket 1 from the others in good years.
3. Income floor: cover essentials with reliable income (annuity, rental, EPF monthly withdrawals), and fund extras from investments.

Risks to plan for:
- Longevity: living longer than expected.
- Inflation, especially healthcare costs.
- Scams targeting retirees with lump sums. Check every offer with the SC''s Investment Checker.

Review spending and withdrawals every year.')
,
(N'RET201', 8, 2, N'Text', NULL, NULL,
N'Sources and further reading
- KWSP: Retirement Income Adequacy (RIA) leaflet: https://www.kwsp.gov.my/documents/d/guest/ria_en_28102025
- Investopedia: The 4% rule: https://www.investopedia.com/terms/f/four-percent-rule.asp
- Securities Commission Malaysia: Investment Checker: https://www.sc.com.my/investment-checker')
,
(N'RET201', 9, 1, N'Text', NULL, NULL,
N'Final quiz for EPF, PRS and Planning for Retirement. Choose an answer for each question before opening it.')
,
(N'RET201', 9, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"What share of new EPF contributions goes to Akaun Persaraan?","options":["10%","15%","75%","100%"],"answer":2},{"q":"What is EPF''s ''Adequate'' savings level at age 60 under the RIA framework?","options":["RM240,000","RM390,000","RM650,000","RM1.3 million"],"answer":2},{"q":"What dividend did EPF declare for conventional savings for 2025?","options":["5.50%","6.15%","6.30%","8.00%"],"answer":1},{"q":"Your top tax rate is 19%. How much tax does a RM3,000 PRS contribution save?","options":["RM190","RM300","RM570","RM3,000"],"answer":2},{"q":"Under the 4% rule, someone spending RM40,000 a year needs roughly:","options":["RM160,000","RM400,000","RM1,000,000","RM4,000,000"],"answer":2},{"q":"Which EPF account can be withdrawn at any time?","options":["Akaun Persaraan","Akaun Sejahtera","Akaun Fleksibel","None"],"answer":2},{"q":"What is sequence of returns risk?","options":["Fees rising over time","A crash early in retirement doing more damage than one later","Dividends paid late","Choosing the wrong PRS provider"],"answer":1}]}')
,
(N'RET201', 9, 3, N'Text', NULL, NULL,
N'Sources and further reading
- KWSP: A quick guide to EPF account restructuring: https://www.kwsp.gov.my/en/w/article/account-restructuring-guide
- KWSP: Retirement Income Adequacy (RIA) leaflet: https://www.kwsp.gov.my/documents/d/guest/ria_en_28102025
- Private Pension Administrator (PPA): PRS tax relief: https://www.ppa.my/joining-prs/prs-tax-relief/
- Investopedia: The 4% rule: https://www.investopedia.com/terms/f/four-percent-rule.asp')
;

-- FIN101
INSERT INTO @Blocks VALUES

(N'FIN101', 1, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=n5g_T287kJw',
N'Video: "Digital Wallets Explained: Beginners Guide" by Money Instructor (YouTube).')
,
(N'FIN101', 1, 2, N'Text', NULL, NULL,
N'An e-wallet (such as Touch ''n Go eWallet, GrabPay, ShopeePay, Boost or BigPay) stores money you load into it and lets you pay by QR code, NFC or online.

How your money is held: in Malaysia, e-wallets that store value are e-money issuers approved by Bank Negara Malaysia. Under BNM''s e-money rules, non-bank issuers must keep customer funds safe, separate from their own money (for example, in a trust account with a licensed bank), so they cannot use it for their own business. You can check whether a provider is approved on BNM''s list of regulatees.

Important differences from a bank account:
- E-wallet balances are not deposits, so they are not protected by PIDM deposit insurance.
- Wallets have balance and transaction limits, which depend on your verification level (eKYC).
- Most e-wallets pay little or no interest. Some offer linked investment features such as money market funds, which are investments, not deposits.

Good practice:
- Keep only spending money in e-wallets, not savings.
- Turn on app lock, biometrics and transaction notifications.
- Set daily limits.
- Use DuitNow QR at merchants to pay from any bank or e-wallet.

If you lose your phone, contact the e-wallet provider immediately to freeze the account.')
,
(N'FIN101', 1, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Digital Wallets Explained: Beginners Guide, Money Instructor: https://www.youtube.com/watch?v=n5g_T287kJw
- Investopedia: Digital wallet: https://www.investopedia.com/terms/d/digital-wallet.asp
- Bank Negara Malaysia: Policy document on electronic money (e-money): https://www.bnm.gov.my/-/pd-emoney
- Bank Negara Malaysia: List of regulatees: https://www.bnm.gov.my/list-of-regulatees
- PIDM: Coverage for the Deposit Insurance System: https://www.pidm.gov.my/en/for-public/deposit-insurance-system-dis/coverage-for-dis/')
,
(N'FIN101', 2, 1, N'Text', NULL, NULL,
N'Digital banks are licensed banks without traditional branches. Bank Negara Malaysia awarded five digital bank licences in April 2022: GXBank, Boost Bank, AEON Bank (Islamic), KAF Digital Bank (Islamic) and Ryt Bank. Each was then approved to start operating at different times from 2023 onwards.

How they differ from traditional banks:
- App-only: account opening by eKYC in minutes, no branch visits.
- Often higher interest or profit on savings, and features like savings pockets and daily interest.
- Simpler fee structures.
- Fewer products so far (mostly savings, debit cards, small loans).

Safety:
- Digital banks are regulated by Bank Negara Malaysia like other banks.
- Deposits at digital banks that are PIDM members are protected up to RM250,000 per depositor per member bank, just like traditional banks. Check that the bank is a PIDM member.

Traditional banks still have advantages: branches, ATMs, a full product range (home loans, FDs, foreign currency), and long track records.

A practical setup:
- Keep your salary and bills in a traditional bank.
- Use a digital bank for savings pockets or your emergency fund, if the rate is better and it is PIDM-protected.
- Spread larger savings across banks to stay within PIDM limits.')
,
(N'FIN101', 2, 2, N'Text', NULL, NULL,
N'Sources and further reading
- PIDM: Coverage for the Deposit Insurance System: https://www.pidm.gov.my/en/for-public/deposit-insurance-system-dis/coverage-for-dis/
- Bank Negara Malaysia: List of regulatees: https://www.bnm.gov.my/list-of-regulatees')
,
(N'FIN101', 3, 1, N'Media', N'Video', N'https://www.youtube.com/watch?v=EWk1WCB68lg',
N'Video: "Siri Seram Scam: Taktik Scam APK Malware" by BNM Official (YouTube).')
,
(N'FIN101', 3, 2, N'Text', NULL, NULL,
N'Scams in Malaysia increasingly target phones and banking apps. The video, from Bank Negara Malaysia, is in Bahasa Malaysia.

Phishing: fake SMS, emails, WhatsApp messages or websites pretending to be your bank, LHDN, PDRM, Pos Malaysia, a courier or an e-wallet. They push you to click a link and enter your login or TAC/OTP.

APK malware scams: you are persuaded to install an app from outside the official app store, often an .apk file sent through WhatsApp or a link, for a cleaning service, a cheap deal, a parcel, or a "government aid" form. The app asks for permissions (accessibility, SMS) that let scammers read your OTPs and control your phone, then drain your accounts.

How to protect yourself:
- Never install apps from links or files. Use only Google Play or the App Store.
- Never share your banking password, TAC/OTP or card PIN with anyone. Banks will never ask for them.
- Type your bank''s address yourself instead of clicking links.
- Use the kill switch in your banking app, or call your bank, if something looks wrong.
- Check suspicious phone numbers and bank accounts with PDRM''s Semak Mule.

If you have been scammed: call the National Scam Response Centre (NSRC) at 997 immediately, then your bank. The first hour matters most for stopping transfers.')
,
(N'FIN101', 3, 3, N'Text', NULL, NULL,
N'Sources and further reading
- Video: Siri Seram Scam: Taktik Scam APK Malware, BNM Official: https://www.youtube.com/watch?v=EWk1WCB68lg
- MyGOV: NSRC 997 scam hotline: https://www.malaysia.gov.my/en/topics/nsrc-997-hotline
- PDRM: Semak Mule: https://semakmule.rmp.gov.my/
- Bank Negara Malaysia: List of regulatees: https://www.bnm.gov.my/list-of-regulatees')
,
(N'FIN101', 4, 1, N'Text', NULL, NULL,
N'Check what you learned in E-Wallets and Digital Banking Safely. Choose an answer for each question before opening it.')
,
(N'FIN101', 4, 2, N'Quiz', NULL, NULL,
N'{"questions":[{"q":"Are e-wallet balances protected by PIDM deposit insurance?","options":["Yes, up to RM250,000","No, they are not deposits","Only for Touch ''n Go","Only on weekends"],"answer":1},{"q":"How many digital bank licences did Bank Negara award in 2022?","options":["Two","Three","Five","Ten"],"answer":2},{"q":"A courier sends a WhatsApp link to install an .apk app to track your parcel. You should:","options":["Install it quickly","Ignore it and only use official app stores","Send your OTP to confirm","Forward it to friends"],"answer":1},{"q":"Which number do you call immediately after being scammed in Malaysia?","options":["999","997","911","1300"],"answer":1},{"q":"Where can you check if a bank account or phone number is linked to scams?","options":["PDRM Semak Mule","MyTax","i-Akaun","Bursa Malaysia"],"answer":0},{"q":"What is the safest place for your emergency savings among these?","options":["An e-wallet","A PIDM-protected bank or digital bank account","A crypto wallet","Cash at home"],"answer":1}]}')
,
(N'FIN101', 4, 3, N'Text', NULL, NULL,
N'Sources and further reading
- PIDM: Coverage for the Deposit Insurance System: https://www.pidm.gov.my/en/for-public/deposit-insurance-system-dis/coverage-for-dis/
- MyGOV: NSRC 997 scam hotline: https://www.malaysia.gov.my/en/topics/nsrc-997-hotline
- PDRM: Semak Mule: https://semakmule.rmp.gov.my/')
;

INSERT INTO dbo.LessonBlocks (LessonId, Position, BlockType, MediaKind, MediaUrl, Body)
SELECT l.LessonId, b.BlockPos, b.BlockType, b.MediaKind, b.MediaUrl, b.Body
FROM @Blocks b
JOIN dbo.Courses c       ON c.CourseCode = b.CourseCode
JOIN dbo.CourseLessons l ON l.CourseId = c.CourseId AND l.Position = b.LessonPos
WHERE NOT EXISTS (SELECT 1 FROM dbo.LessonBlocks x WHERE x.LessonId = l.LessonId)
ORDER BY l.LessonId, b.BlockPos;

SELECT COUNT(DISTINCT b.LessonId) AS LessonsWithContent,
       COUNT(*)                   AS Blocks,
       SUM(CASE WHEN b.BlockType = 'Media' THEN 1 ELSE 0 END) AS Videos,
       SUM(CASE WHEN b.BlockType = 'Quiz'  THEN 1 ELSE 0 END) AS Quizzes
FROM dbo.LessonBlocks b
JOIN dbo.CourseLessons l ON l.LessonId = b.LessonId
JOIN dbo.Courses c       ON c.CourseId = l.CourseId
WHERE c.ImageUrl IS NOT NULL;

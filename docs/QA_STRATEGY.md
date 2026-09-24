# Task 2: QA Strategy for a Mobile Trading App

The scenario: I've just joined a fintech startup. There's an iOS and Android trading app going live in two weeks. There are no tests, no QA documentation, and the developers have been moving fast. Real people's money will be in this app.

My background is frontend and UI testing (functional, regression and end-to-end), so that's the lens I've written this from. Where something falls outside that, like unit tests or backend checks, I've said who I'd work with to cover it.

---

## 1. Where do you start?

I wouldn't start by writing tests. With two weeks to go, the first job is figuring out what absolutely can't break.

On day one I'd install the app on an iPhone and an Android phone and use it the way a new customer would. I'd sign up, go through verification, add funds, buy something, sell it, and try to withdraw. That tells me more in a few hours than any document would, and it usually turns up a few serious bugs straight away.

Alongside that, I'd sit down with the product owner and the lead developer and ask a few simple questions:
- What changed most recently?
- What are you most worried about?
- Where have bugs shown up before?

Developers almost always know where the weak spots are. They just haven't had anyone to tell.

From there I'd write down the main user journeys, starting with every place where money moves:
- signing up and verifying identity,
- logging in (password, 2FA, Face ID / fingerprint),
- depositing money,
- buying, selling and converting,
- checking balances and order history,
- withdrawing,
- recovering a locked account.

These are what I'd test first and hardest.

A few practical things I'd sort out in the first couple of days:
- a test environment with test money, so I'm not testing trades with real funds,
- one place to log bugs, with agreed severity levels,
- a short daily check-in with the developers to go through new bugs,
- an agreement with the team on what "ready to release" means. I want that settled early, not argued about the night before launch.

I'd be realistic about automation. Two weeks isn't enough to build a full automated suite and test the app properly at the same time. So the first week is mostly hands-on testing of the critical journeys. I'd start automating the most important flows as soon as they're stable, and keep building the suite after launch.

---

## 2. How would you approach testing this app?

I'd focus on what the customer sees and does, and test the riskiest parts the hardest.

**Functional testing of every critical journey, on both platforms.** Each journey from question 1 gets tested properly on iOS and Android. That covers the normal path, but also:
- wrong inputs,
- empty states,
- error messages,
- what happens when you go back halfway through.

**Money on screen has to be right.** I can't see the backend, but I can check what the customer sees. After every buy, sell, deposit or withdrawal:
- Does the balance update correctly?
- Is the fee shown the fee that was charged?
- Do small amounts and long decimals display properly?

I'd also double-tap the Buy and Withdraw buttons and check that only one order goes through. A duplicate withdrawal is exactly the kind of bug that makes the news.

**End-to-end tests.** These cover full journeys from start to finish: open the app, log in, deposit, trade, check the balance, log out. These are what I'd automate first, using Appium, or Robot Framework with AppiumLibrary since that's what I already work with.

**Real-life mobile situations.** People don't use their phones in perfect conditions. I'd test:
- losing signal in the middle of a trade,
- switching between Wi-Fi and mobile data,
- a phone call coming in,
- the app going into the background,
- the phone locking,
- the app being force-closed and reopened.

Each time, the question is whether the customer ends up with a clear, correct state or a confusing one.

**Devices.** I'd pick a sensible set: the last two or three iOS versions, and a mix of popular Android phones (Samsung, Pixel, Xiaomi), including one cheaper, slower phone. I'd use a few real devices and a cloud device service such as BrowserStack for the rest.

**The release build itself.** I'd test the exact build that's going to the App Store and Play Store, not just the development builds. Things sometimes break only in the final version.

**What I'd make sure someone else covers.** Developers should own unit tests, and the backend team should be checking their APIs. I'd ask what coverage exists so the team knows where the gaps are. I'd also push for a security review before launch, because it's an app holding people's money. From the front end, I'd still check:
- sessions time out,
- logging out actually logs you out,
- sensitive screens are hidden in the app switcher.

**Safety nets for launch.** They aren't tests, but I'd push for them:
- releasing to a small percentage of users first,
- a switch to turn off trading or withdrawals if something goes wrong,
- a way to force users onto a fixed version.

---

## 3. What does QA look like inside a sprint?

Here's how I'd want a ticket to move through a sprint:

1. **Refinement.** I join the planning conversation with product and the developers. I help write the acceptance criteria and ask the awkward questions early. What happens if the user has no balance? What does the error message say? Does this work the same on Android? A ticket isn't ready until everyone agrees how we'll know it works.
2. **While it's being built.** I write my test cases and plan any exploratory testing. If the team can produce a test build for each change, I start testing before it's merged.
3. **Ready for QA.**
   - I test against the acceptance criteria on both iOS and Android.
   - Then I explore around the change, because new features often break things next door.
   - Every bug gets clear steps, the device and OS version, screenshots or a screen recording, and a severity.
4. **Fixes.** I retest the fix, and check the area around it too.
5. **Adding to the regression suite.** If the ticket touches a critical journey, I add or update the automated test in the same sprint. If that isn't possible, I raise a ticket for it so it doesn't get forgotten.
6. **Done means done:**
   - acceptance criteria pass on both platforms,
   - no open serious bugs,
   - the regression suite still passes.
7. **Before release.** Full regression on the release candidate, a smoke test on real devices, then a go/no-go conversation using the release checklist below.
8. **After release.** I keep an eye on crash reports and customer feedback. Any bug that slipped through gets a new regression test, so the same bug can't come back unnoticed.

---

## 4. What does your ideal regression suite look like?

I'd build it in layers, based on how often each layer runs:

| Layer | When it runs | What it covers |
|---|---|---|
| Smoke tests | Every new build | App opens, login works, balance shows, one small test trade, logout. About 10–15 minutes. |
| Nightly E2E regression | Every night, during off hours | Every critical journey end to end, on both iOS and Android, across the device list. |
| Full release regression | Before every release | The nightly suite, plus manual exploratory testing of anything new or risky. |

**The nightly run matters most to me.** I'd schedule the full E2E suite to run every day during off hours, say 2 a.m. By the time the team is back at work, there's a complete report waiting that shows what's working and what broke overnight. I'd go through it first thing, so broken builds are caught before standup, not days later when nobody remembers what changed. This repo does the same thing: the GitHub Actions workflow runs the web suite every night at 02:00 UTC.

A few things make a regression suite worth trusting:
- **Stable test data.** Dedicated test accounts with known balances, so a test never fails because someone else used the account.
- **Independent tests.** Each test sets itself up, so it can run on its own or in any order.
- **No flaky tests left lying around.** A test that fails at random is worse than no test, because people learn to ignore red results. Flaky tests get pulled out, fixed, then put back.
- **Organised with tags,** so I can run just the login tests, or just the trading tests, when that's all that changed.
- **Easy-to-read results** that non-testers can understand, with screenshots of failures.
- **Kept up to date.** When a feature changes, its tests change too. Every bug that reaches customers gets a test added.

---

## 5. What would keep you up at night about this app?

Honestly, anything to do with money going to the wrong place:
- **Duplicate or wrong transactions.** A double tap or a dropped connection creating two orders, or a balance on screen that doesn't match what the customer actually has.
- **Crypto withdrawals to the wrong address.** Unlike a bank transfer, that money usually can't be recovered. The address checks and confirmation screens have to be solid.
- **Someone getting into another person's account.** For a fintech, one security incident at launch could end the product.
- **Prices that are out of date.** If prices stop updating during a busy market, people could trade at the wrong price, and launch day is when traffic is highest.
- **No safety net for quick fixes.** With no existing tests and a team shipping fast, every hotfix after launch is a gamble unless the regression suite is in place.
- **Not being able to take a bad release back.** A website can be rolled back in minutes. A mobile release has to go through store review, and old versions stay on people's phones. That's why I'd push hard for staged rollouts and a kill switch.
- **Compliance gaps,** like users getting through identity checks they shouldn't, or missing risk warnings.
- **Finding out from customers first.** If something breaks, I want us to see it in our monitoring before people start posting about it.
I have had an experience with my current organisation where the trade was interrupted mid-way and the user (my browser during the nightly runs) was charged twice. Hence, the testcases related to trades are something i like keeping a close eye on.
---

## Release Readiness Checklist

**Testing**
- [ ] All critical journeys tested on the release build, on iOS and Android
- [ ] Nightly E2E regression passing, and the smoke suite passing on the release build
- [ ] No open critical or high-severity bugs; remaining known issues listed and accepted by product
- [ ] Money checks done: balances, fees and amounts correct after deposit, buy, sell, convert and withdraw
- [ ] Double-tap and lost-connection tests passed on order and withdrawal screens
- [ ] Tested on the agreed device list, including a low-end Android phone
- [ ] Upgrade from the previous beta version tested

**Security and compliance**
- [ ] Security review done, with findings fixed or formally accepted
- [ ] Session timeout, logout and sensitive-screen hiding checked
- [ ] Identity verification, country restrictions and risk warnings checked
- [ ] Privacy policy, terms and store listing reviewed
- [ ] App Store and Play Store rules for financial apps met

**Launch readiness**
- [ ] Crash reporting and transaction monitoring live, with alerts set up
- [ ] Kill switch ready for trading and withdrawals
- [ ] Staged rollout plan agreed (for example 5%, then 25%, then 100%)
- [ ] Forced-update option working
- [ ] Plan for what to do if something goes wrong, and who's on call during launch week
- [ ] Support team briefed on known issues

**Sign-off**
- [ ] Go/no-go meeting held; product, engineering, QA and compliance all agree

---

## Risk Matrix

Likelihood and impact are scored 1 (low) to 3 (high). Risk = likelihood × impact: **7–9 High, 4–6 Medium, 1–3 Low**.

| # | Risk | Likelihood | Impact | Score | How I'd reduce it |
|---|---|---|---|---|---|
| 1 | No regression safety net while the team ships fast | 3 | 3 | **9 High** | Smoke tests on every build and nightly E2E regression from week one |
| 2 | A bad release can't be pulled back quickly | 3 | 3 | **9 High** | Staged rollout, kill switch, forced update |
| 3 | Duplicate order or withdrawal from a double tap or dropped connection | 2 | 3 | 6 Medium | Double-tap and network-loss tests on every money screen, on both platforms |
| 4 | Wrong balance, fee or amount shown to the customer | 2 | 3 | 6 Medium | Check on-screen values after every transaction type, with small, large and many-decimal amounts |
| 5 | Crypto sent to the wrong address or network | 2 | 3 | 6 Medium | Test address validation and confirmation screens with wrong and mismatched addresses |
| 6 | Someone gets into another person's account | 2 | 3 | 6 Medium | Security review before launch; front-end checks of login, 2FA, timeout and logout |
| 7 | Out-of-date prices during busy periods | 2 | 3 | 6 Medium | Test price updates, reconnecting after signal loss, and what the user sees if prices stop |
| 8 | Launch-day traffic or a payment/ID-check provider goes down | 2 | 3 | 6 Medium | Test the error screens users see when a provider fails; team to load-test before launch |
| 9 | Compliance gaps (ID checks, country restrictions, risk warnings) | 2 | 3 | 6 Medium | Walk through with compliance; test the verification and restriction flows |
| 10 | Crashes on certain Android phones | 3 | 2 | 6 Medium | Test on a wide device list via a cloud device service; crash reporting with alerts |
| 11 | Bugs that only appear in the final store build | 2 | 2 | 4 Medium | Test the exact build being submitted |
| 12 | Store rejection delays launch | 2 | 2 | 4 Medium | Check store rules early and submit with time to spare |
| 13 | Accessibility problems (screen readers, large text) | 2 | 1 | 2 Low | Check key journeys with VoiceOver/TalkBack and large font settings |

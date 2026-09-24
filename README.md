# mb.io QA Automation: MultiBank QA Engineer Challenge

**Candidate:** Amna Syed Aamir
**Repository:** https://github.com/amnasyedaamirr/mbio-qa-automation

This repo has both parts of the assessment:
- **Task 1:** an automated UI test suite for the public mb.io website, built with Robot Framework and Selenium (Python).
- **Task 2:** my QA strategy for a mobile trading app.

## Table of contents

| Contents | Links |
|---|---|
| How to run the tests | [Running the tests](#running-the-tests) |
| Results and bugs found | [What the tests found](#what-the-tests-found) |
| How the framework is built, and why | [How it's built](#how-its-built) |
| Assumptions | [Assumptions](#assumptions) |
| Test plan | [Summary below](#test-plan-summary) · [full test plan](https://github.com/amnasyedaamirr/mbio-qa-automation/blob/main/docs/TEST_PLAN.md) |
| Sample test report | [docs/sample-report](https://github.com/amnasyedaamirr/mbio-qa-automation/tree/main/docs/sample-report) |
| Cross-browser results | [Chrome + Edge report](https://github.com/amnasyedaamirr/mbio-qa-automation/tree/main/docs/sample-report/cross-browser) · [Chrome + Firefox in GitHub Actions](https://github.com/amnasyedaamirr/mbio-qa-automation/actions) |
| CI setup | [.github/workflows/ui-tests.yml](https://github.com/amnasyedaamirr/mbio-qa-automation/blob/main/.github/workflows/ui-tests.yml) |
| Task 2 answers | [Summary below](#task-2-qa-strategy-summary) · [full answers](https://github.com/amnasyedaamirr/mbio-qa-automation/blob/main/docs/QA_STRATEGY.md) |
| Task 2 release readiness checklist | [Checklist](https://github.com/amnasyedaamirr/mbio-qa-automation/blob/main/docs/QA_STRATEGY.md#release-readiness-checklist) |
| Task 2 risk matrix | [Risk matrix](https://github.com/amnasyedaamirr/mbio-qa-automation/blob/main/docs/QA_STRATEGY.md#risk-matrix) |

---

## Running the tests

You'll need Python 3.10 or newer and Google Chrome. You don't need to download ChromeDriver; Selenium sorts that out itself.

```bash
git clone https://github.com/amnasyedaamirr/mbio-qa-automation.git
cd mbio-qa-automation
python -m pip install -r requirements.txt
python run_tests.py
```

On a Mac or Linux, use `python3` if `python` isn't found.

When it finishes, open `results/chrome/report.html` for the summary. Click any test to see its step-by-step log, including a screenshot of anything that failed.

**Using a virtual environment (optional).** This keeps the packages separate from the rest of your system:

| Windows (PowerShell) | Mac / Linux |
|---|---|
| `python -m venv .venv` | `python3 -m venv .venv` |
| `.\.venv\Scripts\Activate.ps1` | `source .venv/bin/activate` |
| `python -m pip install -r requirements.txt` | `python -m pip install -r requirements.txt` |

**Other ways to run it:**

| Command | What it does |
|---|---|
| `python run_tests.py` | All tests in Chrome |
| `python run_tests.py --headless` | All tests with no browser window showing |
| `python run_tests.py --include smoke` | Just the quick smoke tests |
| `python run_tests.py --include navigation` | Just one area. Other tags: `layout`, `trading`, `content`, `links`, `app-links`, `about`, `negative`, `performance` |
| `python run_tests.py --browser firefox` | A different browser: `chrome`, `firefox`, `edge` or `safari` |
| `python run_tests.py --cross-browser chrome edge` | Several browsers one after another, combined into one report at `results/report.html` |

It works on Windows, Mac and Linux. The tests open links in new tabs with Ctrl+click, or Cmd+click on a Mac; this is picked automatically.

---

## What the tests found

I ran the suite on 24 Sept 2026 in Chrome and Edge: **25 passed and 2 failed in both browsers**, with identical results.

Both failures are real problems on the site, not problems with the tests, so I've left them failing on purpose:

| Test | What I found | Severity |
|---|---|---|
| HP17 | All 26 coin links in the homepage market section (for example `https://mb.io/explore/BTC`) return an **HTTP 500 server error**. I checked BTC by hand in Chrome DevTools: the page still shows up for visitors, but the server reports an error behind the scenes. Search engines and uptime monitors see these pages as broken, which can hurt how the coin pages show up in search. The links are missing the language part of the address (`/explore/BTC` instead of `/en/explore/BTC`), which might be the cause. | Medium |
| WM08 | The Cointelegraph press release link under "Community & Media" on the Why MultiBank page returns **404 Not Found**. The article looks like it has been moved or taken down. | Low |

Because of these two bugs, the runs in GitHub Actions show as failed. That's the pipeline doing its job. You can download each run's full report from the **Artifacts** section of the run.

---

## What's covered

There are 27 tests in two suites, and every requirement in the brief has at least one:

| Requirement from the brief | Tests |
|---|---|
| Top navigation shows all expected items | HP01, HP03 |
| Each navigation item goes to the right page | HP02, HP05 |
| Navigation works at standard desktop sizes (1920, 1440, 1366 px) | HP04 |
| Trading section shows trading pairs | HP06 |
| Pairs are grouped into categories (Top Gainers, Trending Now, Top Losers) with a symbol, price and % change | HP07 |
| Marketing banners appear in the right part of the page | HP10 |
| App Store and Google Play links go to the right place | HP12, HP13 |
| About Us > Why MultiBank page shows the right headings, text and sections | WM01 to WM08 |
| Edge case: a page that doesn't exist | HP15 |
| Edge case: broken links | HP16, HP17, WM08 |
| Edge case: content that's slow to load | HP18, HP19 |
| Extra checks I added | Headings and key text including the Risk Warning (HP08, HP09), call-to-action buttons (HP11), footer legal links (HP14) |
| Bonus: CI | GitHub Actions runs everything in Chrome and Firefox on every push and every night |

---

## Project layout

```
├── .github/workflows/ui-tests.yml   GitHub Actions: runs on every push and nightly at 02:00 UTC
├── docs/
│   ├── TEST_PLAN.md                 Task 1 test plan
│   ├── QA_STRATEGY.md               Task 2 answers, release checklist and risk matrix
│   └── sample-report/               Sample test reports, single-browser and cross-browser
├── resources/
│   ├── variables.robot              All test data and settings: URLs, expected text, timeouts
│   ├── locators.robot               All the ways the tests find elements on the page
│   ├── keywords.robot               Reusable steps the tests are built from
│   └── link_checker.py              Small Python helper for checking links quickly
├── tests/
│   ├── homepage_tests.robot         Homepage tests (HP01 to HP19)
│   └── why_multibank_tests.robot    Why MultiBank page tests (WM01 to WM08)
├── run_tests.py                     Runs everything with one command, on any operating system
└── requirements.txt
```

---

## How it's built

**Why Robot Framework.** The tests read almost like plain English, so anyone on the team can follow them, not just testers. It also produces clear HTML reports with screenshots out of the box.

**Everything has one home.** I kept the framework in four layers:
- the test files say *what* is being checked,
- `keywords.robot` holds *how* each check is done,
- `locators.robot` holds how elements are found on the page,
- `variables.robot` holds the data: URLs, expected text, timeouts.

If a URL or a heading changes on the site, I change it in one place and every test picks it up. The test files themselves don't need touching.

**Adding a test is usually just adding a line.** Menu items, buttons, headings and footer links are lists in `variables.robot`, and the tests loop through them. Adding a new menu item to the list adds a new check. These tests also carry on after a failure, so one run tells you everything that's broken, not just the first thing.

**Finding elements in a way that doesn't break easily.** The site is built with Next.js, which changes its CSS class names every time it's deployed. So the tests find elements by what a person sees instead: button text, heading text, image file names. Responsive sites also often have hidden copies of elements, one for desktop and one for mobile, so the tests always pick the one that's actually visible.

**No fixed waiting times.** There are no "wait 5 seconds" steps anywhere. Every wait watches for something specific: an element appearing, the address changing, an image finishing loading. The tests move on as soon as it happens, up to a maximum set in one place. That keeps them quick when the site is fast and patient when it's slow.

**Links open in a new tab.** When a test checks a link, it Ctrl+clicks it so the page opens in a new tab. It then checks the new tab lands on the right address (following any redirects), closes it, and goes back. The page being tested never gets navigated away from. If a link ignores Ctrl+click, which some JavaScript buttons do, the test opens the link's address in a new tab instead and notes that in the log.

**Checks that mean something.**
- Images are only counted as working if they actually loaded, not just if they're in the page code.
- Banners have to sit between the header and the footer.
- For live prices, the tests check the format (a coin symbol, a price, a % change) rather than exact numbers, which change every second.

**Fast link checks.** Opening every link in a browser would be slow, so the Python helper `link_checker.py` checks each link's status directly. It also pretends to be an iPhone and then an Android phone, to confirm the app download link sends each one to the right store.

**Tests don't depend on each other.** Each test starts from a clean page: extra tabs closed, window size reset, page reloaded. So any test can run on its own, or in any order.

**Being careful about what counts as broken.** Some sites block automated checks and return a "forbidden" (403) or "too many requests" (429) response. Those get flagged as warnings to check by hand, instead of being reported as broken links.

---

## Assumptions

- **The target site.** The email named mb.io as the fallback target, so I tested `https://mb.io/en-AE`. Depending on location, the site sometimes redirects `/en-AE` to `/en`, so the tests accept both.
- **The trading scenario.** I couldn't log in, so I used the market section on the homepage for "spot trading". It shows trading pairs grouped into Top Gainers, Trending Now and Top Losers.
- **About Us > Why MultiBank.** This content is on the `/company` page, under the heading "Why MultiBank Group?".
- **The navigation menu.** It loads after the rest of the page, so I confirmed the menu labels on the live site before adding them to the tests.
- **What I left out.** I chose not to include the mobile screen size test. From the bonus list, I only did CI. I didn't create accounts or submit any data.
- **GitHub Actions location.** GitHub's servers are in the US, and the site says it isn't aimed at US residents. So results in GitHub Actions might differ a little from local runs.

**If the menu changes:** open the site in Chrome, press F12, go to the **Console** tab, and run:

```js
[...document.querySelectorAll('header a')].map(a => `${a.innerText.trim()}  ->  ${a.href}`).join('\n')
```

Then update `NAV_LINKS` in `resources/variables.robot` with what it lists.

---

## Test plan summary

Full version: [docs/TEST_PLAN.md](https://github.com/amnasyedaamirr/mbio-qa-automation/blob/main/docs/TEST_PLAN.md)

I tested the homepage and the Why MultiBank page as a logged-out visitor on desktop. The goal is to make sure a new visitor can find their way around, sees the right information, and doesn't hit broken pages.

The strongest checks go on what would hurt the business most if it broke:
- **sign-up and login buttons,** because they're how new customers join,
- **the Risk Warning and legal links,** because a regulated platform must show them,
- **the market prices,** because missing prices make the site look untrustworthy,
- **the app download link,** because it's how visitors get the app.

The suite runs in Chrome, Edge and Firefox, on Windows locally and on Linux in GitHub Actions. Testing counts as finished when:
- all high-priority tests pass,
- the suite has run in more than one browser,
- every failure has been looked into and sorted into either a site bug (listed above) or a test problem (fixed).

---

## Task 2: QA strategy summary

Full answers, the release readiness checklist and the risk matrix are here: [docs/QA_STRATEGY.md](https://github.com/amnasyedaamirr/mbio-qa-automation/blob/main/docs/QA_STRATEGY.md)

*The scenario: a new iOS and Android trading app, two weeks from launch, with no tests, no QA documents, and real customer money involved. My background is frontend UI testing (functional, regression and end-to-end), so that's the angle I've taken.*

**1. Where do you start?**
- I'd start by using the app myself on an iPhone and an Android phone, the way a customer would.
- I'd talk to the product owner and developers about what worries them.
- Then I'd list every journey where money moves: sign-up, login, deposit, buy, sell, withdraw. Those get tested first and hardest.
- I'd agree early what "ready to release" means, so it isn't argued about the night before launch.

**2. How would you approach testing?**
- Functional testing of every critical journey on both platforms, including errors and edge cases.
- Careful checks that money shown on screen is right after every transaction, and that double-tapping Buy or Withdraw only creates one order.
- End-to-end tests of full journeys, automated with Appium or Robot Framework with AppiumLibrary.
- Real-world phone situations: losing signal mid-trade, calls coming in, the app being closed.
- A realistic device list, and the exact build going to the stores.
- Developers own unit tests and the backend team owns API checks. I'd make sure those gaps are known and push for a security review before launch.

**3. QA inside a sprint**
1. I help write clear acceptance criteria in planning.
2. I write test cases while the feature is being built.
3. I test on both iOS and Android, then explore around the change.
4. I log bugs with screenshots or recordings, then retest the fixes.
5. I add critical journeys to the regression suite in the same sprint.
6. Before release: full regression and a go/no-go check. After release: every bug that got through gets a new test.

**4. Ideal regression suite**

It has three layers:
- **smoke tests** on every build,
- **a full end-to-end regression that runs every night during off hours** (for example 2 a.m.),
- **full regression plus exploratory testing** before each release.

The nightly run means that when the team gets back to work, there's already a full report showing what's working and what broke overnight. Problems get caught before standup, not days later. This repo does the same thing: GitHub Actions runs the web suite every night at 02:00 UTC.

**5. What would keep me up at night?**

Money going to the wrong place:
- duplicate or wrong transactions,
- crypto sent to a wrong address, which usually can't be recovered.

Beyond that:
- someone getting into another person's account,
- prices going stale on a busy launch day,
- no test safety net for quick fixes,
- mobile releases that can't be pulled back as easily as a website,
- finding out about problems from customers before our own monitoring spots them.

---

## What I'd add next

- Visual comparison tests, to catch layout changes the eye would notice.
- Mobile screen size tests.
- Running tests in parallel, to make the suite faster.
- Splitting `keywords.robot` into one file per page as more pages get covered.

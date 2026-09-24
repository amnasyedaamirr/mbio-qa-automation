# mb.io QA Automation – MultiBank QA Engineer Challenge

UI automation framework for the public mb.io website, built with **Robot Framework + SeleniumLibrary (Python)**, plus written QA strategy for a mobile trading app.

| Deliverable | Where |
|---|---|
| Task 1 – automation framework | `resources/`, `tests/`, `run_tests.py` |
| Task 1 – test plan | [docs/TEST_PLAN.md](docs/TEST_PLAN.md) |
| Task 2 – QA strategy answers, release readiness checklist, risk matrix | [docs/QA_STRATEGY.md](docs/QA_STRATEGY.md) |
| Sample execution report | `docs/sample-report/` (download and open `report.html`) |
| Cross-browser evidence | `docs/sample-report/cross-browser/` and the **Actions** tab (Chrome + Firefox on every push) |
| CI pipeline | [.github/workflows/ui-tests.yml](.github/workflows/ui-tests.yml) |

---

## Quick start – run the suite with one command

**Prerequisites:** Python 3.10+ and Google Chrome. Browser drivers are downloaded automatically by Selenium Manager, so no ChromeDriver setup is needed.

```bash
git clone <this-repo-url>
cd <repo-folder>
python -m pip install -r requirements.txt
python run_tests.py
```

On macOS/Linux, use `python3` if `python` is not found.

Results are written to `results/chrome/report.html` (summary) and `log.html` (step-by-step detail with screenshots of any failure).

### Recommended: use a virtual environment

| Windows (PowerShell) | macOS / Linux |
|---|---|
| `python -m venv .venv` | `python3 -m venv .venv` |
| `.\.venv\Scripts\Activate.ps1` | `source .venv/bin/activate` |
| `python -m pip install -r requirements.txt` | `python -m pip install -r requirements.txt` |

### Run options

| Command | What it does |
|---|---|
| `python run_tests.py` | All tests, Chrome, visible window |
| `python run_tests.py --headless` | All tests, no visible window (also forces a 1920×1080 viewport on any screen) |
| `python run_tests.py --include smoke` | Only the quick smoke tests |
| `python run_tests.py --include navigation` | One area (tags: `navigation`, `layout`, `trading`, `content`, `links`, `app-links`, `about`, `negative`, `performance`, `smoke`) |
| `python run_tests.py --browser firefox` | Another browser (`chrome`, `firefox`, `edge`, `safari`) |
| `python run_tests.py --cross-browser` | Chrome, Firefox and Edge one after another, merged into `results/report.html` |
| `python -m robot --outputdir results tests` | Plain Robot Framework command, without the runner |

The suite runs on **Windows, macOS and Linux**. The new-tab shortcut (Cmd+click on macOS, Ctrl+click elsewhere) is detected automatically.

---

## What is tested

27 tests across two suites. Each brief requirement maps to at least one test.

| Brief requirement | Tests |
|---|---|
| Top navigation renders with all expected items | HP01, HP03 |
| Each navigation item links to the correct destination | HP02, HP05 |
| Navigation at standard desktop viewports (1920, 1440, 1366 px) | HP04 |
| Trading section renders and displays trading pairs | HP06 |
| Pairs grouped into categories (Top Gainers / Trending Now / Top Losers) with expected data fields (symbol, price, % change) | HP07 |
| Marketing banners render in the expected page region | HP10 |
| App Store and Google Play download links resolve correctly | HP12, HP13 |
| About Us > Why MultiBank page: components, headings and section text | WM01–WM08 |
| Edge case: invalid route handling | HP15 |
| Edge case: broken link detection | HP16, HP17, WM08 |
| Edge case: content loading timeout handling | HP18, HP19 (and polling waits throughout) |
| Additional coverage | HP08–HP09 headings and key copy (incl. the regulatory Risk Warning), HP11 CTAs, HP14 footer legal links |
| Bonus: basic CI | GitHub Actions, Chrome + Firefox |

---

## Project structure

```
├── .github/workflows/ui-tests.yml   CI: headless Chrome + Firefox, reports uploaded as artifacts
├── docs/                            Test plan, Task 2 strategy, sample report
├── resources/
│   ├── variables.robot              ALL test data and configuration (URLs, expected text, timeouts)
│   ├── locators.robot               ALL element locators
│   ├── keywords.robot               Reusable keywords – the "how"
│   └── link_checker.py              Python helper for fast HTTP status and redirect checks
├── tests/
│   ├── homepage_tests.robot         Homepage suite (HP01–HP19) – the "what"
│   └── why_multibank_tests.robot    About Us > Why MultiBank suite (WM01–WM08)
├── run_tests.py                     Cross-platform single-command runner
└── requirements.txt
```

---

## Framework design decisions

**Robot Framework + SeleniumLibrary.** Keyword-driven tests read like plain English, so product owners and manual testers can review them. The built-in HTML reports come with logs, tags and failure screenshots at no extra cost.

**Layered separation of concerns.** Each layer changes for a different reason:
- **Tests** say *what* is verified.
- **Keywords** say *how*.
- **Locators** change when the markup changes.
- **Variables** change when content or URLs change.

A copy change or a redesign touches one file, never the tests.

**Data-driven templates.** Navigation items, CTAs, headings, categories and footer links are dictionaries or lists in `variables.robot`. Adding a row adds a test case, with no new code. Templated tests also keep going after a failure, so one run reports every broken item.

**Resilient locators.** Elements are found by visible text, semantic tags (`header`, `h1`–`h4`) or stable image file names. Generated CSS class names change with each Next.js build, so they aren't used. A helper returns the first *visible* match, because responsive sites keep hidden desktop and mobile duplicates.

**No fixed sleeps.** Every wait polls a condition up to a named timeout:
- an element becomes visible,
- the URL matches,
- an image finishes loading,
- the document is ready.

This keeps the suite fast when the site is fast and patient when it is slow.

**New-tab link verification.** Links are opened with Ctrl/Cmd+click so the page under test never navigates away. The keyword waits for the new tab to settle on the expected URL (after redirects), then closes it. If a JavaScript-driven link ignores the modifier key, it falls back to opening the `href` in a new tab and logs a warning.

**Meaningful assertions.**
- URLs are matched with patterns, so harmless redirects don't fail tests.
- Images must have *loaded* (`naturalWidth > 0`), not just exist.
- Banners must sit between the header and footer.
- Live market data is checked for *format* (symbol, price, % change), not values that change every second.

**HTTP checks without the browser.** `link_checker.py` uses `requests` to check link status in milliseconds. It also follows the app download link as an iPhone and as an Android phone (by user agent), to prove each is routed to its store.

**Test independence.** One browser per suite keeps runs fast. Before every test, the Test Setup closes extra tabs, resets the viewport and timeouts, and reloads the page, so tests can run alone or in any order.

**Honest reporting.** Link scans collect every broken link before failing. HTTP 403/429 responses (typical of bot protection) are logged as warnings for manual follow-up rather than reported as broken links.

---

## Assumptions

- **Target.** The recruiter's email named mb.io as the fallback target. This suite tests `https://mb.io/en-AE`. The site may redirect `/en-AE` to `/en` depending on region, so both are accepted.
- **Trading scenario.** No login is allowed, so the brief's "spot trading section" is covered by the homepage market section. It shows trading pairs grouped into Top Gainers, Trending Now and Top Losers.
- **About Us > Why MultiBank.** This content lives at `/company` ("Why MultiBank Group?").
- **Navigation labels.** The header is rendered client-side. Its labels were confirmed on the live site and are stored in `NAV_LINKS`.
- **Out of scope.** Mobile-breakpoint viewport regression was intentionally excluded. From the bonus list, only CI was implemented. No accounts were created and no data was submitted.
- **CI location.** GitHub-hosted runners are in the US, and the site states its content is not directed at US residents. CI results may therefore differ from local runs. Any such difference is itself a useful signal.

### Finding the navigation labels

If the site's menu changes, open the page in Chrome, press F12, open the **Console**, and run:

```js
[...document.querySelectorAll('header a')].map(a => `${a.innerText.trim()}  ->  ${a.href}`).join('\n')
```

Then update `NAV_LINKS` in `resources/variables.robot`.

---

## Findings from the latest run

<!-- Fill in after the final run: list any test that fails because of a genuine site issue, with the test ID and what was observed. Delete this comment. If everything passes, say so. -->

| Test | Observation | Severity |
|---|---|---|
| | | |

---

## Future improvements

- Visual regression checks (e.g. with Applitools or Playwright screenshots).
- API validation of the market-data responses behind the trading section.
- Mobile-breakpoint coverage.
- Parallel execution with `pabot`.
- A Selenium Grid or cloud device farm for wider browser and OS coverage.
- Splitting `keywords.robot` into one resource file per page as the suite grows.

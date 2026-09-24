# Test Plan – mb.io Public Website (Task 1)

## 1. Objective

Verify that the public mb.io homepage and the About Us > Why MultiBank page work correctly for a logged-out visitor on desktop browsers. That means:
- navigation leads where it should,
- market data and marketing content render,
- download and legal links resolve,
- the site handles bad routes, broken links and slow loading gracefully.

## 2. Scope

**In scope**
- Homepage `https://mb.io/en-AE`: header navigation, logo, CTAs, market section (Top Gainers / Trending Now / Top Losers), headings and key copy (including the regulatory Risk Warning), banners, app download link, footer legal links.
- About Us > Why MultiBank page `https://mb.io/en-AE/company`: headings, section text, company figures, strength cards, images, contact CTA, links.
- Negative and edge cases: invalid route, broken links, page-load performance budget, page-load timeout handling.
- Desktop viewports 1920×1080, 1440×900 and 1366×768.

**Out of scope**
- Anything behind login.
- Account creation, forms or any data submission.
- Mobile breakpoints.
- Visual regression.
- Load testing.
- Content accuracy of live prices.

## 3. Approach

- **Risk-based priority.** The strongest checks go where a failure would cost the business most:
  - sign-up and login routing (acquisition),
  - legal links and the Risk Warning (compliance),
  - market data (trust),
  - app download routing (installs).
- **Automated UI checks** use Robot Framework + SeleniumLibrary. Tests are data-driven from a single variables file.
- **HTTP-level checks** (Python `requests`) cover link health, 404 status codes and app-store redirect chains, which are faster and more precise than a browser for these.
- **Assertions check structure and format, not volatile values.** For example, a price change must look like `+2.35%`, but its value is not fixed.

## 4. Test environment

| Item | Detail |
|---|---|
| Browsers | Chrome (primary), Firefox, Edge |
| Operating systems | Windows (local), Linux (GitHub Actions); macOS supported |
| Execution | Local visible browser, local headless, CI headless |
| Tooling | Python 3.10+, Robot Framework 7, SeleniumLibrary 6, Selenium 4 (Selenium Manager) |
| Test data | Stored in `../resources/variables.robot`; no personal data used |

## 5. Test cases

| ID | Area | Test | Priority |
|---|---|---|---|
| HP01 | Navigation | Header shows every expected navigation item | High |
| HP02 | Navigation | Each navigation item opens the correct destination in a new tab | High |
| HP03 | Navigation | Header logo links back to the homepage | Medium |
| HP04 | Layout | Navigation is usable at standard desktop viewports | Medium |
| HP05 | Navigation | About Us navigation links to the Why MultiBank page | Medium |
| HP06 | Trading | Market section renders with link to all assets | High |
| HP07 | Trading | Pairs grouped into categories with symbol, price and % change | High |
| HP08 | Content | All expected section headings are visible | Medium |
| HP09 | Content | Key marketing and legal copy (incl. Risk Warning) is visible | High |
| HP10 | Content | Hero and marketing banners load in the main content region | Medium |
| HP11 | Links | Homepage CTAs open the correct destination in a new tab | High |
| HP12 | Links | App download link opens and resolves on desktop | Medium |
| HP13 | Links | App download link sends iOS / Android visitors to the right store | High |
| HP14 | Links | Footer legal links point to the correct pages and respond | High |
| HP15 | Negative | Invalid route returns HTTP 404 and a not-found page | Medium |
| HP16 | Negative | Header navigation has no broken links | High |
| HP17 | Negative | Homepage has no broken links | Medium |
| HP18 | Performance | Homepage becomes ready within 8 s | Medium |
| HP19 | Negative | Forced page-load timeout fails cleanly and the session recovers | Low |
| WM01 | About | Page loads with correct title and main heading | High |
| WM02 | About | All section headings visible | Medium |
| WM03 | About | Each section shows its expected text | Medium |
| WM04 | About | Key company figures displayed | Low |
| WM05 | About | Strength cards displayed | Low |
| WM06 | About | Section images load in the main content region | Low |
| WM07 | About | "Get in touch" opens the contact page in a new tab | Medium |
| WM08 | About | Page has no broken links | Medium |

## 6. Entry and exit criteria

**Entry**
- The site is reachable.
- Dependencies are installed.
- The dry run (`python -m robot --dryrun tests`) passes.

**Exit**
- All High-priority tests pass in Chrome.
- The suite has run in at least one additional browser.
- Every failure has been triaged either as a genuine site defect (recorded in the README findings) or as a test issue (fixed).

## 7. Risks to the test effort

| Risk | Mitigation |
|---|---|
| Live content or markup changes | Text and file-name locators in one file; data in one file |
| Market data loads late or changes constantly | Polling waits; assert format, not values |
| Bot protection blocks HTTP checks (403/429) | Logged as warnings for manual follow-up instead of false failures |
| Region-based redirects (`/en-AE` → `/en`, US-hosted CI) | URL patterns accept both locales; CI differences documented |
| Header rendered client-side | Waits on visibility; labels verified on the live site |
| Screen smaller than 1920×1080 | Headless mode sets an explicit window size |

## 8. Deliverables

- The framework source.
- Robot Framework `report.html` / `log.html` (sample in `docs/sample-report/`).
- Cross-browser merged report.
- CI run history in GitHub Actions.
- This plan.
- `docs/QA_STRATEGY.md`.

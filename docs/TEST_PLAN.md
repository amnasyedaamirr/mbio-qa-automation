# Test Plan: mb.io Public Website (Task 1)

## What I'm testing and why

This plan covers two public pages on mb.io:
- the homepage,
- the About Us > Why MultiBank page.

I'm testing them as a logged-out visitor on a desktop browser. The goal is to make sure a new visitor can find their way around, sees the right information, and doesn't hit broken links or pages along the way.

## In scope

- **Homepage** (`https://mb.io/en-AE`):
  - header navigation and logo,
  - call-to-action buttons,
  - the market section (Top Gainers, Trending Now, Top Losers),
  - section headings and key text, including the Risk Warning,
  - banner images,
  - the app download link,
  - footer legal links.
- **Why MultiBank page** (`https://mb.io/en-AE/company`):
  - headings and section text,
  - company figures,
  - strength cards,
  - images,
  - the "Get in touch" button,
  - all links on the page.
- **Edge cases:**
  - a page that doesn't exist,
  - broken links,
  - how long the page takes to load,
  - what happens when a page takes too long.
- **Desktop screen sizes:** 1920×1080, 1440×900 and 1366×768.

## Out of scope

- Anything that needs a login, and any form submission or account creation.
- Mobile screen sizes (left out by choice for this exercise).
- Visual comparison testing and load testing.
- Whether live prices are accurate. I check that prices show up in the right format, not their values, which change every second.

## How I'm approaching it

I've put the strongest checks on what would hurt the business most if it broke:
- **Sign-up and login buttons.** If these break, new customers can't join.
- **The Risk Warning and legal links.** A regulated platform has to show these.
- **The market section.** Missing or broken prices make the site look untrustworthy.
- **The app download link.** Visitors on each phone need to land in the right store.

The tests are automated with Robot Framework and Selenium. All the expected text, links and settings live in one file, so a content change means one edit, not ten. Link checks and the "page not found" check use quick HTTP requests instead of opening a browser each time, which keeps the suite fast.

## Where it runs

| | |
|---|---|
| Browsers | Chrome (main), Edge, Firefox |
| Computers | Windows locally, Linux in GitHub Actions; macOS also supported |
| When | Locally on demand, on every push to GitHub, and every night at 02:00 UTC |
| Tools | Python, Robot Framework, SeleniumLibrary, Selenium |

## Test cases

| ID | Area | What's checked | Priority |
|---|---|---|---|
| HP01 | Navigation | Every expected menu item is visible in the header | High |
| HP02 | Navigation | Each menu item opens the right page in a new tab | High |
| HP03 | Navigation | The logo takes you back to the homepage | Medium |
| HP04 | Layout | The menu still works at each desktop screen size | Medium |
| HP05 | Navigation | The menu links to the Why MultiBank page | Medium |
| HP06 | Trading | The market section shows, with its "Explore all assets" link | High |
| HP07 | Trading | Top Gainers, Trending Now and Top Losers each show coins with a symbol, price and % change | High |
| HP08 | Content | All section headings show | Medium |
| HP09 | Content | Key text shows, including the Risk Warning | High |
| HP10 | Content | Banner images load and sit in the main part of the page | Medium |
| HP11 | Links | Each call-to-action button opens the right page in a new tab | High |
| HP12 | Links | The app download link opens on desktop | Medium |
| HP13 | Links | The app download link sends iPhones to the App Store and Android phones to Google Play | High |
| HP14 | Links | Footer legal links go to the right pages and load | High |
| HP15 | Negative | A made-up address shows a proper "not found" page (HTTP 404) | Medium |
| HP16 | Negative | No broken links in the header | High |
| HP17 | Negative | No broken links anywhere on the homepage | Medium |
| HP18 | Performance | The homepage is ready within 8 seconds | Medium |
| HP19 | Negative | A page that takes too long fails cleanly, and the browser recovers | Low |
| WM01 | About | The page loads with the right title and main heading | High |
| WM02 | About | All section headings show | Medium |
| WM03 | About | Each section shows its expected text | Medium |
| WM04 | About | The company figures show | Low |
| WM05 | About | The strength cards show | Low |
| WM06 | About | Section images load in the main part of the page | Low |
| WM07 | About | "Get in touch" opens the contact page in a new tab | Medium |
| WM08 | About | No broken links on the page | Medium |

## When testing starts and when it's finished

**Ready to start when:**
- the site is up,
- the tools are installed,
- a dry run (`python -m robot --dryrun tests`) passes.

**Finished when:**
- all High-priority tests pass in Chrome,
- the suite has run in at least one other browser,
- every failure has been looked at and sorted into either a real problem on the site (written up in the README) or a problem with the test (fixed).

## Things that could get in the way

| Risk | What I did about it |
|---|---|
| The site's text or layout changes | Locators use visible text and image names instead of code-generated names, and everything is kept in one place |
| Prices load late and change constantly | Tests wait for the data to appear, and check its format rather than its value |
| The site blocks automated link checks | Blocked responses (403/429) are flagged for a manual check instead of failing the test |
| The site redirects based on location (`/en-AE` to `/en`, and GitHub's US servers) | Both addresses are accepted; the CI difference is noted in the README |
| The menu loads after the page | Tests wait for the menu to appear before checking it |
| Small laptop screen | Headless mode sets the browser size directly |

## What gets delivered

- The automation framework.
- Test reports: `report.html` and `log.html`, with a sample in `docs/sample-report/`.
- A cross-browser report.
- Nightly and per-push results in GitHub Actions.
- This plan.
- The Task 2 strategy in `docs/QA_STRATEGY.md`.

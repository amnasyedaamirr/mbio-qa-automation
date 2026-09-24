# Task 2 – QA Strategy for a Mobile Trading App

**Scenario:** Day one as the first QA Engineer at a fintech startup. An iOS and Android trading app is two weeks from its first public release. There is no test suite, no QA documentation, and the team has been shipping fast. Real user funds are involved.

---

## 1. Where do you start?

I start by understanding the risk, not by writing tests. Two weeks is not enough time to test everything, so the first job is to decide what must not fail.

**Days 1–2: learn the product and the money flows**
- Talk to the product owner, the tech lead and whoever owns compliance. I ask:
  - What does the app do?
  - What has changed recently?
  - What are people already nervous about?
- Install the current builds on real iPhones and Android phones (TestFlight and an internal Play track). Do a hands-on tour of every main journey. This gives me a baseline, and usually turns up blockers on day one.
- Map the critical user journeys, especially every flow where money moves:
  - onboarding and KYC,
  - login, 2FA and biometrics,
  - deposit (card and bank),
  - buy / sell / convert,
  - order history and balances,
  - withdrawal,
  - account recovery.
- Find out what already exists:
  - unit tests,
  - a CI pipeline,
  - a staging environment with sandbox payments and trading,
  - feature flags,
  - crash reporting,
  - logs and monitoring.

**Days 2–3: agree how we'll decide to ship**
- Build a risk matrix (below) with the team and use it to prioritise everything that follows.
- Agree release criteria with stakeholders now, not the day before launch. For example: no open critical or high defects in money flows, crash-free sessions above an agreed rate, and a rollback plan in place.
- Set up a simple bug process: one tracker, clear severity definitions, and a daily 15-minute triage with dev and product.

The first week is mostly risk-based manual and exploratory testing, plus quick API automation of the money flows. A full UI automation suite comes after launch. Building it now would cost the time we need for testing.

---

## 2. How would you approach testing this app?

A layered, risk-based approach. The deepest testing goes where real money moves.

**Money correctness (highest priority)**
- **Balances, fees and precision.** Balances match the ledger after every buy, sell, convert, deposit and withdrawal. Fees match the published schedule. Rounding and decimal precision are correct; crypto often uses 8+ decimals, and small rounding errors add up.
- **Duplicate prevention.** Double-tapping "Buy", or losing the network and retrying, must not create two orders or two withdrawals. The operation must be idempotent.
- **Order edge cases.** Partial fills, cancellations, quotes that expire while the user is on the confirm screen, insufficient balance, and minimum and maximum amounts.
- **Withdrawals.** Address validation, network selection and confirmation steps. Crypto sent to the wrong address or network can't be recovered.

**API and backend testing.** Most business logic lives in the backend, and API tests are fast and stable. So I'd automate the critical money flows at the API level first, e.g. with pytest or Postman/Newman in CI. This is the highest-value automation in a two-week window.

**Security**
- Session handling and token expiry.
- Secure storage (Keychain / Keystore).
- No sensitive data in logs or screenshots.
- Certificate pinning.
- Jailbreak and root behaviour.
- Rate limiting on login and 2FA.
- IDOR: can user A see user B's orders by changing an ID?

I'd use OWASP MASVS as the checklist and push for an external penetration test before release if one hasn't been done.

**Mobile-specific conditions**
- **Interruptions mid-transaction:** an incoming call, backgrounding the app, killing it, the device locking.
- **Network changes:** offline, slow 3G, switching between Wi-Fi and cellular, airplane mode during an order.
- **Device and system features:** push notifications and deep links, biometrics, permissions, low storage, font scaling, dark mode, accessibility (VoiceOver / TalkBack).

**Device coverage.** A device matrix based on the target market: the last 2–3 iOS versions, and popular Android makers (Samsung, Xiaomi, Pixel) including a low-end device. I'd use a few real devices plus a cloud device farm such as BrowserStack.

**Real-time data.** Price feeds updating, stale-price handling, and reconnecting after the connection drops.

**Release build testing.** The final store build must be tested, not only debug builds. Code shrinking, obfuscation and production configuration can break things that worked in debug.

**Compliance.** KYC gating, geo-restrictions, risk disclosures, terms acceptance, and app store rules for financial apps.

**Launch safety nets.** These aren't tests, but QA should push for them:
- staged rollout (Play percentage rollout, App Store phased release),
- feature flags or a kill switch for trading and withdrawals,
- a forced-update mechanism,
- monitoring dashboards,
- alerts on failed transactions.

---

## 3. What does QA look like inside a sprint?

QA runs through the whole ticket, not just the end of it.

1. **Refinement.** QA joins backlog refinement ("three amigos": product, dev, QA). I help write acceptance criteria in Given/When/Then form. I ask about edge cases, error states, both platforms and test data. A ticket isn't "ready" until its criteria are testable.
2. **Ticket creation.** Each ticket states acceptance criteria, platforms affected, any API changes, feature flags, and test data needs.
3. **During development.** I write test cases or exploratory charters in parallel and link them to the ticket. Developers write unit tests. I add or extend API tests for backend changes. CI produces a test build per pull request, so testing can start before merge.
4. **Ready for QA.** I verify the acceptance criteria on iOS and Android, then explore around the change. Bugs are logged with steps, device, OS, build, severity and evidence. Fixes are retested and the surrounding area is re-checked.
5. **Automation in the same sprint.** New critical paths get automated tests in the sprint where they're built. If that isn't possible, a follow-up ticket is created so the gap is visible.
6. **Definition of Done:**
   - acceptance criteria pass on both platforms,
   - no open critical or high bugs,
   - automated tests added and passing,
   - affected areas regression-checked.
7. **Release candidate.** Automated regression runs on the release build, plus targeted manual regression and a smoke test on real devices. Then the release readiness checklist, and a go/no-go decision with stakeholders.
8. **After release.** Monitor crash rates, failed transactions and support tickets. In the retrospective, every bug that escaped to production gets a root cause and a new regression test.

---

## 4. What does your ideal regression suite look like?

**Shaped like a pyramid.**
- **Unit tests (many, owned by developers):** business rules, calculations, validation.
- **API and integration tests (the core):** every money flow, authentication, and error handling. Fast, stable and run on every change.
- **UI end-to-end tests (few, the critical journeys only):** e.g. Appium, Maestro, or XCUITest and Espresso, on both platforms.

**In three tiers.**

| Tier | When | Contents | Target time |
|---|---|---|---|
| Smoke | Every build / pull request | Launch, login, view balance, place a small sandbox order, log out | Under 15 min |
| Critical path | Nightly | All money flows end-to-end on both platforms | Under 1 hour |
| Full regression | Before each release | Full device matrix, plus manual exploratory charters for what automation can't cover | Before go/no-go |

**Properties that matter:**
- **Deterministic.** Seeded test accounts, controlled test data, sandbox payment and KYC providers, mocked price feeds for UI checks. A flaky test is worse than no test, because people learn to ignore failures.
- **Independent and parallel.** Any test runs alone or alongside others, across a device cloud.
- **Tagged by feature and risk,** so we can run exactly what a change touches.
- **Visible.** Results in CI with a dashboard and chat notifications.
- **Actively maintained.**
  - Flaky tests are quarantined and fixed within a set time.
  - Every production bug adds a test.
  - Obsolete tests are deleted.
- **Tests old app versions too.** Not every user updates, so older app versions still in use should be run against the new backend.

Coverage is decided by the risk matrix, not by counting tests.

---

## 5. What would keep you up at night?

1. **Money correctness.** A duplicated order or withdrawal from a retry, or a rounding error. Or a balance on screen that doesn't match the ledger. With real funds, every one of these is a financial loss and a trust problem.
2. **Irreversible withdrawals.** Crypto sent to the wrong address or network is gone. Address validation and confirmation steps have to be solid.
3. **Account takeover and data exposure.** Weak session handling, a way around 2FA, or an API that returns another user's data. For a fintech, a security incident at launch can end the product.
4. **Wrong prices.** A stale or broken price feed letting users trade at the wrong price, especially in a volatile market. Launch-day load on the backend and third parties (payments, KYC) makes this worse.
5. **No safety net for hotfixes.** No existing tests and a fast-moving team means unknown bugs, and no quick way to prove a hotfix doesn't break something else.
6. **Mobile releases can't be pulled back instantly.** Store review takes time, and old versions stay on phones. Without feature flags, a kill switch and staged rollout, a bad release stays in users' hands.
7. **Compliance gaps.** KYC bypasses, users from restricted countries getting through, or missing risk disclosures. These carry regulatory consequences, not just bug reports.
8. **Blind spots after launch.** If something goes wrong, will we find out from our monitoring or from users on social media?

**What I'd push for before release:**
- agreed go/no-go criteria,
- staged rollout,
- kill switches for trading and withdrawals,
- transaction and crash monitoring with alerts,
- an on-call rota and incident runbook,
- a known-issues list signed off by product.

---

## Release Readiness Checklist

**Quality**
- [ ] All critical-path tests pass on the release build (iOS and Android)
- [ ] No open critical or high defects; known medium/low issues documented and accepted by product
- [ ] Money flows verified end-to-end in staging: deposit, buy, sell, convert, withdraw, balances
- [ ] Duplicate-submission and network-interruption tests pass for orders and withdrawals
- [ ] Regression run on the agreed device and OS matrix
- [ ] Release (store) build tested, not only debug builds
- [ ] Upgrade path tested from any previous beta version

**Security and compliance**
- [ ] Security review / penetration test findings resolved or formally accepted
- [ ] No secrets or personal data in the app binary, logs or screenshots
- [ ] KYC, geo-restriction and risk-disclosure flows verified
- [ ] Privacy policy, terms and store listing reviewed by compliance
- [ ] App Store / Play Store financial-services policies met

**Operations**
- [ ] Crash reporting and transaction monitoring live, with alerts configured
- [ ] Feature flags / kill switch ready for trading and withdrawals
- [ ] Staged rollout plan agreed (e.g. 5% → 25% → 100%)
- [ ] Forced-update mechanism working
- [ ] Backend load-tested for expected launch traffic
- [ ] Rollback and incident runbook written; on-call rota set for launch week
- [ ] Customer support briefed on known issues and escalation path

**Sign-off**
- [ ] Go/no-go meeting held; product, engineering, QA and compliance sign off

---

## Risk Matrix

Likelihood and impact are rated 1 (low) to 3 (high). Score = likelihood × impact: **7–9 High**, **4–6 Medium**, **1–3 Low**.

| # | Risk | Likelihood | Impact | Score | Mitigation |
|---|---|---|---|---|---|
| 1 | Duplicate order or withdrawal on retry / double tap | 2 | 3 | 6 Medium | Idempotency tests at API and UI level; network-interruption tests |
| 2 | Incorrect balance, fee or rounding calculation | 2 | 3 | 6 Medium | Ledger reconciliation tests; precision boundary tests; automated API checks |
| 3 | Funds sent to wrong address or network | 2 | 3 | 6 Medium | Address and network validation tests; confirmation-step review; withdrawal limits for new accounts |
| 4 | Account takeover / broken authentication | 2 | 3 | 6 Medium | Penetration test; session and 2FA tests; rate limiting; secure storage checks |
| 5 | No regression safety net as the team ships fast | 3 | 3 | **9 High** | Smoke + critical-path suite in CI from week one; merge gate on smoke |
| 6 | Bad release can't be pulled back quickly | 3 | 3 | **9 High** | Staged rollout; feature flags / kill switch; forced update |
| 7 | Stale or incorrect price feed | 2 | 3 | 6 Medium | Feed-staleness and reconnect tests; price-deviation alerts |
| 8 | Launch-day load or third-party outage (payments, KYC) | 2 | 3 | 6 Medium | Load test; graceful error handling tests; provider status monitoring |
| 9 | Compliance gap (KYC bypass, geo-restriction, disclosures) | 2 | 3 | 6 Medium | Compliance walkthrough; KYC and geo tests; sign-off in checklist |
| 10 | Device / OS-specific crash (Android fragmentation) | 3 | 2 | 6 Medium | Device matrix on a cloud farm; crash reporting with alerts |
| 11 | Release-build-only defect (obfuscation, prod config) | 2 | 2 | 4 Medium | Test the exact store build before submission |
| 12 | Store rejection delays launch | 2 | 2 | 4 Medium | Pre-submission policy review; submit early to allow a resubmission |
| 13 | Accessibility issues exclude users | 2 | 1 | 2 Low | VoiceOver/TalkBack and font-scaling checks on key journeys |

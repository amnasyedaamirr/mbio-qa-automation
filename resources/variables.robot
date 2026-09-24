*** Settings ***
Documentation     SINGLE SOURCE OF TRUTH for configuration and test data.
...
...               Change a URL, timeout or expected value HERE and every test picks
...               it up - nothing is repeated anywhere else in the framework.
...
...               Any scalar variable can also be overridden at run time, e.g.
...               robot --variable BROWSER:firefox --variable HEADLESS:True tests
...
...               Regex tip: patterns use [.] for a literal dot and [0-9] for a
...               digit, so they need no double-escaping inside Robot files.


*** Variables ***
# ============================================================================
# ENVIRONMENT
# ============================================================================
${BASE_URL}                         https://mb.io
${LOCALE}                           en-AE
${HOME_URL}                         ${BASE_URL}/${LOCALE}
# The site redirects /en-AE to /en for some regions, so both are accepted.
${HOME_URL_PATTERN}                 ^https://mb[.]io/en(-AE)?/?([?#].*)?$
# chrome (default) | firefox | edge | safari (macOS, no headless)
${BROWSER}                          chrome
# True = run without a visible window (used in CI)
${HEADLESS}                         ${False}
# Key held during a click to open a new tab.
# AUTO = COMMAND on macOS, CTRL on Windows and Linux.
${NEW_TAB_MODIFIER}                 AUTO


# ============================================================================
# VIEWPORTS (desktop only - mobile breakpoint is out of scope)
# ============================================================================
${DEFAULT_WIDTH}                    1920
${DEFAULT_HEIGHT}                   1080
@{DESKTOP_VIEWPORTS}                1920x1080    1440x900    1366x768


# ============================================================================
# TIMEOUTS - there are NO fixed sleeps; every wait polls up to these limits
# ============================================================================
${ELEMENT_TIMEOUT}                  15s
${PAGE_LOAD_TIMEOUT}                45s
${NEW_TAB_TIMEOUT}                  10s
${REDIRECT_TIMEOUT}                 30s
${RETRY_INTERVAL}                   500ms
${COOKIE_BANNER_TIMEOUT}            3s
# Seconds, used by the Python HTTP helper
${HTTP_TIMEOUT}                     20
# Deliberately impossible limit, used to prove timeouts are handled cleanly
${FORCED_PAGE_LOAD_TIMEOUT}         10ms
# Performance budget: DOMContentLoaded must finish within this many ms
${DOM_READY_BUDGET_MS}              8000


# ============================================================================
# 1. TOP NAVIGATION   label = regex the destination URL must match
# ============================================================================
# The header is rendered by JavaScript, so confirm the labels on the live
# site (README > "Finding the navigation labels") and add one line per item,
# e.g.   ...    Log in=trade[.]mb[.]io/.*login
# Every navigation test picks new lines up automatically.
&{NAV_LINKS}
...    Sign up=trade[.]mb[.]io/.*register

${LOGO_DESTINATION_PATTERN}         ^https://mb[.]io/?(en(-AE)?)?/?([?#].*)?$


# ============================================================================
# 2. TRADING / MARKET SECTION (homepage)
# ============================================================================
${MARKET_SECTION_HEADING}           Catch your next trade
${EXPLORE_ASSETS_TEXT}              Explore all assets
@{MARKET_CATEGORIES}                Top Gainers    Trending Now    Top Losers
${MIN_ENTRIES_PER_CATEGORY}         1
# Data fields every trading-pair entry must show
${SYMBOL_PATTERN}                   [A-Z]{2,10}
${PRICE_PATTERN}                    [0-9][0-9,]*[.][0-9]+
${PERCENT_CHANGE_PATTERN}           [0-9]+([.,][0-9]+)?[ ]?%


# ============================================================================
# 3a. HOMEPAGE CONTENT & LINKS
# ============================================================================
${HERO_HEADING}                     Crypto for everyone

@{HOMEPAGE_HEADINGS}
...    ${HERO_HEADING}
...    Securely build your portfolio
...    Unblemished. Unstoppable. United.
...    Smarter ways to trade and grow
...    ${MARKET_SECTION_HEADING}

@{HOMEPAGE_KEY_TEXT}
...    Simple, secure and speedy.
...    The fastest way to trade
...    Credit card & Bank transfers
...    Diversify your crypto portfolio on a highly regulated platform
...    Risk Warning

# Banner image file name = description used in reports
&{HOMEPAGE_BANNERS}
...    mobile-dashboard-small=Hero image
...    khabib-img.webp=Marketing banner

# Call-to-action button text = regex the destination URL must match
&{HOMEPAGE_CTAS}
...    Open an account=trade[.]mb[.]io/.*register
...    Start Portfolio=trade[.]mb[.]io/.*register
...    View platform features=trade[.]mb[.]io/.*login
...    ${EXPLORE_ASSETS_TEXT}=mb[.]io/en(-AE)?/explore

# App download link (a tracking link that redirects per device)
${APP_DOWNLOAD_TEXT}                Download the app
${APP_DOWNLOAD_DESKTOP_PATTERN}     (go[.]link|mb[.]io|apps[.]apple[.]com|play[.]google[.]com)
${APP_STORE_PATTERN}                (apps[.]apple[.]com|itms-apps://)
${PLAY_STORE_PATTERN}               (play[.]google[.]com|market://)
${IOS_USER_AGENT}                   Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1
${ANDROID_USER_AGENT}               Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36

# Footer legal link text = path its href must contain
&{FOOTER_LINKS}
...    Acceptable Use Policy=/about/acceptable-use-policy
...    Privacy Policy=/about/privacy-policy
...    Cookie Policy=/about/cookie-policy
...    Terms & Conditions=/about/terms-conditions
...    Client Agreement=/about/client-agreement


# ============================================================================
# 3b. ABOUT US > WHY MULTIBANK PAGE
# ============================================================================
${WHY_MB_PATH}                      /company
${WHY_MB_URL}                       ${HOME_URL}${WHY_MB_PATH}
${WHY_MB_URL_PATTERN}               ^https://mb[.]io/en(-AE)?/company/?([?#].*)?$
${WHY_MB_TITLE_PATTERN}             About mb[.]io
${WHY_MB_HEADING}                   Why MultiBank Group?

@{WHY_MB_HEADINGS}
...    ${WHY_MB_HEADING}
...    A tradition of global leadership
...    Innovation with purpose
...    Integrity built into every decision
...    The strength behind MultiBank Group
...    Community & Media

# Section heading = opening words of the text that must appear with it
&{WHY_MB_SECTIONS}
...    ${WHY_MB_HEADING}=For nearly two decades, MultiBank has built a reputation
...    A tradition of global leadership=Founded in 2005, MultiBank has grown
...    Innovation with purpose=We believe technology should simplify finance
...    Integrity built into every decision=Trust is earned through consistent action

@{WHY_MB_STAT_LABELS}               Annual turnover    Customers worldwide    Offices globally
@{WHY_MB_STRENGTHS}                 Regulation at our core    Proven track record    Secure & trusted

# Image file name = description used in reports
&{WHY_MB_IMAGES}
...    multibank-group.webp=Global leadership image
...    innovation.webp=Innovation image
...    dashboard.webp=Integrity image
...    regulation-at-core.webp=Regulation strength icon

${CONTACT_CTA_TEXT}                 Get in touch
${CONTACT_URL_PATTERN}              mb[.]io/en(-AE)?/support/contact-us


# ============================================================================
# 4. NEGATIVE / EDGE CASES
# ============================================================================
${INVALID_ROUTE_URL}                ${HOME_URL}/qa-automation-route-that-does-not-exist
${EXPECTED_NOT_FOUND_STATUS}        404
${NOT_FOUND_TEXT_PATTERN}           (?i)(404|not found|does not exist|doesn.t exist|page .*missing)
# Status codes typical of bot protection (Cloudflare etc.): reported as
# warnings for manual follow-up rather than failed as broken links.
@{BOT_PROTECTION_STATUS_CODES}      ${403}    ${429}

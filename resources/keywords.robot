*** Settings ***
Documentation     Reusable keywords: the "functions" layer of the framework.
...
...               Tests describe WHAT is verified; these keywords describe HOW.
...               No URL, text or locator is hard-coded here: test data lives in
...               variables.robot and element locators in locators.robot.
...
...               Waiting strategy: no fixed sleeps. Every wait polls for a
...               condition (element visible, URL matches, image loaded) up to a
...               timeout defined in variables.robot.
Resource          variables.robot
Resource          locators.robot
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot
Library           String
Library           Collections
Library           ${CURDIR}${/}link_checker.py


*** Keywords ***
# ============================================================================
# BROWSER SESSION (works on Windows, macOS and Linux)
# ============================================================================
Start Browser Session
    [Documentation]    Suite Setup building block. Opens ONE browser for the
    ...                whole suite (fast) with global timeouts and viewport.
    [Arguments]    ${url}    ${url_pattern}    ${ready_heading}
    Set Screenshot Directory    ${OUTPUT DIR}${/}screenshots
    Resolve New Tab Modifier
    ${options}=    Build Browser Options
    Open Browser    ${url}    ${BROWSER}    options=${options}
    Set Selenium Timeout    ${ELEMENT_TIMEOUT}
    Set Selenium Page Load Timeout    ${PAGE_LOAD_TIMEOUT}
    Set Window Size    ${DEFAULT_WIDTH}    ${DEFAULT_HEIGHT}
    Wait For Page To Load    ${url_pattern}    ${ready_heading}
    Dismiss Cookie Banner If Present

Build Browser Options
    [Documentation]    Returns browser start-up arguments. Headless mode gets an
    ...                explicit window size so the 1920px viewport works on any
    ...                screen and in CI. Returns None for a normal visible window.
    ${browser}=    Convert To Lower Case    ${BROWSER}
    IF    not ${HEADLESS}    RETURN    ${None}
    IF    '${browser}' == 'firefox'
        RETURN    add_argument("-headless");add_argument("--width=${DEFAULT_WIDTH}");add_argument("--height=${DEFAULT_HEIGHT}")
    END
    RETURN    add_argument("--headless=new");add_argument("--window-size=${DEFAULT_WIDTH},${DEFAULT_HEIGHT}");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")

Resolve New Tab Modifier
    [Documentation]    New tab = Cmd+click on macOS, Ctrl+click elsewhere.
    IF    '${NEW_TAB_MODIFIER}' != 'AUTO'    RETURN
    ${is_mac}=    Evaluate    sys.platform == "darwin"    modules=sys
    ${modifier}=    Set Variable If    ${is_mac}    COMMAND    CTRL
    Set Global Variable    ${NEW_TAB_MODIFIER}    ${modifier}

Reset To Page
    [Documentation]    Test Setup building block. Puts every test in the same
    ...                clean state, so tests are independent and order-free.
    [Arguments]    ${url}    ${url_pattern}    ${ready_heading}
    Close All Extra Tabs
    Set Selenium Page Load Timeout    ${PAGE_LOAD_TIMEOUT}
    Set Window Size    ${DEFAULT_WIDTH}    ${DEFAULT_HEIGHT}
    Go To    ${url}
    Wait For Page To Load    ${url_pattern}    ${ready_heading}
    Dismiss Cookie Banner If Present

Wait For Page To Load
    [Documentation]    A page counts as loaded when the document is complete,
    ...                the URL is right, and the header and its main heading show.
    [Arguments]    ${url_pattern}    ${ready_heading}
    Wait For Document Ready
    Location Should Match Pattern    ${url_pattern}
    Wait Until Element Is Visible    ${HEADER}
    ...    error=The page header did not become visible within ${ELEMENT_TIMEOUT}.
    Heading Should Be Visible    ${ready_heading}

Wait For Document Ready
    Wait For Condition    return document.readyState === "complete";    timeout=${PAGE_LOAD_TIMEOUT}

Close All Extra Tabs
    [Documentation]    Closes every tab except the original one, then focuses it.
    @{handles}=    Get Window Handles
    FOR    ${handle}    IN    @{handles}[1:]
        Switch Window    ${handle}
        Close Window
    END
    Switch Window    MAIN

Dismiss Cookie Banner If Present
    [Documentation]    Accepts the cookie banner if one appears, so it can't
    ...                cover elements. Does nothing if there is no banner.
    ${banner_shown}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${COOKIE_ACCEPT_BUTTON}    timeout=${COOKIE_BANNER_TIMEOUT}
    IF    ${banner_shown}    Click Element    ${COOKIE_ACCEPT_BUTTON}

# ---- Page-specific shortcuts (used as Suite/Test Setup) --------------------
Open Browser To Homepage
    Start Browser Session    ${HOME_URL}    ${HOME_URL_PATTERN}    ${HERO_HEADING}

Reset To Homepage
    Reset To Page    ${HOME_URL}    ${HOME_URL_PATTERN}    ${HERO_HEADING}

Open Browser To Why MultiBank Page
    Start Browser Session    ${WHY_MB_URL}    ${WHY_MB_URL_PATTERN}    ${WHY_MB_HEADING}

Reset To Why MultiBank Page
    Reset To Page    ${WHY_MB_URL}    ${WHY_MB_URL_PATTERN}    ${WHY_MB_HEADING}


# ============================================================================
# ELEMENT HELPERS
# ============================================================================
Build Locator
    [Documentation]    Fills a locator template from locators.robot with text,
    ...                e.g. NAV_LINK_BY_TEXT + "Sign up".
    [Arguments]    ${template}    ${text}
    ${locator}=    Format String    ${template}    ${text}
    RETURN    ${locator}

Get First Visible Element
    [Documentation]    Returns the first VISIBLE match for a locator. Needed
    ...                because responsive sites keep hidden duplicates (desktop
    ...                and mobile copies) of the same element.
    [Arguments]    ${locator}    ${description}
    Wait Until Page Contains Element    ${locator}
    ...    error=${description} was not found on the page.
    ${element}=    Wait Until Keyword Succeeds    ${ELEMENT_TIMEOUT}    ${RETRY_INTERVAL}
    ...    Find Visible Element    ${locator}    ${description}
    RETURN    ${element}

Find Visible Element
    [Documentation]    One attempt: scrolls each match to the centre of the
    ...                screen (triggers scroll animations and keeps it clear of
    ...                the sticky header) and returns the first visible one.
    [Arguments]    ${locator}    ${description}
    @{elements}=    Get WebElements    ${locator}
    FOR    ${element}    IN    @{elements}
        Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});
        ...    ARGUMENTS    ${element}
        ${is_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${element}
        IF    ${is_visible}    RETURN    ${element}
    END
    Fail    ${description} is in the page but no matching element is visible.

Location Should Match Pattern
    [Documentation]    Asserts the current URL matches a regular expression.
    [Arguments]    ${expected_url_pattern}
    ${current_url}=    Get Location
    Should Match Regexp    ${current_url}    ${expected_url_pattern}
    ...    msg=Expected a URL matching "${expected_url_pattern}" but the browser is on "${current_url}".

Page Title Should Match
    [Arguments]    ${expected_title_pattern}
    ${title}=    Get Title
    Should Match Regexp    ${title}    ${expected_title_pattern}
    ...    msg=Page title "${title}" does not match "${expected_title_pattern}".


# ============================================================================
# NEW-TAB LINK VERIFICATION
# ============================================================================
Open In New Tab And Verify Destination
    [Documentation]    Ctrl/Cmd+clicks a link so it opens in a NEW tab, waits for
    ...                the (possibly redirected) URL to match the expected
    ...                pattern, then closes that tab and returns to the original.
    ...                The original tab is never navigated away from.
    [Arguments]    ${locator}    ${expected_url_pattern}    ${description}
    ${origin_url}=    Get Location
    ${link}=    Get First Visible Element    ${locator}    ${description}
    ${href}=    Get Element Attribute    ${link}    href
    Log    ${description} has href: ${href}
    @{tabs_before}=    Get Window Handles
    ${tab_count_before}=    Get Length    ${tabs_before}
    Click Element    ${link}    modifier=${NEW_TAB_MODIFIER}
    ${new_tab_opened}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${NEW_TAB_TIMEOUT}    ${RETRY_INTERVAL}
    ...    New Tab Should Have Opened    ${tab_count_before}
    IF    not ${new_tab_opened}
        Open Href In New Tab As Fallback    ${href}    ${description}    ${origin_url}
    END
    Switch Window    NEW
    Wait Until Keyword Succeeds    ${REDIRECT_TIMEOUT}    ${RETRY_INTERVAL}
    ...    Location Should Match Pattern    ${expected_url_pattern}
    ${final_url}=    Get Location
    Log    ${description} opened: ${final_url}
    [Teardown]    Close All Extra Tabs

New Tab Should Have Opened
    [Documentation]    Passes once more tabs are open than before the click.
    [Arguments]    ${tab_count_before}
    @{handles}=    Get Window Handles
    ${tab_count_now}=    Get Length    ${handles}
    Should Be True    ${tab_count_now} > ${tab_count_before}
    ...    msg=No new tab opened.

Open Href In New Tab As Fallback
    [Documentation]    Safety net for links that ignore Ctrl/Cmd+click (some are
    ...                JavaScript-driven). Logs a warning, restores the original
    ...                page if the click navigated in place, then opens the href
    ...                in a new tab so the destination is still verified.
    [Arguments]    ${href}    ${description}    ${origin_url}
    Should Not Be Equal    ${href}    ${None}
    ...    msg=${description} ignored the new-tab click and has no href to fall back on.
    Log    New-tab click on ${description} did not open a tab; opening its href in a new tab instead.    WARN
    Switch Window    MAIN
    ${current_url}=    Get Location
    IF    $current_url != $origin_url    Go To    ${origin_url}
    Execute Javascript    window.open(arguments[0], "_blank");    ARGUMENTS    ${href}
    Wait Until Keyword Succeeds    ${NEW_TAB_TIMEOUT}    ${RETRY_INTERVAL}
    ...    New Tab Should Have Opened    ${1}


# ============================================================================
# 1. NAVIGATION & LAYOUT
# ============================================================================
Header Should Show Logo
    Get First Visible Element    ${HEADER_LOGO}    Header logo

Navigation Item Should Be Visible
    [Arguments]    ${label}
    ${locator}=    Build Locator    ${NAV_LINK_BY_TEXT}    ${label}
    Get First Visible Element    ${locator}    Navigation item "${label}"

Navigation Item Should Open Correct Destination
    [Arguments]    ${label}    ${expected_url_pattern}
    ${locator}=    Build Locator    ${NAV_LINK_BY_TEXT}    ${label}
    Open In New Tab And Verify Destination    ${locator}    ${expected_url_pattern}    Navigation item "${label}"

Logo Should Link Back To Homepage
    Open In New Tab And Verify Destination    ${HEADER_LOGO}    ${LOGO_DESTINATION_PATTERN}    Header logo

About Us Menu Should Link To Why MultiBank Page
    [Documentation]    The header contains a link to the About/Why MultiBank page.
    ...                Checked in the page structure, so it passes whether the
    ...                link sits in the top bar or inside a hover dropdown.
    ${locator}=    Build Locator    ${NAV_LINK_BY_HREF_PART}    ${WHY_MB_PATH}
    Wait Until Page Contains Element    ${locator}
    ...    error=The header navigation has no link to the Why MultiBank page (${WHY_MB_PATH}).
    ${href}=    Get Element Attribute    ${locator}    href
    Should Match Regexp    ${href}    ${WHY_MB_URL_PATTERN}
    ...    msg=About Us link points to "${href}" instead of the Why MultiBank page.
    Url Should Respond Successfully    ${href}

Navigation Should Be Usable At Viewport
    [Documentation]    Resizes the window (e.g. "1366x768"), then checks the
    ...                logo, every nav item and that nothing overflows sideways.
    [Arguments]    ${viewport}
    ${width}    ${height}=    Split String    ${viewport}    x
    Set Window Size    ${width}    ${height}
    Wait Until Element Is Visible    ${HEADER}
    Header Should Show Logo
    FOR    ${label}    IN    @{NAV_LINKS}
        Navigation Item Should Be Visible    ${label}
    END
    Page Should Not Scroll Horizontally    ${viewport}

Page Should Not Scroll Horizontally
    [Documentation]    Layout check: page content must fit the window width.
    [Arguments]    ${context}
    ${fits}=    Execute Javascript
    ...    return document.documentElement.scrollWidth <= window.innerWidth + 1;
    Should Be True    ${fits}    msg=Page content overflows horizontally at ${context}.


# ============================================================================
# 2. TRADING / MARKET SECTION
# ============================================================================
Market Category Should Show Trading Pairs
    [Documentation]    A category (e.g. "Top Gainers") is visible and lists at
    ...                least one entry with a symbol, a price and a % change.
    ...                Retries because market data loads after the page.
    [Arguments]    ${category}
    Heading Should Be Visible    ${category}
    ${section}=    Build Locator    ${MARKET_SECTION_BY_TITLE}    ${category}
    Wait Until Keyword Succeeds    ${ELEMENT_TIMEOUT}    ${RETRY_INTERVAL}
    ...    Market Section Should Contain Pair Data    ${section}    ${category}

Market Section Should Contain Pair Data
    [Arguments]    ${section_locator}    ${category}
    ${section_text}=    Get Text    ${section_locator}
    Should Match Regexp    ${section_text}    ${SYMBOL_PATTERN}
    ...    msg=${category}: no trading-pair symbol found.
    Should Match Regexp    ${section_text}    ${PRICE_PATTERN}
    ...    msg=${category}: no price found.
    @{change_values}=    Get Regexp Matches    ${section_text}    ${PERCENT_CHANGE_PATTERN}
    ${entry_count}=    Get Length    ${change_values}
    Should Be True    ${entry_count} >= ${MIN_ENTRIES_PER_CATEGORY}
    ...    msg=${category}: expected at least ${MIN_ENTRIES_PER_CATEGORY} entries with a % change, found ${entry_count}.
    Log    ${category}: ${entry_count} entries with price-change data.


# ============================================================================
# 3. CONTENT & LINKS
# ============================================================================
Heading Should Be Visible
    [Arguments]    ${text}
    ${locator}=    Build Locator    ${HEADING_BY_TEXT}    ${text}
    Get First Visible Element    ${locator}    Heading "${text}"

Text Should Be Visible On Page
    [Arguments]    ${text}
    ${locator}=    Build Locator    ${TEXT_BY_CONTENT}    ${text}
    Get First Visible Element    ${locator}    Text "${text}"

Section Should Show Heading And Text
    [Documentation]    A section's heading and its expected body text are both visible.
    [Arguments]    ${heading}    ${expected_text}
    Heading Should Be Visible    ${heading}
    Text Should Be Visible On Page    ${expected_text}

Image Should Render In Main Content
    [Documentation]    The image is visible, its file actually loaded, and it
    ...                sits between the header and footer (the expected region).
    [Arguments]    ${file_name}    ${description}
    ${locator}=    Build Locator    ${IMAGE_BY_FILE_NAME}    ${file_name}
    ${image}=    Get First Visible Element    ${locator}    ${description}
    Wait Until Keyword Succeeds    ${ELEMENT_TIMEOUT}    ${RETRY_INTERVAL}
    ...    Image Should Have Loaded    ${image}    ${description}
    Element Should Be In Main Content Region    ${image}    ${description}

Image Should Have Loaded
    [Arguments]    ${image}    ${description}
    ${loaded}=    Execute Javascript
    ...    return arguments[0].complete && arguments[0].naturalWidth > 0;
    ...    ARGUMENTS    ${image}
    Should Be True    ${loaded}    msg=${description} is visible but its image file failed to load.

Element Should Be In Main Content Region
    [Arguments]    ${element}    ${description}
    ${in_region}=    Execute Javascript
    ...    window.scrollTo({top: 0, behavior: "instant"});
    ...    var el = arguments[0];
    ...    var header = document.querySelector("header");
    ...    var footer = document.querySelector("footer");
    ...    var top = el.getBoundingClientRect().top + window.scrollY;
    ...    var headerBottom = header ? header.getBoundingClientRect().bottom + window.scrollY : 0;
    ...    var footerTop = footer ? footer.getBoundingClientRect().top + window.scrollY : document.body.scrollHeight;
    ...    return top >= headerBottom && top < footerTop;
    ...    ARGUMENTS    ${element}
    Should Be True    ${in_region}
    ...    msg=${description} is rendered outside the main content region (between header and footer).

CTA Should Open Correct Destination
    [Arguments]    ${cta_text}    ${expected_url_pattern}
    ${locator}=    Build Locator    ${LINK_BY_TEXT}    ${cta_text}
    Open In New Tab And Verify Destination    ${locator}    ${expected_url_pattern}    CTA "${cta_text}"

App Download Link Should Open
    ${locator}=    Build Locator    ${LINK_BY_TEXT}    ${APP_DOWNLOAD_TEXT}
    Open In New Tab And Verify Destination    ${locator}    ${APP_DOWNLOAD_DESKTOP_PATTERN}    "${APP_DOWNLOAD_TEXT}" link

App Download Link Should Route To Store
    [Documentation]    Requests the app link as a phone would (user agent) and
    ...                checks it redirects to the correct app store.
    [Arguments]    ${user_agent}    ${expected_store_pattern}    ${store_name}
    ${locator}=    Build Locator    ${LINK_BY_TEXT}    ${APP_DOWNLOAD_TEXT}
    ${link}=    Get First Visible Element    ${locator}    "${APP_DOWNLOAD_TEXT}" link
    ${href}=    Get Element Attribute    ${link}    href
    ${final_url}=    Get Final Url    ${href}    ${HTTP_TIMEOUT}    ${user_agent}
    Log    ${store_name} visitors land on: ${final_url}
    Should Match Regexp    ${final_url}    ${expected_store_pattern}
    ...    msg=${store_name} visitors were sent to "${final_url}" instead of the store.

Footer Link Should Point To
    [Arguments]    ${label}    ${expected_path}
    ${locator}=    Build Locator    ${LINK_BY_TEXT}    ${label}
    ${link}=    Get First Visible Element    ${locator}    Footer link "${label}"
    ${href}=    Get Element Attribute    ${link}    href
    Should Contain    ${href}    ${expected_path}
    ...    msg=Footer link "${label}" points to "${href}", expected a path containing "${expected_path}".
    Url Should Respond Successfully    ${href}


# ============================================================================
# 4. NEGATIVE / EDGE CASES
# ============================================================================
Url Should Respond Successfully
    [Documentation]    Fails on 4xx/5xx or no response. Bot-protection codes
    ...                (403/429) are logged as warnings, not failures.
    [Arguments]    ${url}
    ${status}=    Get Http Status    ${url}    ${HTTP_TIMEOUT}
    IF    $status in $BOT_PROTECTION_STATUS_CODES
        Log    ${url} returned HTTP ${status} (likely bot protection) - verify manually.    WARN
    ELSE
        Should Be True    0 < ${status} < 400    msg=${url} returned HTTP ${status}.
    END

Collect Unique Http Links
    [Documentation]    Returns every distinct http(s) href matched by a locator.
    [Arguments]    ${locator}
    Wait Until Page Contains Element    ${locator}
    @{elements}=    Get WebElements    ${locator}
    @{urls}=    Create List
    FOR    ${element}    IN    @{elements}
        ${href}=    Get Element Attribute    ${element}    href
        ${is_web_link}=    Run Keyword And Return Status    Should Match Regexp    ${href}    ^https?://
        IF    ${is_web_link} and $href not in $urls    Append To List    ${urls}    ${href}
    END
    ${link_count}=    Get Length    ${urls}
    Log    Found ${link_count} unique links: ${urls}
    RETURN    ${urls}

Links Should Not Be Broken
    [Documentation]    Checks every link and reports ALL broken ones together
    ...                at the end, instead of stopping at the first failure.
    [Arguments]    ${locator}    ${area}
    @{urls}=    Collect Unique Http Links    ${locator}
    Should Not Be Empty    ${urls}    msg=No links found in ${area}.
    @{broken}=    Create List
    FOR    ${url}    IN    @{urls}
        ${status}=    Get Http Status    ${url}    ${HTTP_TIMEOUT}
        IF    $status in $BOT_PROTECTION_STATUS_CODES
            Log    ${url} returned HTTP ${status} (likely bot protection) - verify manually.    WARN
        ELSE IF    $status == 0 or $status >= 400
            Append To List    ${broken}    HTTP ${status}: ${url}
        ELSE
            Log    OK HTTP ${status}: ${url}
        END
    END
    ${report}=    Catenate    SEPARATOR=\n    @{broken}
    Should Be Empty    ${broken}    msg=Broken links in ${area}:\n${report}

Invalid Route Should Show Not Found Page
    [Documentation]    An unknown URL must return HTTP 404 (not a "soft 404"
    ...                with status 200) and show a user-friendly not-found page.
    ${status}=    Get Http Status    ${INVALID_ROUTE_URL}    ${HTTP_TIMEOUT}
    IF    $status in $BOT_PROTECTION_STATUS_CODES
        Log    HTTP check blocked (HTTP ${status}); relying on the UI check only.    WARN
    ELSE
        Should Be Equal As Integers    ${status}    ${EXPECTED_NOT_FOUND_STATUS}
        ...    msg=Invalid route returned HTTP ${status} instead of ${EXPECTED_NOT_FOUND_STATUS}.
    END
    Go To    ${INVALID_ROUTE_URL}
    Wait For Document Ready
    Wait Until Element Is Visible    ${PAGE_BODY}
    ${page_text}=    Get Text    ${PAGE_BODY}
    Should Match Regexp    ${page_text}    ${NOT_FOUND_TEXT_PATTERN}
    ...    msg=Invalid route did not show a recognisable "not found" message.

Page Should Be Ready Within Budget
    [Documentation]    Reads the browser's own Navigation Timing data for the
    ...                load that the Test Setup just performed.
    ${dom_ready_ms}=    Execute Javascript
    ...    var nav = performance.getEntriesByType("navigation")[0];
    ...    return nav ? Math.round(nav.domContentLoadedEventEnd) : -1;
    Should Be True    ${dom_ready_ms} >= 0    msg=Navigation Timing data is not available.
    Log    DOMContentLoaded after ${dom_ready_ms} ms (budget ${DOM_READY_BUDGET_MS} ms).
    Should Be True    ${dom_ready_ms} <= ${DOM_READY_BUDGET_MS}
    ...    msg=Page took ${dom_ready_ms} ms to become ready (budget ${DOM_READY_BUDGET_MS} ms).

Slow Page Load Should Time Out Cleanly And Recover
    [Documentation]    Forces an impossible page-load limit to prove a slow page
    ...                raises a clear timeout error instead of hanging, and that
    ...                the same browser session recovers once limits are restored.
    Set Selenium Page Load Timeout    ${FORCED_PAGE_LOAD_TIMEOUT}
    Run Keyword And Expect Error    *imeout*    Go To    ${HOME_URL}
    Set Selenium Page Load Timeout    ${PAGE_LOAD_TIMEOUT}
    Wait Until Keyword Succeeds    3x    2s    Go To    ${HOME_URL}
    Wait For Page To Load    ${HOME_URL_PATTERN}    ${HERO_HEADING}
    [Teardown]    Set Selenium Page Load Timeout    ${PAGE_LOAD_TIMEOUT}

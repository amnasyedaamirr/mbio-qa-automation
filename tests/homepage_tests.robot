*** Settings ***
Documentation     mb.io homepage - UI automation suite (MultiBank QA challenge, Task 1).
...
...               Scope: the public homepage at https://mb.io/en-AE. No login, no
...               account creation, no personal or financial data is submitted.
...
...               This file only says WHAT is tested. HOW lives in
...               resources/keywords.robot, test data in resources/variables.robot
...               and element locators in resources/locators.robot.
Resource          ../resources/keywords.robot
Suite Setup       Open Browser To Homepage
Suite Teardown    Close All Browsers
Test Setup        Reset To Homepage
Test Timeout      3 minutes
Test Tags         homepage


*** Test Cases ***
# ============================================================================
# 1. NAVIGATION & LAYOUT
# ============================================================================
HP01 Header Shows Every Expected Navigation Item
    [Documentation]    Every label listed in NAV_LINKS is visible in the header.
    [Tags]    navigation    smoke
    [Template]    Navigation Item Should Be Visible
    FOR    ${label}    IN    @{NAV_LINKS}
        ${label}
    END

HP02 Each Navigation Item Opens The Correct Destination In A New Tab
    [Documentation]    Ctrl/Cmd+clicks each nav item, checks the new tab's URL, closes it.
    [Tags]    navigation
    [Template]    Navigation Item Should Open Correct Destination
    FOR    ${label}    ${expected_url_pattern}    IN    &{NAV_LINKS}
        ${label}    ${expected_url_pattern}
    END

HP03 Header Logo Links Back To The Homepage
    [Tags]    navigation    smoke
    Header Should Show Logo
    Logo Should Link Back To Homepage

HP04 Navigation Is Usable At Standard Desktop Viewports
    [Documentation]    Logo and all nav items stay visible, with no sideways
    ...                overflow, at each size in DESKTOP_VIEWPORTS.
    [Tags]    navigation    layout
    [Template]    Navigation Should Be Usable At Viewport
    FOR    ${viewport}    IN    @{DESKTOP_VIEWPORTS}
        ${viewport}
    END

HP05 About Us Navigation Links To The Why MultiBank Page
    [Tags]    navigation    about
    About Us Menu Should Link To Why MultiBank Page


# ============================================================================
# 2. TRADING FUNCTIONALITY (homepage market section)
# ============================================================================
HP06 Market Section Renders With Link To All Assets
    [Tags]    trading    smoke
    Heading Should Be Visible    ${MARKET_SECTION_HEADING}
    ${explore_link}=    Build Locator    ${LINK_BY_TEXT}    ${EXPLORE_ASSETS_TEXT}
    Get First Visible Element    ${explore_link}    "${EXPLORE_ASSETS_TEXT}" link

HP07 Trading Pairs Are Grouped Into Categories With Expected Data Fields
    [Documentation]    Each category shows entries with symbol, price and % change.
    [Tags]    trading
    [Template]    Market Category Should Show Trading Pairs
    FOR    ${category}    IN    @{MARKET_CATEGORIES}
        ${category}
    END


# ============================================================================
# 3. CONTENT & LINKS
# ============================================================================
HP08 Homepage Displays All Expected Section Headings
    [Tags]    content    smoke
    [Template]    Heading Should Be Visible
    FOR    ${heading}    IN    @{HOMEPAGE_HEADINGS}
        ${heading}
    END

HP09 Homepage Displays Key Marketing And Legal Copy
    [Tags]    content
    [Template]    Text Should Be Visible On Page
    FOR    ${text}    IN    @{HOMEPAGE_KEY_TEXT}
        ${text}
    END

HP10 Hero And Marketing Banners Render In The Main Content Region
    [Tags]    content
    [Template]    Image Should Render In Main Content
    FOR    ${file_name}    ${description}    IN    &{HOMEPAGE_BANNERS}
        ${file_name}    ${description}
    END

HP11 Homepage CTAs Open The Correct Destination In A New Tab
    [Tags]    content    links
    [Template]    CTA Should Open Correct Destination
    FOR    ${cta_text}    ${expected_url_pattern}    IN    &{HOMEPAGE_CTAS}
        ${cta_text}    ${expected_url_pattern}
    END

HP12 App Download Link Opens And Resolves On Desktop
    [Tags]    content    links    app-links
    App Download Link Should Open

HP13 App Download Link Sends Mobile Visitors To The Correct Store
    [Documentation]    Simulates an iPhone and an Android phone (user agent) and
    ...                follows the redirect chain to the App Store / Google Play.
    [Tags]    content    links    app-links
    [Template]    App Download Link Should Route To Store
    ${IOS_USER_AGENT}        ${APP_STORE_PATTERN}     App Store (iOS)
    ${ANDROID_USER_AGENT}    ${PLAY_STORE_PATTERN}    Google Play (Android)

HP14 Footer Legal Links Point To The Correct Pages
    [Tags]    content    links
    [Template]    Footer Link Should Point To
    FOR    ${label}    ${expected_path}    IN    &{FOOTER_LINKS}
        ${label}    ${expected_path}
    END


# ============================================================================
# 4. NEGATIVE / EDGE CASES
# ============================================================================
HP15 Invalid Route Returns A Not Found Page
    [Tags]    negative
    Invalid Route Should Show Not Found Page

HP16 Header Navigation Has No Broken Links
    [Tags]    negative    links    navigation
    Links Should Not Be Broken    ${HEADER_LINKS}    the header navigation

HP17 Homepage Has No Broken Links
    [Documentation]    Scans every link on the homepage (header, body, footer).
    [Tags]    negative    links
    [Timeout]    10 minutes
    Links Should Not Be Broken    ${ALL_LINKS}    the homepage

HP18 Homepage Content Loads Within The Performance Budget
    [Tags]    negative    performance
    Page Should Be Ready Within Budget

HP19 Slow Page Load Times Out Cleanly And The Session Recovers
    [Tags]    negative    performance
    Slow Page Load Should Time Out Cleanly And Recover

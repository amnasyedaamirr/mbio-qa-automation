*** Settings ***
Documentation     About Us > Why MultiBank page - UI automation suite (Task 1, scenario 3).
...
...               Scope: the public page at https://mb.io/en-AE/company, which
...               carries the "Why MultiBank Group?" content. No data is submitted.
Resource          ../resources/keywords.robot
Suite Setup       Open Browser To Why MultiBank Page
Suite Teardown    Close All Browsers
Test Setup        Reset To Why MultiBank Page
Test Timeout      3 minutes
Test Tags         about


*** Test Cases ***
WM01 Why MultiBank Page Loads With Correct Title And Main Heading
    [Tags]    smoke    content
    Location Should Match Pattern    ${WHY_MB_URL_PATTERN}
    Page Title Should Match    ${WHY_MB_TITLE_PATTERN}
    Heading Should Be Visible    ${WHY_MB_HEADING}

WM02 Why MultiBank Page Shows All Expected Section Headings
    [Tags]    content
    [Template]    Heading Should Be Visible
    FOR    ${heading}    IN    @{WHY_MB_HEADINGS}
        ${heading}
    END

WM03 Each Section Shows Its Expected Text
    [Documentation]    Each heading is paired with the opening words of its copy.
    [Tags]    content
    [Template]    Section Should Show Heading And Text
    FOR    ${heading}    ${expected_text}    IN    &{WHY_MB_SECTIONS}
        ${heading}    ${expected_text}
    END

WM04 Key Company Figures Are Displayed
    [Tags]    content
    [Template]    Text Should Be Visible On Page
    FOR    ${label}    IN    @{WHY_MB_STAT_LABELS}
        ${label}
    END

WM05 Strength Cards Are Displayed
    [Tags]    content
    [Template]    Text Should Be Visible On Page
    FOR    ${strength}    IN    @{WHY_MB_STRENGTHS}
        ${strength}
    END

WM06 Section Images Load In The Main Content Region
    [Tags]    content
    [Template]    Image Should Render In Main Content
    FOR    ${file_name}    ${description}    IN    &{WHY_MB_IMAGES}
        ${file_name}    ${description}
    END

WM07 Get In Touch Opens The Contact Page In A New Tab
    [Tags]    links
    CTA Should Open Correct Destination    ${CONTACT_CTA_TEXT}    ${CONTACT_URL_PATTERN}

WM08 Why MultiBank Page Has No Broken Links
    [Tags]    negative    links
    [Timeout]    10 minutes
    Links Should Not Be Broken    ${ALL_LINKS}    the Why MultiBank page

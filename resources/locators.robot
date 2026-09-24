*** Settings ***
Documentation     ALL element locators live here, separate from test data.
...
...               If the site's markup changes, only this file needs updating.
...               Locators prefer visible text, file names and semantic tags
...               (header, h1-h4) over generated CSS class names, which change on
...               every deploy of a Next.js site.
...
...               Entries containing {} or {0} are TEMPLATES: the keyword
...               "Build Locator" fills in the text at run time.


*** Variables ***
# ---------------------------------------------------------------------------
# Page regions
# ---------------------------------------------------------------------------
${HEADER}                       css:header
${PAGE_BODY}                    css:body
# Image/SVG link inside the header = the brand logo
${HEADER_LOGO}                  xpath://header//a[.//img or .//*[local-name()="svg"]]

# ---------------------------------------------------------------------------
# Templates  ({} / {0} = text supplied by the test data)
# ---------------------------------------------------------------------------
${NAV_LINK_BY_TEXT}             xpath://header//a[normalize-space()="{}"]
${NAV_LINK_BY_HREF_PART}        xpath://header//a[contains(@href,"{}")]
${LINK_BY_TEXT}                 xpath://a[normalize-space()="{}"]
${HEADING_BY_TEXT}              xpath://*[self::h1 or self::h2 or self::h3 or self::h4][normalize-space()="{}"]
# Deepest element whose text contains the given copy
${TEXT_BY_CONTENT}              xpath://body//*[not(self::script or self::style)][contains(normalize-space(.),"{0}")][not(*[contains(normalize-space(.),"{0}")])]
# Image whose src/srcset contains a file name
${IMAGE_BY_FILE_NAME}           xpath://img[contains(@src,"{0}") or contains(@srcset,"{0}")]
# Closest container around a market heading that holds % price-change values
${MARKET_SECTION_BY_TITLE}      xpath:(//*[self::h2 or self::h3][normalize-space()="{}"]/ancestor::*[.//*[contains(text(),"%")]])[last()]

# ---------------------------------------------------------------------------
# Link collections (broken-link scans)
# ---------------------------------------------------------------------------
${HEADER_LINKS}                 xpath://header//a[@href]
${ALL_LINKS}                    xpath://a[@href]

# ---------------------------------------------------------------------------
# Cookie consent (matches any button whose text contains "accept")
# ---------------------------------------------------------------------------
${COOKIE_ACCEPT_BUTTON}         xpath://button[contains(translate(normalize-space(.),"ACEPT","acept"),"accept")]

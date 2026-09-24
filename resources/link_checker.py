"""HTTP helpers exposed to Robot Framework as keywords.

Robot turns each function listed in __all__ into a keyword:
    get_http_status  ->  Get Http Status
    get_final_url    ->  Get Final Url

Why a Python helper? Checking dozens of links by opening each one in the
browser is slow. A direct HTTP request confirms a link is alive in
milliseconds, and lets us impersonate phones (user agent) to verify that the
app download link sends iOS and Android visitors to the right store.
"""
from urllib.parse import urljoin

import requests

__all__ = ["get_http_status", "get_final_url"]

DESKTOP_USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
)


def _headers(user_agent=None):
    """Browser-like headers so the site treats us like a real visitor."""
    return {
        "User-Agent": user_agent or DESKTOP_USER_AGENT,
        "Accept": "text/html,application/xhtml+xml,*/*;q=0.8",
        "Accept-Language": "en",
    }


def get_http_status(url, timeout=15, user_agent=None):
    """Return the final HTTP status code of ``url`` after redirects.

    Tries a lightweight HEAD request first and falls back to GET, because
    some servers reject HEAD. Returns 0 if the request fails entirely
    (DNS error, timeout, SSL error), so the test can report it as broken.
    """
    timeout = float(timeout)
    try:
        response = requests.head(url, headers=_headers(user_agent),
                                 allow_redirects=True, timeout=timeout)
        if response.status_code >= 400:
            response = requests.get(url, headers=_headers(user_agent),
                                    allow_redirects=True, timeout=timeout,
                                    stream=True)
            response.close()
        return response.status_code
    except requests.RequestException as error:
        print(f"*WARN* Request to {url} failed: {error}")
        return 0


def get_final_url(url, timeout=15, user_agent=None, max_hops=10):
    """Follow redirects one hop at a time and return where ``url`` ends up.

    Stops early when a redirect points to a non-web scheme such as
    ``itms-apps://`` (App Store) or ``market://`` (Google Play), which the
    requests library cannot follow but which prove the store routing works.
    """
    current = url
    for _ in range(int(max_hops)):
        try:
            response = requests.get(current, headers=_headers(user_agent),
                                    allow_redirects=False,
                                    timeout=float(timeout), stream=True)
            response.close()
        except requests.RequestException as error:
            print(f"*WARN* Request to {current} failed: {error}")
            return current
        location = response.headers.get("Location")
        if not (response.is_redirect and location):
            return current
        next_url = urljoin(current, location)
        if not next_url.lower().startswith(("http://", "https://")):
            return next_url
        current = next_url
    return current

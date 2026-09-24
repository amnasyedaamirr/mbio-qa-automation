#!/usr/bin/env python3
"""Single command to run the test suite on Windows, macOS or Linux.

Examples (use "python3" instead of "python" on macOS/Linux if needed):
    python run_tests.py                      # all tests, Chrome, visible window
    python run_tests.py --headless           # all tests, Chrome, no window
    python run_tests.py --include smoke      # only tests tagged "smoke"
    python run_tests.py --browser firefox    # another browser
    python run_tests.py --cross-browser      # Chrome + Firefox + Edge, merged report

Results are written to results/<browser>/report.html and log.html.
"""
import argparse
import sys
from pathlib import Path

import robot

ROOT = Path(__file__).resolve().parent
TESTS_DIR = ROOT / "tests"
RESULTS_DIR = ROOT / "results"
CROSS_BROWSER_DEFAULT = ["chrome", "firefox", "edge"]


def parse_args():
    parser = argparse.ArgumentParser(description="Run the mb.io UI test suite.")
    parser.add_argument("--browser", default="chrome",
                        help="chrome (default), firefox, edge or safari")
    parser.add_argument("--headless", action="store_true",
                        help="run without opening a visible browser window")
    parser.add_argument("--include", action="append", default=[],
                        help="only run tests with this tag (repeatable)")
    parser.add_argument("--exclude", action="append", default=[],
                        help="skip tests with this tag (repeatable)")
    parser.add_argument("--cross-browser", nargs="*", metavar="BROWSER",
                        help="run in several browsers and merge the reports "
                             f"(default: {' '.join(CROSS_BROWSER_DEFAULT)})")
    return parser.parse_args()


def run_suite(browser, args):
    """Run every suite in tests/ in one browser; returns Robot's exit code."""
    output_dir = RESULTS_DIR / browser
    print(f"\n=== Running tests in {browser} "
          f"({'headless' if args.headless else 'visible'}) ===\n")
    return robot.run(
        str(TESTS_DIR),
        outputdir=str(output_dir),
        name=f"mb.io - {browser}",
        variable=[f"BROWSER:{browser}", f"HEADLESS:{args.headless}"],
        include=args.include,
        exclude=args.exclude,
    )


def main():
    args = parse_args()

    if args.cross_browser is None:
        sys.exit(run_suite(args.browser, args))

    browsers = args.cross_browser or CROSS_BROWSER_DEFAULT
    exit_codes = [run_suite(browser, args) for browser in browsers]
    outputs = [str(RESULTS_DIR / b / "output.xml") for b in browsers
               if (RESULTS_DIR / b / "output.xml").exists()]
    print("\n=== Merging results into results/report.html ===\n")
    robot.rebot(*outputs, outputdir=str(RESULTS_DIR),
                name="mb.io - Cross-browser")
    sys.exit(min(sum(exit_codes), 250))


if __name__ == "__main__":
    main()

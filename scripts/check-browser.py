#!/usr/bin/env python3
"""Open the installed browser example in headless Firefox and read its verdict (the page sets its
title to "ok" or "FAIL"). Speaks WebDriver to geckodriver over HTTP, with no other dependency.
For GitHub's runners, which carry Firefox and geckodriver; not for a laptop.
  python3 scripts/check-browser.py <path to browser/index.html>"""
import json, os, subprocess, sys, time, urllib.request

page = "file://" + os.path.abspath(sys.argv[1])
port = 4444
driver = subprocess.Popen(["geckodriver", "--port", str(port)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def call(method, path, body=None):
    req = urllib.request.Request(f"http://127.0.0.1:{port}{path}", method=method,
                                 data=None if body is None else json.dumps(body).encode(),
                                 headers={"Content-Type": "application/json"})
    return json.load(urllib.request.urlopen(req, timeout=60))["value"]


try:
    for _ in range(50):
        try:
            call("GET", "/status"); break
        except Exception:
            time.sleep(0.2)
    caps = {"capabilities": {"alwaysMatch": {"moz:firefoxOptions": {"args": ["-headless"]}}}}
    sid = call("POST", "/session", caps)["sessionId"]
    try:
        call("POST", f"/session/{sid}/url", {"url": page})
        title = ""
        for _ in range(60):
            title = call("GET", f"/session/{sid}/title")
            if title in ("ok", "FAIL"): break
            time.sleep(0.5)
        text = call("POST", f"/session/{sid}/execute/sync", {"script": "return document.getElementById('out').textContent", "args": []})
        print(text)
        sys.exit(0 if title == "ok" else 1)
    finally:
        call("DELETE", f"/session/{sid}")
finally:
    driver.terminate()

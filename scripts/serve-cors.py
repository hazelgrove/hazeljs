#!/usr/bin/env python3
"""Serve this package as an npm CDN would, for trying hazel-listings.js across origins (hazelgrove/hazeljs#2).

  python3 scripts/serve-cors.py PORT [DIR]

Like `python3 -m http.server PORT --bind 127.0.0.1`, with two differences that matter here: every answer says
Access-Control-Allow-Origin: *, as jsDelivr's and unpkg's do, and an .html file is sent as text/plain, as jsDelivr sends it,
so a page cannot be framed from it directly."""
import functools, http.server, sys


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def guess_type(self, path):
        return "text/plain" if str(path).endswith(".html") else super().guess_type(path)


port = int(sys.argv[1])
root = sys.argv[2] if len(sys.argv) > 2 else "."
http.server.ThreadingHTTPServer(("127.0.0.1", port), functools.partial(Handler, directory=root)).serve_forever()

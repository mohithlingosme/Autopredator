"""
Minimal HTTP ingestion stub for ClickHouse events.

Usage:
  export CLICKHOUSE_HOST=localhost CLICKHOUSE_PORT=9000 CLICKHOUSE_USER=analytics CLICKHOUSE_PASSWORD=secret CLICKHOUSE_DB=autopredator_analytics
  python scripts/analytics_ingest.py

POST /events with JSON body:
  {"session_id": "...", "user_id": "...", "org_id": 1, "name": "search", "properties": {"q": "scooter"}, "source": "web"}
"""

import json
import os
import sys
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer

from clickhouse_driver import Client


def make_client() -> Client:
    return Client(
        host=os.getenv("CLICKHOUSE_HOST", "localhost"),
        port=int(os.getenv("CLICKHOUSE_PORT", "9000")),
        user=os.getenv("CLICKHOUSE_USER", "analytics"),
        password=os.getenv("CLICKHOUSE_PASSWORD", "analytics_pw"),
        database=os.getenv("CLICKHOUSE_DB", "autopredator_analytics"),
        secure=False,
        compression=True,
    )


def coerce_properties(props):
    if not isinstance(props, dict):
        return {}
    return {str(k): str(v) for k, v in props.items()}


class IngestHandler(BaseHTTPRequestHandler):
    client = make_client()

    def log_message(self, fmt, *args):
        sys.stderr.write("%s - - [%s] %s\n" % (self.address_string(), self.log_date_time_string(), fmt % args))

    def do_GET(self):
        if self.path != "/health":
            self.send_response(404)
            self.end_headers()
            return
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok")

    def do_POST(self):
        if self.path != "/events":
            self.send_response(404)
            self.end_headers()
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw_body = self.rfile.read(length) if length else b"{}"
        try:
            payload = json.loads(raw_body.decode("utf-8"))
        except json.JSONDecodeError:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"invalid json")
            return

        events = payload if isinstance(payload, list) else [payload]
        rows = []
        for event in events:
            if "name" not in event:
                continue
            rows.append(
                (
                    event.get("event_time", datetime.utcnow()),
                    event.get("session_id", "unknown"),
                    event.get("user_id"),
                    event.get("org_id"),
                    event["name"],
                    coerce_properties(event.get("properties", {})),
                    event.get("source", "web"),
                )
            )

        if not rows:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"no events to insert")
            return

        self.client.execute(
            """
            INSERT INTO autopredator_analytics.events
            (event_time, session_id, user_id, org_id, name, properties, source)
            VALUES
            """,
            rows,
        )

        self.send_response(202)
        self.end_headers()
        self.wfile.write(b"accepted")


def main():
    port = int(os.getenv("ANALYTICS_INGEST_PORT", "8088"))
    server = HTTPServer(("0.0.0.0", port), IngestHandler)
    print(f"Ingestion stub listening on :{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()

"""
Connectivity smoke test for the data layer.

Requires python packages: psycopg2-binary, redis, opensearch-py, clickhouse-driver, boto3.
Environment variables are read from infra/.env (POSTGRES_*, REDIS_*, OPENSEARCH_*, CLICKHOUSE_*, AWS_*).
"""

import os
import sys
import uuid
from datetime import datetime

import boto3
import psycopg2
import redis
from clickhouse_driver import Client as ClickhouseClient
from opensearchpy import OpenSearch


def check_postgres():
    conn = psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=int(os.getenv("POSTGRES_PORT", "5432")),
        dbname=os.getenv("POSTGRES_DB", "autopredator_dev"),
        user=os.getenv("POSTGRES_USER", "autopredator"),
        password=os.getenv("POSTGRES_PASSWORD", "password"),
    )
    with conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.fetchone()
    conn.close()
    print("Postgres OK")


def check_redis():
    client = redis.Redis(
        host=os.getenv("REDIS_HOST", "localhost"),
        port=int(os.getenv("REDIS_PORT", "6379")),
        password=os.getenv("REDIS_PASSWORD"),
        decode_responses=True,
    )
    key = f"smoke:{uuid.uuid4()}"
    value = "pong"
    client.set(key, value, ex=30)
    assert client.get(key) == value
    print("Redis OK")


def check_opensearch():
    client = OpenSearch(
        hosts=[
            {
                "host": os.getenv("OPENSEARCH_HOST", "localhost"),
                "port": int(os.getenv("OPENSEARCH_PORT", "9200")),
                "scheme": os.getenv("OPENSEARCH_SCHEME", "http"),
            }
        ]
    )
    index = "smoke_test"
    if client.indices.exists(index=index):
        client.indices.delete(index=index)
    client.indices.create(index=index, body={"mappings": {"properties": {"message": {"type": "text"}}}})
    doc_id = str(uuid.uuid4())
    client.index(index=index, id=doc_id, body={"message": "hello"})
    client.indices.refresh(index=index)
    hits = client.search(index=index, body={"query": {"match": {"message": "hello"}}})
    assert hits["hits"]["total"]["value"] >= 1
    client.indices.delete(index=index)
    print("OpenSearch OK")


def check_clickhouse():
    client = ClickhouseClient(
        host=os.getenv("CLICKHOUSE_HOST", "localhost"),
        port=int(os.getenv("CLICKHOUSE_PORT", "9000")),
        user=os.getenv("CLICKHOUSE_USER", "analytics"),
        password=os.getenv("CLICKHOUSE_PASSWORD", "analytics_pw"),
        database=os.getenv("CLICKHOUSE_DB", "autopredator_analytics"),
    )
    client.execute("CREATE DATABASE IF NOT EXISTS autopredator_analytics")
    client.execute(
        """
        CREATE TABLE IF NOT EXISTS autopredator_analytics.smoke_events
        (event_time DateTime, name String)
        ENGINE = Memory
        """
    )
    client.execute(
        "INSERT INTO autopredator_analytics.smoke_events (event_time, name) VALUES",
        [(datetime.utcnow(), "smoke")],
    )
    rows = client.execute("SELECT count(*) FROM autopredator_analytics.smoke_events")
    assert rows and rows[0][0] >= 1
    print("ClickHouse OK")


def check_minio():
    endpoint = os.getenv("AWS_S3_ENDPOINT", "http://localhost:9000")
    bucket = os.getenv("AWS_DEFAULT_BUCKET", "autopredator-dev")
    s3 = boto3.client(
        "s3",
        endpoint_url=endpoint,
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=os.getenv("AWS_REGION", "auto"),
    )
    try:
        s3.head_bucket(Bucket=bucket)
    except Exception:
        s3.create_bucket(Bucket=bucket)
    key = f"smoke/{uuid.uuid4()}.txt"
    s3.put_object(Bucket=bucket, Key=key, Body=b"hello")
    response = s3.list_objects_v2(Bucket=bucket, Prefix="smoke/")
    assert response.get("KeyCount", 0) >= 1
    print("MinIO OK")


def main():
    checks = [
        ("Postgres", check_postgres),
        ("Redis", check_redis),
        ("OpenSearch", check_opensearch),
        ("ClickHouse", check_clickhouse),
        ("MinIO", check_minio),
    ]
    for name, fn in checks:
        try:
            fn()
        except Exception as exc:
            print(f"{name} check failed: {exc}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()

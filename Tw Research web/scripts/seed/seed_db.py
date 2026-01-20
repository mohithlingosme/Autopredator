"""
Deterministic synthetic data seeder for Autopredator.

Usage:
  DATABASE_URL=postgresql://user:pass@localhost:5432/autopredator_dev python scripts/seed/seed_db.py --reset --small

Flags:
  --reset           Truncate all app tables (FK-safe order) before seeding.
  --small           Use small preset from seed_config.json.
  --medium          Use medium preset (default).
  --large           Use large preset.
  --seed <int>      Override random seed for deterministic output.
  --dry-run         Show planned counts without writing to the database.
"""

import argparse
import json
import os
import random
import sys
from copy import deepcopy
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from urllib.parse import urlparse

import psycopg2
import psycopg2.extras

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.append(str(ROOT_DIR))

from scripts.seed import data_generators as gen

CONFIG_PATH = Path(__file__).resolve().parent / "seed_config.json"

CITY_LIST = [
    ("Bengaluru", "Karnataka"),
    ("Hyderabad", "Telangana"),
    ("Chennai", "Tamil Nadu"),
    ("Mumbai", "Maharashtra"),
    ("Delhi", "Delhi"),
    ("Pune", "Maharashtra"),
    ("Kolkata", "West Bengal"),
    ("Ahmedabad", "Gujarat"),
    ("Jaipur", "Rajasthan"),
    ("Lucknow", "Uttar Pradesh"),
    ("Kochi", "Kerala"),
    ("Coimbatore", "Tamil Nadu"),
    ("Indore", "Madhya Pradesh"),
    ("Surat", "Gujarat"),
    ("Patna", "Bihar"),
]

MANUFACTURERS = [
    "Maruti Suzuki",
    "Hyundai",
    "Tata Motors",
    "Mahindra",
    "Honda",
    "Toyota",
    "Kia",
    "Skoda",
    "Royal Enfield",
    "TVS",
    "Bajaj",
    "Hero",
]


@dataclass
class SeedConfig:
    num_manufacturers: int
    num_models_per_mfr: Dict[str, int]
    num_variants_per_model: Dict[str, int]
    num_cities: int
    num_listings: int
    num_leads: int
    num_users: int
    num_dealers: int
    price_months: int
    price_start_month: date
    price_end_month: date
    seed: int


def load_config(preset: str, seed_override: Optional[int]) -> SeedConfig:
    raw = json.loads(CONFIG_PATH.read_text())
    config = deepcopy(raw)
    preset_cfg = config.get("presets", {}).get(preset, {})
    for key, value in preset_cfg.items():
        config[key] = value
    seed_value = seed_override if seed_override is not None else config.get("seed", 42)
    start_month = date.fromisoformat(config["price_history"]["start_month"])
    end_month = date.fromisoformat(config["price_history"]["end_month"])
    requested_months = config["price_history"]["months"]
    span_months = (end_month.year - start_month.year) * 12 + (end_month.month - start_month.month) + 1
    price_months = min(requested_months, span_months)
    return SeedConfig(
        num_manufacturers=config["num_manufacturers"],
        num_models_per_mfr=config["num_models_per_mfr"],
        num_variants_per_model=config["num_variants_per_model"],
        num_cities=config["num_cities"],
        num_listings=config["num_listings"],
        num_leads=config["num_leads"],
        num_users=config["num_users"],
        num_dealers=config["num_dealers"],
        price_months=price_months,
        price_start_month=start_month,
        price_end_month=end_month,
        seed=seed_value,
    )


def get_conn():
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        raise SystemExit("DATABASE_URL is required to run seeding.")
    # Enable psycopg2 to parse query params
    parsed = urlparse(db_url)
    if parsed.scheme not in {"postgres", "postgresql"}:
        raise SystemExit("DATABASE_URL must use postgres/postgresql scheme.")
    return psycopg2.connect(db_url)


def truncate_tables(conn) -> None:
    tables = [
        "ops.audit_logs",
        "ops.import_jobs",
        "crm.lead_activities",
        "crm.leads",
        "market.listing_media",
        "market.inspections",
        "market.listings",
        "pricing.price_quotes",
        "catalog.variant_features",
        "catalog.vehicle_specs",
        "catalog.variants",
        "catalog.models",
        "catalog.model_families",
        "catalog.manufacturers",
        "catalog.features",
        "pricing.cities",
        "catalog.body_types",
        "catalog.transmission_types",
        "catalog.fuel_types",
        "auth.org_members",
        "auth.organizations",
        "auth.users",
    ]
    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE TABLE {', '.join(tables)} RESTART IDENTITY CASCADE;")
    conn.commit()


def execute_values(conn, query: str, rows: List[tuple], page_size: int = 1000) -> None:
    if not rows:
        return
    with conn.cursor() as cur:
        psycopg2.extras.execute_values(cur, query, rows, page_size=page_size)


def ensure_lookup(conn, table: str, column: str, values: List[str]) -> Dict[str, int]:
    rows = [(v,) for v in values]
    execute_values(
        conn,
        f"INSERT INTO {table} ({column}) VALUES %s ON CONFLICT ({column}) DO NOTHING",
        rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute(f"SELECT id, {column} FROM {table}")
        return {row[column]: row["id"] for row in cur.fetchall()}


def ensure_features(conn) -> List[Tuple[int, str, str]]:
    features = gen.feature_catalog()
    rows = [(f["category"], f["name"]) for f in features]
    execute_values(
        conn,
        """
        INSERT INTO catalog.features (category, name)
        VALUES %s
        ON CONFLICT (category, name) DO NOTHING
        """,
        rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, category, name FROM catalog.features")
        return [(row["id"], row["category"], row["name"]) for row in cur.fetchall()]


def insert_manufacturers(conn, rng: random.Random, cfg: SeedConfig) -> List[Tuple[int, str]]:
    names = MANUFACTURERS[: cfg.num_manufacturers]
    rows = [(name,) for name in names]
    execute_values(
        conn,
        "INSERT INTO catalog.manufacturers (name) VALUES %s ON CONFLICT (name) DO NOTHING",
        rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, name FROM catalog.manufacturers")
        return [(row["id"], row["name"]) for row in cur.fetchall()]


def insert_model_families(conn, rng, manufacturers, cfg: SeedConfig) -> List[Tuple[int, int, str]]:
    family_names = [
        "Prime",
        "City",
        "Cruiser",
        "Glide",
        "Nova",
        "Pulse",
        "Sprint",
        "Rover",
        "Aero",
        "Trail",
        "Urban",
        "Max",
        "Flex",
        "Edge",
        "Ace",
        "Bolt",
    ]
    rows = []
    for m_id, m_name in manufacturers:
        count = rng.randint(cfg.num_models_per_mfr["min"], cfg.num_models_per_mfr["max"])
        picks = rng.sample(family_names, k=count)
        for fam in picks:
            rows.append((m_id, f"{m_name.split()[0]} {fam}"))
    execute_values(
        conn,
        """
        INSERT INTO catalog.model_families (manufacturer_id, name)
        VALUES %s ON CONFLICT (manufacturer_id, name) DO NOTHING
        """,
        rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, manufacturer_id, name FROM catalog.model_families")
        return [(row["id"], row["manufacturer_id"], row["name"]) for row in cur.fetchall()]


def insert_models(conn, rng, families, cfg: SeedConfig) -> List[Tuple[int, int, str, int, Optional[int]]]:
    rows = []
    for fam_id, _, fam_name in families:
        num_models = rng.randint(1, 3)
        for _ in range(num_models):
            name_suffix = rng.choice(["LX", "VX", "ZX", "GT", "X", "S", "N"])
            start_year = rng.randint(2016, 2022)
            end_year = rng.choice([None, start_year + rng.randint(2, 5)])
            rows.append((fam_id, f"{fam_name} {name_suffix}", start_year, end_year))
    execute_values(
        conn,
        """
        INSERT INTO catalog.models (model_family_id, name, year_start, year_end)
        VALUES %s ON CONFLICT (model_family_id, name, year_start) DO NOTHING
        """,
        rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, model_family_id, name, year_start, year_end FROM catalog.models")
        return [
            (row["id"], row["model_family_id"], row["name"], row["year_start"], row["year_end"])
            for row in cur.fetchall()
        ]


def insert_variants(
    conn,
    rng,
    models,
    fuel_map,
    trans_map,
    body_map,
    features: List[Tuple[int, str, str]],
    cfg: SeedConfig,
) -> Tuple[List[Dict[str, Any]], Dict[int, float]]:
    rows = []
    specs_rows = []
    variant_feature_rows = []
    pricing_base: Dict[int, float] = {}
    variant_names = ["Base", "Mid", "Plus", "Pro", "Max", "Sport", "Elite", "Signature"]
    for model_id, _, model_name, _, _ in models:
        variant_count = rng.randint(cfg.num_variants_per_model["min"], cfg.num_variants_per_model["max"])
        for i in range(variant_count):
            body_type_name = gen.select_body_type(rng)
            fuel = rng.choice(gen.FUEL_TYPES)
            transmission = gen.select_transmission(rng, fuel)
            variant_label = variant_names[i % len(variant_names)]
            name = f"{variant_label} {fuel[:3]} {transmission}"
            rows.append(
                (
                    model_id,
                    name,
                    fuel_map[fuel],
                    trans_map[transmission],
                    body_map[body_type_name],
                )
            )
    execute_values(
        conn,
        """
        INSERT INTO catalog.variants (model_id, name, fuel_type_id, transmission_type_id, body_type_id)
        VALUES %s
        ON CONFLICT (model_id, name) DO NOTHING
        """,
        rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute(
            """
            SELECT
                v.id,
                v.model_id,
                v.name,
                v.fuel_type_id,
                v.transmission_type_id,
                v.body_type_id,
                ft.name AS fuel,
                tt.name AS transmission,
                bt.name AS body
            FROM catalog.variants v
            JOIN catalog.fuel_types ft ON ft.id = v.fuel_type_id
            JOIN catalog.transmission_types tt ON tt.id = v.transmission_type_id
            JOIN catalog.body_types bt ON bt.id = v.body_type_id
            """
        )
        variants = cur.fetchall()
    for v in variants:
        specs = gen.generate_specs(v["body"], v["fuel"], rng)
        specs_rows.append(
            (
                v["id"],
                specs["engine_cc"],
                specs["power_hp"],
                specs["torque_nm"],
                specs["mileage_kmpl"],
                specs["seating"],
                specs["airbags"],
                specs["length_mm"],
                specs["width_mm"],
                specs["height_mm"],
                specs["wheelbase_mm"],
            )
        )
        base_price = gen.base_price_for_body(v["body"], rng)
        pricing_base[v["id"]] = base_price
        standard, optional = gen.pick_variant_features(features, rng)
        for fid in standard:
            variant_feature_rows.append((v["id"], fid, True))
        for fid in optional:
            variant_feature_rows.append((v["id"], fid, False))

    execute_values(
        conn,
        """
        INSERT INTO catalog.vehicle_specs
        (variant_id, engine_cc, power_hp, torque_nm, mileage_kmpl, seating, airbags, length_mm, width_mm, height_mm, wheelbase_mm)
        VALUES %s
        ON CONFLICT (variant_id) DO NOTHING
        """,
        specs_rows,
    )
    execute_values(
        conn,
        """
        INSERT INTO catalog.variant_features (variant_id, feature_id, is_standard)
        VALUES %s
        ON CONFLICT (variant_id, feature_id) DO UPDATE SET is_standard = EXCLUDED.is_standard
        """,
        variant_feature_rows,
    )
    conn.commit()
    return [dict(row) for row in variants], pricing_base


def insert_cities(conn, cfg: SeedConfig) -> Dict[str, int]:
    rows = [(name, state) for name, state in CITY_LIST[: cfg.num_cities]]
    execute_values(
        conn,
        """
        INSERT INTO pricing.cities (name, state)
        VALUES %s
        ON CONFLICT (name, state) DO NOTHING
        """,
        rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, name FROM pricing.cities")
        return {row["name"]: row["id"] for row in cur.fetchall()}


def insert_price_quotes(conn, rng, variants, cities, pricing_base, cfg: SeedConfig):
    rows = []
    months = cfg.price_months
    start_month = cfg.price_start_month
    for variant in variants:
        base_price = pricing_base[variant["id"]]
        series = gen.price_series(base_price, months, start_month, rng)
        for city_name, city_id in cities.items():
            for month_date, ex_price, on_price in series:
                rows.append(
                    (
                        variant["id"],
                        city_id,
                        month_date,
                        ex_price,
                        on_price,
                        "synthetic_seed",
                    )
                )
    execute_values(
        conn,
        """
        INSERT INTO pricing.price_quotes
        (variant_id, city_id, quote_date, ex_showroom, on_road, source)
        VALUES %s
        ON CONFLICT (variant_id, city_id, quote_date) DO UPDATE
        SET ex_showroom = EXCLUDED.ex_showroom,
            on_road = EXCLUDED.on_road,
            source = EXCLUDED.source
        """,
        rows,
        page_size=5000,
    )


def make_orgs(conn, rng, cfg: SeedConfig) -> Dict[str, List[Dict[str, Any]]]:
    org_rows = [("Autopredator Admin", "admin")]
    for i in range(cfg.num_dealers):
        name = f"Dealer {i+1:02d}"
        org_rows.append((name, "dealer"))
    execute_values(
        conn,
        """
        INSERT INTO auth.organizations (name, type)
        VALUES %s
        ON CONFLICT (name) DO NOTHING
        """,
        org_rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, name, type FROM auth.organizations")
        orgs = [dict(row) for row in cur.fetchall()]
    admin_org = [o for o in orgs if o["type"] == "admin"][0]
    dealer_orgs = [o for o in orgs if o["type"] == "dealer"]
    return {"admin": admin_org, "dealers": dealer_orgs}


def make_users_and_members(conn, rng, cfg: SeedConfig, orgs) -> List[Dict[str, Any]]:
    users_rows = []
    now = datetime.utcnow()
    for i in range(cfg.num_users):
        name = gen.random_name(rng)
        email = gen.random_email(name, rng)
        phone = gen.random_phone(rng)
        status = rng.choice(["active", "active", "active", "inactive"])
        users_rows.append((email, phone, "demo-password-hash", status, now, now))
    execute_values(
        conn,
        """
        INSERT INTO auth.users (email, phone, password_hash, status, created_at, updated_at)
        VALUES %s
        ON CONFLICT (email) DO NOTHING
        """,
        users_rows,
    )
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, email FROM auth.users")
        all_users = [dict(row) for row in cur.fetchall()]

    # Assign members to dealer orgs
    member_rows = []
    roles = ["owner", "manager", "sales", "sales"]
    if orgs["admin"] and all_users:
        member_rows.append((orgs["admin"]["id"], all_users[0]["id"], "owner"))
    user_cycle = iter(all_users)
    for dealer in orgs["dealers"]:
        staff_count = rng.randint(3, 6)
        for _ in range(staff_count):
            try:
                user = next(user_cycle)
            except StopIteration:
                user = rng.choice(all_users)
            role = rng.choice(roles)
            member_rows.append((dealer["id"], user["id"], role))
    execute_values(
        conn,
        """
        INSERT INTO auth.org_members (org_id, user_id, role)
        VALUES %s
        ON CONFLICT (org_id, user_id) DO NOTHING
        """,
        member_rows,
    )
    return all_users


def build_latest_price_map(conn) -> Dict[Tuple[int, int], float]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT variant_id, city_id, on_road
            FROM (
                SELECT variant_id, city_id, on_road,
                       row_number() OVER (PARTITION BY variant_id, city_id ORDER BY quote_date DESC) AS rn
                FROM pricing.price_quotes
            ) t
            WHERE rn = 1
            """
        )
        data = cur.fetchall()
    return {(row[0], row[1]): float(row[2]) for row in data}


def make_listings(
    conn,
    rng,
    cfg: SeedConfig,
    variants: List[Dict[str, Any]],
    cities: Dict[str, int],
    dealer_orgs: List[Dict[str, Any]],
    users: List[Dict[str, Any]],
    latest_prices: Dict[Tuple[int, int], float],
) -> Dict[str, Any]:
    rows = []
    media_rows = []
    inspection_rows = []
    variant_map = {v["id"]: v for v in variants}
    statuses = ["draft", "published", "published", "published", "sold", "archived"]
    city_ids = list(cities.values())
    variant_ids = [v["id"] for v in variants]
    for i in range(cfg.num_listings):
        variant_id = rng.choice(variant_ids)
        city_id = rng.choice(city_ids)
        variant = variant_map[variant_id]
        listing_type = "used" if rng.random() < 0.7 else "new"
        year = rng.randint(2024, 2026) if listing_type == "new" else rng.randint(2012, 2025)
        km = 0 if listing_type == "new" else rng.randint(5_000, 180_000)
        price_base = latest_prices.get((variant_id, city_id), rng.uniform(500_000, 1_500_000))
        price = gen.listing_price(listing_type, price_base, year, km, rng)
        org = rng.choice(dealer_orgs)
        user_id = rng.choice(users)["id"]
        status = rng.choice(statuses)
        created_at = datetime.utcnow() - timedelta(days=rng.randint(0, 120))
        rows.append(
            (
                org["id"],
                user_id,
                variant_id,
                city_id,
                variant["fuel_type_id"],
                variant["transmission_type_id"],
                listing_type,
                year,
                km,
                price,
                status,
                created_at,
                created_at,
            )
        )
    execute_values(
        conn,
        """
        INSERT INTO market.listings
        (org_id, user_id, variant_id, city_id, fuel_type_id, transmission_type_id, listing_type, year, km, price, status, created_at, updated_at)
        VALUES %s
        RETURNING id, listing_type, created_at
        """,
        rows,
        page_size=2000,
    )
    listing_rows = []
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, listing_type, created_at FROM market.listings ORDER BY id")
        listing_rows = [dict(row) for row in cur.fetchall()]

    for listing in listing_rows:
        media_count = rng.randint(2, 8)
        for j in range(media_count):
            media_rows.append(
                (
                    listing["id"],
                    "image",
                    f"listings/{listing['id']}/image_{j+1}.jpg",
                    f"https://cdn.example.com/listings/{listing['id']}/image_{j+1}.jpg",
                )
            )
        if listing["listing_type"] == "used" and rng.random() < 0.5:
            score = rng.randint(60, 95)
            inspection_rows.append(
                (
                    listing["id"],
                    score,
                    json.dumps({"engine": score - 5, "body": score - 3, "interior": score - 2}),
                    listing["created_at"],
                )
            )

    execute_values(
        conn,
        """
        INSERT INTO market.listing_media (listing_id, media_type, object_key, url)
        VALUES %s
        """,
        media_rows,
        page_size=5000,
    )
    execute_values(
        conn,
        """
        INSERT INTO market.inspections (listing_id, score, report_json, created_at)
        VALUES %s
        ON CONFLICT (listing_id) DO NOTHING
        """,
        inspection_rows,
        page_size=2000,
    )
    return {
        "listings": len(listing_rows),
        "listing_ids": [row["id"] for row in listing_rows],
        "media": len(media_rows),
        "inspections": len(inspection_rows),
    }


def make_leads_and_activities(
    conn,
    rng,
    cfg: SeedConfig,
    listing_ids: List[int],
    dealer_orgs: List[Dict[str, Any]],
    users: List[Dict[str, Any]],
) -> Dict[str, int]:
    lead_rows = []
    activity_rows = []
    statuses = ["new", "contacted", "qualified", "lost", "won"]
    sources = ["web", "walk_in", "referral", "ads", "call"]
    activity_types = ["call", "whatsapp", "visit", "test_drive", "negotiation"]
    now = datetime.utcnow()
    for i in range(cfg.num_leads):
        has_listing = rng.random() < 0.7
        listing_id = rng.choice(listing_ids) if has_listing else None
        org = rng.choice(dealer_orgs)
        user_id = rng.choice(users)["id"] if rng.random() < 0.5 else None
        name = gen.random_name(rng)
        phone = gen.random_phone(rng)
        email = gen.random_email(name, rng)
        status = rng.choices(statuses, weights=[0.3, 0.25, 0.2, 0.15, 0.1])[0]
        source = rng.choice(sources)
        created_at = now - timedelta(days=rng.randint(0, 90))
        lead_rows.append(
            (
                listing_id,
                org["id"],
                user_id,
                name,
                phone,
                email,
                status,
                source,
                created_at,
            )
        )
    execute_values(
        conn,
        """
        INSERT INTO crm.leads
        (listing_id, org_id, user_id, name, phone, email, status, source, created_at)
        VALUES %s
        RETURNING id, status, created_at
        """,
        lead_rows,
        page_size=5000,
    )
    lead_rows_db = []
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, status, created_at FROM crm.leads ORDER BY id")
        lead_rows_db = [dict(row) for row in cur.fetchall()]

    for lead in lead_rows_db:
        acts = rng.randint(1, 6)
        for _ in range(acts):
            activity_rows.append(
                (
                    lead["id"],
                    rng.choice(activity_types),
                    "Follow-up note",
                    lead["created_at"] + timedelta(hours=rng.randint(1, 72)),
                )
            )
    execute_values(
        conn,
        """
        INSERT INTO crm.lead_activities (lead_id, activity_type, notes, created_at)
        VALUES %s
        """,
        activity_rows,
        page_size=5000,
    )
    return {"leads": len(lead_rows_db), "lead_ids": [row["id"] for row in lead_rows_db], "activities": len(activity_rows)}


def make_audit_logs(conn, rng, listing_ids: List[int], lead_ids: List[int], users: List[Dict[str, Any]]) -> int:
    rows = []
    actor_ids = [u["id"] for u in users]
    now = datetime.utcnow()
    for listing_id in listing_ids:
        actor = rng.choice(actor_ids)
        rows.append(
            (
                actor,
                "listing_created",
                "listing",
                listing_id,
                json.dumps({"listing_id": listing_id}),
                now - timedelta(days=rng.randint(0, 30)),
            )
        )
        if rng.random() < 0.6:
            rows.append(
                (
                    actor,
                    "listing_status_changed",
                    "listing",
                    listing_id,
                    json.dumps({"status": "published"}),
                    now - timedelta(days=rng.randint(0, 30)),
                )
            )
    for lead_id in lead_ids:
        if rng.random() < 0.6:
            actor = rng.choice(actor_ids)
            rows.append(
                (
                    actor,
                    "lead_status_changed",
                    "lead",
                    lead_id,
                    json.dumps({"status": "contacted"}),
                    now - timedelta(days=rng.randint(0, 20)),
                )
            )
    execute_values(
        conn,
        """
        INSERT INTO ops.audit_logs (actor_user_id, action, entity_type, entity_id, meta_json, created_at)
        VALUES %s
        """,
        rows,
        page_size=5000,
    )
    return len(rows)


def make_import_jobs(conn, rng) -> int:
    rows = []
    now = datetime.utcnow()
    for i in range(3):
        start = now - timedelta(days=i + 1)
        rows.append(
            (
                "catalog_seed",
                "completed",
                start,
                start + timedelta(minutes=5),
                json.dumps({"inserted": 1, "duration_sec": 30}),
            )
        )
    execute_values(
        conn,
        """
        INSERT INTO ops.import_jobs (source, status, started_at, finished_at, stats_json)
        VALUES %s
        """,
        rows,
    )
    return len(rows)


def summarize_counts() -> Dict[str, int]:
    tables = {
        "auth.users": "SELECT count(*) FROM auth.users",
        "auth.organizations": "SELECT count(*) FROM auth.organizations",
        "auth.org_members": "SELECT count(*) FROM auth.org_members",
        "catalog.manufacturers": "SELECT count(*) FROM catalog.manufacturers",
        "catalog.variants": "SELECT count(*) FROM catalog.variants",
        "pricing.price_quotes": "SELECT count(*) FROM pricing.price_quotes",
        "market.listings": "SELECT count(*) FROM market.listings",
        "market.listing_media": "SELECT count(*) FROM market.listing_media",
        "market.inspections": "SELECT count(*) FROM market.inspections",
        "crm.leads": "SELECT count(*) FROM crm.leads",
        "crm.lead_activities": "SELECT count(*) FROM crm.lead_activities",
        "ops.audit_logs": "SELECT count(*) FROM ops.audit_logs",
        "ops.import_jobs": "SELECT count(*) FROM ops.import_jobs",
    }
    output = {}
    with get_conn() as conn:
        with conn.cursor() as cur:
            for table, query in tables.items():
                cur.execute(query)
                output[table] = cur.fetchone()[0]
    return output


def main():
    parser = argparse.ArgumentParser(description="Seed Autopredator Postgres with synthetic data.")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--small", action="store_true", help="Use small preset")
    group.add_argument("--medium", action="store_true", help="Use medium preset (default)")
    group.add_argument("--large", action="store_true", help="Use large preset")
    parser.add_argument("--reset", action="store_true", help="Truncate tables before seeding")
    parser.add_argument("--seed", type=int, help="Override random seed")
    parser.add_argument("--dry-run", action="store_true", help="Print counts without writing")
    args = parser.parse_args()

    preset = "medium"
    if args.small:
        preset = "small"
    elif args.large:
        preset = "large"
    cfg = load_config(preset, args.seed)
    rng = random.Random(cfg.seed)

    if args.dry_run:
        print(f"[dry-run] preset={preset} seed={cfg.seed}")
        print(
            json.dumps(
                {
                    "num_manufacturers": cfg.num_manufacturers,
                    "num_models_per_mfr": cfg.num_models_per_mfr,
                    "num_variants_per_model": cfg.num_variants_per_model,
                    "num_cities": cfg.num_cities,
                    "num_listings": cfg.num_listings,
                    "num_leads": cfg.num_leads,
                    "num_users": cfg.num_users,
                    "num_dealers": cfg.num_dealers,
                    "price_months": cfg.price_months,
                },
                indent=2,
            )
        )
        return

    with get_conn() as conn:
        if args.reset:
            truncate_tables(conn)

        fuel_map = ensure_lookup(conn, "catalog.fuel_types", "name", gen.FUEL_TYPES)
        trans_map = ensure_lookup(conn, "catalog.transmission_types", "name", gen.TRANSMISSION_TYPES)
        body_map = ensure_lookup(conn, "catalog.body_types", "name", gen.BODY_TYPES)
        cities = insert_cities(conn, cfg)
        features = ensure_features(conn)
        manufacturers = insert_manufacturers(conn, rng, cfg)
        families = insert_model_families(conn, rng, manufacturers, cfg)
        models = insert_models(conn, rng, families, cfg)
        variants, pricing_base = insert_variants(conn, rng, models, fuel_map, trans_map, body_map, features, cfg)
        insert_price_quotes(conn, rng, variants, cities, pricing_base, cfg)
        orgs = make_orgs(conn, rng, cfg)
        users = make_users_and_members(conn, rng, cfg, orgs)
        latest_prices = build_latest_price_map(conn)
        listing_summary = make_listings(conn, rng, cfg, variants, cities, orgs["dealers"], users, latest_prices)
        lead_summary = make_leads_and_activities(conn, rng, cfg, listing_summary["listing_ids"], orgs["dealers"], users)
        audit_count = make_audit_logs(conn, rng, listing_summary["listing_ids"], lead_summary["lead_ids"], users)
        make_import_jobs(conn, rng)
        conn.commit()

    summary = summarize_counts()
    final_summary = {
        **summary,
        "market.listing_media": listing_summary["media"],
        "market.inspections": listing_summary["inspections"],
        "crm.lead_activities": lead_summary["activities"],
        "ops.audit_logs": audit_count,
    }
    print("\nSeed complete (row counts):")
    for table, count in final_summary.items():
        print(f"  {table}: {count}")


if __name__ == "__main__":
    main()

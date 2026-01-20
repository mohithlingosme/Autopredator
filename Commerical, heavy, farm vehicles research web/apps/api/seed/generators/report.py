from __future__ import annotations

from typing import Dict, List

import sqlalchemy as sa

from ..config import BASE_COUNTS
from ..types import SeedContext

MIN_LOOKUPS = {"states": 20, "cities": 80, "body_types": 10}


async def _table_count(conn, table) -> int:
    return int((await conn.execute(sa.select(sa.func.count()).select_from(table))).scalar_one())


async def run_validations_and_report(ctx: SeedContext) -> None:
    """Validate seeded data and print a concise summary."""
    metadata = ctx.metadata
    conn = await ctx.engine.connect()
    errors: List[str] = []
    counts: Dict[str, int] = {}

    tables = {
        "states": metadata.tables["states"],
        "cities": metadata.tables["cities"],
        "body_types": metadata.tables["body_types"],
        "manufacturers": metadata.tables["manufacturers"],
        "model_families": metadata.tables["model_families"],
        "models": metadata.tables["models"],
        "variants": metadata.tables["variants"],
        "price_history": metadata.tables["price_history"],
        "listings": metadata.tables["listings"],
        "listing_media": metadata.tables["listing_media"],
        "leads": metadata.tables["leads"],
        "offers": metadata.tables["offers"],
        "fleet_vehicles": metadata.tables["fleet_vehicles"],
        "drivers": metadata.tables["drivers"],
        "trips": metadata.tables["trips"],
        "fuel_logs": metadata.tables["fuel_logs"],
        "maintenance_jobs": metadata.tables["maintenance_jobs"],
        "compliance_docs": metadata.tables["compliance_docs"],
        "finance_applications": metadata.tables["finance_applications"],
        "kyc_documents": metadata.tables["kyc_documents"],
        "bank_offers": metadata.tables["bank_offers"],
        "categories": metadata.tables["categories"],
        "tags": metadata.tables["tags"],
        "articles": metadata.tables["articles"],
    }

    for name, table in tables.items():
        counts[name] = await _table_count(conn, table)

    # Minimums
    for name, minimum in MIN_LOOKUPS.items():
        if counts[name] < minimum:
            errors.append(f"{name} below minimum ({counts[name]} < {minimum})")

    entity_minimums = {
        "manufacturers": BASE_COUNTS["manufacturers"],
        "model_families": BASE_COUNTS["model_families"],
        "models": BASE_COUNTS["models"],
        "variants": BASE_COUNTS["variants"],
        "price_history": BASE_COUNTS["price_history_variants"] * BASE_COUNTS["price_history_cities"] * BASE_COUNTS["price_history_months"],
        "listings": BASE_COUNTS["listings_used"] + BASE_COUNTS["listings_new"],
        "leads": BASE_COUNTS["leads"],
        "fleet_vehicles": BASE_COUNTS["fleet_vehicles"],
        "drivers": BASE_COUNTS["drivers"],
        "trips": BASE_COUNTS["trips"],
        "fuel_logs": BASE_COUNTS["fuel_logs"],
        "maintenance_jobs": BASE_COUNTS["maintenance_jobs"],
        "finance_applications": BASE_COUNTS["finance_applications"],
        "articles": BASE_COUNTS["articles"],
    }
    for name, minimum in entity_minimums.items():
        if counts.get(name, 0) < minimum:
            errors.append(f"{name} below minimum ({counts.get(name, 0)} < {minimum})")

    # Listing constraints
    listing_checks = await conn.execute(
        sa.text(
            """
            SELECT MIN(year) as min_year, MAX(year) as max_year,
                   MIN(km_driven) as min_km, MAX(km_driven) as max_km,
                   MIN(price) as min_price, MAX(price) as max_price
            FROM listings
            """
        )
    )
    min_year, max_year, min_km, max_km, min_price, max_price = listing_checks.one()
    if min_year and min_year < 2008:
        errors.append(f"Listing year too low ({min_year})")
    if max_year and max_year > 2026:
        errors.append(f"Listing year too high ({max_year})")
    if min_km is not None and min_km < 0:
        errors.append("Listing km_driven negative")
    if min_price is not None and min_price < 0:
        errors.append("Listing price negative")

    # Price history coverage
    coverage_query = await conn.execute(
        sa.text(
            """
            SELECT COUNT(*) FROM (
                SELECT variant_id,
                       COUNT(DISTINCT city_id) AS cities,
                       COUNT(DISTINCT effective_date) AS months
                FROM price_history
                GROUP BY variant_id
                HAVING COUNT(DISTINCT city_id) >= :city_min
                   AND COUNT(DISTINCT effective_date) >= :month_min
            ) t
            """
        ),
        {"city_min": BASE_COUNTS["price_history_cities"], "month_min": BASE_COUNTS["price_history_months"]},
    )
    coverage_variants = coverage_query.scalar_one()
    if coverage_variants < BASE_COUNTS["price_history_variants"]:
        errors.append(
            f"Price history coverage insufficient ({coverage_variants} variants with required city/month coverage)"
        )

    if errors:
        print("[SEED] Validation errors detected:")
        for err in errors:
            print(f" - {err}")
        await conn.close()
        raise RuntimeError("Seed validation failed")

    # Summary report
    print("\n[SEED] Summary counts")
    for key in ["states", "cities", "body_types", "manufacturers", "model_families", "models", "variants", "price_history", "listings", "listing_media", "leads", "offers", "fleet_vehicles", "drivers", "trips", "fuel_logs", "maintenance_jobs", "compliance_docs", "finance_applications", "kyc_documents", "bank_offers", "articles"]:
        print(f" - {key}: {counts.get(key, 0)}")

    top_cities = (
        await conn.execute(
            sa.text(
                """
                SELECT c.name, COUNT(*) as listings
                FROM listings l
                JOIN cities c ON l.city_id = c.id
                GROUP BY c.name
                ORDER BY listings DESC
                LIMIT 10
                """
            )
        )
    ).all()
    print("\nTop 10 freight cities by listings:")
    for city, total in top_cities:
        print(f" - {city}: {total}")

    top_manufacturers = (
        await conn.execute(
            sa.text(
                """
                SELECT m.name, COUNT(v.id) as variants
                FROM variants v
                JOIN models mo ON v.model_id = mo.id
                JOIN model_families mf ON mo.family_id = mf.id
                JOIN manufacturers m ON mf.manufacturer_id = m.id
                GROUP BY m.name
                ORDER BY variants DESC
                LIMIT 10
                """
            )
        )
    ).all()
    print("\nTop 10 manufacturers by variants:")
    for name, total in top_manufacturers:
        print(f" - {name}: {total}")

    averages = (
        await conn.execute(
            sa.text(
                """
                SELECT AVG(price)::numeric(12,2) as avg_price, AVG(km_driven)::numeric(12,2) as avg_km
                FROM listings WHERE listing_type='used'
                """
            )
        )
    ).one()
    print(f"\nAvg used listing price: {averages.avg_price} | Avg km: {averages.avg_km}")

    year_distribution = (
        await conn.execute(
            sa.text(
                """
                SELECT year, COUNT(*) FROM listings GROUP BY year ORDER BY year
                """
            )
        )
    ).all()
    print("\nYear distribution (listings):")
    for yr, total in year_distribution:
        print(f" - {yr}: {total}")

    segment_distribution = (
        await conn.execute(
            sa.text(
                """
                SELECT specs.extras->>'segment' as segment, COUNT(*) FROM variant_specs specs
                GROUP BY segment
                ORDER BY COUNT(*) DESC
                """
            )
        )
    ).all()
    print("\nSegment distribution (variants):")
    for segment, total in segment_distribution:
        print(f" - {segment}: {total}")

    body_distribution = (
        await conn.execute(
            sa.text(
                """
                SELECT bt.label, COUNT(*) FROM variants v
                JOIN body_types bt ON v.body_type_id = bt.id
                GROUP BY bt.label
                ORDER BY COUNT(*) DESC
                """
            )
        )
    ).all()
    print("\nBody type distribution (variants):")
    for body, total in body_distribution:
        print(f" - {body}: {total}")

    await conn.close()

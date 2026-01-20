from __future__ import annotations

from datetime import timedelta
from decimal import Decimal

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import insert as pg_insert

from ..types import SeedContext, deterministic_uuid, utc_now


def _build_listing_description(owner_count: int, accident: bool, fitness_valid: bool, tyre: int, body_grade: str) -> str:
    return (
        f"Owners: {owner_count}; Accident history: {'Yes' if accident else 'No'}; "
        f"Fitness valid: {'Yes' if fitness_valid else 'No'}; "
        f"Tyre condition: {tyre}% ; Body grade: {body_grade}"
    )


async def seed_marketplace(ctx: SeedContext) -> dict[str, list]:
    """Seed listings, media, leads, status histories, and offers."""
    lookups = ctx.lookups
    iam = ctx.iam
    catalog = ctx.catalog
    if not (lookups and iam and catalog):
        raise RuntimeError("Lookups, IAM, and catalog data are required before marketplace seeding")

    metadata = ctx.metadata
    listings_table = metadata.tables["listings"]
    media_table = metadata.tables["listing_media"]
    leads_table = metadata.tables["leads"]
    lead_history_table = metadata.tables["lead_status_history"]
    offers_table = metadata.tables["offers"]

    rng = ctx.rng
    now = utc_now()

    used_target = ctx.counts["listings_used"]
    new_target = ctx.counts["listings_new"]
    listing_rows = []
    media_rows = []

    seller_candidates_new = iam.dealer_org_ids
    seller_candidates_used = iam.dealer_org_ids + iam.fleet_org_ids
    city_ids = list(lookups.cities_by_code.values())

    listing_meta: list[dict] = []
    for idx in range(used_target + new_target):
        listing_type = "used" if idx < used_target else "new"
        variant = rng.choice(catalog.variants)
        city_id = rng.choice(city_ids)
        year = rng.randint(2008, 2026) if listing_type == "used" else rng.randint(2023, 2026)
        km = 0 if listing_type == "new" else rng.randint(50000, 800000)
        owner_count = 1 if listing_type == "new" else rng.randint(1, 4)
        accident_history = listing_type == "used" and rng.random() < 0.12
        fitness_valid = True if listing_type == "new" else rng.random() > 0.1
        tyre_condition = rng.randint(55, 95) if listing_type == "used" else 100
        body_grade = rng.choice(["A", "B", "C"])
        desc = _build_listing_description(owner_count, accident_history, fitness_valid, tyre_condition, body_grade)
        base_price = variant.msrp
        if listing_type == "used":
            depreciation_factor = rng.uniform(0.35, 0.85)
            price = max(int(base_price * depreciation_factor), 250000)
        else:
            price = int(base_price * rng.uniform(0.95, 1.1))

        seller_org_id = (
            seller_candidates_used[idx % len(seller_candidates_used)]
            if listing_type == "used"
            else seller_candidates_new[idx % len(seller_candidates_new)]
        )
        listing_id = deterministic_uuid(f"listing-{idx}")
        listing_rows.append(
            {
                "id": listing_id,
                "listing_type": listing_type,
                "variant_id": variant.id,
                "seller_org_id": seller_org_id,
                "price": Decimal(price),
                "year": year,
                "km_driven": km,
                "city_id": city_id,
                "fuel_type_id": variant.fuel_type_id,
                "transmission_id": variant.transmission_id,
                "body_type_id": variant.body_type_id,
                "status": "published",
                "description": desc,
                "created_at": now,
                "updated_at": now,
            }
        )
        listing_meta.append(
            {
                "id": listing_id,
                "price": price,
                "listing_type": listing_type,
                "owner_count": owner_count,
                "accident_history": accident_history,
                "fitness_valid": fitness_valid,
                "tyre_condition": tyre_condition,
                "body_grade": body_grade,
                "city_id": city_id,
                "variant": variant,
            }
        )
        media_count = rng.randint(ctx.counts["listing_media_min"], ctx.counts["listing_media_max"])
        for m_idx in range(media_count):
            media_rows.append(
                {
                    "id": deterministic_uuid(f"listing-media-{listing_id}-{m_idx}"),
                    "listing_id": listing_id,
                    "media_type": "image",
                    "url": f"https://cdn.autopredator.local/listings/{listing_id}/img-{m_idx+1}.jpg",
                    "caption": f"{variant.name} view {m_idx+1}",
                    "sort_order": m_idx,
                    "metadata": {
                        "is_primary": m_idx == 0,
                        "angle": rng.choice(["front", "side", "rear", "cabin"]),
                        "owner_count": owner_count,
                        "tyre_condition": tyre_condition,
                        "body_grade": body_grade,
                    },
                    "created_at": now,
                }
            )

    leads_rows = []
    lead_history_rows = []
    offers_rows = []
    buyer_candidates = [user for user in iam.users if user.role in ("fleet_manager", "sales_agent")]
    status_flow = [
        "new",
        "contacted",
        "inspection_scheduled",
        "negotiated",
    ]
    for idx in range(ctx.counts["leads"]):
        listing_info = listing_meta[idx % len(listing_meta)]
        listing = listing_rows[idx % len(listing_rows)]
        lead_id = deterministic_uuid(f"lead-{idx}")
        final_status = "won" if rng.random() < 0.35 else "lost"
        buyer = rng.choice(buyer_candidates) if buyer_candidates else None
        created_at = now - timedelta(days=rng.randint(0, 60))
        leads_rows.append(
            {
                "id": lead_id,
                "listing_id": listing["id"],
                "buyer_user_id": buyer.id if buyer else None,
                "seller_org_id": listing["seller_org_id"],
                "status": final_status,
                "source": rng.choice(["organic", "paid", "referral", "dealer"]),
                "contact_name": buyer.full_name if buyer else "Fleet Buyer",
                "contact_phone": f"+91{rng.randint(7000000000, 9999999999)}",
                "created_at": created_at,
                "updated_at": created_at + timedelta(hours=1),
            }
        )
        # status history progression
        step_time = created_at
        for st in status_flow + [final_status]:
            lead_history_rows.append(
                {
                    "id": deterministic_uuid(f"lead-status-{idx}-{st}"),
                    "lead_id": lead_id,
                    "status": st,
                    "notes": f"auto-seeded status {st}",
                    "changed_by": buyer.id if buyer else None,
                    "created_at": step_time,
                }
            )
            step_time += timedelta(hours=ctx.rng.randint(2, 48))
        if rng.random() < 0.25:
            negotiated_amount = int(listing_info["price"] * rng.uniform(0.92, 1.05))
            offers_rows.append(
                {
                    "id": deterministic_uuid(f"offer-{idx}"),
                    "lead_id": lead_id,
                    "amount": Decimal(negotiated_amount),
                    "status": "pending" if final_status != "won" else "accepted",
                    "expires_at": created_at + timedelta(days=7),
                    "created_at": created_at + timedelta(hours=1),
                }
            )

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(listings_table)
            .values(listing_rows)
            .on_conflict_do_update(
                index_elements=[listings_table.c.id],
                set_={
                    "price": sa.text("excluded.price"),
                    "status": sa.text("excluded.status"),
                    "description": sa.text("excluded.description"),
                    "updated_at": sa.text("excluded.updated_at"),
                },
            )
        )
        await conn.execute(
            pg_insert(media_table)
            .values(media_rows)
            .on_conflict_do_nothing(index_elements=[media_table.c.id])
        )
        await conn.execute(
            pg_insert(leads_table)
            .values(leads_rows)
            .on_conflict_do_update(
                index_elements=[leads_table.c.id],
                set_={"status": sa.text("excluded.status"), "updated_at": sa.text("excluded.updated_at")},
            )
        )
        await conn.execute(
            pg_insert(lead_history_table)
            .values(lead_history_rows)
            .on_conflict_do_nothing(index_elements=[lead_history_table.c.id])
        )
        if offers_rows:
            await conn.execute(
                pg_insert(offers_table)
                .values(offers_rows)
                .on_conflict_do_update(
                    index_elements=[offers_table.c.id],
                    set_={"amount": sa.text("excluded.amount"), "status": sa.text("excluded.status")},
                )
            )

    return {"listings": listing_rows, "leads": leads_rows}

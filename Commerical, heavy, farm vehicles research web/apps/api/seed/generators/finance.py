from __future__ import annotations

from datetime import timedelta
from decimal import Decimal

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import insert as pg_insert

from ..types import SeedContext, deterministic_uuid, utc_now


async def seed_finance(ctx: SeedContext) -> None:
    """Seed finance applications, KYC docs, bank offers, and status history."""
    iam = ctx.iam
    catalog = ctx.catalog
    if not (iam and catalog):
        raise RuntimeError("IAM and catalog data are required before finance seeding")

    metadata = ctx.metadata
    applications_table = metadata.tables["finance_applications"]
    kyc_table = metadata.tables["kyc_documents"]
    offers_table = metadata.tables["bank_offers"]
    status_table = metadata.tables["finance_status_history"]
    leads_table = metadata.tables["leads"]

    rng = ctx.rng
    now = utc_now()

    # Fetch leads to associate finance flows
    async with ctx.engine.connect() as conn:
        lead_rows = (
            await conn.execute(
                sa.select(leads_table.c.id, leads_table.c.buyer_user_id, leads_table.c.seller_org_id)
            )
        ).all()
    lead_cycle = lead_rows or []
    actor_user_id = iam.admin_user_ids[0] if iam.admin_user_ids else None

    applications_rows = []
    kyc_rows = []
    offer_rows = []
    status_rows = []
    app_count = ctx.counts["finance_applications"]

    for idx in range(app_count):
        variant = catalog.variants[idx % len(catalog.variants)]
        lead = lead_cycle[idx % len(lead_cycle)] if lead_cycle else None
        application_id = deterministic_uuid(f"finance-app-{idx}")
        amount = int(variant.msrp * rng.uniform(0.55, 0.9))
        vehicle_price = int(variant.msrp * rng.uniform(0.9, 1.1))
        tenure = rng.choice([36, 48, 60, 72])
        interest = round(rng.uniform(8.5, 16.5), 2)
        status = rng.choice(["submitted", "docs_pending", "approved", "rejected", "disbursed"])
        applications_rows.append(
            {
                "id": application_id,
                "lead_id": lead.id if lead else None,
                "user_id": lead.buyer_user_id if lead and lead.buyer_user_id else (iam.admin_user_ids[0] if iam.admin_user_ids else None),
                "org_id": lead.seller_org_id if lead else iam.fleet_org_ids[idx % len(iam.fleet_org_ids)],
                "amount": Decimal(amount),
                "tenure_months": tenure,
                "status": status,
                "submitted_at": now - timedelta(days=rng.randint(1, 45)),
                "vehicle_price": Decimal(vehicle_price),
                "interest_rate": Decimal(interest),
                "created_at": now,
                "updated_at": now,
            }
        )
        # KYC documents
        for d_idx in range(rng.randint(ctx.counts["kyc_docs_min"], ctx.counts["kyc_docs_max"])):
            kyc_rows.append(
                {
                    "id": deterministic_uuid(f"kyc-{application_id}-{d_idx}"),
                    "application_id": application_id,
                    "doc_type": rng.choice(["pan", "aadhaar", "gst", "address_proof", "bank_statement"]),
                    "doc_number": f"KYC-{idx}-{d_idx}",
                    "file_url": f"https://cdn.autopredator.local/kyc/{application_id}/{d_idx}.pdf",
                    "status": "submitted",
                    "uploaded_at": now - timedelta(days=rng.randint(1, 30)),
                }
            )
        # Bank offers
        for offer_idx in range(rng.randint(ctx.counts["bank_offers_min"], ctx.counts["bank_offers_max"])):
            offer_rows.append(
                {
                    "id": deterministic_uuid(f"bank-offer-{application_id}-{offer_idx}"),
                    "application_id": application_id,
                    "bank_name": rng.choice(["HDFC Bank", "ICICI Bank", "SBI", "Axis Bank", "Kotak Mahindra"]),
                    "interest_rate": Decimal(round(interest + rng.uniform(-0.5, 1.0), 2)),
                    "processing_fee": Decimal(rng.uniform(5000, 25000)),
                    "ltv_percent": Decimal(round(rng.uniform(70, 90), 2)),
                    "status": rng.choice(["pending", "approved", "rejected"]),
                    "offered_at": now - timedelta(days=rng.randint(1, 30)),
                }
            )
        # Status trail
        flow = ["submitted", "docs_pending", "approved" if status in {"approved", "disbursed"} else "rejected"]
        if status == "disbursed":
            flow.append("disbursed")
        step_time = now - timedelta(days=10)
        for st in flow:
            status_rows.append(
                {
                    "id": deterministic_uuid(f"finance-status-{application_id}-{st}"),
                    "application_id": application_id,
                    "status": st,
                    "notes": f"auto-seeded status {st}",
                    "actor_user_id": actor_user_id,
                    "created_at": step_time,
                }
            )
            step_time += timedelta(days=2)

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(applications_table)
            .values(applications_rows)
            .on_conflict_do_update(
                index_elements=[applications_table.c.id],
                set_={
                    "status": sa.text("excluded.status"),
                    "interest_rate": sa.text("excluded.interest_rate"),
                    "updated_at": sa.text("excluded.updated_at"),
                },
            )
        )
        await conn.execute(
            pg_insert(kyc_table)
            .values(kyc_rows)
            .on_conflict_do_nothing(index_elements=[kyc_table.c.id])
        )
        await conn.execute(
            pg_insert(offers_table)
            .values(offer_rows)
            .on_conflict_do_update(
                index_elements=[offers_table.c.id],
                set_={"status": sa.text("excluded.status"), "interest_rate": sa.text("excluded.interest_rate")},
            )
        )
        await conn.execute(
            pg_insert(status_table)
            .values(status_rows)
            .on_conflict_do_nothing(index_elements=[status_table.c.id])
        )

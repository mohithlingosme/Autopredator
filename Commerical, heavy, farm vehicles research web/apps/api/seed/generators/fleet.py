from __future__ import annotations

from datetime import timedelta
from decimal import Decimal

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import insert as pg_insert

from ..types import SeedContext, deterministic_uuid, utc_now


async def seed_fleet(ctx: SeedContext) -> dict[str, list]:
    """Seed fleet vehicles, drivers, assignments, trips, fuel logs, and compliance."""
    lookups = ctx.lookups
    iam = ctx.iam
    catalog = ctx.catalog
    if not (lookups and iam and catalog):
        raise RuntimeError("Lookups, IAM, and catalog data are required before fleet seeding")

    metadata = ctx.metadata
    vehicles_table = metadata.tables["fleet_vehicles"]
    drivers_table = metadata.tables["drivers"]
    assignments_table = metadata.tables["driver_assignments"]
    trips_table = metadata.tables["trips"]
    fuel_logs_table = metadata.tables["fuel_logs"]
    maintenance_table = metadata.tables["maintenance_jobs"]
    compliance_table = metadata.tables["compliance_docs"]

    rng = ctx.rng
    now = utc_now()

    vehicles_rows = []
    drivers_rows = []
    assignments_rows = []
    trips_rows = []
    fuel_logs_rows = []
    maintenance_rows = []
    compliance_rows = []

    fleet_orgs = iam.fleet_org_ids
    city_ids = list(lookups.cities_by_code.values())

    vehicle_count = ctx.counts["fleet_vehicles"]
    driver_count = ctx.counts["drivers"]

    for idx in range(vehicle_count):
        org_id = fleet_orgs[idx % len(fleet_orgs)]
        variant = catalog.variants[idx % len(catalog.variants)]
        reg_no = f"{rng.choice(list(lookups.states_by_code.keys()))}{rng.randint(10,99)}-{rng.randint(1000,9999)}"
        year = rng.randint(2008, 2024)
        vehicle_id = deterministic_uuid(f"vehicle-{idx}")
        vehicles_rows.append(
            {
                "id": vehicle_id,
                "org_id": org_id,
                "variant_id": variant.id,
                "registration_no": reg_no,
                "vin": f"VIN{idx:06d}",
                "year": year,
                "status": "active",
                "telemetry_unit_id": f"TLM-{idx:05d}",
                "created_at": now,
                "updated_at": now,
            }
        )
        # compliance documents
        for doc_type, offset_days in [
            ("insurance", 365),
            ("fitness", 540),
            ("puc", 180),
        ]:
            valid_from = now.date() - timedelta(days=30)
            valid_until = valid_from + timedelta(days=offset_days)
            compliance_rows.append(
                {
                    "id": deterministic_uuid(f"compliance-{vehicle_id}-{doc_type}"),
                    "vehicle_id": vehicle_id,
                    "doc_type": doc_type,
                    "doc_number": f"{doc_type.upper()}-{idx:06d}",
                    "valid_from": valid_from,
                    "valid_until": valid_until,
                    "status": "active",
                    "file_url": f"https://cdn.autopredator.local/docs/{vehicle_id}/{doc_type}.pdf",
                    "created_at": now,
                }
            )

    for idx in range(driver_count):
        org_id = fleet_orgs[idx % len(fleet_orgs)]
        driver_id = deterministic_uuid(f"driver-{idx}")
        drivers_rows.append(
            {
                "id": driver_id,
                "org_id": org_id,
                "user_id": None,
                "name": f"Driver {idx+1:04d}",
                "phone": f"+91{rng.randint(7000000000, 9999999999)}",
                "license_no": f"LIC{idx:06d}",
                "license_valid_until": (now + timedelta(days=rng.randint(180, 720))).date(),
                "status": "active",
                "created_at": now,
                "updated_at": now,
            }
        )

    # driver assignments
    assignment_count = ctx.counts["driver_assignments"]
    for idx in range(assignment_count):
        driver_id = drivers_rows[idx % len(drivers_rows)]["id"]
        vehicle_id = vehicles_rows[idx % len(vehicles_rows)]["id"]
        start_at = now - timedelta(days=rng.randint(15, 90))
        end_at = start_at + timedelta(days=rng.randint(5, 20))
        assignments_rows.append(
            {
                "id": deterministic_uuid(f"assignment-{idx}"),
                "driver_id": driver_id,
                "vehicle_id": vehicle_id,
                "start_at": start_at,
                "end_at": end_at,
                "status": "active",
                "created_at": start_at,
            }
        )

    # trips
    for idx in range(ctx.counts["trips"]):
        vehicle = vehicles_rows[idx % len(vehicles_rows)]
        driver = drivers_rows[idx % len(drivers_rows)]
        start_time = now - timedelta(days=rng.randint(1, 120))
        duration_hours = rng.randint(6, 72)
        end_time = start_time + timedelta(hours=duration_hours)
        distance = round(rng.uniform(50, 2000), 2)
        origin = rng.choice(city_ids)
        destination = rng.choice(city_ids)
        trips_rows.append(
            {
                "id": deterministic_uuid(f"trip-{idx}"),
                "vehicle_id": vehicle["id"],
                "driver_id": driver["id"],
                "origin_city_id": origin,
                "destination_city_id": destination,
                "start_time": start_time,
                "end_time": end_time,
                "distance_km": distance,
                "fuel_used_liters": round(distance / rng.uniform(2.5, 4.5), 2),
                "status": rng.choice(["completed", "in_progress", "cancelled"]),
                "created_at": start_time,
            }
        )

    # fuel logs
    for idx in range(ctx.counts["fuel_logs"]):
        vehicle = vehicles_rows[idx % len(vehicles_rows)]
        driver = drivers_rows[idx % len(drivers_rows)]
        fuel_type_id = catalog.variants[idx % len(catalog.variants)].fuel_type_id
        filled_at = now - timedelta(days=rng.randint(1, 120))
        volume = round(rng.uniform(40, 220), 2)
        fuel_logs_rows.append(
            {
                "id": deterministic_uuid(f"fuel-{idx}"),
                "vehicle_id": vehicle["id"],
                "driver_id": driver["id"],
                "fuel_type_id": fuel_type_id,
                "volume_liters": volume,
                "cost": Decimal(volume * rng.uniform(85, 120)),
                "odometer_km": round(rng.uniform(10000, 800000), 2),
                "filled_at": filled_at,
                "station_name": "Seed Fuel Station",
                "created_at": filled_at,
            }
        )

    # maintenance
    for idx in range(ctx.counts["maintenance_jobs"]):
        vehicle = vehicles_rows[idx % len(vehicles_rows)]
        scheduled = now - timedelta(days=rng.randint(5, 150))
        completed = scheduled + timedelta(days=rng.randint(1, 5))
        maintenance_rows.append(
            {
                "id": deterministic_uuid(f"maint-{idx}"),
                "vehicle_id": vehicle["id"],
                "job_type": rng.choice(["service", "tyres", "clutch", "brakes", "engine"]),
                "status": rng.choice(["scheduled", "in_progress", "completed"]),
                "scheduled_at": scheduled,
                "completed_at": completed,
                "cost": Decimal(rng.uniform(5000, 90000)),
                "odometer_km": round(rng.uniform(20000, 900000), 2),
                "notes": "Seeded maintenance job",
                "created_at": scheduled,
            }
        )

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(vehicles_table)
            .values(vehicles_rows)
            .on_conflict_do_update(
                index_elements=[vehicles_table.c.id],
                set_={"status": sa.text("excluded.status"), "updated_at": sa.text("excluded.updated_at")},
            )
        )
        await conn.execute(
            pg_insert(drivers_table)
            .values(drivers_rows)
            .on_conflict_do_update(
                index_elements=[drivers_table.c.license_no],
                set_={"status": sa.text("excluded.status"), "phone": sa.text("excluded.phone")},
            )
        )
        await conn.execute(
            pg_insert(assignments_table)
            .values(assignments_rows)
            .on_conflict_do_update(
                index_elements=[assignments_table.c.id],
                set_={"end_at": sa.text("excluded.end_at"), "status": sa.text("excluded.status")},
            )
        )
        await conn.execute(
            pg_insert(trips_table)
            .values(trips_rows)
            .on_conflict_do_nothing(index_elements=[trips_table.c.id])
        )
        await conn.execute(
            pg_insert(fuel_logs_table)
            .values(fuel_logs_rows)
            .on_conflict_do_nothing(index_elements=[fuel_logs_table.c.id])
        )
        await conn.execute(
            pg_insert(maintenance_table)
            .values(maintenance_rows)
            .on_conflict_do_update(
                index_elements=[maintenance_table.c.id],
                set_={"status": sa.text("excluded.status"), "cost": sa.text("excluded.cost")},
            )
        )
        await conn.execute(
            pg_insert(compliance_table)
            .values(compliance_rows)
            .on_conflict_do_update(
                index_elements=[compliance_table.c.id],
                set_={"valid_until": sa.text("excluded.valid_until"), "status": sa.text("excluded.status")},
            )
        )

    return {"vehicles": vehicles_rows, "drivers": drivers_rows}

from __future__ import annotations

import math
from datetime import date, timedelta
from decimal import Decimal
from typing import List

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import insert as pg_insert

from ..fixtures.lookups import AXLE_CONFIGS
from ..types import CatalogData, SeedContext, VariantInfo, deterministic_uuid, utc_now

MANUFACTURERS = [
    "Tata Motors CV",
    "Ashok Leyland",
    "Mahindra Truck & Bus",
    "Eicher Trucks",
    "BharatBenz",
    "Volvo Trucks",
    "Scania",
    "MAN",
    "Force Motors",
    "SML Isuzu",
    "Isuzu",
    "Piaggio CV",
    "AMW",
    "Daimler Fuso",
    "Caterpillar",
    "Komatsu",
]

FAMILY_LABELS = [
    "Haulage",
    "Tipper",
    "Long Haul",
    "Distribution",
    "Prime",
    "Tractor",
    "Construction",
    "Reefer",
]

MODEL_LABELS = ["X", "Pro", "Ultra", "Plus", "Max", "CX", "NX", "LX"]
SEGMENTS = ["LCV", "ICV", "MCV", "HCV"]
APPLICATIONS = ["haulage", "mining", "construction", "logistics", "city_distribution"]
EMISSIONS = ["BS4", "BS6", "BS6 Phase-2"]
BODY_TYPE_PREF = {
    "LCV": "pickup",
    "ICV": "container",
    "MCV": "open",
    "HCV": "trailer_head",
}


def _price_range_for_segment(segment: str) -> tuple[int, int]:
    return {
        "LCV": (1200000, 2200000),
        "ICV": (2200000, 3200000),
        "MCV": (3200000, 4500000),
        "HCV": (4500000, 7500000),
    }.get(segment, (2000000, 5000000))


def _spec_for_segment(ctx: SeedContext, segment: str, fuel_code: str, transmission_code: str, body_type_code: str) -> dict:
    rng = ctx.rng
    gvw_bounds = {
        "LCV": (3500, 7500),
        "ICV": (7500, 16000),
        "MCV": (16000, 25000),
        "HCV": (25000, 55000),
    }
    gvw_low, gvw_high = gvw_bounds.get(segment, (12000, 25000))
    gvw = rng.randint(gvw_low, gvw_high)
    payload = int(gvw * rng.uniform(0.55, 0.7))
    wheelbase = rng.choice([2800, 3200, 3600, 4200, 4800, 5600])
    cabin = rng.choice(["day", "sleeper"])
    emission = rng.choice(EMISSIONS)
    application = rng.choice(APPLICATIONS)
    axle_config = rng.choice(AXLE_CONFIGS)
    permit_type = rng.choice(["national", "state"])
    now = utc_now().date()
    fitness = now + timedelta(days=rng.randint(180, 720))
    insurance = now + timedelta(days=rng.randint(90, 365))
    transmission_label = transmission_code
    extras = {
        "segment": segment,
        "gvw_kg": gvw,
        "payload_kg": payload,
        "axle_config": axle_config,
        "body_type": body_type_code,
        "wheelbase_mm": wheelbase,
        "fuel": fuel_code,
        "cabin_type": cabin,
        "emission_norm": emission,
        "transmission": transmission_label,
        "application": application,
        "permit_type": permit_type,
        "fitness_expiry": fitness.isoformat(),
        "insurance_expiry": insurance.isoformat(),
        "features": {
            "abs": True,
            "hill_hold": segment in {"ICV", "MCV", "HCV"},
            "cruise_control": segment in {"MCV", "HCV"},
            "telematics_ready": True,
        },
    }
    return {
        "engine_type": f"{emission} turbo diesel",
        "displacement_cc": rng.choice([3000, 3800, 5600, 6800, 9000]),
        "power_hp": rng.randint(90, 450),
        "torque_nm": rng.randint(280, 2000),
        "seating_capacity": 2 if cabin == "day" else 3,
        "mileage_kmpl": round(rng.uniform(2.5, 9.5), 2),
        "emission_standard": emission,
        "safety_rating": None,
        "dimensions": {"wheelbase_mm": wheelbase},
        "extras": extras,
    }


async def seed_catalog(ctx: SeedContext) -> CatalogData:
    """Seed manufacturers, families, models, variants, and price history."""
    metadata = ctx.metadata
    lookups = ctx.lookups
    if lookups is None:
        raise RuntimeError("Lookup data must be seeded before catalog")

    manufacturers_table = metadata.tables["manufacturers"]
    families_table = metadata.tables["model_families"]
    models_table = metadata.tables["models"]
    variants_table = metadata.tables["variants"]
    specs_table = metadata.tables["variant_specs"]
    price_history_table = metadata.tables["price_history"]

    manufacturer_target = ctx.counts["manufacturers"]
    family_target = ctx.counts["model_families"]
    model_target = ctx.counts["models"]
    variant_target = ctx.counts["variants"]

    selected_manufacturers = MANUFACTURERS[:manufacturer_target]
    manufacturer_rows = []
    manufacturer_ids: list[str] = []
    now = utc_now()

    for name in selected_manufacturers:
        mid = deterministic_uuid(f"manufacturer-{name}")
        manufacturer_ids.append(mid)
        manufacturer_rows.append(
            {
                "id": mid,
                "name": name,
                "country": "India",
                "status": "active",
                "created_at": now,
                "updated_at": now,
            }
        )

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(manufacturers_table)
            .values(manufacturer_rows)
            .on_conflict_do_update(
                index_elements=[manufacturers_table.c.name],
                set_={"status": sa.text("excluded.status"), "country": sa.text("excluded.country")},
            )
        )

    families_per_manufacturer = max(2, math.ceil(family_target / len(selected_manufacturers)))
    models_per_family = max(2, math.ceil(model_target / (families_per_manufacturer * len(selected_manufacturers))))
    variants_per_model = max(2, math.ceil(variant_target / (models_per_family * families_per_manufacturer * len(selected_manufacturers))))

    family_rows = []
    model_rows = []
    variant_rows = []
    spec_rows = []
    variant_infos: List[VariantInfo] = []

    fuel_codes = list(lookups.fuel_types_by_code.keys())
    trans_codes = list(lookups.transmissions_by_code.keys())
    body_codes = list(lookups.body_types_by_code.keys())

    def pick_body(segment: str) -> str:
        preferred = BODY_TYPE_PREF.get(segment)
        if preferred and preferred in lookups.body_types_by_code:
            return preferred
        return ctx.rng.choice(body_codes)

    family_count = 0
    model_count = 0
    variant_count = 0

    for m_idx, manufacturer_name in enumerate(selected_manufacturers):
        manufacturer_id = deterministic_uuid(f"manufacturer-{manufacturer_name}")
        for f_idx in range(families_per_manufacturer):
            if family_count >= family_target:
                break
            segment = SEGMENTS[(m_idx + f_idx) % len(SEGMENTS)]
            family_name = f"{manufacturer_name.split()[0]} {FAMILY_LABELS[f_idx % len(FAMILY_LABELS)]} {segment}"
            family_id = deterministic_uuid(f"family-{manufacturer_name}-{f_idx}")
            family_rows.append(
                {
                    "id": family_id,
                    "manufacturer_id": manufacturer_id,
                    "name": family_name,
                    "segment": segment,
                    "status": "active",
                    "created_at": now,
                    "updated_at": now,
                }
            )
            family_count += 1

            for model_idx in range(models_per_family):
                if model_count >= model_target:
                    break
                model_name = f"{family_name} {MODEL_LABELS[model_idx % len(MODEL_LABELS)]}"
                body_code = pick_body(segment)
                body_id = lookups.body_types_by_code.get(body_code)
                year_start = ctx.rng.randint(2014, 2022)
                model_id = deterministic_uuid(f"model-{family_id}-{model_idx}")
                model_rows.append(
                    {
                        "id": model_id,
                        "family_id": family_id,
                        "name": model_name,
                        "body_type_id": body_id,
                        "year_start": year_start,
                        "year_end": None,
                        "status": "active",
                        "created_at": now,
                        "updated_at": now,
                    }
                )
                model_count += 1

                for variant_idx in range(variants_per_model):
                    if variant_count >= variant_target:
                        break
                    fuel_code = ctx.rng.choice(fuel_codes)
                    trans_code = ctx.rng.choice(trans_codes)
                    fuel_id = lookups.fuel_types_by_code.get(fuel_code)
                    trans_id = lookups.transmissions_by_code.get(trans_code)
                    body_id = lookups.body_types_by_code.get(body_code)
                    v_name = f"{model_name} {segment}-{variant_idx+1}"
                    v_id = deterministic_uuid(f"variant-{model_id}-{variant_idx}")
                    year_start = year_start
                    msrp_low, msrp_high = _price_range_for_segment(segment)
                    msrp = ctx.rng.randint(msrp_low, msrp_high)
                    variant_rows.append(
                        {
                            "id": v_id,
                            "model_id": model_id,
                            "name": v_name,
                            "fuel_type_id": fuel_id,
                            "transmission_id": trans_id,
                            "body_type_id": body_id,
                            "drivetrain": ctx.rng.choice(["4x2", "6x4", "8x2", "8x4"]),
                            "status": "active",
                            "year_start": year_start,
                            "year_end": None,
                            "msrp_ex_showroom": Decimal(msrp),
                            "created_at": now,
                            "updated_at": now,
                        }
                    )
                    spec = _spec_for_segment(ctx, segment, fuel_code, trans_code, body_code)
                    spec_rows.append(
                        {
                            "id": deterministic_uuid(f"variant-spec-{v_id}"),
                            "variant_id": v_id,
                            **spec,
                            "created_at": now,
                            "updated_at": now,
                        }
                    )
                    variant_infos.append(
                        VariantInfo(
                            id=v_id,
                            model_id=model_id,
                            family_id=family_id,
                            manufacturer_id=manufacturer_id,
                            name=v_name,
                            body_type_id=body_id,
                            fuel_type_id=fuel_id,
                            transmission_id=trans_id,
                            segment=segment,
                            msrp=float(msrp),
                            application=spec["extras"]["application"],
                            axle_config=spec["extras"]["axle_config"],
                            body_type_code=body_code,
                        )
                    )
                    variant_count += 1
                if variant_count >= variant_target:
                    break
            if variant_count >= variant_target:
                break
        if variant_count >= variant_target:
            break

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(families_table)
            .values(family_rows)
            .on_conflict_do_update(
                index_elements=[families_table.c.id],
                set_={"status": sa.text("excluded.status"), "segment": sa.text("excluded.segment")},
            )
        )
        await conn.execute(
            pg_insert(models_table)
            .values(model_rows)
            .on_conflict_do_update(
                index_elements=[models_table.c.id],
                set_={"body_type_id": sa.text("excluded.body_type_id"), "status": sa.text("excluded.status")},
            )
        )
        await conn.execute(
            pg_insert(variants_table)
            .values(variant_rows)
            .on_conflict_do_update(
                index_elements=[variants_table.c.id],
                set_={
                    "fuel_type_id": sa.text("excluded.fuel_type_id"),
                    "transmission_id": sa.text("excluded.transmission_id"),
                    "body_type_id": sa.text("excluded.body_type_id"),
                    "msrp_ex_showroom": sa.text("excluded.msrp_ex_showroom"),
                    "status": sa.text("excluded.status"),
                },
            )
        )
        await conn.execute(
            pg_insert(specs_table)
            .values(spec_rows)
            .on_conflict_do_update(
                index_elements=[specs_table.c.variant_id],
                set_={"extras": sa.text("excluded.extras"), "dimensions": sa.text("excluded.dimensions")},
            )
        )

    # Price history seeding
    price_rows = []
    price_variants = variant_infos[: ctx.counts["price_history_variants"]]
    price_cities = list(lookups.cities_by_code.values())[: ctx.counts["price_history_cities"]]
    start_month = utc_now().date().replace(day=1)
    months = [start_month - timedelta(days=30 * m) for m in range(ctx.counts["price_history_months"])]

    for variant in price_variants:
        base_low, base_high = _price_range_for_segment(variant.segment)
        base_price = ctx.rng.randint(base_low, base_high)
        for city_id in price_cities:
            rolling_price = base_price
            for month_date in months:
                # gentle month-to-month change
                delta = ctx.rng.randint(-15000, 15000)
                rolling_price = max(int(rolling_price + delta), int(base_low * 0.7))
                price_rows.append(
                    {
                        "variant_id": variant.id,
                        "city_id": city_id,
                        "effective_date": month_date,
                        "ex_showroom_price": Decimal(rolling_price),
                        "currency": "INR",
                        "created_at": now,
                    }
                )

    batch_size = 2000
    async with ctx.engine.begin() as conn:
        for i in range(0, len(price_rows), batch_size):
            chunk = price_rows[i : i + batch_size]
            await conn.execute(
                pg_insert(price_history_table)
                .values(chunk)
                .on_conflict_do_update(
                    index_elements=[
                        price_history_table.c.variant_id,
                        price_history_table.c.city_id,
                        price_history_table.c.effective_date,
                    ],
                    set_={"ex_showroom_price": sa.text("excluded.ex_showroom_price")},
                )
            )

    catalog = CatalogData(
        manufacturers=manufacturer_ids,
        model_families=[row["id"] for row in family_rows],
        models=[row["id"] for row in model_rows],
        variants=variant_infos,
        price_history_variants=[v.id for v in price_variants],
    )
    ctx.catalog = catalog
    return catalog

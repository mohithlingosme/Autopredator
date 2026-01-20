from __future__ import annotations

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import insert as pg_insert

from ..fixtures.lookups import (
    AXLE_CONFIGS,
    BODY_TYPES,
    CITIES,
    FUEL_TYPES,
    ROUTE_CORRIDORS,
    STATES,
    TRANSMISSIONS,
)
from ..types import LookupData, SeedContext


async def seed_lookups(ctx: SeedContext) -> LookupData:
    """Seed lookup tables: states, cities, fuels, transmissions, body types."""
    metadata = ctx.metadata
    tables = {
        "states": metadata.tables["states"],
        "cities": metadata.tables["cities"],
        "fuel_types": metadata.tables["fuel_types"],
        "transmissions": metadata.tables["transmissions"],
        "body_types": metadata.tables["body_types"],
    }

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(tables["states"])
            .values(STATES)
            .on_conflict_do_update(
                index_elements=[tables["states"].c.code],
                set_={"name": sa.text("excluded.name")},
            )
        )

        # Refresh state ids for city FK
        state_rows = (
            await conn.execute(sa.select(tables["states"].c.id, tables["states"].c.code))
        ).all()
        state_map = {row.code: row.id for row in state_rows}

        city_payload = []
        for city in CITIES:
            state_id = state_map.get(city["state"])
            if state_id is None:
                continue
            city_payload.append(
                {
                    "name": city["name"],
                    "code": city["code"],
                    "state_id": state_id,
                }
            )
        await conn.execute(
            pg_insert(tables["cities"])
            .values(city_payload)
            .on_conflict_do_update(
                index_elements=[tables["cities"].c.state_id, tables["cities"].c.name],
                set_={"code": sa.text("excluded.code")},
            )
        )

        await conn.execute(
            pg_insert(tables["fuel_types"])
            .values(FUEL_TYPES)
            .on_conflict_do_update(
                index_elements=[tables["fuel_types"].c.code],
                set_={"label": sa.text("excluded.label")},
            )
        )

        await conn.execute(
            pg_insert(tables["transmissions"])
            .values(TRANSMISSIONS)
            .on_conflict_do_update(
                index_elements=[tables["transmissions"].c.code],
                set_={"label": sa.text("excluded.label")},
            )
        )

        await conn.execute(
            pg_insert(tables["body_types"])
            .values(BODY_TYPES)
            .on_conflict_do_update(
                index_elements=[tables["body_types"].c.code],
                set_={"label": sa.text("excluded.label")},
            )
        )

    # Build lookup maps
    async with ctx.engine.connect() as conn:
        states = (
            await conn.execute(sa.select(tables["states"].c.code, tables["states"].c.id))
        ).all()
        cities = (
            await conn.execute(sa.select(tables["cities"].c.code, tables["cities"].c.id))
        ).all()
        fuels = (
            await conn.execute(sa.select(tables["fuel_types"].c.code, tables["fuel_types"].c.id))
        ).all()
        transmissions = (
            await conn.execute(
                sa.select(tables["transmissions"].c.code, tables["transmissions"].c.id)
            )
        ).all()
        body_types = (
            await conn.execute(sa.select(tables["body_types"].c.code, tables["body_types"].c.id))
        ).all()

    lookup = LookupData(
        states_by_code={row.code: row.id for row in states},
        cities_by_code={row.code: row.id for row in cities},
        body_types_by_code={row.code: row.id for row in body_types},
        fuel_types_by_code={row.code: row.id for row in fuels},
        transmissions_by_code={row.code: row.id for row in transmissions},
        route_corridors=ROUTE_CORRIDORS,
        axle_configs=AXLE_CONFIGS,
    )
    ctx.lookups = lookup
    return lookup

from __future__ import annotations

import argparse
import asyncio
import random
import sys
from pathlib import Path

import sqlalchemy as sa
from sqlalchemy.ext.asyncio import create_async_engine

ROOT_DIR = Path(__file__).resolve().parents[2]
API_DIR = ROOT_DIR / "apps" / "api"
for path in (str(ROOT_DIR), str(API_DIR)):
    if path not in sys.path:
        sys.path.append(path)

from app.core.config import settings  # noqa: E402

from .config import build_counts
from .generators import (
    run_validations_and_report,
    seed_catalog,
    seed_content,
    seed_finance,
    seed_fleet,
    seed_iam,
    seed_lookups,
    seed_marketplace,
)
from .types import SeedContext


MODE_SEEDS = {"small": 1337, "medium": 4242, "large": 9001}


async def run_seed(mode: str) -> None:
    rng = random.Random(MODE_SEEDS.get(mode, 1337))
    counts = build_counts(mode)

    engine = create_async_engine(settings.DATABASE_URL, echo=False, future=True)
    metadata = sa.MetaData()
    async with engine.begin() as conn:
        await conn.run_sync(metadata.reflect)

    ctx = SeedContext(
        engine=engine,
        metadata=metadata,
        rng=rng,
        mode=mode,
        counts=counts,
        db_url=settings.DATABASE_URL,
    )

    print(f"[SEED] Starting seed in '{mode}' mode against {ctx.describe_db()}")
    await seed_lookups(ctx)
    print("[SEED] Lookups ready")
    await seed_iam(ctx)
    print("[SEED] IAM seeded")
    await seed_catalog(ctx)
    print("[SEED] Catalog seeded")
    await seed_marketplace(ctx)
    print("[SEED] Marketplace seeded")
    await seed_fleet(ctx)
    print("[SEED] Fleet seeded")
    await seed_finance(ctx)
    print("[SEED] Finance seeded")
    await seed_content(ctx)
    print("[SEED] Content seeded")
    await run_validations_and_report(ctx)
    await engine.dispose()
    print("[SEED] Completed")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="AutoPredator database seed runner")
    parser.add_argument(
        "--mode",
        choices=["small", "medium", "large"],
        default="medium",
        help="Seed volume profile",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    asyncio.run(run_seed(args.mode))


if __name__ == "__main__":
    main()

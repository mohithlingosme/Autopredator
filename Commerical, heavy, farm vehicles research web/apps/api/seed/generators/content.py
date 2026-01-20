from __future__ import annotations

import re
from datetime import timedelta

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import insert as pg_insert

from ..types import SeedContext, deterministic_uuid, utc_now

CATEGORY_NAMES = [
    "Truck Buying Guide",
    "Fleet Operations",
    "Maintenance",
    "Permits and Compliance",
    "Fuel Saving",
    "Tyres",
    "Mining Tippers",
    "Trailer Operations",
    "Financing",
    "Insurance",
    "Telematics",
    "EV Commercial",
    "Body Builders",
    "Aftermarket",
    "Routes and Corridors",
    "Driver Welfare",
    "Safety",
    "Logistics",
    "Cold Chain",
    "Construction Fleets",
]

TAG_SEEDS = [
    "bs6",
    "bs4",
    "lcv",
    "icv",
    "mcv",
    "hcv",
    "tipper",
    "haulage",
    "reefer",
    "tanker",
    "fleet_card",
    "emi",
    "insurance",
    "compliance",
    "permit",
    "fitness",
    "puc",
    "hybrid",
    "cng",
    "lng",
    "electric",
    "axle_config",
    "6x4",
    "8x4",
    "10x2",
    "payload",
    "gvw",
    "wheelbase",
    "telematics",
    "gps",
    "driver_training",
    "safety",
    "tyres",
    "retread",
    "financing",
    "ltv",
    "interest",
    "routes",
    "nh44",
    "golden_quadrilateral",
    "mining",
    "construction",
    "city_distribution",
    "long_haul",
    "spares",
    "aftermarket",
    "oem",
    "dealer",
    "leasing",
    "subscription",
    "service_interval",
    "brakes",
    "clutch",
    "engine",
    "emissions",
    "gst",
    "billing",
    "toll",
    "fastag",
    "opensearch",
    "analytics",
    "clickhouse",
    "redis",
    "puc",
    "insurance_claim",
    "fleet_card",
    "diesel_price",
    "fuel_efficiency",
    "kmpl",
    "routes",
    "backhaul",
    "lead_management",
    "marketplace",
    "listing",
    "cold_chain",
    "reefer",
]


def _slugify(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return text


async def seed_content(ctx: SeedContext) -> None:
    """Seed content hub categories, tags, articles, and SEO metadata."""
    metadata = ctx.metadata
    iam = ctx.iam
    if iam is None:
        raise RuntimeError("IAM data required for content seeding")

    categories_table = metadata.tables["categories"]
    tags_table = metadata.tables["tags"]
    articles_table = metadata.tables["articles"]
    article_tags_table = metadata.tables["article_tags"]
    seo_meta_table = metadata.tables["seo_meta"]

    rng = ctx.rng
    now = utc_now()

    # Categories
    category_rows = []
    for name in CATEGORY_NAMES[: ctx.counts["content_categories"]]:
        slug = _slugify(name)
        category_rows.append(
            {
                "id": deterministic_uuid(f"category-{slug}"),
                "name": name,
                "slug": slug,
                "description": f"{name} resources for commercial vehicles.",
                "created_at": now,
                "updated_at": now,
            }
        )

    tag_rows = []
    for tag in TAG_SEEDS[: ctx.counts["content_tags"]]:
        slug = _slugify(tag)
        tag_rows.append(
            {
                "id": deterministic_uuid(f"tag-{slug}"),
                "name": tag.replace("_", " ").title(),
                "slug": slug,
                "created_at": now,
            }
        )

    articles_rows = []
    article_tag_rows = []
    seo_rows = []

    author_id = iam.admin_user_ids[0] if iam.admin_user_ids else None
    category_cycle = category_rows or []
    tag_cycle = tag_rows or []

    for idx in range(ctx.counts["articles"]):
        category = category_cycle[idx % len(category_cycle)]
        title = f"{category['name']} #{idx+1}"
        slug = _slugify(f"{title}-{idx}")
        article_id = deterministic_uuid(f"article-{slug}")
        published_at = now - timedelta(days=rng.randint(1, 120))
        body = (
            f"{title}\n\nPractical guidance for Indian commercial vehicles across segments. "
            f"Includes tips for {category['name'].lower()} and case studies from fleet operators."
        )
        articles_rows.append(
            {
                "id": article_id,
                "title": title,
                "slug": slug,
                "body": body,
                "status": "published",
                "category_id": category["id"],
                "author_id": author_id,
                "org_id": iam.admin_org_id,
                "published_at": published_at,
                "created_at": published_at,
                "updated_at": published_at,
            }
        )
        # attach 3 tags
        for t_idx in range(3):
            tag = tag_cycle[(idx + t_idx) % len(tag_cycle)]
            article_tag_rows.append(
                {
                    "article_id": article_id,
                    "tag_id": tag["id"],
                }
            )
        seo_rows.append(
            {
                "id": deterministic_uuid(f"seo-{article_id}"),
                "article_id": article_id,
                "meta_title": title,
                "meta_description": body[:150],
                "canonical_url": f"https://autopredator.local/articles/{slug}",
                "og_image_url": "https://autopredator.local/assets/og-default.jpg",
                "keywords": ",".join(
                    [category["slug"]] + [tag_cycle[(idx + t_idx) % len(tag_cycle)]["slug"] for t_idx in range(3)]
                ),
                "created_at": published_at,
            }
        )

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(categories_table)
            .values(category_rows)
            .on_conflict_do_update(
                index_elements=[categories_table.c.slug],
                set_={"description": sa.text("excluded.description"), "updated_at": sa.text("excluded.updated_at")},
            )
        )
        await conn.execute(
            pg_insert(tags_table)
            .values(tag_rows)
            .on_conflict_do_update(
                index_elements=[tags_table.c.slug],
                set_={"name": sa.text("excluded.name")},
            )
        )
        await conn.execute(
            pg_insert(articles_table)
            .values(articles_rows)
            .on_conflict_do_update(
                index_elements=[articles_table.c.slug],
                set_={
                    "title": sa.text("excluded.title"),
                    "body": sa.text("excluded.body"),
                    "status": sa.text("excluded.status"),
                },
            )
        )
        await conn.execute(
            pg_insert(article_tags_table)
            .values(article_tag_rows)
            .on_conflict_do_nothing(index_elements=[article_tags_table.c.article_id, article_tags_table.c.tag_id])
        )
        await conn.execute(
            pg_insert(seo_meta_table)
            .values(seo_rows)
            .on_conflict_do_update(
                index_elements=[seo_meta_table.c.article_id],
                set_={"meta_title": sa.text("excluded.meta_title"), "meta_description": sa.text("excluded.meta_description")},
            )
        )

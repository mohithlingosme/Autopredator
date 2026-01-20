from __future__ import annotations

import math
from typing import Dict

from .types import SeedCounts


BASE_COUNTS: Dict[str, int] = {
    "manufacturers": 15,
    "model_families": 60,
    "models": 120,
    "variants": 300,
    "price_history_variants": 150,
    "price_history_cities": 20,
    "price_history_months": 18,
    "listings_used": 5000,
    "listings_new": 500,
    "listing_media_min": 2,
    "listing_media_max": 10,
    "leads": 12000,
    "fleet_vehicles": 2000,
    "drivers": 1200,
    "driver_assignments": 2000,
    "trips": 25000,
    "fuel_logs": 20000,
    "maintenance_jobs": 4000,
    "compliance_docs_per_vehicle": 3,
    "finance_applications": 4000,
    "kyc_docs_min": 2,
    "kyc_docs_max": 6,
    "bank_offers_min": 1,
    "bank_offers_max": 3,
    "content_categories": 20,
    "content_tags": 80,
    "articles": 300,
}

MODE_MULTIPLIER = {
    "small": 1.0,
    "medium": 1.5,
    "large": 3.0,
}


def build_counts(mode: str) -> SeedCounts:
    """Scale base counts according to mode, keeping a floor at the base."""
    multiplier = MODE_MULTIPLIER.get(mode, 1.0)
    scaled: Dict[str, int] = {}
    for key, base in BASE_COUNTS.items():
        scaled[key] = max(base, math.ceil(base * multiplier))
    return SeedCounts(values=scaled)

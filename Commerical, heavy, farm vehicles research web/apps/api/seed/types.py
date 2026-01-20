from __future__ import annotations

import random
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from sqlalchemy.engine import make_url
from sqlalchemy.ext.asyncio import AsyncEngine
from sqlalchemy import MetaData


UUID_NAMESPACE = uuid.uuid5(uuid.NAMESPACE_DNS, "autopredator-seed")


def deterministic_uuid(name: str) -> uuid.UUID:
    """Create deterministic UUIDs to keep seed idempotent."""
    return uuid.uuid5(UUID_NAMESPACE, name)


def utc_now() -> datetime:
    """Timezone-aware now helper."""
    return datetime.now(timezone.utc)


@dataclass
class SeedCounts:
    """Counts per entity calculated for the current mode."""

    values: Dict[str, int]

    def __getitem__(self, item: str) -> int:
        return self.values[item]

    def get(self, item: str, default: int = 0) -> int:
        return self.values.get(item, default)


@dataclass
class LookupData:
    states_by_code: Dict[str, int]
    cities_by_code: Dict[str, int]
    body_types_by_code: Dict[str, int]
    fuel_types_by_code: Dict[str, int]
    transmissions_by_code: Dict[str, int]
    route_corridors: List[str]
    axle_configs: List[str]


@dataclass
class OrgInfo:
    id: uuid.UUID
    name: str
    org_type: str


@dataclass
class UserInfo:
    id: uuid.UUID
    email: str
    org_id: Optional[uuid.UUID]
    full_name: str
    role: str


@dataclass
class IAMData:
    orgs: List[OrgInfo]
    users: List[UserInfo]
    admin_org_id: uuid.UUID
    fleet_org_ids: List[uuid.UUID]
    dealer_org_ids: List[uuid.UUID]
    admin_user_ids: List[uuid.UUID]


@dataclass
class VariantInfo:
    id: uuid.UUID
    model_id: uuid.UUID
    family_id: uuid.UUID
    manufacturer_id: uuid.UUID
    name: str
    body_type_id: Optional[int]
    fuel_type_id: Optional[int]
    transmission_id: Optional[int]
    segment: str
    msrp: float
    application: str
    axle_config: str
    body_type_code: Optional[str] = None


@dataclass
class CatalogData:
    manufacturers: List[uuid.UUID]
    model_families: List[uuid.UUID]
    models: List[uuid.UUID]
    variants: List[VariantInfo]
    price_history_variants: List[uuid.UUID]


@dataclass
class SeedContext:
    engine: AsyncEngine
    metadata: MetaData
    rng: random.Random
    mode: str
    counts: SeedCounts
    db_url: str = ""
    lookups: Optional[LookupData] = None
    iam: Optional[IAMData] = None
    catalog: Optional[CatalogData] = None

    def describe_db(self) -> str:
        url = make_url(self.db_url)
        obfuscated = url._replace(password="***")
        return str(obfuscated)

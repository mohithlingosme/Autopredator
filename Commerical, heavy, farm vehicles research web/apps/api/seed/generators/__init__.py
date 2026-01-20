"""
Seed generators per domain.

Each generator accepts a SeedContext and returns any artefacts needed by downstream steps.
"""

from .lookups import seed_lookups
from .iam import seed_iam
from .catalog import seed_catalog
from .marketplace import seed_marketplace
from .fleet import seed_fleet
from .finance import seed_finance
from .content import seed_content
from .report import run_validations_and_report

__all__ = [
    "seed_lookups",
    "seed_iam",
    "seed_catalog",
    "seed_marketplace",
    "seed_fleet",
    "seed_finance",
    "seed_content",
    "run_validations_and_report",
]

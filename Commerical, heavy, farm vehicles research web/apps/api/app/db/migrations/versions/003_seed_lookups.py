"""
Seed lookup/reference data for AutoPredator.
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "003_seed_lookups"
down_revision = "002_all_domains"
branch_labels = None
depends_on = None


def upgrade() -> None:
    states_table = sa.table(
        "states",
        sa.column("code", sa.String()),
        sa.column("name", sa.String()),
    )
    op.bulk_insert(
        states_table,
        [
            {"code": "MH", "name": "Maharashtra"},
            {"code": "KA", "name": "Karnataka"},
            {"code": "DL", "name": "Delhi"},
            {"code": "TN", "name": "Tamil Nadu"},
            {"code": "TS", "name": "Telangana"},
            {"code": "GJ", "name": "Gujarat"},
            {"code": "RJ", "name": "Rajasthan"},
            {"code": "UP", "name": "Uttar Pradesh"},
            {"code": "WB", "name": "West Bengal"},
        ],
    )

    fuel_types_table = sa.table("fuel_types", sa.column("code", sa.String()), sa.column("label", sa.String()))
    op.bulk_insert(
        fuel_types_table,
        [
            {"code": "petrol", "label": "Petrol"},
            {"code": "diesel", "label": "Diesel"},
            {"code": "cng", "label": "CNG"},
            {"code": "lpg", "label": "LPG"},
            {"code": "electric", "label": "Electric"},
            {"code": "hybrid", "label": "Hybrid"},
        ],
    )

    transmissions_table = sa.table(
        "transmissions",
        sa.column("code", sa.String()),
        sa.column("label", sa.String()),
    )
    op.bulk_insert(
        transmissions_table,
        [
            {"code": "manual", "label": "Manual"},
            {"code": "amt", "label": "AMT"},
            {"code": "at", "label": "Automatic"},
            {"code": "cvt", "label": "CVT"},
            {"code": "dct", "label": "DCT"},
        ],
    )

    body_types_table = sa.table("body_types", sa.column("code", sa.String()), sa.column("label", sa.String()))
    op.bulk_insert(
        body_types_table,
        [
            {"code": "truck", "label": "Truck"},
            {"code": "tipper", "label": "Tipper"},
            {"code": "tractor", "label": "Tractor"},
            {"code": "bus", "label": "Bus"},
            {"code": "van", "label": "Van"},
            {"code": "pickup", "label": "Pickup"},
            {"code": "mpv", "label": "MPV"},
            {"code": "suv", "label": "SUV"},
        ],
    )

    roles_table = sa.table(
        "roles",
        sa.column("name", sa.String()),
        sa.column("scope", sa.String()),
        sa.column("description", sa.String()),
    )
    op.bulk_insert(
        roles_table,
        [
            {"name": "platform_admin", "scope": "global", "description": "Platform superuser"},
            {"name": "dealer_admin", "scope": "org", "description": "Dealer org admin"},
            {"name": "fleet_manager", "scope": "org", "description": "Fleet management lead"},
            {"name": "sales_agent", "scope": "org", "description": "Sales and lead follow-ups"},
            {"name": "driver", "scope": "org", "description": "Driver app user"},
            {"name": "content_editor", "scope": "org", "description": "Content / SEO management"},
        ],
    )

    city_rows = [
        ("Mumbai", "MUM", "MH"),
        ("Pune", "PNQ", "MH"),
        ("Bengaluru", "BLR", "KA"),
        ("Chennai", "MAA", "TN"),
        ("Delhi", "DEL", "DL"),
        ("Ahmedabad", "AMD", "GJ"),
        ("Jaipur", "JAI", "RJ"),
        ("Lucknow", "LKO", "UP"),
        ("Kolkata", "CCU", "WB"),
        ("Hyderabad", "HYD", "TS"),
    ]
    for name, code, state_code in city_rows:
        op.execute(
            sa.text(
                """
                INSERT INTO cities (name, code, state_id)
                VALUES (:name, :code, (SELECT id FROM states WHERE code = :state_code))
                ON CONFLICT DO NOTHING
                """
            ),
            parameters={"name": name, "code": code, "state_code": state_code},
        )


def downgrade() -> None:
    op.execute("DELETE FROM cities WHERE code IN ('MUM','PNQ','BLR','MAA','DEL','AMD','JAI','LKO','CCU','HYD')")
    op.execute("DELETE FROM roles WHERE name IN ('platform_admin','dealer_admin','fleet_manager','sales_agent','driver','content_editor')")
    op.execute("DELETE FROM body_types WHERE code IN ('truck','tipper','tractor','bus','van','pickup','mpv','suv')")
    op.execute("DELETE FROM transmissions WHERE code IN ('manual','amt','at','cvt','dct')")
    op.execute("DELETE FROM fuel_types WHERE code IN ('petrol','diesel','cng','lpg','electric','hybrid')")
    op.execute("DELETE FROM states WHERE code IN ('MH','KA','DL','TN','TS','GJ','RJ','UP','WB')")

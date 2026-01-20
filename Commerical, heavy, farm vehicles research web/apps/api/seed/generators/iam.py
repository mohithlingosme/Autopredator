from __future__ import annotations

import uuid

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import insert as pg_insert

from app.core.security import get_password_hash

from ..types import IAMData, OrgInfo, SeedContext, UserInfo, deterministic_uuid, utc_now


ADMIN_ORG_NAME = "AutoPredator Platform Admin"
DEFAULT_PASSWORD = "password123"


async def _ensure_roles(ctx: SeedContext, role_names: list[str]) -> dict[str, object]:
    roles_table = ctx.metadata.tables["roles"]
    payload = [{"name": name, "scope": "org", "description": f"{name} role"} for name in role_names]
    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(roles_table)
            .values(payload)
            .on_conflict_do_update(
                index_elements=[roles_table.c.name],
                set_={"description": sa.text("excluded.description"), "scope": sa.text("excluded.scope")},
            )
        )
        rows = (await conn.execute(sa.select(roles_table.c.name, roles_table.c.id))).all()
    return {row.name: row.id for row in rows if row.name in role_names}


async def seed_iam(ctx: SeedContext) -> IAMData:
    """Seed organizations, users, and memberships."""
    metadata = ctx.metadata
    orgs_table = metadata.tables["organizations"]
    users_table = metadata.tables["users"]
    org_members_table = metadata.tables["org_members"]
    user_roles_table = metadata.tables["user_roles"]

    # Ensure baseline roles exist
    role_map = await _ensure_roles(
        ctx,
        ["platform_admin", "dealer_admin", "fleet_manager", "sales_agent", "driver", "content_editor"],
    )

    fleet_org_target = 20
    dealer_org_target = 30
    admin_org_id = deterministic_uuid("org-admin")
    org_rows = [
        {
            "id": admin_org_id,
            "name": ADMIN_ORG_NAME,
            "org_type": "admin",
            "status": "active",
            "metadata": {"tier": "platform"},
        }
    ]

    fleet_org_ids: list[uuid.UUID] = []
    dealer_org_ids: list[uuid.UUID] = []

    for idx in range(fleet_org_target):
        name = f"Fleet Org {idx+1:02d}"
        oid = deterministic_uuid(f"org-fleet-{idx}")
        fleet_org_ids.append(oid)
        org_rows.append(
            {
                "id": oid,
                "name": name,
                "org_type": "fleet",
                "status": "active",
                "metadata": {"segment": "fleet", "tier": "standard"},
            }
        )

    for idx in range(dealer_org_target):
        name = f"Dealer Org {idx+1:02d}"
        oid = deterministic_uuid(f"org-dealer-{idx}")
        dealer_org_ids.append(oid)
        org_rows.append(
            {
                "id": oid,
                "name": name,
                "org_type": "dealer",
                "status": "active",
                "metadata": {"channel": "retail", "tier": "gold" if idx < 5 else "standard"},
            }
        )

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(orgs_table)
            .values(org_rows)
            .on_conflict_do_update(
                index_elements=[orgs_table.c.name],
                set_={"status": sa.text("excluded.status"), "metadata": sa.text("excluded.metadata")},
            )
        )

    # Users + memberships
    password_hash = get_password_hash(DEFAULT_PASSWORD)
    now = utc_now()
    user_rows = []
    member_rows = []
    user_role_rows = []
    users: list[UserInfo] = []

    admin_users = [
        ("platform.admin1@autopredator.local", "Platform Admin", "platform_admin"),
        ("platform.admin2@autopredator.local", "Ops Admin", "platform_admin"),
    ]

    for email, full_name, role in admin_users:
        uid = deterministic_uuid(email)
        user_rows.append(
            {
                "id": uid,
                "email": email,
                "full_name": full_name,
                "phone": f"+9100000{len(user_rows):04d}",
                "password_hash": password_hash,
                "status": "active",
                "email_verified": True,
                "created_at": now,
                "updated_at": now,
            }
        )
        member_rows.append(
            {
                "org_id": admin_org_id,
                "user_id": uid,
                "role": role,
                "status": "active",
                "invited_at": now,
                "joined_at": now,
                "created_at": now,
                "updated_at": now,
            }
        )
        role_id = role_map.get(role)
        if role_id:
            user_role_rows.append(
                {
                    "user_id": uid,
                    "role_id": role_id,
                    "org_id": admin_org_id,
                    "assigned_at": now,
                }
            )
        users.append(UserInfo(id=uid, email=email, org_id=admin_org_id, full_name=full_name, role=role))

    def add_org_users(org_id: str, prefix: str, count: int, role: str) -> list[str]:
        created_ids: list[str] = []
        for i in range(count):
            email = f"{prefix}.{i+1:02d}@autopredator.local"
            uid = deterministic_uuid(email)
            full_name = f"{prefix.title()} User {i+1:02d}"
            created_ids.append(str(uid))
            user_rows.append(
                {
                    "id": uid,
                    "email": email,
                    "full_name": full_name,
                    "phone": f"+91{ctx.rng.randint(7000000000, 9999999999)}",
                    "password_hash": password_hash,
                    "status": "active",
                    "email_verified": True,
                    "created_at": now,
                    "updated_at": now,
                }
            )
            member_rows.append(
                {
                    "org_id": org_id,
                    "user_id": uid,
                    "role": role,
                    "status": "active",
                    "invited_at": now,
                    "joined_at": now,
                    "created_at": now,
                    "updated_at": now,
                }
            )
            role_id = role_map.get(role)
            if role_id:
                user_role_rows.append(
                    {
                        "user_id": uid,
                        "role_id": role_id,
                        "org_id": org_id,
                        "assigned_at": now,
                    }
                )
            users.append(UserInfo(id=uid, email=email, org_id=org_id, full_name=full_name, role=role))
        return created_ids

    fleet_users: list[str] = []
    dealer_users: list[str] = []

    for idx, org_id in enumerate(fleet_org_ids):
        fleet_users.extend(add_org_users(org_id, f"fleet{idx+1:02d}.manager", 3, "fleet_manager"))

    for idx, org_id in enumerate(dealer_org_ids):
        dealer_users.extend(add_org_users(org_id, f"dealer{idx+1:02d}.agent", 2, "sales_agent"))

    async with ctx.engine.begin() as conn:
        await conn.execute(
            pg_insert(users_table)
            .values(user_rows)
            .on_conflict_do_update(
                index_elements=[users_table.c.email],
                set_={
                    "full_name": sa.text("excluded.full_name"),
                    "phone": sa.text("excluded.phone"),
                    "password_hash": sa.text("excluded.password_hash"),
                    "status": sa.text("excluded.status"),
                },
            )
        )
        await conn.execute(
            pg_insert(org_members_table)
            .values(member_rows)
            .on_conflict_do_update(
                index_elements=[org_members_table.c.org_id, org_members_table.c.user_id],
                set_={"role": sa.text("excluded.role"), "status": sa.text("excluded.status")},
            )
        )
        if user_role_rows:
            await conn.execute(
                pg_insert(user_roles_table)
                .values(user_role_rows)
                .on_conflict_do_update(
                    index_elements=[
                        user_roles_table.c.user_id,
                        user_roles_table.c.role_id,
                        user_roles_table.c.org_id,
                    ],
                    set_={"assigned_at": sa.text("excluded.assigned_at")},
                )
            )

    org_infos = [OrgInfo(id=row["id"], name=row["name"], org_type=row["org_type"]) for row in org_rows]
    iam_data = IAMData(
        orgs=org_infos,
        users=users,
        admin_org_id=admin_org_id,
        fleet_org_ids=[org_id for org_id in fleet_org_ids],
        dealer_org_ids=[org_id for org_id in dealer_org_ids],
        admin_user_ids=[user.id for user in users if user.role == "platform_admin"],
    )
    ctx.iam = iam_data
    return iam_data

"""
Initial migration for FleetCommand.

Create tables: orgs, users, user_org_memberships, audit_logs
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = "001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Upgrade database schema."""

    # Create orgs table
    op.create_table(
        "orgs",
        sa.Column("id", postgresql.UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("status", sa.String(length=50), server_default="active", nullable=False),
        sa.Column("settings", postgresql.JSONB(), server_default="{}", nullable=False),
        sa.Column("created_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("idx_orgs_status", "orgs", ["status"], unique=False)
    op.create_index("idx_orgs_created_at", "orgs", ["created_at"], unique=False)

    # Create users table
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("first_name", sa.String(length=100), nullable=True),
        sa.Column("last_name", sa.String(length=100), nullable=True),
        sa.Column("status", sa.String(length=50), server_default="active", nullable=False),
        sa.Column("email_verified", sa.Boolean(), server_default="false", nullable=False),
        sa.Column("last_login_at", postgresql.TIMESTAMP(timezone=True), nullable=True),
        sa.Column("created_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )
    op.create_index("idx_users_email", "users", ["email"], unique=True)
    op.create_index("idx_users_status", "users", ["status"], unique=False)
    op.create_index("idx_users_created_at", "users", ["created_at"], unique=False)

    # Create user_org_memberships table
    op.create_table(
        "user_org_memberships",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("org_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("role", sa.String(length=50), nullable=False),
        sa.Column("status", sa.String(length=50), server_default="active", nullable=False),
        sa.Column("invited_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("invited_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("joined_at", postgresql.TIMESTAMP(timezone=True), nullable=True),
        sa.Column("created_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["invited_by"], ["users.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["org_id"], ["orgs.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "org_id"),
    )
    op.create_index("idx_user_org_memberships_org_id", "user_org_memberships", ["org_id"], unique=False)
    op.create_index("idx_user_org_memberships_user_id", "user_org_memberships", ["user_id"], unique=False)
    op.create_index("idx_user_org_memberships_role", "user_org_memberships", ["role"], unique=False)

    # Create audit_logs table
    op.create_table(
        "audit_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), nullable=False),
        sa.Column("org_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("action", sa.String(length=100), nullable=False),
        sa.Column("entity_type", sa.String(length=100), nullable=False),
        sa.Column("entity_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("old_values", postgresql.JSONB(), nullable=True),
        sa.Column("new_values", postgresql.JSONB(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(), server_default="{}", nullable=False),
        sa.Column("ip_address", postgresql.INET(), nullable=True),
        sa.Column("user_agent", sa.String(), nullable=True),
        sa.Column("created_at", postgresql.TIMESTAMP(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["actor_user_id"], ["users.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["org_id"], ["orgs.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("idx_audit_logs_org_id", "audit_logs", ["org_id"], unique=False)
    op.create_index("idx_audit_logs_actor_user_id", "audit_logs", ["actor_user_id"], unique=False)
    op.create_index("idx_audit_logs_entity_type", "audit_logs", ["entity_type"], unique=False)
    op.create_index("idx_audit_logs_entity_id", "audit_logs", ["entity_id"], unique=False)
    op.create_index("idx_audit_logs_created_at", "audit_logs", ["created_at"], unique=False)
    op.create_index("idx_audit_logs_action", "audit_logs", ["action"], unique=False)
    op.create_index("idx_audit_logs_entity_type_id", "audit_logs", ["entity_type", "entity_id"], unique=False)


def downgrade() -> None:
    """Downgrade database schema."""

    # Drop audit_logs table
    op.drop_index("idx_audit_logs_entity_type_id", table_name="audit_logs")
    op.drop_index("idx_audit_logs_action", table_name="audit_logs")
    op.drop_index("idx_audit_logs_created_at", table_name="audit_logs")
    op.drop_index("idx_audit_logs_entity_id", table_name="audit_logs")
    op.drop_index("idx_audit_logs_entity_type", table_name="audit_logs")
    op.drop_index("idx_audit_logs_actor_user_id", table_name="audit_logs")
    op.drop_index("idx_audit_logs_org_id", table_name="audit_logs")
    op.drop_table("audit_logs")

    # Drop user_org_memberships table
    op.drop_index("idx_user_org_memberships_role", table_name="user_org_memberships")
    op.drop_index("idx_user_org_memberships_user_id", table_name="user_org_memberships")
    op.drop_index("idx_user_org_memberships_org_id", table_name="user_org_memberships")
    op.drop_table("user_org_memberships")

    # Drop users table
    op.drop_index("idx_users_created_at", table_name="users")
    op.drop_index("idx_users_status", table_name="users")
    op.drop_index("idx_users_email", table_name="users")
    op.drop_table("users")

    # Drop orgs table
    op.drop_index("idx_orgs_created_at", table_name="orgs")
    op.drop_index("idx_orgs_status", table_name="orgs")
    op.drop_table("orgs")
